# Level Zero print-factory arena boundary correction

**Status:** EXPERIMENTAL / PROPOSED / not a canonical GDD change

## Verified issue
The creator supplied `20261105-2211-35.7040069.mp4` on 2026-11-05.
Gameplay footage shows Sigma walking on top of the printed-message
machine/stack geometry. The original V3 Ruin Alley floor polygon was still
in use even when the Level Zero art renderer had changed the background.

## Focused fix
- `solo_run.gd` delegates floor movement, LOS, spawn and walkability via
  four hooks whose default implementations are exactly the V3 Ruin Alley
  static world rules. No production geometry or content changes.
- Only `level_zero_run.gd` overrides those hooks, using
  `world_rules_v1.gd`, with a hand-traced polygon aligning the new
  1672×941 source art's center-cropped presentation within the existing
  1448×1086 field.
- Stage-specific provisional start and boss positions are inside the
  walkable candidate polygon, so neither begins inside the print press.
- Enemy sampling rectangle, maximum attempts, RNG source and cover
  geometry follow the existing V3 code. Candidate floor rejections may
  change the Level Zero random draw sequence, but remain deterministic.
- Camera world size, saves, IDs, artwork, encounter clock and attacks do
  not change. Normal Ruin Alley continues to use its original world rules.

## Tests and actual limitations
- Numeric polygon validity, spawn centers, top machinery exclusion and
  side boundary were checked offline against source art.
- A targeted Godot contract test now checks isolated factory bounds,
  no normal-world regression and valid player/boss starts.
- Full Godot import, complete gameplay and WebGL2 human rendering remain
  to be validated on the draft branch, not automatically approved.
- Candidate polygon points are visual-review placements, not canonical
  approved gameplay numbers. Edge alignment at mobile viewport and
  enemy navigation requires creator acceptance.

## Rollback
Revert this focused branch/commit. No save schema or geometry migration.
