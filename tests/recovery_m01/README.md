# M0.1 / M0.2 — navigation and UI recovery

Creator review only. Keep this PR in Draft; no automatic merge or M0 acceptance.

Baseline: PR #81 `09ad704e5e0e34d2bb898a9e861c8a40bbe7e353`. New branch `fix/m0-navigation-ui-recovery` targets `art/m0-final-button-components`. The stack is main → #80 → #81 → this recovery. Initial main was `201127a6377f2a8d557d5edc51b63e4f426e2273`; #80 remained open/Draft at `9f3cc26b27a8a9c1b5f8cd2cdbbd946e92683836`. The only other open PR was the separate GDD-lettering documentation #77. The audited baseline preview was READY at `aura-farmer-godot-n1ib68j2z-pedroestrela6-8110.vercel.app`, exact #81 SHA above. Final deployment and CI references are in the PR description.

## Confirmed defects and corrections

| ID / severity | Evidence and cause | Correction / regression |
| --- | --- | --- |
| NAV-01 / P0 | Seed 8201: 15/220 legal pursuit routes failed after 20 seconds. Actors oscillated beside cover tangents: direct-line clearance was only 0.5 U and arc arrival required 0.05 U despite axis-separated integration. Most failures used 25.2 U elite radii; one used 12 U. [Baseline log](evidence/nav-before.log). | 2 U planning clearance and arrival tolerance `max(2 U, 1.5 × requested step)`. Reconsider the committed side after a 64 U target change. Same collision solver and speed budget. 220/220 now reach their targets. |
| NAV-02 / P0 | The spawn sampler required 24 U clearance for every actor. Seed 8202: 77/300 positions valid at 24 U were illegal for Big Hater's actual 48 U collider. [Reproduction](evidence/spawn-before.log). | Pass the real radius, including elite enlargement, into the existing bounded spawn sampler. 1,500 samples at five enlarged radii remain legal and ≥260 U from the player. |
| UI-01 / P0 | Boss plate overlapped wave and Berserk warning in portrait; its legacy silhouette-avoidance layout had no knowledge of Shield or warning reservations. [Comparison](evidence/compare-boss-390x844.jpg). | Clean Cut owns one reserved vertical stack for health/Shield, wave, boss and warning. No legacy rectangle provider competes for the same region. |
| UI-02 / P1 | Normal card title/meta regions intersected; body/comparison regions intersected by 22 logical pixels at desktop/portrait. Longer descriptions could be ellipsized by a five-line limit. | Measure actual wrapped strings and reserve independent title, metadata, body, comparison and state rows. Retain at least 80 U description space, remove trimming/line cap, grow cards inside the existing scroll region. [Comparison](evidence/compare-choice-selected-1600x900.jpg). |
| UI-03 / P1 | Build inspection overrode a three-column presenter's grid with a large icon and 66 U title box; empty-slot text extended into metadata/next rows. [Comparison](evidence/compare-build-844x390.jpg). | Component owns its one/two-column rows, separates capacity counters from titles and reserves enough vertical space. Full names and all 3+5 slots stay scrollable. |
| UI-04 / P1 | On mobile landscape, 460 U hero cards gave help text only 40 U. Actual wrapped help needed 70–94 U and escaped the card; two-line Flex titles also collided with the fixed help origin. | Measure both the Flex title and help before allocating separate rows and card height. Regression verifies every hero text region fits its actual Button. The bottom help remains accessible by scrolling. [Scrolled comparison](evidence/compare-hero-details-844x390.jpg). |

The creator's exact recorded stuck event was not available with this directive; these are reproduced failure classes in the actual baseline implementation, not an asserted frame-for-frame match to that event. No claim that all possible navigation defects have been exhausted.

## Navigation evidence and performance

`test_navigation_stress.gd` covers deterministic legal approaches to both covers, 12/15/21/25.2/48 U radii, a dense 100-actor scenario with fast/slow movers, five changed-target segments near concave floor regions, collision/speed legality, and no RNG consumption during pursuit. Existing actual-AI tests retain ranged distance, terminal, stagger, recovery, boss telegraph and locked charge guarantees; the full enemy/boss/Flex suite remains enabled.

Opt-in `EnemyNavigation.observe` accumulates **requested movement** over 1.5 active seconds and checks net progress against 15% of the movement budget (minimum 2 U). It catches small oscillations rather than treating every stationary frame as a fault. Gaps in active pursuit reset the window; zero-speed, range-band, stagger, terminal, recovery and committed charge states are not sampled. Events contain stable ID/kind, position/target/waypoint, cover, requested speed/direction, actual displacement, phase, stalled time, collision rejection indication, wave and simulation time. The event ring is capped at 128; disabled diagnostics allocate nothing and consume no RNG. This is development instrumentation, disabled by default.

