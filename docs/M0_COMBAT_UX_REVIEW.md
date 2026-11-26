# M0 combat UX review candidate

Baseline: `125604db7f78ae9ee48e82c63e37eea8a7ac57f4`, rechecked against remote main on 2026-11-26. One branch: `fix/m0-combat-ux-recovery`. Review only; no release, merge or deployment.

Authority: Canon main `7b4d3940e18da0c8550279c8b46fe27311bde74b`, bounded GDD V4.0 and preserved V3 Solo annex. Read QA issue [#6](https://github.com/pedro-ai-coder/clutchpunks-qa-evidence/issues/6), including prior scoped approvals and Video Project 2 feedback. Original media is unavailable in this workspace; video-supported observations below are attributed to that issue, not a fresh video decode. Prior approvals remain intact.

## Scope and dependencies

Affected: `hero_clash_hud.gd`, `clean_cut_skin.gd`, `passive_feedback_view.gd` (HUD observation/layout); `solo_run.gd` rendering functions, `hero_clash_threat_overlay.gd`, `weapon_presentation.gd` (existing geometry); `passive_feedback.gd`, `arcade_presentation.gd`, `clean_cut_secondary.gd` (existing descriptions/help). Dependencies: original skin controls/signals, approved icon/art registry, actual clock/enemies/passive counters, existing card scroll/confirmation and paused Build inspection. No new art or theme. Export presets exclude the documentation galleries from playable packs.

Acceptance: keep critical HP/shield/XP/level/wave/time/Flex accessible; reduce reserved HUD area; distinguish warning/active/friendly/pickup without color alone; identify all five arrivals without freezing control; describe purpose then exact values using existing scrollable cards. Rollback: revert this branch's single implementation commit; return to the baseline export. Profile schema and keys are unchanged.

## Complaint to change

| Complaint | Applied presentation change |
| --- | --- |
| Player disappears behind HUD | Smaller status, timer, equipment, XP and Flex modules; Pause retains >=48 physical pixels at supported test sizes. Decoration becomes translucent where the player overlaps, while critical text and original hit targets stay available. |
| Persistent passive explanation | Recurring proc counters stay on existing slot tabs and in paused Build. Acquisition/important notices use the existing panel, capped visually at 1.35 active seconds. |
| Unclear damage ownership and timing | Hostile preparation uses dashed, dark-backed orange paths; active danger uses thicker solid red paths. Hostile shots have a dark silhouette and small pale core. Friendly boundary opacity is reduced and stays thin/below hostile geometry. |
| Weak miniboss communication | Existing boss lane shows the newest living event's real name, portrait and HP. Brief THREAT ARRIVING text expires two active seconds after materialization. Existing offscreen/occlusion threat locator remains in use. Big Hater schedule/phase warnings remain. |
| Power-up meaning unclear | Plain-English purpose for all nine weapons and 23 offerable passives precedes existing exact details. Legendary weapon cards now retain the ordinary behavior AND the legendary addition. Actual passive levels/caps/triggers come from the existing descriptor. Existing confirmation/replacement UI retained. |

## Source-grounded visual classification

| Function | Source and actual meaning | Presentation |
| --- | --- | --- |
| Hostile shots | `solo_run.gd::_spawn_hostile_shot`, `_step_hostile_shots`, final `_draw` loop; Hater/Ping Sniper projectiles damage on player contact; cover blocks them | Moving red core/dark silhouette/pale center; original radius, speed and collision unchanged |
| Enemy aim warnings | `_step_enemies`, `_draw_enemy_aim_warning`; warning/charge-warning locks future direction; line itself is not immediate damage | Dashed orange, below active hostile shots |
| Hostile zones | `_schedule_hazard`, `_hazard_contains`, `_step_hazards`, `_draw_danger_geometry`; before `at` is preparation; from `at` to `end` eligible damage/ticks, subject to existing hit/cover rules | Dashed preparation, thicker solid active outline; line lane retains existing 60-unit width; ring safe gap/expansion unchanged |
| Tether | Same hazard functions: line connects caster/player; damage eligibility is caster range (240 U), not line collision; break range or kill caster to cancel | Existing connection uses warning/active stroke; do not interpret stroke as a new hitbox |
| Friendly attacks | `_fire_weapons`, `_step_weapon_areas`, `weapon_presentation.gd::draw_ground/draw_projectiles/draw_impacts`; real queued/resolved player hits | Thin subdued teal/gold boundaries, authored cap/bolt/weapon silhouettes and actual contact cues |
| Non-damaging indicators | `_draw_enemy_actor` pre-born marker, `_draw_recovery`, Sigma target marker and `passive_feedback.gd::draw_ground` Wi-Fi boundary | Existing spawn marker, medical icon/recovery boundary, target brackets, thin Wi-Fi zone; no new damage implied |
| Pickups | `pickup_visuals.gd`, `_collect_drops`; XP Orb, Street Snack, Aura Magnet; sprites collect, never hostile projectiles | Original collectible artwork preserved; no recoloring into danger palette |
| Status/passives | `passive_feedback.gd::slot_state/describe`, shield arcs, approved Six to Seven and No U observers | Live slot counters/readiness; original approved VFX and all source artwork unchanged |

Hostile geometry remains an existing visualization of authoritative tests, including player collision tolerance. Cone arcs show the existing outer edge; tether is a range link. This change does not claim that every drawn stroke is a complete hitbox editor.

## Validation and evidence

Executed official Godot 4.7.2 / Compatibility on Windows. Focused suites: HUD (six GDD viewports, all heroes, actual damage/heal/shield and all five scheduled introductions); passive contracts/layout/parity; map flow and factory routes; signature Flex; offers/legendary; Neon menu/card journey; profile/RNG; approved No U production/boundaries; mobile joystick/layout/drag; actual pointer and secondary input; combat feedback and threat indicator. Final logs, export checks, SHA, hashes and browser evidence accompany the portable delivery.

The existing parity suite passed 5,376 paired full state/RNG/profile comparisons. A separately recorded unchanged-main Windows baseline also matches the candidate's normal/dense/Flex irregular-frame state hashes. All simulation/input/save code before the rendering section of `solo_run.gd` is unchanged. No gameplay rules, event schedule, save fields, art or canonical files were modified.

Reproduce native matched screenshots with `godot --path . --script res://tests/hud_v2/ux_capture.gd -- 1600 900 <output>` and `844 390 <output>`. Run the identical fixture on baseline and candidate. The fixture extends the existing isolated review run: fixed start seeds 451 (Sigma), 468 (Cool Kid) and 485 (Alpha), preceding history, frozen poses, forced event times, high-health targets and a 100-enemy dense setup; it is SYNTHETIC, not an ordinary survival result, device performance measurement or human comprehension proof. Five states: normal, dense, semantics, miniboss, cards. The semantic fixture deliberately juxtaposes a warning zone and active zone. Portrait/control coverage is in existing six-viewport tests; mobile-sized Web is browser emulation, not a physical phone test.

NOT RUN: new ordinary full victory run, physical-device browser/FPS, independent replay of the original videos or Cool Kid's reported early death. No simulation campaign. Creator review of this exact candidate remains required. Existing final boss/victory, two-map Canon alignment and restricted hosting/release decisions remain separate. See [balance diagnostic](M0_BALANCE_PROPOSAL.md).

Matched native galleries: [desktop](evidence/m0-combat-ux/1600x900.webp) and [mobile-sized](evidence/m0-combat-ux/844x390.webp). Left: unchanged main. Right: candidate. All rows are explicitly synthetic fixtures.

