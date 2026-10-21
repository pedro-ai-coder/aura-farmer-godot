#!/usr/bin/env bash
set -euo pipefail
if command -v godot >/dev/null 2>&1; then
  GODOT_BIN="godot"
elif command -v godot4 >/dev/null 2>&1; then
  GODOT_BIN="godot4"
else
  echo "ERROR: Godot executable not found in PATH" >&2
  exit 2
fi
cd "$(dirname "$0")/.."
"$GODOT_BIN" --headless --path . --editor --quit
"$GODOT_BIN" --headless --path . --script res://tests/test_game_rules.gd
"$GODOT_BIN" --headless --path . --quit-after 10
