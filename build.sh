#!/bin/sh

assets=$(cd src && find assets -type f -print0 | jq -c --raw-input --slurp '[ split("\u0000") | .[] | select(length > 0) ]')

exec typst watch \
         --ignore-system-fonts \
         --font-path src/assets/fonts \
         --features bundle,html \
         --format bundle \
         --root src \
         --input assets="$assets" \
         src/index.typ dist
