# Level Zero factory-footprint review — follow-up 2026-11-05

**Status:** EXPERIMENTAL / NOT GDD APPROVED. Based on the native recording
`Gravação 2026-11-05 222911.mp4` (creator evidence, 7m11s), with intrusion
near the central printed-paper stack at approximately 05:30.

The original candidate scene image is 1672×941 while the Godot world is
1448×1086. The renderer uses a center-cropped cover fit (source X crop ~209px,
scale ~1.154), so its printed props are NOT inherently physics colliders.

The original experimental polygon was insufficient for the hero's visible
upper-body silhouette: even when their feet stayed on an allowed point,
the character overlapped the poster stacks. This **revises only the
experimental** `world_rules_v1.gd` upper edge by ~60–90 world units,
preserving default Ruin Alley geometry and world size. These values are
review candidates for visual alignment, not new canon.

The player stays at (724, 670). The experimental boss enters at (820, 730),
clear of the upper machinery and both existing covers. Neither enemy HP,
attack timing, warning rules, wave count, weapon choice rate nor RNG seed
are changed.

The factory-only move function now substeps displacement in <=12-unit
segments, preventing long updates from skipping a cover or the floor edge.
The existing deterministic 80-attempt spawn process is unchanged.

## Acceptance checklist
- [ ] Godot factory-footprint contract: top stack, machinery, side edges,
  player spawn and boss spawn; Ruin Alley parity.
- [ ] 16:9 desktop and constrained landscape manual video review.
- [ ] No sprite is drawn visibly inside the center stack when pushing up.
- [ ] No enemy can pass a world limit by taking a fast movement step.
- [ ] Test 3-wave run, boss appearance and default Ruin Alley.

**Rollback:** revert the focused patch/PR; no persistent files or schemas change.
