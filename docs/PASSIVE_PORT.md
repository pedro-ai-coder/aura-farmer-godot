# GDD passive effect port — core solo pass

The canonical `docs/GDD.md`, especially §9, remains authoritative. This PR adds **real effect execution** to existing solo passive equipment instead of treating catalog IDs alone as implementation.

Implemented in the shared arithmetic and game loop:

- Main Character Energy, Terminally Online, Built Different, Thick Skin, Caught in 4K, Big Meme Energy, Across the Timeline, Hands On Sight, Cope Harder and Certified W continuous/typed modifiers.
- Timed W Wi-Fi zone, Let Him Cook stacks, No Cap Streak every fifth directional activation, Homie Check eight-hit healing, Big Chad Energy shield pulse, and Six→Seven seventh-hit explosion.
- It's So Over below-30%-HP damage, Aura Goes Viral on Flex, We Are So Back nonfatal low-HP recovery and shielding.
- Absolute Cinema weapon damage/Flex, W Squad buff window/shield support, Too Sigma to Fall nonfatal low-HP shield and No U periodic damage/weaken.
- Damage/proc separation between primary weapon activations and passive secondary effects; at most two primary hit Aura charges per simulated second, preserved during paused time.
- Sigma Flex requires a target and locks the target until its death. Boss berserk resistance begins at 18:00.

Headless tests check several numeric multipliers, role-specific support coefficients, Aura cap, threshold triggers and Sigma target locking.

**Important parity limitations:** projectile/area scheduling remains simplified; some weapon coefficients, legendary secondary attacks, advanced PvE statuses and stacked cooldown mechanics still differ from the Phaser simulation. Effects of several passives are approximate and not fully parity-verified. Tests here are functional contracts, not seeded Phaser-vs-Godot comparison. Accurate player-to-enemy proc accounting and final 15-minute run balance are subsequent work. Official art remains exactly as approved and no game asset is regenerated.
