#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${GODOT_BIN:=godot}"
[[ "$("$GODOT_BIN" --version)" =~ ^4\.7\.2\.stable(\.|$) ]] || { echo 'Godot 4.7.2 stable required' >&2; exit 2; }
python3 scripts/verify_cool_kid_rig.py
mkdir -p build/cool-kid-review
for phase in import export; do
    log="build/cool-kid-review/$phase.log"
    if [[ "$phase" == import ]]; then
        "$GODOT_BIN" --headless --path . --import > "$log" 2>&1
    else
        "$GODOT_BIN" --headless --path . --export-release 'Cool Kid Rig Review' build/cool-kid-review/index.html > "$log" 2>&1
    fi
    if rg -n 'SCRIPT ERROR:|Parse Error:|(^|[[:space:]])ERROR:|Failed to load|Failed to open' "$log"; then exit 1; fi
done
python3 scripts/verify_cool_kid_rig.py build/cool-kid-review/index.pck
python3 scripts/verify_approved_hero_sheets.py build/cool-kid-review/index.pck
python3 scripts/verify_full_hero_atlases.py build/cool-kid-review/index.pck
cp web/platform.js web/aura.webmanifest build/cool-kid-review/
cp assets/ui-button-candidates/v1/secondary-normal.png build/cool-kid-review/fullscreen-button.png
for state in hover focus pressed; do
    cp "assets/ui-button-candidates/v1/secondary-$state.png" "build/cool-kid-review/fullscreen-button-$state.png"
done
cp assets/fonts/hero-clash/Archivo.ttf build/cool-kid-review/fullscreen-archivo.ttf
cp assets/fonts/hero-clash/OFL-Archivo.txt build/cool-kid-review/fullscreen-font-license.txt
printf 'LOCAL REVIEW ONLY: python3 -m http.server 8765 --bind 127.0.0.1 --directory build/cool-kid-review\n'
