goll.cc
=======

My website, written in Markdown, using Pandoc.

## Dependencies

 - Pandoc 3
 - Lua 5.4
 - Node.js
 - jq
 - Python 3.12
 - Ninja 1.10
 - A C compiler

> [!NOTE] 
> Pandoc needs to use Lua 5.4 as its scripting engine and it has to be
> linked dynamically, otherwise it won't be able to load Lua libraries
> written in C.

## Building

To build the website, run:

```sh
python -m setup.build <builddir>
ninja -C <builddir>
```

The resulting files will be created at `<builddir>/dist`.
