# Neon Punk Arcade frontend review candidate

The creator's current task approves the **Neon Punk Arcade direction**. Exact token values, layouts and motion are **CANDIDATE**, pending visual review. This document does not promote new artwork, broaden the bounded GDD V4 approval or authorize merge/publication. Fresh remote verification pins Canon `a1e670ff889b1a804a9c8b97b755e433a5cf3c95`: its GDD V4.0 consolidates only approved snapshot `96d1f51e066daa537680a849dc4cfcb3c1196c51` under decision CPK-GDD-V4-0-2026-11-13-01, inheriting unchanged normative V3 gameplay and its register. The broader V4 Foundation Draft remains PROPOSED. The initially provisioned local Canon checkout was older; its blanket V4-unapproved wording is not the current remote authority.

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

## Motion and Hero Select (stacked PR 2)

`neon_hero_showcase.gd` caches four **existing approved individual-sheet poses** per identity: idle, anticipation, recovery and front stance. A common original-pixel crop/foot registration preserves aspect and alignment; linear filtering avoids nearest-neighbour pixelation. A brief anticipation/recovery reaction plays on entry/selection, followed by occasional stance changes and a small rigid, foot-anchored sway. A single TextureRect replaces its current texture, so rapid selection cannot leave an outgoing hero overlay. The interruptible 240ms entry translation never delays activation. Textures are cached once per identity rather than allocated per frame.

Inspection rejected enlarging the existing 192px combat idle cells: their detail and pose continuity were unsuitable for a large menu showcase. The original 384×352 individual-sheet cells retain more source detail. **No skeletal rig, new blinking frames or independently articulated limbs exist here.** Continuous arm/head articulation still requires newly approved layered/high-resolution art. Existing approved poses visibly change arms/posture without slicing or deforming characters; no gameplay animation module changes.

The existing native Button remains the input/focus owner. `neon_button_feedback.gd` adds a short, interruptible magenta accent inside the fixed hitbox; it never emits activation. Theme states remain immediate. The older Hero Clash feedback component replaces artwork and uses a different palette, so a small frontend-only accent is used. Controller accept/cancel is handled only while the Garage is active because the inherited project maps `ui_accept` to keys only; gameplay InputMap remains untouched. Grid D-pad neighbours are explicit.

`neon_garage_environment.gd` draws restrained independent light/rail drift and a moving platform arc. Hidden menus stop processing their environment/showcase; the existing reduced-motion setting freezes poses, translation, sway and ambient phase. Native focus/selection feedback stays visible. No audio is added: existing assets are combat-event audio and are not approved as navigation sounds.

Hero Select retains a separate large selected-character presentation on desktop and compact landscape, plus a smaller presentation above the six portrait cards in portrait mode. Desktop shows the actual selected kit's existing Flex explanation. All six identities remain available under their existing start checks.

`tests/test_neon_frontend.gd` supplements the existing Garage suite with contrast, independent Theme/state coverage, registered cached pose playback, rapid switching, controller accept/cancel/D-pad, reduced motion, RNG isolation, immediate real run start and return. It reuses the existing isolated Garage fixture; no QA Recorder or Scenario Mode is duplicated.
