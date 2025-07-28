---
description: A TeX Live 2024 bundle for Tectonic
css:
 - /code.css
---

# TeX Live & Tectonic

If you're anything like me, then you *hate* TeX Live and its 3GB$^+$ distribution 
files and `tlmgr` and so. You might have heard of [Tectonic]. It's a LaTeX 
distribution based on XeTeX and TeX Live that downloads distribution files 
on-demand and, among other things, ditches `tlmgr`. As such, it is much more 
manageable and pleasurable to use.

[Tectonic]: https://tectonic-typesetting.github.io

There's one downside, though: for a TeX Live distribution to be usable in Tectonic,
it has to be bundled in a bespoke file format and served so that it can be 
downloaded by clients using HTTP range requests. Unfortunately, although the Tectonic
Typesetting team has created the build files for the latest TeX Live distribution 
release as of the moment I am writing this (which is `20240312`), they haven't 
generated the corresponding bundle. So, if you try to install `tectonic` and use it,
you will notice the latest version of TeX Live available on their servers is `2023`.

I eventually found myself in need of the most recent version, but I didn't want to
have to install the full TeX Live distribution (`tectonic` really is very convenient,
after all) so I ended up building the `20240312` bundle myself, and, in fact, I am
hosting it [here](/texlive2024/bundle.ttb).

> temporarily unavailable because my stupid ass forgot to back it up when distrohopping
> on my server, sorry `>.<`

## Notes

 - If you want to use the `20240312` bundle, you will have to build `tectonic` from
   source or use one of the binaries found in the CI pipeline artifacts, since the
   bundle format has been updated and the latest release of Tectonic available on
   [GitHub](https://github.com/tectonic-typesetting/tectonic) does not support it,
   as it's too old. 

 - If you want to build it yourself, you should be able to just follow the instructions
   outlined on the [README], for the most part. One detail that doesn't seem to be 
   mentioned, however, is that for actually hosting a bundle that can be used by 
   `tectonic`, you will need the `.ttb` and the `index.gz` files (only). 
   If the `.ttb` file is named `<name>.ttb`, then `index.gz` has to be renamed to 
   `<name>.ttb.index.gz`, and they must be placed in the same directory.

   The `index.gz` file is actually contained in the `.ttb` file, and you will have to 
   "extract" it using the `dd` command that is also mentioned in the [README]. 
   That means you will have to look out in the output of `tectonic -X bundle create`
   for the offset and size of the `index.gz` file.

[README]: https://github.com/tectonic-typesetting/tectonic/tree/master/bundles

## Usage

Simply invoke `tectonic` as:

```sh
tectonic -b https://goll.cc/texlive2024/bundle.ttb ...
```
