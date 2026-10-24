> **Creator-approved Clean Cut V2 five-screen runtime integration — 24 October 2026 (PR #71):** The owner explicitly approved the exact corrected artwork of PR #69. The approval is recorded in `docs/art/CREATOR_CLEAN_CUT_V2_APPROVAL_2026-10-24.md`; `assets/runtime-clean-cut/v2/manifest.json` pins 84 reviewed standalone source hashes. A production-bound Godot skin now replaces the isolated-only presentation for Main Menu, Hero Selection, Gameplay HUD, normal upgrades and legendary selection. Approved 37 PNG icons and canonical gameplay remain unchanged. PR #71 is under full validation; until CI, final Web PCK and production deployment are verified, this is **implementation in review**, not published browser or mobile acceptance. Earlier candidate-only entries below are historical checkpoints. Browser WebGL2, physical Android/iOS, 22-screen parity and issue #52 balance acceptance remain separate.

> **Clean Cut correction intake / mobile input — 24 October 2026:** #69 remains candidate-only. The corrected 29-screen / 79-component package has been hash/reference audited; the approved full-playfield circular joystick is implemented independently, with 80/35/119 geometry, actual UI hit priority, multitouch ownership, lifecycle and routed input regressions. See `docs/art/CLEAN_CUT_V2_INTEGRATION.md`. New decorative assets remain unapproved and excluded; the existing 37 icons and gameplay contracts are preserved. Native evidence does not certify browser or physical devices.

> **Published icon acceptance — 24 October 2026:** #67 is merged and production `ea4633d` was inspected directly: all 37 approved icon textures included, candidate/review resources excluded, all 19 original masters retained. See `docs/art/CLEAN_CUT_PUBLISHED_EXPORT.json`. The 32 existing playable items use live artwork; five approved future-only passives remain unavailable. All 41 Godot phases, 11 Python regressions, CI and export checks passed. Artistic approval is resolved for these exact PNGs; matching Touch Grass v2 SVG/refinements, broader visual parity, joystick #66 implementation and physical/browser acceptance remain separate follow-ups.

> **Current update — 24 October 2026:** The creator explicitly approves 37 exact PNGs: eight V5 weapons, 28 V5 passives and Touch Grass Clean Cut v2. Clean Cut is the selected visual refinement recorded in GDD §26. All selected copies are hash-verified and promoted; 32 current items use live bindings, five future-only passive artworks remain unoffered. See `docs/art/CREATOR_ICON_APPROVAL_2026-10-24.md` and `docs/art/CLEAN_CUT_INTEGRATION_ACCEPTANCE.md`. Earlier zero-approval/blocked statements below are historical checkpoints. Original source isolation and all gameplay rules remain intact.

# Private Web Alpha acceptance

Audit baseline: `7fcd007d6d81e1ea29da4e2bd6c5685d169e67da`, 23 October 2026. No open PRs at restart. Phaser remains read-only. Scope is the existing three-hero, nine-weapon, 23-passive solo game with local profiles and static hosting; no gameplay backend, authentication or paid service is introduced.

This is an acceptance ledger, not a release declaration. Existing test coverage is evidence of specific contracts, not a blanket mechanical audit or a human playtest. Use the canonical GDD before historical notes. Owner artistic, human balance and physical-device gates remain separate.

## Release gates

| # | Requirement | Implementation / automated evidence | Separate outstanding gate |
| --- | --- | --- | --- |
| 1 | Three approved heroes | Live selection; hero/combat/navigation tests | Human play and full identity polish |
| 2 | Nine weapons | Timing/projectile/legendary regressions; scoped GDD correction below | Complete interaction audit and real-browser execution |
| 3 | 23 demo passives | Catalog/subset, arithmetic and lifecycle tests | Full runtime interaction audit, not IDs alone |
| 4 | Three current Flexes | Signature timing, target and mitigation tests; actual input fixtures | Human usefulness and dedicated approved exports |
| 5 | 3 weapons / 5 passives | Offer/equipment/replacement tests | Browser replacement journey |
| 6 | XP and leveling | Overflow, queue, level-25 and recovery regressions | Ordinary human progression |
| 7 | Three normal offers | Legal generation, confirmation and keyboard tests | Browser/device card interaction |
| 8 | One legendary, six offers | Cached defer/expiry/slot tests; nine legendary behavior tests | Interaction audit remains incremental |
| 9 | Enemies/events | Pattern/commitment/navigation/arrival tests | Dense ordinary-play counterplay |
| 10 | Big Hater/Berserk | Shared 600/720-second clock, phases, stagger and terminal outcomes | Reliable three-hero/human boss viability |
| 11 | Recovery | Seeded Snack/Magnet and station regressions | Real-browser and device feedback |
| 12 | Victory/defeat/restart | Controlled and normal-health observations; terminal/save tests | Human browser full run |
| 13 | Local save/reload | Versioned v2/v1, corruption, duplicate results and unavailable storage tests | Current production-browser persistence |
| 14 | Desktop controls | Native input fixtures, aim, modal isolation | Current WebGL2 input journey |
| 15 | Mobile-Web controls | Joystick ownership/cancel, safe layout, fullscreen denial tests | Physical browser acceptance |
| 16 | No critical runtime errors | Full local/hosted validation; error-scanned Web export | Complete browser session |
| 17 | Godot CI | Required per scoped PR | Never bypass pending/failing checks |
| 18 | Web export | Vercel checks and commit-versioned artifacts | Export does not prove interactivity |
| 19 | Actual browser play | Earlier G2 software-browser smoke is historical | Current cloud browser reports missing WebGL2; no new interactive pass |
| 20 | Performance | Native software mean/P95 and headless workload evidence | Reference hardware/FPS and long-run memory |
| 21 | Available approved art | 19 original masters/atlases and licensed Inter; source hashes verified | Signed V5 standalone integration when delivered |
| 22 | Missing art/platforms explicit | #49, V5 matrix and native readiness | Missing logo/plate, 37 PNG/SVG icon pairs, signature exports; no physical Android/iOS acceptance |
| 23 | Balance limits disclosed | Historical and strategic raw observations; #52 | More seeds/builds plus humans; no general win-rate claim |
| 24 | No unapproved design | GDD values/scope unchanged; corrections restore existing formulas | New values/art/mechanics still need approval |

## A1/A3 correction: legendary Tank support shields

GDD §8.1 scales weapon damage and the weapon's **own shield** by rarity × level. GDD §8.2 defines **Unbothered** as 5% caster maximum HP × S/100 and **My Aura, My Rules** as 4% caster maximum HP × S/100. These separate support pulses have no additional rarity coefficient. All current solo heroes have reference S=100; existing Certified W/Cope Harder support modifiers and the global 40% shield cap still apply.

Before correction, both support pulses also multiplied by legendary rarity 2.60, and the existing test repeated that implementation error. The new GDD expectations fail five assertions against the old runtime. The fix removes that extra factor only from these two sources. It retains the own Cope Shield 4% × 2.60 source, cadence, actual-hit trigger, support multipliers, independent expiry, pause behavior, caps and all damage values.

| Legal Alpha, 140 max HP, no support passives | Before | GDD-correct result |
| --- | ---: | ---: |
| Third legendary Cope strike: own + Unbothered | 32.76 | 14.56 + 7.00 = 21.56 |
| Unbothered alone after own shield expires | 18.20 | 7.00 |
| Second legendary Personal Space support pulse | 14.56 | 5.60 |

`tests/test_legendary_combat.gd` now verifies independent expiry, unchanged own-weapon rarity scaling, legal Tank loadouts with Certified W/Cope Harder, exclusion of offensive Main Character scaling and paused shield clocks. All 39 local Godot phases pass after the correction. This changes actual shielding to the already approved formula; it is not a new numerical tuning decision and does not edit the GDD.

Historical survival telemetry predates this correction. In particular, Alpha's legendary-Cope results must not be presented as post-correction acceptance. Reproduce seeds 451/452 and run 453–456 with the exact new source revision, retaining every failure as well as success.

Actual native Compatibility captures: [third Cope strike](art/evidence/web-alpha/legendary_shield.jpg), [second Personal Space pulse](art/evidence/web-alpha/legendary_space.jpg). They use controlled legal Tank equipment/count fixtures through the real attack and HUD code, no new artwork, and are not normal-health run or hardware-FPS evidence. Source: `tests/capture_review.gd`, states `legendary_shield` / `legendary_space`.

## Scope and next audit

The weapon/passive audit is **in progress**, not complete. Next inspect attack-event attribution, paired/multi-target proc limits, conditional effects and expiry, then ordinary-health survival. Existing green tests do not eliminate the need to reproduce each suspected mismatch. No P4–P8 experimental feature is enabled. Continue integrating individually approved supplied art in separate batches; the current session supplies only the unchanged PDF, conceptual panel and development instructions, with no standalone art archive.

Restart from current main and this ledger, [V5 acceptance](V5_ACCEPTANCE_STATUS.md), [visual matrix](art/V5_PARITY.md), [strategic evidence](SURVIVAL_STRATEGIC_EVIDENCE.md) and issues #49/#52. Native device/signing, current interactive WebGL2, hardware performance and owner artistic review remain unverified.

## Post-correction strategic replication

[WEB_ALPHA_SURVIVAL_EVIDENCE.md](WEB_ALPHA_SURVIVAL_EVIDENCE.md) and its raw 18-episode dataset repeat seeds 451/452 and add 453–456 against the exact merged PR #58 gameplay source. All episodes terminated normally. Sigma wins 451/455; Alpha enters the boss in 452/455/456 and loses; Cool Kid enters none. Review-only wave/event instrumentation is checked against ordinary combat HP/Aura/RNG/kills/drops and duplicate callbacks. The complete 39-phase local suite passes. These results supersede any use of Alpha's old 810.82-second outcome as current post-correction evidence, while leaving historical files intact. No human, browser, general balance or device acceptance is implied.

Next exact gameplay investigation: isolated Cool Kid event/ranged response and secondary-hit/proc attribution audit, followed by Alpha boss defense/recovery. Review the actual event traces and legal builds before numerical proposals. Art source status is unchanged and no backend is required.

## GDD Chad Hands late-slam correction

A controlled legal Alpha fixture reproduces two §8/§8.2 defects when the opening punch misses and the delayed second punch is the third successful activation. The current area dictionary was appended twice to a temporary list, applying the slam multiplier twice. Resolving the transformation inside the damage loop also skipped outer targets visited before the first close hit. At P=90/common, the same setup caused 65.45 damage and either zero or 65.45 to the outer target depending on array order, rather than the specified 0.40P = 36 each.

Successful activation is now determined using the unchanged eligible geometry before damage recipients are visited. Each existing delayed area is transformed once. Normal/legendary coefficients remain 0.40P / 0.60P×R, radii remain 110/140 U, and the second hit remains at 0.18 s. Shared hit memory, one proc/Aura event, pause and lifecycle remain intact. Common/legendary and reversed-order regressions fail before and pass after; all 39 local Godot phases pass. No canonical tuning values or GDD text are changed.

[Actual native controlled late-slam capture](art/evidence/web-alpha/chad_slam.jpg) uses original artwork and the real attack/HUD code. This is not a normal-health run or artistic/device acceptance. `tests/capture_review.gd -- 1280 720 OUTPUT --state=chad_slam` reproduces only that fixture. The prior 18-run data is explicitly the earlier post-shield source; repeat the same full matrix after this new gameplay correction before presenting current survival acceptance. #49/#52 and browser/human/device gates remain open.

## Current post-Chad validation checkpoint

Completed the full 18-episode 451–456 / three-hero repeat after the late-slam correction. [Current raw results](WEB_ALPHA_CHAD_SURVIVAL_RUNS.json) pin the exact PR #61 core revision/hash; [comparison](WEB_ALPHA_SURVIVAL_EVIDENCE.md#current-repeat-after-the-chad-hands-correction) preserves the prior 18 separately. All 12 ranged/melee episodes reproduce key outcomes exactly. Alpha 452 now loses at 568.40 s before boss; Alpha 455/456 still reach the boss and lose. Sigma wins 451/455; Cool Kid reaches no boss. No broader balance/human acceptance follows.

Concurrent art-only main updates `dca1a758` / `4e0a4f7` add candidate icon sources, not approved runtime art. Preflight verified all 83 manifest file hashes (40 PNG, 37 SVG, six WEBP), PNG dimensions/transparent alpha and the nine weapon / 28 passive ID mapping. Approval remains PRODUCTION_CANDIDATE, Touch Grass v2 has no matching SVG, and actual Godot 32/64-pixel icon acceptance is pending. No candidate is wired to the active UI. The available cloud browser was reopened: its visible loader again reports missing WebGL2; interactive-browser acceptance is not claimed. Its observed loader referenced `game-dca1a7586545.js`; independently fetched production HTML subsequently referenced `game-4e0a4f7eff8b` during automatic deployment.


## Candidate art resource isolation

The #60 candidate library is available for review but remains individually unapproved. An actual production-pack inspection reproduced accidental inclusion through all-resource export. A `.gdignore` exclusion and engine resource regression isolate candidates without activating them. See [candidate isolation evidence](art/CANDIDATE_ART_ISOLATION.md); rendered 32/64px and creator acceptance remain pending.


## G4.1 Clean Cut source review

All 37 canonical candidates and 83 manifest files were audited, including actual Godot SVG decoding and source composites at 32/64/256px on navy/cream. See `docs/art/CLEAN_CUT_ICON_REVIEW.md` and per-ID audit JSON. SVG font differences, narrow margins and compact identity families are recorded. Zero individual approvals or runtime promotions; the 23-passive subset and candidate export isolation remain unchanged. Next: reusable approved icon pipeline and live fallback bindings; activate only exact creator-approved hashes.


## G4.1 approved icon pipeline and safe live bindings

The source audit is integrated through #64. A separate approval ledger, immutable hashed PNG promotion, category-aware cached registry and automatic actual-PCK export guard now prepare live offer/legendary/replacement, build and HUD bindings. Eleven Python regressions and a Godot registry phase supplement the existing suite. All 40 actual before/after fallback captures are pixel-identical; compact viewport one-pixel rounding is recorded. See `docs/art/APPROVED_ICON_PIPELINE.md`. Counts remain 37 audited, 0 creator-approved, 0 promoted, 0 illustrated items accepted in live UI. Creator decisions, approved-icon visual/performance evidence and device/browser gates remain pending; gameplay/23-passive scope are unchanged.
