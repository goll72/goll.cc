#!/bin/sh

# Ensure only one instance of the script can be running at a time
: "${TMPDIR:=/tmp}"
LOCKFILE="$TMPDIR/goll.cc.bld.lck"

exec 30>"$LOCKFILE"

if ! flock -xn 30; then
    echo "Another instance of this script is already running" >&2
    exit 1
fi

trap 'flock -u 30; flock -xn 30 && rm -f "$LOCKFILE"; kill -- -$$' EXIT

# Find asset paths under src/assets
assets=$(cd src && find assets -type f -print0 | jq -c --raw-input --slurp '[ split("\u0000") | .[] | select(length > 0) ]')

# Build scripts in src/scripts
npx tsc

while :; do
    inotifywait -e modify src/scripts
    npx tsc
done &

subsh=$!

# Build external subprojects
[ -n "$EXT" ] && make -C src/ext/brachistochrone

typst watch \
    --ignore-system-fonts \
    --font-path src/assets/fonts \
    --features bundle,html \
    --format bundle \
    --root src \
    --input assets="$assets" \
    src/index.typ dist
