# Approved sprites — visual acceptance iteration

This iteration must make the already-approved Cartoon Arcade sprites clearly visible in the Godot playable preview. The GDD (especially Annex A) is the source of truth. No new or redesigned art, no gameplay-rule changes.

## Baseline findings
- `scripts/approved_visuals.gd` already loads 14 verified PNG assets and renders hero atlases, Ruin Alley, menu art and three enemy sprites.
- Most enemy kinds currently reuse Phone Guy art; collectibles and projectile markers are procedural circles.
- `scripts/solo_run.gd` draws facial circles over approved enemy sprites and cover circles over the illustrated map.
- A READY Vercel deployment only proves the build completed, not that sprites appear correctly in a real browser.

## Visual acceptance checklist
- [ ] Verify asset download, hashes and texture loading in a browser build; never silently fall back to placeholder art when a required approved asset is missing.
- [ ] Show Sigma, Cool Kid and Alpha Chad with approved idle, movement, attack and Flex frames; verify direction and no clipping.
- [ ] Remove procedural facial marks drawn over imported enemy art and review sprite anchors and HP bars.
- [ ] Use the approved Ruin Alley image and menu without obscuring critical art; retain exact collision rules.
- [ ] Map all available approved enemy sprites accurately; for enemies without dedicated approved artwork, record the missing assets explicitly rather than claim completion.
- [ ] Inventory approved collectible/icon assets in Phaser before importing. Do not fabricate collectible sprites or substitute unrelated art.
- [ ] Capture comparable desktop and mobile browser screenshots of hero selection, combat, upgrade menu, Flex, enemy encounter and pickups.
- [ ] Confirm no changes to combat RNG, hitboxes, waves, balance or saves.
- [ ] Run `bash scripts/validate.sh` and confirm the actual CI result before merging.

## Source
- Phaser: `pedro-ai-coder/aura-farmer`, pinned art manifest and GDD Annex A.
- Godot: `assets/approved-assets.json`, `scripts/approved_visuals.gd`, `scripts/solo_run.gd`.
