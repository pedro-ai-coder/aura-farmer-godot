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
| UpgradeCard / LegendaryCard | spotlight_offer_card.gd + arcade_presentation.gd, legal data and V5 hierarchy; illustration incomplete |
| InkPanel / ModalShell / IconSlot | spotlight_components.gd; unsigned art remains absent |
| StatusPlate / WaveBanner / FlexIndicator | spotlight_hud.gd, authoritative simulation state |
| FocusOutline | arcade_theme.gd and solo_run.gd navigation |

## Normal-health survival

Eight deterministic observations without HP/Aura/level grants or early boss spawning. Raw source damage, recovery, XP and wave observations: [V5_SURVIVAL_RUNS.json](V5_SURVIVAL_RUNS.json). All eight historical avoidance/aim-controller observations ended in defeat before Big Hater. Later #55/#56 strategic-controller trials supersede any categorical boss-unreachability claim; see the update below.

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

## G3.6 follow-up

The reattached PDF is available again and matches the prior hash. The live offer-card hierarchy now has direct [V5 comparison evidence](art/V5_PARITY.md#g36--live-offer-card-composition), desktop/compact/portrait captures and longest-text coverage; all 38 local phases pass. Illustrations still require the separate signed handoff archive. This improves phase 2 without changing offer ordering, RNG, combat or balance acceptance. Production #53 was independently verified at commit `059e78dd2e468e79043dd6b34e4ca727fa6b6ce1` before this increment.

## Current upstream survival evidence and G3.7

While the signature-help increment was in progress, #55/#56 integrated a review-only strategic controller and six raw normal-health trials. The [strategic evidence report](SURVIVAL_STRATEGIC_EVIDENCE.md) records Sigma seed 451 winning at 674.72 s, Alpha seed 452 entering the boss and losing at 810.82 s after Berserk, and four defeats before boss. Cool Kid reached neither boss in these two seeds. These are legal scripted strategy observations, not human win-rate or overall balance acceptance. No approved gameplay statistics changed. Issue #52 remains open.

Hero selection now exposes concise current §7.2 Flex help on all three cards, with authoritative names/durations and original identities; obsolete Cool Kid Rampage copy is removed. [Native viewport evidence](art/V5_PARITY.md#g37--current-signature-explanations) includes compact scrolling and fixed START/BACK. The complete 39-phase local Godot validation suite passes against upstream `3c963bf034cb332bc3fb90cb64a5131a2c7c4937`; required CI and owner/device/art gates remain distinct. Signed standalone artwork remains the next art dependency (#49).

## Private Web Alpha — GDD legendary support-shield audit

Restart audited main `7fcd007`, no open PRs, current GDD/production references and #49/#52. Reproduced five GDD-expectation failures: Unbothered and My Aura support shields incorrectly inherited rarity 2.60. Restored §8.2 HP × support formulas while retaining own Cope Shield rarity scaling, support modifiers, expiry/pause and the global shield cap. All 39 local Godot phases pass; native controlled-attack captures are recorded. This is an existing-GDD implementation correction, not new balance tuning. See [WEB_ALPHA_ACCEPTANCE.md](WEB_ALPHA_ACCEPTANCE.md) for the 24 distinct release gates and exact before/after values. Historical survival data is pre-correction; rerun 451/452 and 453–456 next. Standalone art #49, full interaction audit, current WebGL2, human balance and physical-device gates remain open.

## Private Web Alpha — 18 post-correction survival observations

Merged gameplay correction #58 is verified at `a60f574cdab72b425eec93faa43321e123eb5e94` in production. Repeated all three heroes at 451/452 and added 453–456: 18 real normal-health strategic episodes, two Sigma wins, three Alpha boss losses, no Cool Kid boss entry. Five unaffected historical episodes preserve time/kills/level/healing/Flex/equipment/recovery exactly; Alpha 452 now loses at 772.30 s after the GDD shield correction. Full source-hashed data, real event completion and equipment snapshots are in [WEB_ALPHA_SURVIVAL_EVIDENCE.md](WEB_ALPHA_SURVIVAL_EVIDENCE.md). Review-only observers preserve actual HP/Aura/RNG/kills/drops; all 39 local phases pass. No balance values, artwork, production mechanics or backend were added. #52 stays open for broader/human and isolated attack-policy validation; #49 and current browser/device/performance gates remain separate.

## GDD Chad Hands late-slam correction

A controlled legal Alpha fixture reproduces two §8/§8.2 defects when the opening punch misses and the delayed second punch is the third successful activation. The current area dictionary was appended twice to a temporary list, applying the slam multiplier twice. Resolving the transformation inside the damage loop also skipped outer targets visited before the first close hit. At P=90/common, the same setup caused 65.45 damage and either zero or 65.45 to the outer target depending on array order, rather than the specified 0.40P = 36 each.

Successful activation is now determined using the unchanged eligible geometry before damage recipients are visited. Each existing delayed area is transformed once. Normal/legendary coefficients remain 0.40P / 0.60P×R, radii remain 110/140 U, and the second hit remains at 0.18 s. Shared hit memory, one proc/Aura event, pause and lifecycle remain intact. Common/legendary and reversed-order regressions fail before and pass after; all 39 local Godot phases pass. No canonical tuning values or GDD text are changed.

[Actual native controlled late-slam capture](art/evidence/web-alpha/chad_slam.jpg) uses original artwork and the real attack/HUD code. This is not a normal-health run or artistic/device acceptance. `tests/capture_review.gd -- 1280 720 OUTPUT --state=chad_slam` reproduces only that fixture. The prior 18-run data is explicitly the earlier post-shield source; repeat the same full matrix after this new gameplay correction before presenting current survival acceptance. #49/#52 and browser/human/device gates remain open.

## Current post-Chad validation checkpoint

Completed the full 18-episode 451–456 / three-hero repeat after the late-slam correction. [Current raw results](WEB_ALPHA_CHAD_SURVIVAL_RUNS.json) pin the exact PR #61 core revision/hash; [comparison](WEB_ALPHA_SURVIVAL_EVIDENCE.md#current-repeat-after-the-chad-hands-correction) preserves the prior 18 separately. All 12 ranged/melee episodes reproduce key outcomes exactly. Alpha 452 now loses at 568.40 s before boss; Alpha 455/456 still reach the boss and lose. Sigma wins 451/455; Cool Kid reaches no boss. No broader balance/human acceptance follows.

Concurrent art-only main updates `dca1a758` / `4e0a4f7` add candidate icon sources, not approved runtime art. Preflight verified all 83 manifest file hashes (40 PNG, 37 SVG, six WEBP), PNG dimensions/transparent alpha and the nine weapon / 28 passive ID mapping. Approval remains PRODUCTION_CANDIDATE, Touch Grass v2 has no matching SVG, and actual Godot 32/64-pixel icon acceptance is pending. No candidate is wired to the active UI. The available cloud browser was reopened: its visible loader again reports missing WebGL2; interactive-browser acceptance is not claimed. Its observed loader referenced `game-dca1a7586545.js`; independently fetched production HTML subsequently referenced `game-4e0a4f7eff8b` during automatic deployment.


## Candidate art resource isolation

The #60 candidate library is available for review but remains individually unapproved. An actual production-pack inspection reproduced accidental inclusion through all-resource export. A `.gdignore` exclusion and engine resource regression isolate candidates without activating them. See [candidate isolation evidence](art/CANDIDATE_ART_ISOLATION.md); rendered 32/64px and creator acceptance remain pending.
