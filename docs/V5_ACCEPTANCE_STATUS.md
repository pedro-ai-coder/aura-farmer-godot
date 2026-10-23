# Hero Spotlight V5 implementation and acceptance status

23 October 2026. Engineering progress is substantial; full V5 visual, normal-health survival and physical-device acceptance remain open. The complete GDD remains authoritative. No HP, damage, XP, drop, schedule, Flex or equipment-limit values changed.

## Integrated milestones

| PR | Scope |
| --- | --- |
| #46 | Actual 22-composition PDF audit, asset inventory, native baseline and parity matrix |
| #47 | Licensed Inter fonts, semantic theme, reusable components and focus/card states |
| #48 | Separate live home and three-hero selection, responsive navigation |
| #50 | Compact simulation-driven HUD, boss plate, wave/Berserk feedback |
| #51 | Pause, build, settings/master volume, quit, victory and defeat |

Latest QA fixes reproduce and repair two real failures: fresh HEROES/Settings could render before a hero existed, and global Enter handling swallowed focused card selection. Empty-hero backdrop/text guards and two-step focused selection/confirmation have regression coverage. The local official Godot 4.7.2 validation suite passed all 38 phases, including pushed keyboard events and fresh boot. Native staged recording after these fixes emitted no script errors.

## Reusable live component map

| Required role | Implementation |
| --- | --- |
| Primary / Secondary action | spotlight_components.gd and arcade_theme.gd |
| HeroCard | spotlight_home.gd, authoritative hero definitions |
| UpgradeCard / LegendaryCard | arcade_presentation.gd, legal offer data; illustration incomplete |
| InkPanel / ModalShell / IconSlot | spotlight_components.gd; unsigned art remains absent |
| StatusPlate / WaveBanner / FlexIndicator | spotlight_hud.gd, authoritative simulation state |
| FocusOutline | arcade_theme.gd and solo_run.gd navigation |

## Normal-health survival

Eight deterministic observations without HP/Aura/level grants or early boss spawning. Raw source damage, recovery, XP and wave observations: [V5_SURVIVAL_RUNS.json](V5_SURVIVAL_RUNS.json). All ended in defeat before Big Hater.

| Hero | Seed | Controller | Survival seconds | Level | Kills |
| --- | ---: | --- | ---: | ---: | ---: |
| sigma | 451 | avoidance | 431.67 | 20 | 453 |
| cool-kid | 451 | avoidance | 303.62 | 15 | 281 |
| alpha | 451 | avoidance | 446.32 | 20 | 490 |
| sigma | 452 | avoidance | 282.10 | 14 | 267 |
| cool-kid | 452 | avoidance | 362.38 | 17 | 341 |
| alpha | 452 | avoidance | 450.02 | 20 | 537 |
| cool-kid | 451 | aim-flex | 259.85 | 13 | 267 |
| cool-kid | 452 | aim-flex | 216.38 | 12 | 200 |

The three seed-451 avoidance results exactly preserve the earlier FLEX_V2_RUNS baseline for survival seconds, kills, level, healing, Flex count, equipment and recovery. Presentation changes did not alter that deterministic baseline. Ranged/event/hazard damage is material: Sigma 451 loses 67.68 HP to Ping Sniper and 63.554 to Doomscroller hazards; Alpha 451 loses 256.38 HP to Hater and 138.62 to Ping Sniper, in addition to shield absorption. Sigma reaches level 7/13/18 at successive 120/240/360-second boundaries. These samples do not establish broad XP scarcity.

Cool Kid's original avoidance controller records zero secondary Flex damage; aiming during active/ready Flex produces about 159/163 secondary damage but shorter survival. That is controller sensitivity, not proof of a weak or broken kit. Human boss viability remains unestablished. [Issue #52](https://github.com/pedro-ai-coder/aura-farmer-godot/issues/52) tracks investigation. Numeric revisions require a separate GDD proposal and explicit approval.

## Actual rendered evidence and performance

The [22-row matrix](art/V5_PARITY.md) links real native screenshots, including 915×412 pointer emulation and portrait fallbacks. All comparisons remain partial; owner artistic acceptance is open. [Staged native reel](art/evidence/v5-review/staged-native-review.mp4) is a 37.5-second fixed-30-FPS review recording, compressed to 960×540. Reproduction: tests/record_v5_review.gd. It intentionally grants Aura, uses a stationary high-HP target and advances clocks. It is neither a normal run nor an FPS benchmark.

Rendered profiling used Compatibility, X11, Mesa llvmpipe LLVM 20.1.2 software rendering and Dummy audio. Each fixture has 240 frames, 40 warm-up frames excluded; raw cold maxima and counts remain in [V5_RENDER_PROFILE.json](V5_RENDER_PROFILE.json). Protected player and suppressed XP collection make this a workload fixture, not survival evidence. The sandbox was shared with other QA work; CPU identification was unavailable. These are observations, not a controlled before/after comparison or physical hardware acceptance.

| Enemies / friendly projectiles | Mean frame ms | P95 ms | Frames >33 ms / 200 |
| --- | ---: | ---: | ---: |
| 30 / 15 | 22.55 | 31.06 | 6 |
| 100 / 50 | 27.69 | 34.11 | 14 |
| 300 / 150 | 62.29 | 73.90 | 200 |

The 300-enemy stress fixture exceeds the normal 100-enemy cap. Projectile processing is a candidate for separately measured optimization while preserving collision ordering. No 60/30-FPS hardware target is declared passed.

The actual production URL was opened in the available cloud browser. Its runtime reported missing WebGL2; interactive Web acceptance is blocked in that browser. Native renders and successful Web builds do not substitute for a working WebGL2 browser. No Android/iOS physical-device, orientation, safe-area, audible playback or native publishing acceptance is claimed.

## Resume priorities and gates

1. Obtain the missing signed V5 handoff archive: isolated illustrated logo/clean plate, nine weapon and 28 passive PNG/SVG pairs, dedicated signature exports. [Issue #49](https://github.com/pedro-ai-coder/aura-farmer-godot/issues/49) records the gate. Existing 19 approved original PNG masters are verified; PDF compositions are never shipping art exports.
2. Finish illustrated offer/build cards, pickup and enemy/animation visual comparisons after approved exports arrive. Preserve the 23 offered passive subset and nine weapon identities.
3. Complete fine-grained audio/settings and effect help, then owner review against all 22 actual compositions. Master bus persistence exists; separate music/SFX buses and audible playback are not accepted.
4. Run actual WebGL2 and physical Android/iOS acceptance. Native pointer emulation is separate evidence.
5. Investigate #52 with better controller/recovery routing and human normal-health runs before proposing GDD balance revisions. Do not enable prototype P4–P7 mechanics.

Phases 0–2 and 4 have integrated engineering increments; illustrated completeness remains gated. Phase 3 is partial. Phase 5 has responsive architecture/emulation coverage but no physical acceptance. Phase 6 has regression, render and survival evidence, with explicit remaining failures. This document and the parity matrix are the durable restart point.
