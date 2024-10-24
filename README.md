goll.cc
=======

My (statically generated) website. Written using Markdown with support
for embedded LaTeX, and Nunjucks templates. It uses the following componenets:

 - remark and rehype
 - vite
 - katex
 - tree-sitter
 - prisma
 - nunjucks

## Building

Run

```sh
$ git submodule update --init --recursive
$ npm install
$ npm run build
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
