# Pixel Vixen V2 integration checkpoint — 31 October 2026

**Status: blocked on the exact source PNGs. Not V2-playable or visually validated yet.** Continue the existing [PR #97](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/97), not a competing implementation. [PR #95](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/95) is already corrected to immediate cosmetic variants; its exact documentation head `77408e9b18a0a1e27f97ff76c56b522922ab9fd7` passed CI. No documentation rewrite or new hero kits are needed.

Pixel Vixen remains **`sigma` / No Cap / Deadpan Verdict**, with canonical attributes, collisions, RNG, attacks and progression. Byte Baddie and Block Queen keep their existing `cool-kid` and `alpha` mappings and stay art-gated in this staged implementation. Original approved art, hero IDs and v2 save compatibility are preserved. No merge, production deployment or art approval is granted.

## Source package required

`pixel_vixen_v2_upload_ready.zip` is referenced by the existing PR but is not attached to this execution. GitHub contains the V2 manifest but none of its three PNGs. The exact package must supply:

| Destination under `assets/art-candidates/pixel-vixen/v2/` | Dimensions |
| --- | --- |
| `pixel-vixen-atlas-v2.png` | 896×672; 49 cells, 128×96 |
| `pixel-vixen-portrait-v2.png` | 520×460 illustrated selection portrait |
| `pixel-vixen-hud-v2.png` | 480×320 illustrated HUD portrait |

Exact SHA-256 values remain pinned in the unchanged [V2 manifest](../../assets/art-candidates/pixel-vixen/v2/manifest.json). Do not regenerate approximations, relabel V1, upscale a tiny gameplay cell into a selection portrait, change the expected hashes to accept unrelated bytes, or call missing assets visually approved.

## Corrections completed while the source package is unavailable

- Victory and Run Over now route both **name and portrait through the selected appearance**, preserving canonical `sigma` IDs in results. Previously both used male identity even for a female run. The regression fails against the previous source and passes after the correction.
- Official Web builds now fail before exporting when an expected V2 source is absent, has the wrong hash/header/dimensions, or loses candidate/preview status. After export, the actual PCK must contain all three imported textures and the provenance manifest.
- Every existing export preset explicitly includes the V2 manifest and excludes the superseded V1 source directory. Historical V1 bytes remain retained in Git; there is no fallback or art-registry promotion.
- Existing real-asset Godot tests remain mandatory. The result-routing unit test uses an explicitly test-only texture marker; it is not a female sprite, screenshot, gameplay demonstration or replacement for missing art. Binary-header unit fixtures likewise never ship as assets.

## Actual verification

Official Godot **4.7.2 Compatibility** import passed. Eight executed headless suites passed: appearance result routing (both outcomes), profile store, original hero animation, hero combat, Phaser RNG, secondary input, UI cohesion and irregular-frame state traces. Canonical state hashes remain `b36b9dfab8baef81659ba3040bf90e26ac910b8bd68f1226997116eb54ad03a6` (normal), `645b257d9495b673079e415e60ae4bd7649ee960f65d0061505749e873ea3107` (dense), `63ae00700184c8a1dc5e13a4fb2d6e9f5a25c2156bbd6d672c2ac623b5117311` (Flex). Four Python resource-contract tests passed. Build-script syntax and diff checks passed.

`python3 scripts/verify_pixel_vixen.py` correctly fails on the three missing PNGs. The previous PR head `e774da79b106271c8e575295dd96ba80011a501a` already had failing [CI](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/41239369366) for missing V2 assets. Final-head CI/export status is linked on PR #97; missing-source failure must remain a blocker, never a waived pass. No full V2 runtime capture, animation-quality validation, successful V2 export, new physical test or artistic approval is claimed.

## Resume after the ZIP is attached

Copy the exact three PNGs, verify the pinned hashes, run `python3 scripts/verify_pixel_vixen.py`, full mandatory `scripts/validate.sh`, and the official Web export/PCK checks. Inspect actual Hero Selection, HUD, idle/run/attack/hurt/Flex/defeat, result identity and Retry at desktop/mobile sizes on the protected exact-build preview. Review directional coverage/foot pivots against actual art; do not infer production quality from 49 occupied cells alone. Preserve the original Sigma and wait for the creator's Pixel Vixen review before beginning the next female artwork batch.
