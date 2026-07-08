goll.cc
=======

My website, written in Typst.

## Usage

To build the website, you will need to install the dependencies
listed below, as well as the depencies for each external subproject
in `src/ext`:

 - Typst 0.15
 - Node.js
 - npm

After installing the dependencies, run:

```sh
npm i
./build.sh
```

The command above will run the necessary build commands for each
external subproject, transpile Typescript scripts and then run
`typst watch`, outputting the website files to `dist` and serving
them locally.
