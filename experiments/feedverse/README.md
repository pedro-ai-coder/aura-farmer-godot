# Feedverse map production candidates

Source: `aura-farmer-godot` baseline `2f7cfab5d0b498a2d7dade97ec1adf38e58fda50`; original recovered commit `b8740e7811d3d8caf607174091230e177ecf21fd` is retained as this branch's first commit. The six original `.tscn` files and `maps.json` are preserved. Original input archive and patch are separately held by the creator.

## Launch

Open any `experiments/feedverse/maps/<region>.tscn` to inspect the environment and move the marker with WASD or arrows. Bracket keys switch through the six scenes using the original viewer. For an opt-in Solo combat preview, launch `experiments/feedverse/maps/<region>_combat.tscn` directly. These six scenes reuse the existing Solo controller, approved character/enemy/weapon rendering, combat, HUD and camera. They start Sigma and use the original polygon, four covers and spawn data for each map. The live Garage and default Ruin Alley scenes are unchanged.

The preview maps have no campaign selector, save progression or approved encounter assignment. The combat subclass suppresses profile writes. New map rules are supplied only to these opt-in scenes; regular Solo retains `SoloWorldRules` by default. The map data does not change spawn timing, enemy catalog, weapon values, boss rules or RNG algorithm. Different geometry can alter rejection counts in existing spawn sampling, so exact RNG consumption across maps is not claimed to match Ruin Alley.

## Art and provenance

`environment_art.gd` is a reusable, code-drawn candidate kit: shared city backdrop, readable ground, perimeter, modular panels and region-specific props. The six treatments follow the *proposed* profiles in Feedverse World Bible V1.0 (`clutchpunks-canon` PR #46, head `512d34f92180797fc994120eacf3c58c9665c4ec`): factory presses, broken valley bridges, moderation booths, rail platforms, subsurface server banks and the central broadcast citadel. These details are noninteractive scenery. They do not create hazards, powers or canon. Brand colors follow the approved CPK palette; the preview banner uses the existing exact production emblem and Inter font. Solo combat scenes reuse existing approved actor art. No third-party or newly generated binary art was added.

**Status: PROPOSED environment artwork and map integration. Creator visual approval is pending.** The restored graybox commit remains separately accessible in Git history; the completed branch does not claim production map approval.

## Previews and minimal checks

Run `godot --path . --script res://experiments/feedverse/capture_maps.gd` on a desktop renderer to generate six 1280×720 overview PNGs in `evidence/feedverse/maps/`. Headless mode has no frame draw signal for captures. Run `godot --headless --path . --script res://experiments/feedverse/smoke_maps.gd` for a minimal scene, spawn and movement check. This is not a dedicated QA suite or proof of complete campaign balance. Godot version used: official `4.7.2.stable.official.ed1daf0bf`.

The six original previews and six Solo scenes load. The default Ruin Alley scene has not been modified. Full normal-run, target-device, performance and creator visual acceptance are still pending.
