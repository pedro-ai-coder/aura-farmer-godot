# GDD §10 — Legendary window migration

The first solo Godot slice now implements the approved six-card legendary selection.

- At 09:00, pause simulation and show three distinct random legendary buffs from the GDD pool and the three legal weapons for the hero role.
- A user may select one or defer without spending the one-per-run entitlement.
- At 12:00, the **identical** cached six cards are shown again if no legendary was selected. They are not rerolled.
- Between the 9-minute and 14:55 boundaries, `L` / a visible Legendary button can reopen the same offer. At 14:55 it expires without an automatic choice.
- An equipped weapon is promoted in its slot to legendary level 1; a new weapon/passive may use a free slot, or ask the user to explicitly select an occupied slot to replace.
- A legendary passive remains fixed to the prescribed rarity and max level. Choosing one consumes the run's entitlement.

Headless tests verify the times, deferred offer identity, role/slot legality and no duplicate entitlement for all three solo heroes.

**Unfinished Phaser parity:** many advanced legendary weapon secondary attacks, the full legendary passive trigger effects, final boss berserk, polished replacement UI, artwork-specific VFX and save portability. Do not imply that selecting an item guarantees its entire advanced combat effect is ported.

The GDD is the source of truth; gameplay changes should be reviewed against §10 and §§7–9.
