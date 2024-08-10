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

Please do *not* use this code. It is *funky*.

## Building

Run `node --import=tsx src/build.ts build` from the project root.
Use `serve` instead of `build` to run a dev server (vite).

The actual server-side logic doesn't run when using the dev server,
but rather when using `server.ts`.

### Why are there two servers?

I chose to use two servers as vite can do HMR, while oak's routing is
more comprehensible thanks to its use of path-to-regexp.

## Why did you create your own SSG?

Well, I wanted something that worked well with the JS/TS ecosystem,
while at the same time not incorporating an extremely complex framework
within it, and that allowed me to embed LaTeX without weird formatting
issues and that had a divese set of languages for syntax highlighting.

Eventually I noticed pretty much nothing was going to cut it. Alas, here we are.

# TODO

 - Create a dependency tree for Markdown files (only rebuild them if they've changed)
 - Use workers to process files in parallel
