import os
import sys
import shutil
import itertools
import subprocess

from os import PathLike
from pathlib import Path

import argparse

from .ninja import Writer as NinjaWriter


LUA_VERSION = "5.4"

# `node_modules` may not be created if there are no packages to install and it may not
# be up to date if no new files/directories are created within it as immediate children.
#
# `lua_modules` suffers from the same issue but there doesn't seem to be an alternative for luarocks.
NPM_DEP = "package-lock.json"

LUA_MODULES = "lua_modules"
LUA_DEP = LUA_MODULES

DISTDIR = Path("dist")
TEMPDIR = Path("temp")


# NOTE: we use absolute paths, even though we only write relative paths to
# `build.ninja`, as we may be called from any directory, while `ninja`
# should should only ever be called from the build directory.


def find_binary_path(*names: str):
    """
    Returns the first binary in `names` that is found
    in the binary search path.
    """
    description = names[-1]

    print(f"Searching for {description}...")
    paths = (path for name in names if (path := shutil.which(name)) is not None)

    path = next(paths, None)

    if path is None:
        raise FileNotFoundError(f"No binary found providing {description}")

    return path

def with_env(env: dict[str, str], cmd: str) -> str:
    """
    Returns a command-line string to run a given command while
    setting environment variables. Assumes `sh -c '...'` is used.
    """
    return f"{
        " ".join(
            f"{key}={
                {"!","*","?","'","[","]"}.intersection(set(val))
                    and f"'{val.replace("'", r"'\''")}'"
                    or val
            }" for key, val in env.items()
        )
    } {cmd}"


parser = argparse.ArgumentParser()
parser.add_argument("builddir")
args = parser.parse_args()

npm = find_binary_path("npm")
luarocks = find_binary_path(f"luarocks-{LUA_VERSION}", "luarocks")
pandoc = find_binary_path("pandoc")
jq = find_binary_path("jq")
cc = find_binary_path("clang", "gcc", "cc")

builddir = Path(args.builddir).resolve()
rootdir = Path(__file__).parent.parent
sitedir = rootdir / "site"

builddir.mkdir(exist_ok=True)

# Make git ignore the build directory
with open(builddir / ".gitignore", "w") as f:
    f.write("*\n")

def build(x):
    return x.relative_to(builddir, walk_up=True)


print("Setting up Lua/npm package files...")

# Maps package file name in build directory to the
# name of the corresponding file in the source code
pkgfiles = {
    builddir / "goll.cc-0.1-1.rockspec": rootdir / "pkg" / "rockspec.lua",
    builddir / "package.json": rootdir / "pkg" / "package.json"
}

for link, target in pkgfiles.items():
    try:
        link.symlink_to(target)
        link.touch()
    except FileExistsError:
        pass

luarocks_args: list[str | PathLike] = ["--tree", builddir / LUA_MODULES, "--lua-version", LUA_VERSION]

with subprocess.Popen([luarocks, *luarocks_args, "path", "--lr-path"], stdout=subprocess.PIPE, text=True) as lr_path_proc:
    lua_path = lr_path_proc.stdout.read().strip()
    lua_path = ";".join([lua_path, str(rootdir / "?.lua"), str(rootdir / "?" / "init.lua")])
    
with subprocess.Popen([luarocks, *luarocks_args, "path", "--lr-cpath"], stdout=subprocess.PIPE, text=True) as lr_cpath_proc:
    lua_cpath = lr_cpath_proc.stdout.read().strip()

pandoc_env = { "LUA_PATH": lua_path, "LUA_CPATH": lua_cpath, "SITEDIR": str(build(sitedir)), "TMPDIR": os.getenv("TMPDIR") }
python_env = { "PYTHONPATH": str(rootdir) }
node_env = { "NODE_PATH": "node_modules" }


print("Checking filter dependencies...")

filter = rootdir / "filters" / "init.lua"
filter_files = [build(filter), build(filter.parent)]

# Get all (local) dependencies of the Lua filters
with subprocess.Popen([pandoc, "lua", rootdir / "setup" / "find-deps.lua", "filters"], stdout=subprocess.PIPE, env=pandoc_env, text=True) as filter_deps_proc:
    filter_deps = [ build(Path(dep)) for dep in filter_deps_proc.stdout.read().strip().split("\n") ]


def output_for(path):
    output = DISTDIR / path.relative_to(sitedir)
    
    match path.suffix:
        case ".md":
            if path.stem == "index":
                output = output.with_suffix(".html")
            else:
                output = output.with_suffix("") / "index.html"
        case ".ts":
            output = output.with_suffix(".js")

    return output


print(f"Writing Ninja build file to {builddir / "build.ninja"}...")

