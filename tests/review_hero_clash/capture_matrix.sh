#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
GODOT_BIN="${GODOT_BIN:-godot}"
OUTPUT="${1:?Pass an absolute output directory}"
for candidate in a b c; do
  for dimensions in '1920 1080' '1600 900' '1280 720' '915 412' '844 390' '390 844'; do
    read -r width height <<< "$dimensions"
    "$GODOT_BIN" --path . --audio-driver Dummy --script res://tests/review_hero_clash/capture.gd -- "$width" "$height" "$OUTPUT" "--candidate=$candidate"
  done
done
