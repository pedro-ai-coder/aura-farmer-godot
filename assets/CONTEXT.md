# Asset resources and provenance

**Context tier:** thin. **Scope:** `assets/`.

## Purpose

Approved and candidate visuals, fonts, atlases and manifests. Runtime inclusion, Git merge or a filename containing "approved" never independently establishes final artistic approval.

## Key files

- `./approved-assets.json` — approved-source commit, destinations and hashes.
- `./ui/cpk/theme.tres` — native CPK Theme with approved brand palette and existing licensed fonts; component application remains a review candidate.
- `./production/cpk-brand-2026-11-13-v1/manifest.json` / `./production/garage-candidate-v1/manifest.json` — separately pinned approved-source brand derivatives and PROPOSED new Garage background; original Garage reference remains unrecovered.
- `./approved-enemy-frames.json` — enemy-frame inventory.
- `./ui-catalog.json` — UI display text and catalog metadata, not gameplay authority.
- `./production/heroes/full-atlases-v2/manifest.json` — six newly drawn 64-frame animation atlases and explicit sequence/cell/pivot mappings, pending creator game testing.
- `./production/heroes/individual-sheets-v1/manifest.json` — exact six-sheet creator approval, retained masters, technical atlas/portrait/HUD hashes and pivots; active character presentation replaces historical derivatives.

## Guardrails

Keep candidates separate from approved immutable sources. Verify relevant manifest/version, hash and explicit creator approval before promoting or replacing assets; preserve stable content IDs and supersession history. Avoid opening entire binary/asset collections unless required.
