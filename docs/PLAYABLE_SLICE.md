> Historical foundation notes. Current canonical clock: five 120-second waves, Big Hater at 10:00, recoverable berserk at 12:00 (GDD §25.1). Later implementation and validation are tracked in MIGRATION_PROGRESS.md and QA_BACKLOG.md. Earlier completion/parity gaps below describe that foundation, not current feature coverage.

# First playable Godot solo slice — implementation scope

This PR implements a *minimal* runnable Godot-only solo loop, explicitly NOT the full GDD demo or approved artwork port.

Implemented: select the three approved solo heroes, keyboard or mobile drag movement, simple fixed-grid environment and cover avoidance, nine approved weapon IDs (three per role), three equipped weapon slots, five passive slots, auto-attacks, enemy spawns, five timed waves, deterministic seeded choice generation, XP/level upgrade dialog that pauses combat, Aura accumulation with a manually activated hero-specific Flex, damage/HP/shield, XP and recovery drops, timed events, Big Hater, victory/defeat, menu, pause and a small Godot-native summary save.

Limitations / not yet accepted against the GDD:
- Graphics are **temporary procedural diagnostics**, not approved Cartoon Arcade assets. No official sprite/animation files are ported.
- Attack animations, collision precision, ranged projectiles, AI telegraphs, role-specific effects and most of the 23 passive effects are simplified or not implemented. The 23 passive IDs are present for future catalog migration; displaying a passive card is not proof its GDD effect is implemented.
- GDD rarity promotion, legendary offers and complete Flex interactions are not yet ported. Content balance, final boss mechanics and 15-minute completion remain unverified.
- The Godot-native profile file is deliberately independent of the Phaser localStorage v2 save contract. It does NOT import or silently convert existing saves.
- Real Web/Android/iOS export/device QA is not included in this PR.

Next: reconcile rules against the reference Phaser `main`, integrate approved assets, expand deterministic contract tests, and export Web via a separate PR.

Manual smoke tests when Godot is available: choose 1/2/3, move with WASD/arrows, automatic attack within range, collect XP, open a card, choose upgrade, verify pause/flex and defeat/restart. Run `bash scripts/validate.sh` for headless import, foundational contract check, scene load.

This PR preserves `docs/GDD.md` as the product authority, does not change the original Phaser repository, and does not claim production readiness.
