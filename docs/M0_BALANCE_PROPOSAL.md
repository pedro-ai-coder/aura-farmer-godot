# BALANCE PROPOSAL - diagnostics only, no numerical changes

Baseline/current simulation: `125604db7f78ae9ee48e82c63e37eea8a7ac57f4`. Evidence: QA [#6 Video Project 2 record](https://github.com/pedro-ai-coder/clutchpunks-qa-evidence/issues/6#issuecomment-7200210180), `SURVIVAL_STRATEGIC_EVIDENCE.md` and raw historical `SURVIVAL_STRATEGIC_RUNS.json`. Historical automated seeds are not current human reproduction.

## Late Wave 5 / Sigma

Two creator-recorded losses at 09:25 and 09:26 (levels 24, 657/650 kills) establish repeat subjective difficulty, not an identified fatal source. Doomscroll Prime arrives at 08:15, not 09:25; Big Hater cannot explain either loss because it arrives at 10:00. The 09:30 boss countdown also starts after those losses. There is no new scheduled encounter at 09:25.

Actual pressure in `solo_run.gd::_enemy_auxiliary/_step_enemies`: Doomscroll Prime periodically creates two 100-U ground zones, warning 1s then active 3s, 12 base damage, every 7s while not terminal-interrupted. It also schedules a 400-U cone with 0.6s warning, 18 damage, every 4s. `_step_hazards` allows persistent ground zones to tick each second; separate overlapping sources can each damage. These are base amounts before resistance/weaken/shield, not guaranteed HP loss. The existing silhouette/outline ambiguity can lead a player to mistake a damaging zone for friendly pulse/Wi-Fi/pickup geometry; this sprint addresses that presentation only.

`_spawn_logic` continues the unchanged Wave-5 density and within-wave ramp before boss entry. Earlier event enemies can remain alive; Reply Guy's recurring adds, Mod Supremo lanes, chargers, ranged shots, ground zones and support mobs may overlap. Enemy HP/damage wave multipliers apply to ordinary mobs; event/boss stats are handled separately in `_spawn_enemy`. No count, time or multiplier changed here.

Recovery is conditional, not automatic invulnerability: snacks heal 18% max HP times support; Safe Spot requires the existing two-second channel, heals 25% times support and has its existing cooldown. Reach, routing, damage during collection, local drop availability and support/build choices matter. Level 24 is below max-level periodic recovery. A kill count does not establish sustained healing or suitable damage against event HP.

Historical Sigma seed 451 won at 674.72s, with 599.72 HP healed and four Safe Spot uses; seed 452 died at 148.42s. That contradicts mechanical unwinnability but proves neither human fairness nor a stable win rate. Missing for both current videos: seed, legal final build, actual final damage-source log, recovery route and surviving encounter set. Do not assign the fatal hit to Doomscroll Prime solely from timestamp.

## Cool Kid

Early death before 02:15 is CREATOR-REPORTED, UNRESOLVED. Video Project 2 features Sigma and does not independently reproduce this claim. Current baseline gives Cool Kid 110 initial HP and 5% resistance; the melee starter requires closer positioning. `_deal_damage_to_player` grants its active Flex contact reduction only against ordinary non-boss contact; ranged shots, hazards and event bosses remain dangerous. This is an explanation of existing eligibility, not evidence of a numerical defect or permission to buff.

Historical Cool Kid seed 451 survived 569.95s with 769.94 HP healed: Reply Guy direct damage 324.90, Doomscroll Prime direct 245.20 and hazards 44.23 HP. Seed 452 survived 404.90s: Reply Guy 119.7 and Hater shots 67.43 HP were major sources. Neither reached Big Hater. These runs identify plausible source categories and strategy sensitivity, not a current-build human failure rate or reproduction of pre-first-miniboss death.

## Proposed decision

Keep all numbers unchanged for this review candidate. Review the clearer combat presentation first. If pressure remains unacceptable, obtain one targeted ordinary Cool Kid run and the final minute of a Sigma run with seed, build, damage-source and recovery evidence using the existing recorder. No campaign has been run or scheduled. Separate potential decisions by source: ranged/event contact, persistent hazard overlap, recovery access, or legal-build output. Any HP, damage, density, drop or progression adjustment needs an explicit creator-approved numerical proposal with its canonical baseline before implementation. Current evidence does not justify a specific buff/nerf percentage.
