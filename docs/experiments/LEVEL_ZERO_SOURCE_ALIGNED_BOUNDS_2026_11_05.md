# EXPERIMENTAL Level Zero — image-space factory floor review

**Status:** PROPOSED geometry adjustment for EXPERIMENTAL Level Zero only;
NOT a GDD V3/V4 approval and not a final artistically approved level.

## Trigger

Creator feedback from `20261105-2256-25.4511700.mp4`, a 50.93-second
recording of the private 2026-11-05 Level Zero preview: the player is exploring
the printed-paper walls and lateral open floor. Previous PRs #112 and #113 used
hand-chosen WORLD-space vertices (1448×1086), even though the **original
factory backdrop is 1672×941 and center-cover cropped** into that world.
The prior polygon left visually open floor unavailable, particularly near
the props and at the lateral camera edges.

## Scope

- Store candidate foot-level boundary landmarks **in original PNG pixel
  coordinates** (20 vertices). The level's walkable-foot polygon is
  deterministically projected into the actual gameplay coordinates by the
  same `VisualAssets.cover_rect()` transform that renders the background.
- Move only the experimental top/lateral collision limits; the paper stacks,
  presses and walls remain blocked at the specified regression probes.
  The in-game crates continue to use the inherited V3 cover collision.
- Preserve axis-separated movement, substeps, enemy steering, RNG draw counts,
  enemy stats, timers, hero/Imitation spawn, XP, saves and UI.
- Add a **strictly opt-in diagnostic overlay** for creator/art QA:
  `?level_zero=1&lz_bounds_debug=1`, orange line with vertex pins and
  translucent walkable-floor region. The default Level Zero URL remains
  clean; normal Ruin Alley never uses the diagnostic.
- Keep the Git-triggered Vercel build disabled on this draft branch; any
  private preview must be deployed explicitly with creator authorization.

## Tests and acceptance

The existing `tests/test_level_zero_factory_bounds.gd` gains:
exact crop correspondence, source/world vertex synchronization, lateral
accessibility, machinery/paper-stack exclusion, no cover tunnelling, and
the diagnostic-default-off check. These tests are necessary but **not
equivalent to a browser visual review**.

Validate at 1280×720 and 1920×1080 and with the diagnostic overlay; compare
the orange edge against the actual poster piles, printing press, fences and
player feet. Check enemy spawns, high-speed movement, camera corners and
normal Ruin Alley separately. Record any further coordinate corrections
as **candidate refinements**, not changes to approved canon.

## Risk and rollback

The previous, over-conservative polygon blocked (1400,600) even though
that point is still visually open floor. The revised experimental
polygon opens it while preserving collision at the actual right edge
(1442,600). Risks: actor-sprite upper-body overlap, and navigation paths
near a concave image edge. Roll back the single focused geometry/diagnostic
commit to recover PR #114 behavior. No persistent schema migrates.
