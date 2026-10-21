#!/usr/bin/env bash
set -euo pipefail
# Reproducible Godot Web export for Vercel's standard Linux build image.
# Uses only official Godot 4.7.2 binaries, verified against published SHA-256.
VERSION="4.7.2"
TAG="${VERSION}-stable"
RELEASE="https://github.com/godotengine/godot/releases/download/${TAG}"
ENGINE_FILENAME="Godot_v${TAG}_linux.x86_64.zip"
TEMPLATE_FILENAME="Godot_v${TAG}_export_templates.tpz"
ENGINE_SHA="cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4"
TEMPLATE_SHA="f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p build/web
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

require_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "ERROR: Missing required build utility $1" >&2
        exit 2
    fi
}
for tool in curl unzip sha256sum grep; do
    require_tool "$tool"
done

fetch_official() {
    local filename="$1" sha="$2"
    echo "Downloading official Godot archive: $filename"
    curl --fail --location --retry 3 --retry-delay 3 --silent --show-error \
        "$RELEASE/$filename" --output "$WORKDIR/$filename"
    (cd "$WORKDIR"; printf '%s  %s\n' "$sha" "$filename" | sha256sum --check --status) || {
        echo "ERROR: Official Godot archive checksum mismatch: $filename" >&2
        exit 3
    }
}
if [[ -n "${GODOT_BIN:-}" && -x "$GODOT_BIN" ]]; then
    GODOT="$GODOT_BIN"
elif command -v godot >/dev/null 2>&1 && godot --version | grep -q '^4\.7\.2'; then
    GODOT="$(command -v godot)"
else
    fetch_official "$ENGINE_FILENAME" "$ENGINE_SHA"
    unzip -q "$WORKDIR/$ENGINE_FILENAME" -d "$WORKDIR/editor"
    GODOT="$(find "$WORKDIR/editor" -type f -name 'Godot_*linux.x86_64' -print -quit)"
    if [[ -z "$GODOT" ]]; then
        echo "ERROR: Official Godot executable not found in archive." >&2
        exit 3
    fi
    chmod +x "$GODOT"
fi

if [[ "${GODOT_SKIP_TEMPLATE_DOWNLOAD:-0}" != "1" ]]; then
    fetch_official "$TEMPLATE_FILENAME" "$TEMPLATE_SHA"
    VERSION_DIR="$HOME/.local/share/godot/export_templates/${VERSION}.stable"
    mkdir -p "$VERSION_DIR"
    # Extract ONLY Web templates; archive includes all desktop/mobile platforms (~1.2 GB).
    mapfile -t WEB_ENTRIES < <(unzip -Z1 "$WORKDIR/$TEMPLATE_FILENAME" | grep -E '^templates/web.*\.zip$')
    if [[ "${#WEB_ENTRIES[@]}" -eq 0 ]]; then
        echo "ERROR: No official Web templates were found in the export archive." >&2
        exit 4
    fi
    for entry in "${WEB_ENTRIES[@]}"; do
        output="$VERSION_DIR/${entry##*/}"
        echo "Installing Web export template: ${entry##*/}"
        unzip -p "$WORKDIR/$TEMPLATE_FILENAME" "$entry" > "$output"
        test -s "$output"
    done
fi

python3 scripts/sync_approved_assets.py

echo "Godot executable: $GODOT"
"$GODOT" --version
"$GODOT" --headless --path . --import
"$GODOT" --headless --path . --export-release "Web" build/web/index.html

for file in index.html index.js index.wasm index.pck; do
    if [[ ! -s "build/web/$file" ]]; then
        echo "ERROR: Web export missing or empty: build/web/$file" >&2
        exit 5
    fi
done
echo "SUCCESS: Official Godot Web export prepared in build/web"
du -sh build/web
