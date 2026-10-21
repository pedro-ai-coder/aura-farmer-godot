#!/usr/bin/env bash
set -euo pipefail

if command -v godot >/dev/null 2>&1; then
  GODOT_BIN="godot"
elif command -v godot4 >/dev/null 2>&1; then
  GODOT_BIN="godot4"
else
  echo "ERROR: Godot 4.7.2 executable not found in PATH." >&2
  exit 2
fi

cd "$(dirname "$0")/.."

# Godot can return 0 while outputting script/resource errors.
log_dir="$(mktemp -d)"
trap 'rm -rf "$log_dir"' EXIT

run_check() {
  local phase="$1"
  shift
  local log_file="$log_dir/$phase.log"

  echo "Validating Godot phase: $phase"
  if "$GODOT_BIN" "$@" 2>&1 | tee "$log_file"; then
    :
  else
    echo "ERROR: Godot $phase process failed." >&2
    return 1
  fi

  if grep -Eiq 'SCRIPT ERROR:|Parse Error:|(^|[[:space:]])ERROR:|Failed to load|Failed to open' "$log_file"; then
    echo "ERROR: Godot $phase reported parsing/loading/runtime errors." >&2
    return 1
  fi
}

run_check import --headless --path . --import
run_check contracts --headless --path . --script res://tests/test_game_rules.gd
run_check catalog --headless --path . --script res://tests/test_solo_offer_rules.gd
run_check approved-art --headless --path . --script res://tests/test_approved_visuals.gd
run_check playable --headless --path . --script res://tests/test_playable_slice.gd
run_check scene --headless --path . --quit-after 10

echo "PASS: Godot import, GDD rule contracts, and main scene smoke test."
