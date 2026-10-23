> **Current update — 24 October 2026:** The creator explicitly approves 37 exact PNGs: eight V5 weapons, 28 V5 passives and Touch Grass Clean Cut v2. Clean Cut is the selected visual refinement recorded in GDD §26. All selected copies are hash-verified and promoted; 32 current items use live bindings, five future-only passive artworks remain unoffered. See `docs/art/CREATOR_ICON_APPROVAL_2026-10-24.md` and `docs/art/CLEAN_CUT_INTEGRATION_ACCEPTANCE.md`. Earlier zero-approval/blocked statements below are historical checkpoints. Original source isolation and all gameplay rules remain intact.

# Approved Cartoon Arcade assets for the Godot visual migration

The source of truth for visuals and gameplay remains `docs/GDD.md` (especially Annex A).

Source: `pedro-ai-coder/aura-farmer` at the immutable commit `fdbc67b9d79b1d2bfbbcaad40305da1677bc626f`. **No artwork is generated or redesigned.**

`assets/approved-assets.json` lists the exact source path, intended local destination, byte length, source Git blob ID and the original approved manifest SHA-256 when available. The build script `scripts/sync_approved_assets.py` downloads originals directly from the public repository, verifies their Git blob bytes and their SHA-256 where recorded, and refuses mismatches. These approved image binaries are intentionally not duplicated in Git history; Vercel embeds them in each exported Godot Web build.

The first production art pass includes Ruin Alley, the approved menu image, three approved hero portraits, three approved enemies including Big Hater, three runtime character atlases, rear locomotion frames and Cool Kid's Flex animation.

All visual layers must be passive: never advance RNG or gameplay in draw or presentation methods. Preserve world collision radii and timers; textures must not affect hitboxes. If a hash is wrong or a source URL is unavailable the production build must fail rather than silently fall back to generated art.

**Known limits:** approved enemy sprite atlas animation reconstruction and exact hero art masking require a follow-up comparison against Phaser. Source graphics have not been visually reapproved on real mobile hardware by this PR; this is an integration of the existing approved files. The GDD's art acceptance criteria remain binding.


## G4.1 approved icon pipeline and safe live bindings

The source audit is integrated through #64. A separate approval ledger, immutable hashed PNG promotion, category-aware cached registry and automatic actual-PCK export guard now prepare live offer/legendary/replacement, build and HUD bindings. Eleven Python regressions and a Godot registry phase supplement the existing suite. All 40 actual before/after fallback captures are pixel-identical; compact viewport one-pixel rounding is recorded. See `docs/art/APPROVED_ICON_PIPELINE.md`. Counts remain 37 audited, 0 creator-approved, 0 promoted, 0 illustrated items accepted in live UI. Creator decisions, approved-icon visual/performance evidence and device/browser gates remain pending; gameplay/23-passive scope are unchanged.
