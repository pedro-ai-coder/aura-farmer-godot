# GDD bestiary migration — first playable enemy-pattern pass

The Godot slice now uses exactly the 17 approved enemy-kind IDs and baseline HP, speed, attack damage, XP, wave unlocks and collision radii from the Phaser catalog / GDD §§11–12.

Implemented: wave-eligible weighted spawn pools, Hater appearing after 90 seconds, four timed event bosses (3:15, 6:15, 9:15, 12:15), 15-minute Big Hater transition, 3-minute berserk damage/regen ramp, projectile line warnings for Hater and Ping Sniper, basic Ratio Ram charge warnings, Doomscroller hazard marks, simple Hype Bot shields, Comment Mod healing, Copium Puffer death cloud, Fanum Leech warning line and simplified boss cone/beam/ring/add patterns.

All visual warnings are presentation effects tied to gameplay deadlines. Simulation does not advance while modal upgrades or legendary offers are open.

**Not yet exact Phaser parity:** AI-specific collision/cover pathfinding, complete bosses/add spawn control, all six attack patterns in final GDD, projectile obstruction swept collision, enemy animation frame mapping for 17 kinds, elite modifiers, shields/armor effects, stagger, status effects, difficulty tuning and seeded full-run evidence. The approved art is loaded but non-specific kinds still reuse the source Phone Guy/Hater render where a dedicated frame mapping is absent. Do not treat this as an accepted full bestiary port. `docs/GDD.md` remains authoritative.
