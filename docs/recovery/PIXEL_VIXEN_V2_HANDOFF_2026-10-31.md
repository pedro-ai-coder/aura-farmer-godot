# Pixel Vixen V2 source import and runtime verification — 31 October 2026

> Historical Pixel-only checkpoint. The later [complete female roster review](../art/female-roster/README.md) supersedes statements below about Byte Baddie/Block Queen being unavailable; it preserves the Pixel Vixen source assets.

**The missing-source blocker is resolved.** The creator attached `pixel_vixen_v2_for_work(1).zip`. Its three original PNGs have been imported into the existing [PR #97](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/97) branch, `feat/m0-pixel-vixen-playable-candidate`. The existing PNG hash pins and dimensions have not been changed to accept different artwork; only incorrect uniform-grid layout metadata was corrected after inspecting the actual atlas. The ZIP's additional manifest does not replace the repository's provenance or approval record.

These assets remain **UNAPPROVED_CREATOR_REVIEW_CANDIDATE / PREVIEW_ONLY**. This import is not artistic approval, merge authorization or authorization for production deployment. Byte Baddie and Block Queen remain unavailable pending their own artwork and the creator's staged review.

## Exact source verification

All three files match the original hash pins in the [V2 manifest](../../assets/art-candidates/pixel-vixen/v2/manifest.json), byte for byte:

| File | Dimensions | SHA-256 |
| --- | --- | --- |
| `pixel-vixen-atlas-v2.png` | 896 × 672 | `803bfb3370b4e9d8eda4a1c63dfa141539012eb340c3ef9a0bf478a89075cf0d` |
| `pixel-vixen-portrait-v2.png` | 520 × 460 | `13fd0af8fb873a70dd69b14cb6e1914606f4dcd7ff7601fd4169d422cfc6c9b9` |
| `pixel-vixen-hud-v2.png` | 480 × 320 | `337047c012d476f230091f7cf9fff0373b819f4020eba121dd6cc1524d0f0776` |

`python3 scripts/verify_pixel_vixen.py` passes. No regeneration, rescaling, V1 relabeling, replacement of original approved art or approved-registry promotion is part of this import.

## Actual runtime evidence

Official **Godot 4.7.2, Compatibility, X11/Mesa llvmpipe** rendered the actual game. The save-isolated [capture harness](../../tests/pixel_vixen/capture.gd) uses real pointer events to open Hero Selection, choose Female and start the run. It verifies the exact resource paths for the illustrated selection portrait, the separate HUD portrait and the gameplay atlas. The V2 HUD bypasses the original male portrait-crop shader. Movement advances the real simulation; Flex uses the canonical target-required activation.

Thirty native captures cover selection, idle, movement, Flex and defeat at the six requested window sizes: 1920×1080, 1600×900, 1280×720, 915×412, 844×390 and 390×844. All runtime binding assertions passed, with no script/resource errors. The [runtime report](evidence/pixel-vixen-v2/runtime.json) records the actual dimensions, resource paths, atlas frames, canonical kit and positions. Existing responsive-canvas rounding produces 915×411, 843×390 and 390×843 readbacks for the three compact windows; these images have not been resized to hide that difference.

Selected captures are stored as lossless WebP; decoded RGB pixels were verified identical to the original, unresampled Godot PNG readbacks:

- [Desktop Hero Selection](evidence/pixel-vixen-v2/selection-1600x900.webp)
- [Desktop HUD and gameplay](evidence/pixel-vixen-v2/idle-1600x900.webp)
- [Mobile landscape movement](evidence/pixel-vixen-v2/moving-844x390.webp)
- [Mobile landscape Flex](evidence/pixel-vixen-v2/flex-844x390.webp)
- [Portrait selection](evidence/pixel-vixen-v2/selection-390x844.webp)

These are staged native runtime fixtures, not browser, physical-device, performance or human-playtest measurements. The atlas's mirrored/approximated directional coverage remains as documented in the manifest; neither 51 source poses nor 49 logical slots establish final animation-quality approval.

## Atlas registration correction

Visual inspection caught detached boots from the previous row while moving. The supplied atlas actually contains **51 unevenly spaced source poses**, distributed 7/7/7/8/6/8/8, rather than the assumed uniform 128×96 grid. Explicit source rectangles in `scripts/pixel_vixen_frames.gd` now register those poses into the existing 49 logical playback slots. No PNG was edited, no gameplay timing was retuned and no V1 fallback was introduced. The shared Sigma state machine still determines state and timing; short/extra source rows are mapped within that visual adapter. A regression checks that the running pose includes its actual head and excludes the previous idle pose’s boots. Native captures were repeated after this correction.

## Canonical behavior and export guards

Pixel Vixen remains **`sigma` / No Cap / Deadpan Verdict**, using the existing attributes, collisions, RNG, attacks, progression and profile IDs. This import changes no gameplay implementation. Original hero art and the production art manifests are unchanged. Existing result/Retry appearance routing and backwards-compatible optional appearance persistence remain in place.

The mandatory real-asset suites `test_hero_appearance_selection.gd` and `test_pixel_vixen_animation.gd` pass, including six-viewport selection, exact PNG hashes/dimensions, original-art isolation and shared Sigma animation timing. The existing full `scripts/validate.sh` suite remains mandatory; its authoritative final-head result and the matching protected preview are linked in PR #97.

The official Web build still fails closed on missing or mismatched V2 sources. Its exported PCK must contain all three imported V2 textures and this candidate manifest, and must exclude the superseded V1 directory. Historical V1 source bytes remain in Git but are not a runtime/export fallback. Build success and runtime captures do not supersede the creator's approval gate.

The earlier failed runs on `e774da79` and `4b437b6` genuinely lacked the PNGs. They are historical failures, not waived passes. Review the new exact-build preview before approving Pixel Vixen or beginning the next female artwork batch. Do not merge or deploy this candidate to production automatically.

The final exact-preview verification is recorded on PR #97. The cloud browser reached the preview but explicitly reported missing WebGL2; interactive Web/device gameplay remains unverified in this session.
