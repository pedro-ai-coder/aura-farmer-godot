# Fast playable-slice CI contract

The early Godot solo gameplay slice is checked with a **headless GDScript integration test** in addition to foundational slot/rarity tests. This is smoke coverage only.

Verified by `tests/test_playable_slice.gd`:

- Menu and three approved playable heroes with correct starter weapon IDs
- One normal enemy can be hit and drops XP
- XP levels produce three choices and pause the solo run
- Selecting a card removes exactly one pending choice
- Alpha Hold consumes Aura and provides a shield
- At the 15-minute threshold Big Hater spawns and can be defeated to win

`scripts/validate.sh` runs this test in the required `godot-validation` job. Web export metadata is also syntax-checked without downloading a 1.28GB template archive in every CI PR.

The complete GDD requires far more: accurate timing, nine weapons and 23 passive effects, rarity transitions, telegraphed enemies/boss attacks, art, balance, legacy save import, and full 15-minute playthroughs with Web/Android/iOS validation. **Never present this smoke test as proof of full parity.**
