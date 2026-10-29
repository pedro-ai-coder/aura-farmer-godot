# M0 Technical Consolidation — 29 October 2026

**Canonical design:** `docs/GDD.md` V3.0, `main` baseline `6c9697b2c75b8bdfe3d09cc10135e76ff99ae16d`.
**Source reviews:** [PR #80](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/80) (functional UI) and [PR #82](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/82) (navigation, mobile fluency/fullscreen).
**Candidate art:** [PR #81](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/81) and the HUD V2 sources in PR #82.

## Technical improvements preserved

- Reliable real-pointer Quit → STAY and Quit → CONFIRM QUIT, with actual confirmation ownership on the active Clean Cut secondary screen.
- Selected hero poster/selection identity uses the original approved character texture, not a hard-coded Sigma image.
- Blue Shield track with actual shield value, separate from the red HP bar. HP, Shield and all item effects remain unchanged.
- Deterministic cover steering/tangent tolerance with opt-in development diagnostics, no change to speed, attacks, RNG use during movement or enemy behavior contracts.
- Spawn clearance based on actual normal/elite/boss collider radius. Invalid historical large-actor origin samples may consume additional RNG draws; no boss or enemy numeric tuning.
- Existing approved circular joystick sprites update independently of static Clean Cut HUD layout; the candidate HUD V2 is not imported.
- Existing Build panel equipment rows are laid out with readable, scrollable live item data and the canonical three weapon/five passive slots.
- Web browser supports trusted gesture fullscreen attempt, refusal/retry, orientation fallback, iOS Home Screen help, cached safe-area metrics, CSS-sized touch controls and a capped compact-mobile raster DPR. Unsupported browsers can still reject fullscreen.
- Technical regression tests added for pointer Quit/hero/Shield, navigation stress, six-viewport joystick updates and Web platform adapter.

## Explicit candidate-art exclusion

No new asset approval is inferred. **Not imported:** `assets/ui-button-candidates/v1/**` and its 24 button PNGs/authoring SVGs; `assets/ui-hud-candidates/v2/**`, its 20 component SVGs/shaders; `scripts/hero_clash_button_feedback.gd`; `scripts/hero_clash_scene_accent.gd`; alternate animated Flex dial; `scripts/hero_clash_hud.gd`; `scripts/hero_clash_hud_meter.gd`; art-only fixtures and provenance manifests from #81/#82.

The approved 19 original resources, 37 item PNGs and 84 Clean Cut runtime source assets are unchanged. The original source branches remain for creator art review. No gameplay balance, Phaser, backend, Discord Activity, economy, save schema, or public release changes are made.

## Required verification

- `python3 scripts/sync_approved_assets.py`
- `bash scripts/validate.sh` (official Godot 4.7.2, all current regression phases and the new subset)
- `node tests/test_web_platform.cjs`
- `bash scripts/build_web.sh` in a supported environment with official templates
- Compare all modified files to this PR's intended technical scope and verify Web PCK candidate exclusions.

Earlier source-branch **220/220 navigation** and CPU-only joystick metrics must not be represented as new integrated-run evidence until tested again. Normal-health full Web playthrough, physical Pixel 8a/Brave FPS, fullscreen success and creator visual acceptance are still open M0 release gates.

## PR cleanup

Merge only after required checks pass and verify main. Close superseded #80/#82 without merging only if their technical content is reproduced and all candidate art remains retrievable for owner review. Keep #81 open.
