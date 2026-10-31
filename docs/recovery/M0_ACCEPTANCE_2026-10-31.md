# M0 acceptance assessment — 31 October 2026

**Status: technically delivered for review; M0 sign-off remains blocked.** The threat-indicator correction is implemented, regression-tested, exported and available as a protected preview. This assessment does not approve candidate artwork, declare every platform tested, authorize a merge, or open a closed/public release.

## Assessed builds and immediate review

| Role | Exact build / evidence |
| --- | --- |
| Creator-tested production baseline | `05bcef23ae0f040795cacd88e42542b55bc6488e`; production deployment `dpl_BVt9GgzKfedAsRsS3FpomqoP3Vky`; [production entry](https://aura-farmer-godot.vercel.app/) |
| New threat recovery candidate | **`bfab07e55c0130416199cc5cfaf2180c35942e22`**, [Draft PR #91](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/91), based directly on production baseline |
| Build to review now | [Protected Web preview](https://aura-farmer-godot-nnamtvqcx-pedroestrela6-8110.vercel.app/), deployment `dpl_2AVexerJWbXtM3Rbnn5ThpPyAp6t`, READY, preview target; `/build.json` matches the exact candidate and engine 4.7.2 |
| Mandatory candidate validation | [Godot CI 41151751846 — success](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/41151751846); 65 Godot phases plus applicable Node/Python checks; official Web export separately successful |
| Canonical main | `bc690618ac1183e078c2ba84cf49af9839d2d794`; not the published integration. The separate technical proposal accompanying this report is based on this main and is not the device review build. |

The creator's physical Pixel 8a report confirms smooth movement/gameplay across all five waves and the final boss encounter **on baseline 05bcef2**. Browser history identifies Brave on Pixel 8a, but the overnight observation does not supply a version, measured frame time, hero or terminal result. Do not infer those details. This acceptance is preserved; speculative movement work is not reopened. The new candidate still needs a short device regression.

Primary review links: [matched before/after](https://github.com/pedro-ai-coder/aura-farmer-godot/blob/bfab07e55c0130416199cc5cfaf2180c35942e22/tests/threat_indicator/evidence/before-after.jpg), [real-engine transition recording](https://github.com/pedro-ai-coder/aura-farmer-godot/blob/bfab07e55c0130416199cc5cfaf2180c35942e22/tests/threat_indicator/evidence/indicator.mp4), [six-resolution threat gallery](https://github.com/pedro-ai-coder/aura-farmer-godot/blob/bfab07e55c0130416199cc5cfaf2180c35942e22/tests/threat_indicator/README.md), [typography/reference comparison](evidence/overnight-2026-10-31/approved-reference-vs-runtime.jpg), [morning checklist](M0_MORNING_REVIEW_2026-10-31.md).

## Change and technical protection

Only `scripts/hero_clash_threat_overlay.gd` changes runtime behavior in #91. Canonical names replace internal clipping labels. Insignificant clipping no longer produces redundant labels; sustained meaningful HUD/viewport loss and fully off-screen bosses receive one contextual direction/name. Separate visibility thresholds and entry/exit/switch dwell prevent boundary flicker. Stable ownership and a lower-priority handoff guard prevent secondary-name flashes; eligible Big Hater wins priority. Live hostile boundary traces remain independent of label suppression.

The final production baseline already contains no-fade fixes. They remain intact: no HUD opacity, visibility, position or replacement-style changes. No gameplay, navigation policy, movement speed, simulation scheduling, camera, RNG, font, asset, profile, Web adapter or renderer source changes. The integration branch and production deployment remain untouched.

Headless paired component CPU tests (240 samples/path, identical warmed 100-actor fixtures) show sampled visibility median **0.754 → 0.085 ms** without hazards, **0.896 → 0.178 ms** with three hazards. The unchanged between-sample attack-boundary path has medians **0.039 → 0.039 ms** and **0.120 → 0.126 ms** respectively. Its noisy tail is not uniformly better; exact P95/P99 are retained in [paired results](https://github.com/pedro-ai-coder/aura-farmer-godot/blob/bfab07e55c0130416199cc5cfaf2180c35942e22/tests/threat_indicator/evidence/paired-cpu.json). These are CPU/component measurements, not rendering FPS or an Android frame-pacing claim.

## GDD V3 acceptance matrix

Statuses apply to the evidence stated in each row: **PASS** means verified within that scope, **FAIL** a reproducible defect, **PENDING DEVICE QA** a real-browser/device gap, **PENDING CREATOR APPROVAL** an artistic/product decision, **NOT TESTED** no adequate evidence. Automated functional passes do not grant visual approval. All automated rows below refer to exact #91 candidate CI; test source paths are under `tests/` on that commit. Canonical §8.2 includes main's PR #84 acceptance text.

| GDD requirement | Status | Actual evidence / remaining limit |
| --- | --- | --- |
| §2.1 Three starting heroes / original IDs | PASS | `test_game_rules`, `test_hero_combat`, `test_continuous_run`; native selection shows all three approved identities. Future roster is not offered. |
| §5.9 Nine playable weapons / class legality | PASS | `test_game_rules`, `test_solo_offer_rules`, weapon/projectile/timing/legendary-combat suites; no catalogue change. |
| §5.10 23 offered passives, five future-only excluded | PASS | Offer catalogue and passive-effect regressions; 28 approved icons do not imply 28 playable passives. |
| §§2.1/5.11 Three weapon / five passive slots and legal replacement | PASS | Catalogue, Legendary, progression, menu/modal tests; Build uses live 3+5 data. |
| §5.12 Ruin Alley geometry and cover navigation | PASS | World/navigation/camera/stress suites. Exact geometry/RNG preserved; no new AI change in #91. |
| §5.4 Five 120-second waves and boss at 10:00 | PASS | `test_run_clock`, `test_run_acceptance`, continuous seeded three-hero timeline. Controlled automated runs are not human playthroughs. |
| §5.3 XP, level 25 cap, post-cap recovery | PASS | Progression plus `ui_cohesion/test_cohesion`: 24→25, no 26, XP recovery cooldown and live HUD. |
| §5.5 One 0–100 Aura / manual hero-specific Flex | PASS | `test_signature_flex`, hero-combat/progression suites; active clock/caps/lifecycle/manual input. No joystick multiplier or speed change. |
| §5.7 Sigma, Cool Kid, Alpha signatures | PASS | Deterministic timing, mitigation, attribution, retargeting and proc-isolation tests; original authored poses retained. |
| §5.11 Three-card ordinary upgrades | PASS | Offer legality, no normal Legendary roll, explicit selection/confirmation and responsive measured text wrapping; separate footer defect below. |
| §5.11 Six-card one-time Legendary / defer/reopen/expiry | PASS | Legendary/deferred-selection/keyboard/modal suites: six legal stored offers, no reroll, single entitlement and timing. Second row is scroll-accessible on mobile. |
| §5.13 Four event encounters | PASS | Clock/bestiary/enemy-window suites. Reply Guy's actual cone schedules `next_attack = run_time + 4.0`; the adjacent 5-second branch belongs to Fanum Leech, not Reply Guy. No suspected timing defect was left unverified. |
| §5.14 Big Hater and recoverable Berserk | PASS | Boss lifecycle/run clock/enemy patterns/windows; no hard cutoff substituted, real boss-defeat transition tested. |
| §6 Street Snack, Aura Magnet, Safe Spot | PASS | Exact seeded recovery/drop/cap/collection/station/boss-recovery regressions. Presentation unchanged by #91. |
| §§2.1/8.3 Correct victory and defeat behavior | PASS | Boss lifecycle, menu/profile, continuous-run and UI cohesion tests. New native result stills prove presentation only. |
| §§4/8.3 Retry, two-step Quit and modal ownership | PASS | Existing real-pointer event-routing/confirmation, keyboard/menu/restart tests; preserving Quit semantics. No abandoned-run result recorded. |
| §4 Local save compatibility / import-export | PASS | Profile migration/corruption/atomic-write/idempotency tests and isolated settings roundtrip. `profile_store.gd` unchanged. New preview's actual browser storage transfer still needs Web QA. |
| §8.3 Main Menu controls / selected hero identity | PASS | Navigation/theme/UI/button tests; actual native menu and original selected Cool Kid art. Artistic finality remains separate. |
| §8.3 Hero Selection | PASS | Three actual character cards, focus/select/start/back tests and current native evidence. |
| §§7/8 HUD HP and distinct Shield | PASS | HUD V2 all-hero/six-view lifecycle tests; real HP/heal/shield/XP updates, permanent opaque identity and original portraits. |
| §8 Equipment / full names | PASS | Real 3+5 icons/levels; complete names/effects remain in Build and tooltips, with pointer/keyboard Build regressions. Mobile reading remains pending. |
| §§5.5/7/8 Flex charge and READY | PASS | Flex readability/input/HUD suites, circular charge/READY/active/recovery containment and Reduced Motion; approved manual activation preserved. |
| §8 Boss health / active danger boundary | PASS | Final-polish/threat tests preserve actual source hazards and boundary traces; native telegraph crosses occupied HUD without fading it. |
| §8 Contextual visibility, off-screen bearing and priority | PASS | New state-transition tests: full/slight/meaningful/HUD clipping, fully off-screen, dwell, jitter, stable IDs, Big Hater, lifecycle, six safe layouts; actual 13-second recording. |
| §8 Upgrade/Legendary footer contrast | FAIL | Current native desktop/mobile footers run into authored lower-right diagonal cut. [Typography audit](M0_TYPOGRAPHY_AUDIT_2026-10-31.md) identifies exact label/source and smallest inset correction. It is inherited, not introduced by the overlay. |
| §8 Build, Pause, Settings, Quit and result layout | PASS | UI cohesion/final-polish/secondary-input/layout/button tests; 17 current native states captured at two sizes. Ordinary overlap checks do not clear artistic/readability acceptance. |
| §§7.1/7.2 Floating circular full-field joystick | PASS | Real synthetic touch event regressions at all six sizes; contact outside real UI, drag/release, ownership, no whole-HUD rebuild. Geometry/speed unchanged. |
| §7 Independent second finger Flex / Pause | PASS | Multitouch ownership and actual second-finger Sigma Flex fixture; overlay marker is input-transparent and avoids live controls. Physical browser arbitration requires regression. |
| §§7/8 Keyboard, focus, hover/pressed/selected/disabled | PASS | Existing card/secondary/button/input suites and candidate hash/state coverage. This is functional verification, not candidate-art approval. |
| §7 Reduced Motion | PASS | Existing feedback/HUD/Flex tests and new static indicator lifecycle; no new animation or flashing. |
| §8 Approved heroes, enemies, environment and icons | PASS | 19 master, 37 icon and 84 immutable Clean Cut hash verification; approved animation identities. #91 asset diff is empty. |
| §8 New button and HUD source artwork | PENDING CREATOR APPROVAL | 24 button PNGs/editable SVGs, 20 HUD SVGs plus portrait shader retain explicit candidate status. Production presence does not approve them. |
| §8.2 Original typography and logo / issue #76 | PENDING CREATOR APPROVAL | Actual seven-screen and source-reference comparisons supplied. Archivo/brand treatment remains candidate; footer defect and device reading unresolved. Issue remains open. |
| §7 Six responsive viewport contracts / safe insets | PASS | Mandatory layouts and threat fixtures at 1920×1080, 1600×900, 1280×720, 915×412, 844×390, 390×844, including synthetic asymmetric safe insets. These are logical/native checks, not all physical devices. |
| §7 Compact mobile text and interaction comfort | PENDING DEVICE QA | Current native physical-scale values include 15 px HP, 13.5 px Shield, 13.5 px card body, 11.25 px category/progression/footer and 10.5 px result micro labels at requested 844×390. No universal minimum is invented. |
| §7 Browser fullscreen / orientation / DPR contract | PASS | Node trusted-gesture/refusal/retry/iOS-standalone/safe-area/CSS-raster tests; existing compact DPR cap retained. #91 changes no Web platform code. |
| §7 Actual Pixel Brave fullscreen / orientation on new build | PENDING DEVICE QA | Native fixtures and Node mocks cannot prove the browser granted fullscreen or orientation. No fresh physical check available here. |
| §10.2 Baseline physical mobile fluidity | PASS | Creator confirms baseline 05bcef2 through five waves/final encounter. No FPS, version, all-Android or new-build claim. |
| §10.2 New candidate physical regression | PENDING DEVICE QA | Pixel 8a/Brave: boundary cues, touch/Flex/Pause and brief ordinary/dense fluidity on bfab07e. No engine retuning planned without evidence. |
| §§2.1/10.2 Normal-health complete human Web run on exact candidate | NOT TESTED | Baseline observation and controlled three-hero CI runs do not establish this on bfab07e. Record hero/browser/outcome and relevant win/loss/retry flows. |
| §10.2 Interactive desktop/mobile Web rendering on exact candidate | NOT TESTED | Actual native output, protected build/resources and official export are verified. No new interactive WebGL2 screenshot/playthrough is claimed; do not treat prior unavailable review-browser WebGL2 as device validation. |
| §10.2 Official Web export / licensed resources | PASS | Official 4.7.2 archive/template hash checks; PCK 506 entries, 19 masters, 37 icons, 84 Clean Cut resources; candidate hashes and six font/license resources verified; development recorder/review fixtures excluded. |
| §10.2 Restricted preview access | PASS | Existing SSO `enabled: true`, `all_except_custom_domains`; authenticated preview build/license fetches HTTP 200. No protection removal, public share bypass or alias promotion. This does not prove every tester has access. |
| §10.2 Fully polished journey and source approvals | PENDING CREATOR APPROVAL | Exact candidate source decisions, footer correction, responsive Web evidence and interactive visual sign-off still required. Green CI does not clear this row. |
| §10.2 Main/publication reconciliation | NOT TESTED | Full visual consolidation has not been assembled or approved. Independent geometry port is prepared; [precise reconciliation package](M0_MAIN_RECONCILIATION_2026-10-31.md) lists blockers/sequence/rollback. |
| §10.2 Closed-cohort release authorization | PENDING CREATOR APPROVAL | Explicitly not granted. No merge into main/integration, production deploy, release or public opening performed. |

PASS rows are not an exhaustive proof of every scalar in the GDD. Their linked executed suites define the tested boundary. No new gameplay discrepancy was established in this audit; unexecuted physical/interactive journeys remain visible instead of being inferred from fixtures.

## Retained verification and limits

[Verification snapshot](evidence/overnight-2026-10-31/verification.json) retains exact CI phase/PASS lines, historical PR heads, deployment/build identity, protection and Web packaging results. #91's [validation provenance](https://github.com/pedro-ai-coder/aura-farmer-godot/blob/bfab07e55c0130416199cc5cfaf2180c35942e22/tests/threat_indicator/evidence/validation.json) records 60 native frames, raw hashes/readbacks, matching before/after simulation/camera/RNG, and unchanged source scopes. Eight targeted suites also passed before full CI. No failed mandatory check was waived; unrelated art-specific evidence jobs are not represented as applicable passes.

Native evidence uses official Godot 4.7.2 Compatibility/X11 software rendering, controlled game state and isolated review profiles. The transition video is real Godot Movie Maker at offline fixed 30 fps, 1280×720, approximately 13 seconds; it is not delivered rendering FPS, physical gameplay or a full run. Browser/physical recordings of the new preview remain absent. No normal-player save was used by capture fixtures.

The separate technical reconciliation proposal ports only `solo_world_rules.gd`'s previously validated exact cache onto main. A fresh main-specific 388,512-case differential test passes; its final-head mandatory CI/export must be checked in that PR. It does not certify the integrated HUD or replace the primary candidate's green validation.

## Remaining work and release decision

The smallest next implementation is the existing card-footer safe inset, followed by exact-build visual/device regression. Obtain explicit typography/logo/button/HUD source decisions, retain originals and record approved supersession precisely. Complete clean visual reconciliation only after those decisions, preserving main's PR #84 contract. Finally record normal-health interactive Web journey evidence and the creator's closed-cohort release authorization. No M1 backend, Discord, new content or monetization work is part of this package.

The [morning checklist](M0_MORNING_REVIEW_2026-10-31.md) makes the next review concrete. M0 remains open until the defect, device evidence, artistic decisions and release authorization are resolved.
