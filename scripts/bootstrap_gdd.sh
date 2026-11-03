#!/usr/bin/env bash
set -euo pipefail
# Obsolete Phaser import. Canonical GDD and decision register are already
# preserved in this repository and governed by clutchpunks-canon.
# Never fetch a historical GDD or overwrite an approved current design.
cd "$(dirname "$0")/.."
if [[ ! -s docs/GDD.md ]]; then
  echo "ERROR: canonical GDD is missing; restore it from clutchpunks-canon approval provenance." >&2
  exit 1
fi
echo "PASS: local GDD exists. Historical Phaser bootstrap retired; no network access."
