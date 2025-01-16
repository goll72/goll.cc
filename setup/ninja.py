import re

from os import PathLike
from io import TextIOWrapper
from typing import Match

from collections.abc import Iterable, Mapping


P = str | PathLike


def escape_path(word: str) -> str:
    return word.replace("$ ", "$$ ").replace(" ", "$ ").replace(":", "$:")


class Writer(object):
    def __init__(self, output: TextIOWrapper, width: int = 78):
        self.output = output
        self.width = width

    def line(self, text: str = ""):
        self.output.write(text)
        self.output.write("\n")

    def variable(
        self,
        key: str,
        value: bool | int | float | P | Iterable[P] | None,
        indent: int = 0,
    ):
        if value is None:
            return
            
        if isinstance(value, Iterable) and not isinstance(value, str):
            # Filter out empty strings
            value = " ".join(str(x) for x in value if x)

        self.line(f"{'  ' * indent}{key} = {value}")

    def pool(self, name: str, depth: int):
        self.line(f"pool {name}")
        self.variable("depth", depth, indent=1)

    def rule(
        self,
        name: str,
        command: str,
        description: str | None = None,
        depfile: P | None = None,
        generator: bool = False,
        pool: str | None = None,
        restat: bool = False,
        rspfile: P | None = None,
        rspfile_content: str | None = None,
        deps: P | Iterable[P] | None = None,
    ):
        self.line(f"rule {name}")
        self.variable("command", command, indent=1)
        
        if description:
            self.variable("description", description, indent=1)
        if depfile:
            self.variable("depfile", depfile, indent=1)
        if generator:
            self.variable("generator", "1", indent=1)
        if pool:
            self.variable("pool", pool, indent=1)
        if restat:
            self.variable('restat', "1", indent=1)
        if rspfile:
            self.variable("rspfile", rspfile, indent=1)
        if rspfile_content:
            self.variable("rspfile_content", rspfile_content, indent=1)
        if deps:
            self.variable("deps", deps, indent=1)

        self.line()

    def build(
        self,
        outputs: P | Iterable[P],
        rule: str,
        inputs: P | Iterable[P] | None = None,
        implicit: P | Iterable[P] | None = None,
        order_only: P | Iterable[P] | None = None,
        variables: Iterable[tuple[str, P | Iterable[P] | None]]
                | Mapping[str, P | Iterable[P] | None] | None = None,
        implicit_outputs: P | Iterable[P] | None = None,
        pool: str | None = None,
        dyndep: str | None = None,
    ):
        outputs = as_iter(outputs)
        out_outputs: list[str] = [escape_path(str(x)) for x in outputs]
        all_inputs: list[str] = [escape_path(str(x)) for x in as_iter(inputs)]

        if implicit:
            implicit = (escape_path(str(x)) for x in as_iter(implicit))
            all_inputs.append("|")
            all_inputs.extend(implicit)
        if order_only:
            order_only = (escape_path(str(x)) for x in as_iter(order_only))
            all_inputs.append("||")
            all_inputs.extend(order_only)
        if implicit_outputs:
            implicit_outputs = (escape_path(str(x)) for x in as_iter(implicit_outputs))
            out_outputs.append("|")
            out_outputs.extend(implicit_outputs)

        self.line(f"build {' '.join(out_outputs)}: {rule} {' '.join(all_inputs)}")
        
        self.variable("pool", pool, indent=1)
        self.variable("dyndep", dyndep, indent=1)

        if variables:
            if isinstance(variables, Mapping):
                iterator = iter(variables.items())
            else:
                iterator = iter(variables)

            for key, val in iterator:
                self.variable(key, val, indent=1)

    def include(self, path: str):
        self.line(f"include {path}")

    def subninja(self, path: str):
        self.line(f"subninja {path}")

    def default(self, paths: P | Iterable[P]):
        self.line(f"default {' '.join(str(x) for x in as_iter(paths))}")

    def close(self):
        self.output.close()


def as_iter[T](input: T | str | Iterable[T | str]) -> Iterable[T | str]:
    if input is None:
        return []
    if isinstance(input, Iterable) and not isinstance(input, str):
        return input
    return [input]


def escape(string: str) -> str:
    """
    Escape a string such that it can be embedded into a Ninja file without
    further interpretation.
    """
    if "\n" in string:
        raise ValueError("Ninja syntax does not allow newlines")

    # We only have one special metacharacter: "$"
    return string.replace("$", "$$")


def expand(string: str, vars: dict[str, str], local_vars: dict[str, str] = {}) -> str:
    """
    Expand a string containing $vars as Ninja would.

    Note: doesn't handle the full Ninja variable syntax, but it's enough
    to make configure.py's use of it work.
    """
    def exp(m: Match[str]) -> str:
        var = m.group(1)
        if var == "$":
            return "$"
        return local_vars.get(var, vars.get(var, ""))

    return re.sub(r"\$(\$|\w*)", exp, string)
