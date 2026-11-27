# Asset resources and provenance

**Context tier:** thin. **Scope:** `assets/`.

## Purpose

Approved and candidate visuals, fonts, atlases and manifests. Runtime inclusion, Git merge or a filename containing "approved" never independently establishes final artistic approval.

## Key files

- `./approved-assets.json` — approved-source commit, destinations and hashes.
- `./ui/cpk/theme.tres` — native CPK Theme with approved brand palette and existing licensed fonts; component application remains a review candidate.
- `./production/cpk-brand-2026-11-13-v1/manifest.json` / `./production/garage-candidate-v1/manifest.json` — separately pinned brand derivatives and exact Garage background accepted by CPK-NEON-PRODUCTION-2026-11-15-01; original missing reference remains unrecovered; original Garage reference remains unrecovered.
- `./approved-enemy-frames.json` — enemy-frame inventory.
- `./art-candidates/ruin-alley/v3/manifest.json` — pinned review-only Ruin Alley paint and crate exports. V1 and V2 remain in the historical candidate folders and are excluded from Godot's scan.
- `./ui-catalog.json` — UI display text and catalog metadata, not gameplay authority.
- `./production/heroes/full-atlases-v2/manifest.json` — six newly drawn 64-frame animation atlases and explicit sequence/cell/pivot mappings, pending creator game testing.
- `./production/heroes/individual-sheets-v1/manifest.json` — exact six-sheet creator approval, retained masters, technical atlas/portrait/HUD hashes and pivots; active character presentation replaces historical derivatives.

## Guardrails

Keep candidates separate from approved immutable sources. Verify relevant manifest/version, hash and explicit creator approval before promoting or replacing assets; preserve stable content IDs and supersession history. Avoid opening entire binary/asset collections unless required.

- `experimental/no-u-v4/` contains a proposed built-in imagegen atlas and prompt/provenance manifest. Ordinary exports exclude the entire directory; isolated No U review staging includes it. No art approval is implied.
