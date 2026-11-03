# Self-contained approved art migration — PROPOSED

**Status:** Unmerged infrastructure proposal, requires creator approval.
This does not alter the game's approved visual content or any GDD decision.

## Problem

Historically, the Godot Web build downloaded 19 original PNGs from a pinned
commit in the separate Phaser repository. Archiving or privatizing that repo
breaks otherwise unrelated Godot builds. That is an unacceptable operational
coupling.

## Target invariant

Every original approved PNG is a **tracked binary in this Godot repository**.
`scripts/sync_approved_assets.py` verifies the locally committed bytes
against `assets/approved-assets.json` (byte length, Git blob SHA-1, SHA-256).
Normal builds have **zero Phaser fetches**. The manifest retains historic
Phaser source paths and commit SHA as provenance, not a dependency.

Art ownership and future approvals remain governed by the art-production
repository and the creator. Only runtime-approved, immutable snapshots are
vendored into the runtime repo. This is not permission to change existing art.

## Migration procedure (one time only, no public repository needed)

Run with GitHub CLI already authenticated to both private repositories:

```sh
gh repo clone pedro-ai-coder/aura-farmer phaser-pinned-art
git -C phaser-pinned-art checkout fdbc67b9d79b1d2bfbbcaad40305da1677bc626f

gh repo clone pedro-ai-coder/aura-farmer-godot clutchpunks-godot
cd clutchpunks-godot
git checkout build/vendor-approved-art
python3 scripts/sync_approved_assets.py --import-from ../phaser-pinned-art
python3 scripts/sync_approved_assets.py
git add assets/approved
git commit -m "build(assets): finish self-contained original art snapshot"
git push origin build/vendor-approved-art
```

The importer refuses incorrect bytes, so neither the latest state of Phaser
nor an inaccessible URL can silently change the approved asset snapshot.

Do not check in GitHub credentials or use a privileged token in CI.
Delete the temporary local Phaser checkout once the migration is complete.

## Build/QA acceptance

1. Every manifest destination is present in a fresh Godot checkout.
2. All 19 Git blobs and SHA-256 checks match the original approved manifest.
3. Normal Vercel Web export succeeds with Phaser private/archived and no
   authenticated Phaser access in the build environment.
4. Normal save, RNG, visuals, and gameplay regression tests pass.
5. No production merge/deploy without creator authorization.
6. QA PRs #103, #105, and #106 are rebased/updated only after this PR is
   approved; temporary preview branches must not be treated as canonical.

Rollback: leave the PR unmerged. Existing main builds are unaffected.

## Current partial import status

The assistant recovered 11 exact objects already accessible in the Godot Git
object store. The eight remaining source blobs are larger than the connected
GitHub file-content API's inline response limit and require the one-time local
import above:

- `main-menu.png`
- `sigma-atlas.png`
- `cool-kid-atlas.png`
- `alpha-atlas.png`
- `cool-kid-flex-v2.png`
- `cool-kid-rear-v2.png`
- `alpha-rear-v2.png`
- `enemies.png`

**Do not claim build success until these eight original files are committed.**
