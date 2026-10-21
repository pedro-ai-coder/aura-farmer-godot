#!/usr/bin/env bash
set -euo pipefail
# The repository already exists; for subsequent changes use the existing origin.
cd "$(dirname "$0")/.."
if [[ ! -s docs/GDD.md ]]; then
  echo "ERROR: Canonical GDD missing." >&2
  exit 2
fi
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "ERROR: Configure origin as https://github.com/pedro-ai-coder/aura-farmer-godot.git" >&2
  exit 2
fi
git push -u origin main