The 100-actor / 3,600-frame moving-goal test completed in approximately 2.9 CPU seconds with diagnostics enabled. A separate same-host paired 100-actor fixture measured 891,399 µs for the frozen #81 baseline and 676,742 µs for the correction. Earlier route completion changes work performed, so these numbers are **whole-fixture costs**, not per-step speedup, rendered FPS, mobile performance or input-latency measurements. Logs and benchmark sources are included. No full pathfinding graph or per-frame resource rebuild was introduced.

Navigation/diagnostics do not consume RNG. Correct large-radius spawn rejection can change the number of samples rejected and the seeded birth coordinates for large actors; it uses the same existing random stream, 80-attempt bound, distribution rectangle and arrival-distance rule. This is deliberate collision correctness, not a promise of identical invalid baseline spawns. Floor vertices, covers, collision radii, speeds, damage, cadence, XP/Aura and all balance tables are unchanged.

## Runtime UI audit

`layout_audit.gd` traverses actual visible Godot Controls after layout, recording path/type/parent, logical and transformed physical bounds, ancestor clipping, text, effective font size and interaction bounds. It checks named HUD reservations, peer card text, actual hero-card containment, build title/metadata separation and clipped interactive hit regions. The explicit intentional-layer allowlist covers fills inside tracks, labels on faces, icons on plates, transparent selection frames and rarity badges. It does not report every decorative rectangle intersection as a defect.

[Structured audit](evidence/layout-report.json.gz) covers all six sizes and menu, heroes, combat, normal/legendary/replacement choices, pause, build, settings, exit confirmation, import/export and results. It includes long passive names, full passive capacity, zero HP, nonzero Shield and Flex READY. Existing tests add touch ownership, safe-area conversion, selected-hero identity, HP/Shield values, active/recovery Flex, keyboard focus, modal ownership, selected-offer preservation and real held-pointer Quit/STAY/Confirm. Targeted audit reports zero findings in these scenarios; geometry checks remain narrower than a complete visual/device review.

No new font/art direction or button artwork was added. All 24 #81 button PNG/SVG hashes, 37 approved icons, 84 Clean Cut resources and 19 original masters are preserved. Button caching, touch rectangles, Reduced Motion, save schema and confirmation semantics are retained. Review tooling/evidence is under `tests/` and excluded from exports.

## Gameplay recordings and validation limits

- [Normal-health native gameplay](evidence/native-normal-gameplay.mp4): 60-second automated movement recording from the actual menu/hero/start controls, canonical spawns, combat, normal damage and real pointer upgrade choices. Outcome: 59.75 simulation seconds, 45 kills, level 4, 58 HP; still playing. No health protection, forced kill or completion claim.
- [Controlled navigation](evidence/controlled-cover-navigation.mp4): 20-second separately marked fixture, four authored enemies pursuing around the two covers, weapons removed only inside this review scenario to keep pursuers visible. Player still takes real contact damage (84 HP at end). It is not a normal combat run.
- [Unprotected longer simulation](evidence/normal-health-full-review.log): existing strategic controller, seed 451, no invulnerability/clock jumps/XP grants. Legitimate defeat at 154.70 s in wave 2, 125 kills, level 8, seven choices and one Flex; this run did not reach Big Hater and is not a successful full-run claim.
- [Recording metadata](evidence/recording.json): evidence type, frame count, simulation time, HP and outcomes. Videos are 15 FPS encodes scaled from native 1280×720 captures to 960×540 for delivery; screenshots below retain exact resolution. Automated input is not human playtesting.

The complete existing regression suite passed locally, including the seeded three-hero continuous wave/event/legendary/Big Hater/Berserk/victory contracts and legitimate loss/retry/profile tests. Those controlled full-run tests may protect the player or inject timeline/finishing conditions as their sources state. They are not naturally completed normal-health playthroughs. New navigation and live-Control audit checks are appended to the suite; no old tests/assertions are disabled or weakened.

Official checksum-verified Godot 4.7.2 Web export passed. PCK verification checks approved resources, existing font licenses and candidate button hashes. The final PR reports the exact Vercel commit, READY status and access protection. The verification browser opened the app but displayed the explicit missing-WebGL2 feature error; gameplay could not run in that browser. Physical-device testing was not performed; native output and READY status do not establish browser correctness. A complete normal-health Web run, physical mobile comfort/frame pacing and creator acceptance remain outstanding review gates.

