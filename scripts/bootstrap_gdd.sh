#!/usr/bin/env bash
set -euo pipefail
# Pinned source; the canonical GDD is already included in this repository.
SOURCE_REVISION="fdbc67b9d79b1d2bfbbcaad40305da1677bc626f"
EXPECTED_BLOB_SHA="10beed151c045944811e42aead6533b94df77d3a"
cd "$(dirname "$0")/.."
if [[ -e docs/GDD.md ]]; then
  echo "ERROR: docs/GDD.md exists; refusing to overwrite it." >&2
  exit 1
fi
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl --fail --location --silent --show-error "https://raw.githubusercontent.com/pedro-ai-coder/aura-farmer/$SOURCE_REVISION/docs/GDD.md" -o "$tmp"
if [[ "$(git hash-object "$tmp")" != "$EXPECTED_BLOB_SHA" ]]; then
  echo "ERROR: GDD SHA mismatch" >&2
  exit 1
fi
mv "$tmp" docs/GDD.md
echo "Imported verified GDD"
