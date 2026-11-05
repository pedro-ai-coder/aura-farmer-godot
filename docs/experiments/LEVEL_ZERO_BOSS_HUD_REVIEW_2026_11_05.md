# Level Zero — Boss and HUD readability after first complete private run

**Status:** EXPERIMENTAL (not a GDD V4 approval or art acceptance).

Review evidence: creator-provided `Gravação 2026-11-05 222911.mp4`,
approximately 7m11s; Level Zero completed, Hater Imitation defeated.

## Focused presentation changes

- Use the **same original Hater Imitation candidate sprite** already staged for
  the experimental boss world sprite as its Clean Cut HUD portrait. This is
  not a new graphic or approved standalone atlas.
- Normal Ruin Alley still resolves its portrait from the approved enemy atlas.
- The results screen uses `wave_count()` rather than hardcoded five, showing
  **3 / 3** in Level Zero and retaining **5 / 5** in normal runs.
- The optional spotlight status also uses the scene's actual wave count.
- The native FLEX hover tooltip is suppressed **only for Level Zero**,
  because its gameplay HUD already renders the ability label/readiness and
  the tooltip may obscure the bottom equipment strip on desktop.

The factory-footprint boss entrance is handled separately in PR #113, based
on visual evidence and with its own geometry tests.

## Deliberately unchanged pending creator design approval

- Boss HP 2400, attacks, warning windows, wave duration, RNG and difficulty.
- Offer cadence, XP quantities, item pool and pause-on-choice semantics.
- Any canonical art, boss identity, equipment effect, save or monetization.

The 10-second boss defeat and frequent level-up choice interruptions should
be assessed in a **separate PROPOSED balance/UX experiment** using real
playthrough samples before changing any GDD values.

## Acceptance and rollback

- Godot native: Level Zero 3/3 results, FLEX tooltip absent, Hater Imitation
  portrait resolves; normal Ruin Alley portrait/5-wave results unchanged.
- Web: 1920×1080, 1280×720 and 915×412; check boss name legibility,
  placement relative to the hero, bottom equipment strip and input focus.
- No changes to game simulation or profile writes.
- Revert this focused commit to recover prior presentation behavior.

**No merge, canon promotion or production publication.**