## Capture gallery

Actual Godot 4.7.2 Compatibility / Mesa llvmpipe PNG captures, deterministic frozen native states. Before uses exact #81 UI, after uses this correction. Delivered JPEGs preserve original dimensions; there is no retouching or generated imagery. [Manifest](evidence/capture-manifest.json) records source PNG and delivered JPEG hashes. Gzipped reports contain the measured Controls for each capture. Static victory/defeat captures are explicitly staged fixtures.

[Boss comparison](evidence/compare-boss-390x844.jpg) · [Upgrade comparison](evidence/compare-choice-selected-1600x900.jpg) · [Legendary comparison](evidence/compare-legendary-selected-844x390.jpg) · [Build comparison](evidence/compare-build-844x390.jpg)

| Runtime state | 1920×1080 | 1600×900 | 1280×720 | 915×412 | 844×390 | 390×844 |
| --- | --- | --- | --- | --- | --- | --- |
| hero-menu | [capture](evidence/after/m0-hero-menu-1920x1080.jpg) | [capture](evidence/after/m0-hero-menu-1600x900.jpg) | [capture](evidence/after/m0-hero-menu-1280x720.jpg) | [capture](evidence/after/m0-hero-menu-915x412.jpg) | [capture](evidence/after/m0-hero-menu-844x390.jpg) | [capture](evidence/after/m0-hero-menu-390x844.jpg) |
| hero-selection | [capture](evidence/after/m0-hero-selection-1920x1080.jpg) | [capture](evidence/after/m0-hero-selection-1600x900.jpg) | [capture](evidence/after/m0-hero-selection-1280x720.jpg) | [capture](evidence/after/m0-hero-selection-915x412.jpg) | [capture](evidence/after/m0-hero-selection-844x390.jpg) | [capture](evidence/after/m0-hero-selection-390x844.jpg) |
| wave1 | [capture](evidence/after/m0-wave1-1920x1080.jpg) | [capture](evidence/after/m0-wave1-1600x900.jpg) | [capture](evidence/after/m0-wave1-1280x720.jpg) | [capture](evidence/after/m0-wave1-915x412.jpg) | [capture](evidence/after/m0-wave1-844x390.jpg) | [capture](evidence/after/m0-wave1-390x844.jpg) |
| dense | [capture](evidence/after/m0-dense-1920x1080.jpg) | [capture](evidence/after/m0-dense-1600x900.jpg) | [capture](evidence/after/m0-dense-1280x720.jpg) | [capture](evidence/after/m0-dense-915x412.jpg) | [capture](evidence/after/m0-dense-844x390.jpg) | [capture](evidence/after/m0-dense-390x844.jpg) |
| cover-left | [capture](evidence/after/m0-cover-left-1920x1080.jpg) | [capture](evidence/after/m0-cover-left-1600x900.jpg) | [capture](evidence/after/m0-cover-left-1280x720.jpg) | [capture](evidence/after/m0-cover-left-915x412.jpg) | [capture](evidence/after/m0-cover-left-844x390.jpg) | [capture](evidence/after/m0-cover-left-390x844.jpg) |
| cover-right | [capture](evidence/after/m0-cover-right-1920x1080.jpg) | [capture](evidence/after/m0-cover-right-1600x900.jpg) | [capture](evidence/after/m0-cover-right-1280x720.jpg) | [capture](evidence/after/m0-cover-right-915x412.jpg) | [capture](evidence/after/m0-cover-right-844x390.jpg) | [capture](evidence/after/m0-cover-right-390x844.jpg) |
| playing-shield | [capture](evidence/after/m0-playing-shield-1920x1080.jpg) | [capture](evidence/after/m0-playing-shield-1600x900.jpg) | [capture](evidence/after/m0-playing-shield-1280x720.jpg) | [capture](evidence/after/m0-playing-shield-915x412.jpg) | [capture](evidence/after/m0-playing-shield-844x390.jpg) | [capture](evidence/after/m0-playing-shield-390x844.jpg) |
| ready | [capture](evidence/after/m0-ready-1920x1080.jpg) | [capture](evidence/after/m0-ready-1600x900.jpg) | [capture](evidence/after/m0-ready-1280x720.jpg) | [capture](evidence/after/m0-ready-915x412.jpg) | [capture](evidence/after/m0-ready-844x390.jpg) | [capture](evidence/after/m0-ready-390x844.jpg) |
| boss | [capture](evidence/after/m0-boss-1920x1080.jpg) | [capture](evidence/after/m0-boss-1600x900.jpg) | [capture](evidence/after/m0-boss-1280x720.jpg) | [capture](evidence/after/m0-boss-915x412.jpg) | [capture](evidence/after/m0-boss-844x390.jpg) | [capture](evidence/after/m0-boss-390x844.jpg) |
| choice-selected | [capture](evidence/after/m0-choice-selected-1920x1080.jpg) | [capture](evidence/after/m0-choice-selected-1600x900.jpg) | [capture](evidence/after/m0-choice-selected-1280x720.jpg) | [capture](evidence/after/m0-choice-selected-915x412.jpg) | [capture](evidence/after/m0-choice-selected-844x390.jpg) | [capture](evidence/after/m0-choice-selected-390x844.jpg) |
| legendary-selected | [capture](evidence/after/m0-legendary-selected-1920x1080.jpg) | [capture](evidence/after/m0-legendary-selected-1600x900.jpg) | [capture](evidence/after/m0-legendary-selected-1280x720.jpg) | [capture](evidence/after/m0-legendary-selected-915x412.jpg) | [capture](evidence/after/m0-legendary-selected-844x390.jpg) | [capture](evidence/after/m0-legendary-selected-390x844.jpg) |
| paused | [capture](evidence/after/m0-paused-1920x1080.jpg) | [capture](evidence/after/m0-paused-1600x900.jpg) | [capture](evidence/after/m0-paused-1280x720.jpg) | [capture](evidence/after/m0-paused-915x412.jpg) | [capture](evidence/after/m0-paused-844x390.jpg) | [capture](evidence/after/m0-paused-390x844.jpg) |
| build | [capture](evidence/after/m0-build-1920x1080.jpg) | [capture](evidence/after/m0-build-1600x900.jpg) | [capture](evidence/after/m0-build-1280x720.jpg) | [capture](evidence/after/m0-build-915x412.jpg) | [capture](evidence/after/m0-build-844x390.jpg) | [capture](evidence/after/m0-build-390x844.jpg) |
| settings | [capture](evidence/after/m0-settings-1920x1080.jpg) | [capture](evidence/after/m0-settings-1600x900.jpg) | [capture](evidence/after/m0-settings-1280x720.jpg) | [capture](evidence/after/m0-settings-915x412.jpg) | [capture](evidence/after/m0-settings-844x390.jpg) | [capture](evidence/after/m0-settings-390x844.jpg) |
| confirm-exit | [capture](evidence/after/m0-confirm-exit-1920x1080.jpg) | [capture](evidence/after/m0-confirm-exit-1600x900.jpg) | [capture](evidence/after/m0-confirm-exit-1280x720.jpg) | [capture](evidence/after/m0-confirm-exit-915x412.jpg) | [capture](evidence/after/m0-confirm-exit-844x390.jpg) | [capture](evidence/after/m0-confirm-exit-390x844.jpg) |
| won | [capture](evidence/after/m0-won-1920x1080.jpg) | [capture](evidence/after/m0-won-1600x900.jpg) | [capture](evidence/after/m0-won-1280x720.jpg) | [capture](evidence/after/m0-won-915x412.jpg) | [capture](evidence/after/m0-won-844x390.jpg) | [capture](evidence/after/m0-won-390x844.jpg) |
| lost | [capture](evidence/after/m0-lost-1920x1080.jpg) | [capture](evidence/after/m0-lost-1600x900.jpg) | [capture](evidence/after/m0-lost-1280x720.jpg) | [capture](evidence/after/m0-lost-915x412.jpg) | [capture](evidence/after/m0-lost-844x390.jpg) | [capture](evidence/after/m0-lost-390x844.jpg) |

The cover-left/right static fixtures show the shared arena composition; pursuit over time is demonstrated by the separately labelled controlled navigation video.

## Reproduction

```sh
bash scripts/validate.sh
godot --headless --path . --script res://tests/recovery_m01/test_layout.gd -- /absolute/audit.json
godot --path . --script res://tests/recovery_m01/capture.gd -- 844 390 /absolute/captures
godot --path . --script res://tests/recovery_m01/record_gameplay.gd -- /absolute/frames
godot --headless --path . --script res://tests/recovery_m01/benchmark.gd -- before
godot --headless --path . --script res://tests/recovery_m01/benchmark.gd -- after
bash scripts/build_web.sh
```
