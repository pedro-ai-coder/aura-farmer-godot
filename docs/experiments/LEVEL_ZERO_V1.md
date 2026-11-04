# Level Zero 0.1 — experimental private review

Status: EXPERIMENTAL implementation; PROPOSED gameplay/narrative; no art approval,
GDD promotion, merge, public release or production deployment.

## Authority and entry

- Runtime/V3 baseline: `e43236014044533bad41c944222736cce441cf5f`, `docs/GDD.md` §§5.1–5.7.
- Canon #6 proposal: `e0aed0b73df5750102fb17094781ceae5117f282`.
- Canon #12 V4 candidate: `c7416ac92c058a5b7ea85d545b20c1fa9e0879bc`, prologue and Web exclusions.
- Canon #13 narrative: `101f1b1f1b713fbf2295caac15aeda94c80b6ff4`, §§5–6.
- Current creator instruction authorizes this isolated experiment, not those drafts as canon.

Web entry: `/?level_zero=1`. Normal ` / ` retains independent five-wave Ruin Alley.
Native entry: `res://scenes/level_zero.tscn`. The adapter inherits `solo_run.gd`;
small overridable content/presentation seams retain the normal implementation defaults.
Removing the adapter, scene, query route and reverting the seams rolls back the change.
Only the runtime repository changes. No new QA infrastructure or instrumentation.

## Exact experimental differences

Versioned source: `scripts/level_zero/candidate_v1.gd` (`level-zero/0.1.0`).

| Rule | Candidate |
| --- | --- |
| Waves | First three V3 120-second waves; original enemy pools/scaling and 80/120 XP transition crystals |
| Events | No lieutenant events; prototype at 360 s, warning at 330 s |
| Legendary | No wave-four offer: this run never reaches wave four; normal legal rarity rules remain |
| Prototype ID | `experimental-lz-prototype-v1`; never registered as canonical `boss` |
| Prototype stats | 2,400 HP, speed 32 U/s, contact damage 14, radius 36 U, 0 XP; existing event-boss contact interval 0.75 s |
| Attack cycle | First attack after 2 s; alternate slam/beam every 4 s |
| Slam | Cone radius 200 U, tell 1 s, active 0.12 s, damage 28 |
| Beam | Line length 600 U, tell 1.2 s, active 0.1 s, damage 24; existing line width/cover rules |
| Direction / movement | Lock at start of tell; pause boss movement during tell/impact |
| Exclusions | No ring, adds, berserk, regeneration, final-boss stagger/exposure or phase escalation |
| Narrative | Skippable proposed entry; prototype visibly identified; honest defeat and prototype-only victory |
| Saves/rewards | Reads existing preferences; no writes or recorded results; no chests, points, ranks or unlocks |

At boss entry, reuse existing transition cleanup and collection of pending XP.
No new XP curve, automatic level grants, hero stats, weapons/passives, Aura/Flex,
movement, content IDs or RNG sequence changes. Three kits/six appearances remain.
Seeds remain 451 (sigma), 468 (cool-kid), 485 (alpha).
The 7–9-minute target is an unverified hypothesis, not a timeout or guaranteed duration.

## Art and limitations

No asset bytes changed. Existing environment, characters, UI and weapons remain
at the exact baseline manifest versions and approval statuses. Existing Beta Bot
frames temporarily represent the distinct, larger imitation; this does not approve
prototype art. Final Level Zero environment, boss identity, logo and audio are missing.
The review badge explicitly labels experimental status and placeholder art.

## Validation

Linux x86_64; Godot `4.7.2.stable.official.ed1daf0bf`; Compatibility renderer.
Official engine archive SHA-256:
`cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`.
Official templates SHA-256:
`f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`.

Executed 2026-11-04: `godot --headless --path . --script res://tests/<name>.gd`.
Passed: `test_level_zero`, `test_phaser_rng`, `test_game_rules`, `test_run_clock`,
`test_solo_offer_rules`, `test_hero_combat`, `test_signature_flex`,
`test_boss_lifecycle`, `test_profile_store`, `test_female_roster`, `test_menu_flow`,
`test_mobile_layout`, `test_run_progression`, `test_player_projectiles`, `test_passive_effects`.

Level Zero contract tests are **synthetic boundary scenarios**, not normal complete
playthroughs: all six selections, genuine initial loadouts, unchanged seeds,
wave/crystal boundaries, distinct boss, two attacks, locked direction, no late
regeneration/adds, actual HP-driven win/loss, replay and menu return.

`GODOT_BIN=<verified binary> GODOT_SKIP_TEMPLATE_DOWNLOAD=1 bash scripts/build_web.sh`
passed with verified local templates. Export checks passed, including exact existing
asset hashes and absence of development instrumentation. Browser review is tracked
separately in the PR; export success alone does not establish browser acceptance.

## Creator acceptance

- [ ] Review all three kits and six appearances on the protected preview.
- [ ] Accept or reject three-wave pacing and prototype difficulty as an experiment.
- [ ] Review telegraph readability, real outcomes, replay and menu return.
- [ ] Review desktop and mobile landscape input/layout.
- [ ] Accept or reject proposed narrative and temporary visual treatment.
- [ ] Confirm independent normal Ruin Alley and unchanged production save data.
- [ ] Keep final art, GDD promotion and merge/release as separate decisions.
