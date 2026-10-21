# Approved Cartoon Arcade assets for the Godot visual migration

The source of truth for visuals and gameplay remains `docs/GDD.md` (especially Annex A).

Source: `pedro-ai-coder/aura-farmer` at the immutable commit `fdbc67b9d79b1d2bfbbcaad40305da1677bc626f`. **No artwork is generated or redesigned.**

`assets/approved-assets.json` lists the exact source path, intended local destination, byte length, source Git blob ID and the original approved manifest SHA-256 when available. The build script `scripts/sync_approved_assets.py` downloads originals directly from the public repository, verifies their Git blob bytes and their SHA-256 where recorded, and refuses mismatches. These approved image binaries are intentionally not duplicated in Git history; Vercel embeds them in each exported Godot Web build.

The first production art pass includes Ruin Alley, the approved menu image, three approved hero portraits, three approved enemies including Big Hater, three runtime character atlases, rear locomotion frames and Cool Kid's Flex animation.

All visual layers must be passive: never advance RNG or gameplay in draw or presentation methods. Preserve world collision radii and timers; textures must not affect hitboxes. If a hash is wrong or a source URL is unavailable the production build must fail rather than silently fall back to generated art.

**Known limits:** approved enemy sprite atlas animation reconstruction and exact hero art masking require a follow-up comparison against Phaser. Source graphics have not been visually reapproved on real mobile hardware by this PR; this is an integration of the existing approved files. The GDD's art acceptance criteria remain binding.
