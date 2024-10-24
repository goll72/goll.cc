// Uses remark and rehype alongside vite to build
// and/or serve a development version of the website.

import path from "node:path";
import { readdirSync, readFileSync } from "node:fs";
import { writeFile, mkdir, symlink, readdir, stat, cp } from "node:fs/promises";

import { unified } from "unified";
import { VFile } from "vfile";
import { matter } from "vfile-matter";

import { build, createServer } from "vite";

import rehypeParse from "rehype-parse";
import rehypeStringify from "rehype-stringify";
import rehypeMeta from "rehype-meta";
import rehypeMinifyWhitespace from "rehype-minify-whitespace";

import njk from "nunjucks";

import Watcher from "watcher";

import config from "./config.ts";
import { markdownProcessor } from "./process.ts";

const projectRoot = path.join(import.meta.dirname, "..");

// Extracts URL from a pathname
const urlRegex = (path: string) =>
    new RegExp(`${projectRoot}/${path}(/?.*/)index.md`);

const handleFrontMatter = (url: string, path: string) => {
    const file = new VFile({
        path,
        value: readFileSync(path)
    });

    // Adds frontmatter to file.data.matter and strips it from file
    matter(file, { strip: true });

    file.data.matter.url = url;

    if (file.data.matter.published !== undefined) {
        file.data.matter.published = new Date(file.data.matter.published);
    }

    return file;
}

const handleMarkdownFile = async (path: string) => {
    if (!path.endsWith("index.md"))
        return;

    const url = path.replace(urlRegex(config.root), (_, slug) => slug);
    const source = `${config.root}${url}index.md`;
    const dest = `${config.root}${url}index.html`;

    console.log(`[md] ${source}`);

    const file = handleFrontMatter(url, source);

    await markdownProcessor({ trusted: true })
        .process(file);

    /* Replaces file.value with the result of rendering the template, taking care of `layout` */
    let template: string;

    if (file.data.matter.layout !== undefined) {
        template = `{% extends "${file.data.matter.layout}" %}\n{% block content %}\n${file}\n{{ super() }}\n{% endblock content %}\n`;
    } else {
        template = `${file}`;
    }

    const env = njk.configure(`${projectRoot}/templates`);

    /* Returns all pages with the given tag, ordered by `published`. This function has to be sync(!) */
    env.addGlobal("tag", (tag: string) => {
        const pages = readdirSync(`${projectRoot}/tags/${tag}`, { withFileTypes: true, recursive: true })
            .filter(x => x.name.endsWith(".md"))
            .map(x => `${x.parentPath}/${x.name}`)
            .map(x => {
                const url = x.replace(urlRegex(`tags/${tag}`), (_, slug) => slug);
                const file = handleFrontMatter(url, x);

                return file.data.matter;
            });

        pages.sort((a, b) => (a.published as Date).getTime() - (b.published as Date).getTime());

        return pages;
    });

    file.value = njk
        .compile(template, env)
        .render({
            page: file.data.matter,
            config
        });

    const { matter } = file.data;

    const output = await unified()
        .use(rehypeParse)
        .use(rehypeMeta, {
            ...matter,
            type: (matter.tags ?? []).includes("post") ? "article" : "website",
            image: "/favicon.png",
            og: true
        })
        .use(rehypeMinifyWhitespace, {
            newlines: false
        })
        .use(rehypeStringify, {
            allowDangerousCharacters: true,
            allowDangerousHtml: true
        })
        .process(file);

    await writeFile(dest, String(output));

    for (const tag of file.data.matter.tags ?? []) {
        await mkdir(`tags/${tag}${url}`, { recursive: true });

        try {
            await symlink(`${projectRoot}/${source}`, `tags/${tag}${url}index.md`, "file");
        } catch {}
    }
}

const handleFile = async (path: string) => {
    try {
        await handleMarkdownFile(path);
    } catch (err) {
        console.error(`[err] ${err.message}`);
        console.error(err.stack);
    }
};

// Scaffolding
try {
    await stat("public/katex.css");
} catch {
    await cp("node_modules/katex/dist/fonts", "public/fonts", { recursive: true });
    await cp("node_modules/katex/dist/katex.min.css", "public/katex.css");
}

const files = (await readdir(`${projectRoot}/${config.root}`, { withFileTypes: true, recursive: true }))
    .filter(x => x.isFile() && x.name.endsWith(".md"))
    .map(x => `${x.parentPath}/${x.name}`);

const htmlFiles = files.map(x => x.replace(/\.md$/, ".html"));

for (const [index, _] of files.entries()) {
    try {
        const { mtime: htmlMtime } = await stat(htmlFiles[index]);
        const { mtime: mdMtime } = await stat(files[index]);

        if (mdMtime > htmlMtime)
            handleFile(files[index])
    } catch {
        handleFile(files[index]);
    }
}

const configWithHtml = {
    ...config,
    build: {
        rollupOptions: {
            input: htmlFiles,
            cache: true
        },
        ...config.build
    }
};

// Production
if (process.argv.includes("-p")) {
    await build(configWithHtml);
} else {
    const watcher = new Watcher(config.root, { recursive: true });
    watcher.on("change", handleFile);

    const server = await createServer(configWithHtml);
    await server.listen();
    
    console.log(`[vite] dev server started`);
}
