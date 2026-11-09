# Pixel Vixen — Clean-Cut Cartoon Sprite Integration Gate

**Status:** DRAFT / CODE STAGED / EXACT PNG NOT YET COMMITTED / GODOT NOT RUN.
**Date:** 2026-11-09
**Target:** Creator-approved CPK brand identity `CPK-BRAND-2026-11-09-01` and six-hero visual direction `CPK-VISUAL-2026-11-09-02`.
**Existing gameplay authority:** GDD V3, unchanged three kits and stable `sigma` ID.

## What this branch really implements

- `scripts/approved_visuals.gd`: presentation-only asset selection for Pixel Vixen using a **49-frame 7x7 RGBA atlas**. It loads **only** if the binary file exists and its SHA-256 matches the expected hash; otherwise the original verified V2 Pixel Vixen remains.
- `tests/test_pixel_vixen_cpk_art_gate.gd`: an **intentional blocked integration gate** until the precise atlas is imported, size 672x672 and unchanged Sigma animation slot mapping verified.
- No edits to `scripts/solo_run.gd`, kit stats, weapon, Flex timing, RNG, saves or content IDs.

## Exact asset that must still be uploaded

The creator-facing local ZIP `CLUTCHPUNKS_PixelVixen_CleanCut_v1.zip` was prepared separately in the project conversation. Its asset is:

- `assets/production/pixel-vixen/cpk-v1/pixel-vixen-cpk-v1-atlas.png`
- Source SHA-256: `65a724ba088ee15d765bdc8c22b96f28fb50a007d7621eafa7a25f0682a64b24`
- 672x672 RGBA, 49 actual populated 96x96 sprite cells in 7 animation state rows.
- Additional `pixel-vixen-cpk-v1-entry.png` (three visual entry poses) and `manifest.json` under the same path.

**The binary is missing from this GitHub branch** because the current connector cannot stream local PNG bytes. Do not merge this PR or claim the game visually changed until the exact bytes are checked into the feature branch and a native Godot run is verified.

## Art readiness is not yet final

The 49 frames come from manual selection and automated alpha extraction from a *new generated design board*, not an individually creator-approved animation master. The non-pixel-art clean-cut direction is closer to the approved recent hero board, but the automatic masks, frame spacing, 8-direction coverage and character silhouette need visible creator review.

The **Flex row is an honest visual approximation** using other state frames. The actual canonical Sigma Flex **Deadpan Verdict** and its timing remain unchanged; replace this with a separately authored matching Flex animation before declaring final production quality.

## Executed vs outstanding evidence

**Executed outside GitHub:** 49-frame PNG/alpha SHA-256 static test, local integration-patch anchor test, Chromium 144 animation art QA for idle/run/attack/hurt/Flex-proxy/defeat/restart; no JS errors. This is evidence of an **art playback simulation**, not the Godot game.

**NOT EXECUTED:** Godot import/headless validation, actual Godot gameplay victory/loss, renderer capture at real game scale, all four browser targets, final creator artwork and motion approval.

## Completion criteria

1. Import exact PNG + entry frames + manifest to this feature branch and a versioned master to `clutchpunks-art-pipeline`; verify original and derivative source SHA-256.
2. Execute `godot --headless --path . --script res://tests/test_pixel_vixen_cpk_art_gate.gd` plus the existing tests; require a complete normal run.
3. Validate original Sigma unaffected and the female appearance still has the correct weapon/Flex states and result screen.
4. Capture real gameplay in Level Zero, check 48/64/96px readability, motion clarity, alpha edges and any residual generic marks.
5. Obtain creator-specific sprite/art acceptance, then and only then consider the completed production asset. No automatic merge, release or deployment.

**Rollback:** revert the renderer-only patch and remove the exact versioned atlas from this feature branch, preserving the existing V2 source in the game.
