# Neon Punk Arcade frontend review candidate

The creator's current task approves the **Neon Punk Arcade direction**. Exact token values, layouts and motion are **CANDIDATE**, pending visual review. This document does not promote new artwork, approve GDD V4 or authorize merge/publication. Operational authority remains GDD V3 plus scoped creator decisions. The older Garage document's V4 authority statement is not used by this change.

Base: `56d4ff39c6c1c217acd616bff5ba680136cbb55d` (open PR #139, dependent on #138/#137). This intentionally excludes the later environment/combat branch stack. Only frontend presentation files change. The existing Solo scene remains the owner of simulation, saves, IDs, unlock checks, rules and RNG.

## Foundation

`neon_arcade.gd` provides a cached frontend-only Theme, angular panels/buttons, high contrast lime primary action, magenta pressed treatment, visible focus/disabled states, spacing and motion tokens. It duplicates the existing Theme rather than mutating gameplay UI. Archivo/Archivo Black are reused unchanged under SIL OFL; provenance and hashes: `assets/fonts/hero-clash/manifest.json` and accompanying OFL files. No dependency or generated artwork is added.

`signal_breaker_garage.gd` uses an asymmetric navigation/hero composition with separate portrait, compact landscape and desktop layouts. Only real existing destinations are exposed. Information binds to the actual kit catalogue; the full existing Flex description remains on the information panel tooltip. All six identities retain their existing kit and appearance mappings.

## Immutable art sources

- Portraits: `assets/production/heroes/individual-sheets-v1/manifest.json`, recorded approval in `docs/art/APPROVED_INDIVIDUAL_SHEETS_INTEGRATION_2026-11-14.md`.
- Existing authored animation atlas: `assets/production/heroes/full-atlases-v2/manifest.json`; current composition decision in `docs/art/ANIMATION_FLUENCY_PILOT.md`. Historical candidate/status fields remain untouched; reuse does not constitute new art approval.
- Wordmark: `assets/production/cpk-brand-2026-11-13-v1/manifest.json`, immutable Art source `6b0da4f4cee5a72caec3c12b87c3e5817d94f969`.
- Garage: `assets/production/garage-candidate-v1/manifest.json`, immutable Art source `a36ad90be52c6fcdb6ee5da7bb536ddca4c59391`. Remains **PROPOSED**; not the unrecovered approved original environment image.

No source image, manifest, licence or source hash changes. Rollback: revert these frontend commits; the prior coordinator and original Solo scene remain available.

## Verification approach

Use Godot **4.7.2 Compatibility**. Existing `tests/test_signal_breaker_garage.gd` verifies actual input, all six identities, six viewport layouts, legitimate run/pause/return/settings and menu RNG isolation; its optional argument writes native captures. Run `scripts/verify_cpk_garage_assets.py`, the existing approved-sheet/full-atlas verifiers and `scripts/validate.sh`. Record actual outcomes, tested SHA, platform and artifacts separately in PR evidence. Native Linux software rendering cannot certify physical devices or final artistic acceptance.

Skills: catalogue discovery found no Godot, game UI, cutout/rigging or motion-specific skill. The cloud-desktop skill informed native capture/fallback selection; no desktop MCP is available, so native Godot screenshots use a local X server. Existing `scripts/CONTEXT.md` and `tests/CONTEXT.md` route focused reads/checks instead of broad repository scans.
