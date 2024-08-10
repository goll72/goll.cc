// Uses remark and rehype alongside vite to build
// and/or serve a development version of the website.

import path from "node:path";
import { readdirSync, readFileSync } from "node:fs";
import { writeFile, mkdir, symlink, readdir, stat, cp, rm } from "node:fs/promises";

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
import { PrismaClient } from "@prisma/client";

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

const prisma = new PrismaClient();

const handleMarkdownFile = async (path: string) => {
    if (!path.endsWith("index.md"))
        return;

    const url = path.replace(urlRegex(config.server.source), (_, slug) => slug);
    const source = `${config.server.source}${url}index.md`;
    const dest = `${config.server.source}${url}index.html`;

    console.log(`[md] ${source}`);

    const file = handleFrontMatter(url, source);

    if (mode === "build" && file.data.matter.draft) {
        await rm(dest, { force: true });
        return;
    }

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

    const output = await unified()
        .use(rehypeParse)
        .use(rehypeMeta, {
            title: file.data.matter.title,
            description: file.data.matter.description,
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

    if (file.data.matter.layout === "with-comments.njk") {
        await prisma.page.upsert({
            create: { url },
            update: {},
            where: { url }
        });
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

if (process.argv[2] !== "build" && process.argv[2] !== "serve") {
    throw Error(`Invalid argument. Usage: ${process.argv[0]} ${process.argv[1]} <build|serve>`);
}

const mode: "build" | "serve" = process.argv[2];

// Scaffolding
try {
    await stat("public/katex.css");
} catch {
    await cp("node_modules/katex/dist/fonts", "public/fonts", { recursive: true });
    await cp("node_modules/katex/dist/katex.min.css", "public/katex.css");
}

if (mode === "serve") {
    const watcher = new Watcher(config.server.source, { recursive: true });
    const server = await createServer(config.vite);

    server.middlewares.use((req, _, next) => {
        if (req.originalUrl !== "/" && !req.originalUrl?.endsWith("index.html")) {
            req.url += "/index.html";
        }

        next();
    });

    await server.listen();

    for (const event of ["add", "change"]) {
        watcher.on(event, handleFile);
    }
} else if (mode === "build") {
    const files = (await readdir(`${projectRoot}/${config.server.source}`, { withFileTypes: true, recursive: true }))
        .filter(x => x.isFile() && x.name.endsWith(".md"))
        .map(x => `${x.parentPath}/${x.name}`);

    for (const path of files) {
        handleFile(path);
    }

    await build({
        ...config.vite,
        build: {
            rollupOptions: {
                input: files.map(x => x.replace(/\.md$/, ".html"))
            },
            ...config.vite.build
        }
    });
}
