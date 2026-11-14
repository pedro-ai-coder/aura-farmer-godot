# Asset resources and provenance

**Context tier:** thin. **Scope:** `assets/`.

## Purpose

Approved and candidate visuals, fonts, atlases and manifests. Runtime inclusion, Git merge or a filename containing "approved" never independently establishes final artistic approval.

## Key files

- `./approved-assets.json` — approved-source commit, destinations and hashes.
- `./approved-enemy-frames.json` — enemy-frame inventory.
- `./ui-catalog.json` — UI display text and catalog metadata, not gameplay authority.

## Guardrails

Keep candidates separate from approved immutable sources. Verify relevant manifest/version, hash and explicit creator approval before promoting or replacing assets; preserve stable content IDs and supersession history. Avoid opening entire binary/asset collections unless required.
