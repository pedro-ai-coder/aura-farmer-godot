# Combat feedback and phase reward recovery

## Implemented source

Runtime: `ef089759553ec3691b5bbf2e72d958908b05c3b2`, tree `8d3d108b01b84b0f527cf74044909b1a5054a6c9`.
Comparison baseline: `dbe71a62660aedca9113aae2f609bf8f059c2cb1`.
PR #73 remains draft. This is not M0 acceptance.

- Successful damage, enemy defeat and XP collection now produce bounded presentation feedback. The queue is capped at 64, follows simulation time, freezes with pause and clears on restart. Zero damage creates no impact. Feedback does not consume gameplay RNG.
- Area weapon visuals follow emitted radius, arc and facing. Hostile projectiles render above friendly feedback. Approved enemy frames gain brief impact/death presentation; reduced motion disables stretching.
- GDD V3 §5.4 / R12 is implemented: transitions at 2/4/6/8 minutes spawn a collectible 80/120/160/200 XP crystal instead of directly granting XP. Collection grants the reward once, including through Aura Magnet. Deterministic placement checks 16 directions at 96 units against walkability and line clearance, with a player-position fallback. The 96-unit placement is an implementation choice, not a new reward or balance rule.
- HP display rounds both current and maximum consistently: 129.6/129.6 displays 130/130 without modifying health. Equipment icons and reward-card art are larger; names retain full tooltips. Wave/time uses one readable line. Reward focus/hover animation respects reduced motion.
- Approved source artwork, damage values, enemy AI, movement speed and spawn rules were not changed by this runtime commit.

## Reconfirmed durable validation

[GitHub Actions run 40373810656](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/40373810656) completed successfully on the runtime revision. Its logs were fetched again after session resumption: **48 Godot phases**, **11 Python tests**, Node platform checks. [Selected validation log lines](evidence/combat-recovery/ci-validation-excerpts.log) retain phase headings and results; this is an excerpt, not the complete CI log.

The new combat regression covers actual damage, zero damage, pause, death collision removal, bounded effects, RNG preservation, expiry, restart, fractional HP presentation, low-magnitude movement placement and magnet collection. Existing progression/clock/acceptance tests now require collection before phase XP is credited.

GitHub also reports successful Vercel status for this runtime. Deployment success is not evidence of interactive Web play.

## Previous local observations and evidence availability

The previous execution produced a Web export and inspected its PCK: 31,860,160 bytes, SHA-256 `a09a894dd6e0fa22acdd5f1ba8f46027ca56593c85fd427fa1bfade8f9aed21a`, 379 entries, 19 approved masters, 37 icons, 84 Clean Cut resources and no candidate/test entries. These results were recorded in the session; the local export/log files were removed when the workspace reset and are not attached here.

Native staged desktop/portrait captures and two controlled nine-weapon reels were generated previously. They were not published before the workspace reset and are **not available as review evidence in this checkpoint**. The committed `tests/record_combat_recovery.gd` makes the controlled reel reproducible; it is not an ordinary human run.

A sequential seven-scene native software-rendering diagnostic previously recorded mixed frame times (dense-scene mean 17.90 → 17.41 ms, but most other scene means increased and boss P99 reached 114.44 ms). Raw results were lost with the workspace. These observations do not establish a performance improvement; repeat and retain raw measurements before using them for acceptance. An earlier pair overlapping video encoding was invalid and excluded.

Existing images and measurements in [the earlier UI report](M0_UI_VALIDATION_REPORT.md) remain historical evidence for their explicitly pinned sources, not screenshots or performance measurements of this runtime. Its scripted survival outcome must not be reused as a current-run result after the phase XP correction.

## Remaining acceptance work

- Regenerate and publish source-pinned before/after screenshots, controlled reels and raw performance data.
- Run and record normal gameplay on the current source; obtain creator review of combat feel, dense-scene hierarchy, weapon/Flex states and visual composition.
- Complete interactive WebGL2 and physical-device multitouch/performance QA. The previous Vercel permission obstacle was resolved during the session; the observed cloud-browser blocker was unavailable WebGL2, not the historical metadata 403.
- Review actual approved audio coverage and final presentation.
- Obtain creator acceptance before changing draft status, merging or releasing.

Green CI, native staging and export success do not close these gates. No merge or public release was performed.
