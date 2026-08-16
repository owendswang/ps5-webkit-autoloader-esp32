#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 {minimize|datadir} SOURCE_DIR OUTPUT_DIR" >&2
    exit 2
fi

MODE="$1"
SOURCE_DIR="$2"
OUTPUT_DIR="$3"

case "$MODE" in
    minimize)
        REQUIRED_TOOLS=(terser cleancss html-minifier-terser jq svgo)
        ;;
    datadir)
        REQUIRED_TOOLS=(gzip)
        ;;
    *)
        echo "Error: unknown mode: $MODE" >&2
        exit 2
        ;;
esac

for tool in "${REQUIRED_TOOLS[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "Error: $tool is required (run ./install-deps.sh)" >&2
        exit 1
    }
done

test -d "$SOURCE_DIR" || {
    echo "Error: source data directory was not found: $SOURCE_DIR" >&2
    exit 1
}

minimize_file() {
    local file="$1"
    local tmp_file="${file}.minimize.tmp"

    case "$file" in
        *.js)
            # Terser only reformats here; compression and name mangling are opt-in.
            terser "$file" --output "$tmp_file"
            ;;
        *.css)
            cleancss -O0 --output "$tmp_file" "$file"
            ;;
        *.html)
            html-minifier-terser \
                --collapse-inline-tag-whitespace \
                --collapse-whitespace \
                --minify-css '{"level":0}' \
                --minify-js '{"compress":false,"mangle":false}' \
                --remove-comments \
                --output "$tmp_file" \
                "$file"
            ;;
        *.json)
            jq --compact-output '.' "$file" >"$tmp_file"
            ;;
        *.svg)
            svgo \
                --config "$(dirname "$0")/svgo-minimize.config.mjs" \
                --input "$file" \
                --output "$tmp_file"
            ;;
        *)
            return
            ;;
    esac

    chmod --reference="$file" "$tmp_file"
    mv -f "$tmp_file" "$file"
}

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cp -a "$SOURCE_DIR/." "$OUTPUT_DIR/"
find "$OUTPUT_DIR" -type f -name '*.gz' -delete

if [ "$MODE" = minimize ]; then
    echo "Minimizing JS, CSS, HTML, JSON and SVG files..."
    while IFS= read -r -d '' file; do
        minimize_file "$file"
    done < <(find "$OUTPUT_DIR" -type f \( \
        -name '*.js' -o \
        -name '*.css' -o \
        -name '*.html' -o \
        -name '*.json' -o \
        -name '*.svg' \
    \) -print0)
else
    echo "Compressing minimized files for LittleFS..."
    while IFS= read -r -d '' file; do
        gzip -9 -n "$file"
    done < <(find "$OUTPUT_DIR" -type f \( \
        -name '*.html' -o \
        -name '*.js' -o \
        -name '*.elf' -o \
        -name '*.bin' -o \
        -name 'cache.appcache' -o \
        -name '*.svg' -o \
        -name '*.css' -o \
        -name 'version' -o \
        -name '__complete__' -o \
        -name '*.json' \
    \) -print0)
fi
