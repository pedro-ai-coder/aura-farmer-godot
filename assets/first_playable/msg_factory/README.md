# MSG Factory V4 runtime art

**PROPOSED runtime derivatives for creator review.** The creator approved the V4 direction for this implementation.

- Source package: `msg-factory-v4-review.zip`. The arena and four transparent cover sprites derive from `msg-factory-v4-proposed.png` (SHA-256 `1b05fd40e6d3d126dbe005e08295f112645e85725e9dac787ccdab38d7474026`). The package includes the OpenRaster master and the editable CPK paint layer.
- The four props were cut out of the plate, keyed to their footpoints and depth-sorted alongside actors. The plate was filled behind each cutout. The large CPK stencil comes from the package's paint treatment of the approved identity emblem (decision `CPK-BRAND-2026-11-13-01`). Recessed seams and a pull handle make the stencil-bearing panel read as the factory door.
- The V4 study's boundary and centers were diagram coordinates. The runtime floor follows the visible walls and fixed machinery and the four collider centers register to the extracted sprites. All four cover radii come from the study. The player starts at the scaled V4 center. The eastern Silence Terminal has a factory-specific position clear of the dispatch rack.
- The layout history and shared Solo integration follow [PR #152](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/152) and [PR #153](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/153).

## V4.1 candidate treatment

**PROPOSED.** V4.1 reuses all five V4 textures byte for byte. The plate shader confines print motion and lighting to the existing press and terminal, with quieter floor wear around the machine bases. Existing printed sheets, ink equipment, dispatch racks and the CPK-painted door convey the factory's function. The effects introduce no new marks or narrative content.

The four factory footprints now follow the width and depth of the illustrated bases. The west boundary follows the visible pallet stack. The art anchors, four cover locations, arena bounds, spawn point and existing encounter placements are retained. The footprint corrections affect factory movement and lines of sight, especially around the shoulders of each base. Review those routes on their own merits before accepting the candidate.

Run the Godot collision and navigation checks with `godot --headless --path . --script res://tests/first_playable/test_factory_routes.gd`. Run `godot --path . --script res://tests/first_playable/review_factory.gd -- <absolute-output-dir> stills` for native captures. Use `benchmark` in place of `stills` for the seeded performance fixture. For an automated ordinary opening run, pass `--write-movie <absolute-output.avi> --fixed-fps 30` before the script and use `movie` after the output directory.

## V4 baseline captures

[Map select](../../../tests/first_playable/evidence/map-select.webp) · [Ruin Alley](../../../tests/first_playable/evidence/ruin-alley.webp) · [MSG Factory](../../../tests/first_playable/evidence/msg-factory.webp) · [Factory door and cover detail](../../../tests/first_playable/evidence/msg-factory-door-and-cover.webp)

The detail capture uses the gameplay camera near the northwest door with the HUD hidden. The other captures show the regular UI. Run the scoped smoke check with `godot --headless --path . --script res://tests/first_playable/smoke.gd`. For native screenshots, omit `--headless` and pass an absolute output directory after `--`.
