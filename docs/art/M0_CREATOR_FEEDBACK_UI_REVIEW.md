# M0 Creator UI Feedback — Bugfix / Presentation Review

Date: 2026-10-28
Status: Draft review only. GDD V3.0 remains source of truth.

## Evidence and problem statement

The creator-supplied 89-second Godot gameplay capture demonstrates the small
top-left HP/shield cluster, the Pause screen and the Quit Run control, plus
ordinary gameplay, equipment and reward selection. The creator separately
reports that Quit is not working and that the selected hero does not appear.
Those reported bugs are treated as real acceptance blockers even where the
video alone does not isolate the internal failure.

## Changes

- Canonical two-step Quit Run confirmation: dedicated visible CONFIRM QUIT
  and STAY actions, stable ownership of the active modal button to prevent
  held-pointer state loss. Do not silently abandon a run.
- Live selected hero art in the menu and selection, not hard-coded Sigma.
  Existing approved hero sources and gameplay hero rendering remain intact.
- Independent Shield track, blue live fill and numeric display under red HP;
  shield cap rules, damage absorption and values are unchanged.
- Embossed button affordances and actual press/release animation on original
  signal-bound controls; no new hit targets and no rerouted mouse/touch input.
- Slow non-flashing gold READY ring and tactile feedback on circular Flex,
  gated by real Aura state. Reduced Motion disables continuous pulse.
- No gameplay RNG, damage, cooldown, weapon, character speed, backend,
  Phaser, or profile format changes.

## Verification required

Use held-pointer Quit → STAY and Quit → CONFIRM QUIT → Menu checks at
1280x720, 915x412 and 390x844. Check chosen character identity, Shield
separation and live ratios, ready ring and Reduced Motion. Render native
screens at 1920x1080, 1600x900, 1280x720, 915x412, 844x390 and 390x844.
Check physical Web/touch interactions separately before creator approval.

PR must remain Draft. Do not merge or release automatically.
