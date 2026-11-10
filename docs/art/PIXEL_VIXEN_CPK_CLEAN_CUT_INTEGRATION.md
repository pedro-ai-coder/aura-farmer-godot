# Pixel Vixen — CPK Approved Sprite Integration

**Status 2026-11-10:** EXACT APPROVED MASTER PRESERVED IN ART PIPELINE / 49-FRAME GAME ATLAS COMMITTED TO THIS FEATURE BRANCH / NATIVE GAMEPLAY QA PENDING.

> **[Start with the before-and-after review, live PNG previews and verifiable source hashes](PIXEL_VIXEN_BEFORE_AFTER_REVIEW.md).**

## What is now actually in GitHub

- **Art repository**: the creator-approved original `sprite_atlas_da_pixel_vixen_em_ação.png`, preserved byte-for-byte and versioned in `clutchpunks-art-pipeline` (source SHA-256 `5a16816eb51b6ca1d5e3f7f4036064243bd7152d561fdf866c5bd543ca29b490`).
- **Godot branch**: `assets/production/pixel-vixen/cpk-v1/pixel-vixen-cpk-v1-atlas.png`, **49 transparent frames, 96×96 pixels each**, full atlas **672×672**, SHA-256 `4058de734cd81eb29656267bede422756555dbf02d0680f20a91d609f9f05c63`.
- A versioned manifest with hashes, unchanged `sigma` kit, and source lineage. Import/renderer selection in `scripts/approved_visuals.gd` with exact SHA check and existing V2 fallback on mismatch.
- A required GDScript art/kit compatibility gate in `tests/test_pixel_vixen_cpk_art_gate.gd`, called from `scripts/validate.sh`.

## What remains

1. Execute and capture native Godot 4.7.2 CI and visual gameplay. The current development container has no Godot binary; do not mark tests PASS before CI evidence exists.
2. Perform an ordinary female Sigma run with movement, primary ranged attack, XP/upgrades, Flex, hurt, defeat, restart and result screen; verify 49-frame mapping and appearance at gameplay scale.
3. Check the technical derivative's cutout edges and 64-color quantisation, since the creator approved the **original master** and the derivative was made for engine import. Address any specific quality feedback in the same focused PR.
4. Later, produce a separate directional entry animation for the selected-hero Level Zero cinematic. Its absence does not change the existing Sigma game kit.
5. Integrate only after passing validation and a separate creator decision about merging and/or publishing.

**Gameplay rule changes:** NONE. Stable content IDs, V3 kit, RNG, saves and existing enemy/boss rules are preserved.

**Rollback:** revert the cosmetic loader and remove the new atlas file. The original V2 Pixel Vixen art remains unchanged.
