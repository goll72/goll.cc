goll.cc
=======

My (mostly-statically-generated) website. Written using Markdown with support
for embedded LaTeX, Nunjucks templates and server-side support for comments.
It uses the following componenets:

 - remark and rehype
 - vite
 - katex
 - tree-sitter
 - prisma
 - nunjucks
 - oak

This code may have high doses of *funkiness*.

## Building

Run

```sh
$ git submodule update --init --recursive
$ npm install
$ prisma generate
$ node --import=tsx src/build.ts
```

from the project root.

## Why did you create your own SSG?

Well, I wanted something that worked well with the JS/TS ecosystem,
while at the same time not incorporating an extremely complex framework
within it, and that allowed me to embed LaTeX without weird formatting
issues and that had a divese set of languages for syntax highlighting.

Eventually I noticed pretty much nothing was going to cut it. Alas, here we are.

# TODO

 - Create a dependency tree for Markdown files (only rebuild them if they've changed)
 - Use workers to process files in parallel(?)