with open(builddir / "build.ninja", "w") as f:
    ninja = NinjaWriter(f)

    ninja.line("ninja_required_version = 1.10")

    ninja.line()

    template = rootdir / "templates" / "page.html"
    ninja.build("filter_deps", "phony", filter_deps)

    ninja.line()
    
    ninja.rule("copy", "cp $in $out", description="...")

    ninja.rule(
        "pandoc_md",
        with_env(
            pandoc_env,
            f"{pandoc} -s -f markdown -t html --template={build(template)} -M url=$url -L {build(filter)} --wrap=preserve --embed-resources --resource-path={build(sitedir)} --mathml $in -o $out"
        ),
        depfile="$out.d",
        deps="gcc",
        description="Transpiling Markdown file $in"
    )

    # jq filter to output a Make-style depfile from the JSON metafile generated by esbuild
    JQ_FILTER_ESBUILD_DEPFILE = r"""'"\($$out): \([ .inputs | keys[] | select(. != $$in and (startswith("node_modules") | not)) ] | join(" "))"'"""

    # ...here, the depfile is used to track the asset's own dependencies from the information in esbuild's metafile
    ninja.rule(
        "esbuild",
        with_env(
            node_env,
            f"./node_modules/.bin/esbuild --bundle --format=esm --loader:.woff=file --loader:.woff2=file --asset-names='assets/[name]' --metafile=/dev/stdout --outbase={DISTDIR} $in --outfile=$out | {jq} -r --arg in $in --arg out $out {JQ_FILTER_ESBUILD_DEPFILE} > $depfile"
        ),
        depfile="$out.d",
        deps="gcc",
        description="Bundling $in"
    )
    
    ninja.rule(
        "regenerate_build",
        with_env(
            python_env,
            f"{sys.executable} -m setup.build ."
        ),
        generator=True,
        pool="console",
        restat=True,
        description="Regenerating build files"
    )

    ninja.rule(
        "cc",
        f"{cc} $cflags $in $libs -o $out",
        description="Compiling C file $in"
    )

    input_dirs = []
    md_files: list[Path] = []

    md_deps = ["filter_deps", LUA_DEP, build(template), "pikchr"]
    assets = []

    # Files are built depth-first (all files in a given directory will be built before `index.md`,
    # which will be built before all files in the parent directory; this allows filters such as
    # `meta.lua` and `page-list.lua` to work properly [in the way they are currently used])
    for root, dirs, files in sitedir.walk(top_down=False, follow_symlinks=True):        
        input_dirs.append(build(root))
        
        index_found = False
        
        for file in itertools.chain(files, ["index.md"]):
            if file == "index.md" and not index_found:
                index_found = True
                continue
                
            path = root / file

            output = output_for(path)
            input = build(path)

            valid = True
            
            match path.suffix:
                case ".md":
                    url = str("/" / output.parent.relative_to(DISTDIR))

                    intermediate = TEMPDIR / output / "out"
                    dyndep = TEMPDIR / output / "dep"

                    # We have to use an intermediate output file to support
                    # dynamic dependencies generated by the `deps.lua` filter
                    ninja.build(
                        output,
                        "copy",
                        intermediate,
                        order_only=dyndep,
                        dyndep=dyndep
                    )

                    # Meanwhile, the dyndep is used for assets bundled with `esbuild` and such:
                    # We add build directives to bundle every asset found, but only reference
                    # them in the dyndep file, as a dependency of a given Markdown file
                    # (they won't be built unless actually needed)
                    ninja.build(
                        intermediate,
                        "pandoc_md",
                        input,
                        implicit=itertools.chain(
                            md_deps,
                            (file for file in md_files if output.parent in file.parents)
                        ),
                        implicit_outputs=dyndep,
                        variables={ "url": url }
                    )

                    md_files.append(output)
                case ".css" | ".ts" | ".js":
                    ninja.build(output, "esbuild", input, implicit=NPM_DEP)
                case ".svg" | ".png":
                    ninja.build(output, "copy", input)
                    assets.append(output)
                case _:
                    valid = False

            if valid:
                ninja.line()

    regen_pkg_out = [ build(pkgfile) for pkgfile in pkgfiles.keys() ]
    own_files = [build(rootdir / "setup"), build(rootdir / "setup" / "build.py"), build(rootdir / "setup" / "ninja.py")]

    ninja.build(["build.ninja", ".gitignore"] + regen_pkg_out, "regenerate_build", input_dirs + own_files + filter_files)

    ninja.line()

    ninja.rule(
        "npm_install",
        f"{npm} install",
        description="Installing npm packages"
    )

    ninja.rule(
        "luarocks_install",
        f"{luarocks} --tree $out --lua-version {LUA_VERSION} install --only-deps --deps-mode one $in",
        description="Installing Lua packages"
    )

    ninja.build(NPM_DEP, "npm_install", "package.json")
    ninja.build(LUA_DEP, "luarocks_install", "goll.cc-0.1-1.rockspec")

    ninja.line()

    # Pikchr is used to generate diagrams
    ninja.build(
        "pikchr", 
        "cc", 
        build(rootdir / "deps" / "pikchr.c"), 
        variables={ "cflags": "-DPIKCHR_SHELL", "libs": "-lm"  }
    )

    ninja.line()

    ninja.default(md_files + assets + [DISTDIR / "assets" / "favicon.png", DISTDIR / "styles.css"])
