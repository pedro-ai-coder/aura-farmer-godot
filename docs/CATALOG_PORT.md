# GDD §10 item offer / inventory parity

This migration uses the **GDD** to define legal rarity levels and wave-dependent offer weights. `SoloOfferRules` preserves the exact current Phaser solo subset of **23 passive IDs**, including their fixed rarity and role restrictions.

Implemented:
- 3 legal cards per level; initially favor one equipped-item upgrade when available.
- Pick category before weighted rarity for cards based on GDD wave weights.
- Never offer legendary items in normal cards; do not invent rare/epic variants of a common passive.
- Weapons are role-locked to the selected hero; passive role restrictions are enforced. Three weapon slots, five passive slots, no duplicate IDs, and rarity cap levels preserved.
- Upgrade equipped items within their rarity cap. Promote equipped weapons to a higher legal rarity, retaining the legal level.
- When equipment slots are full, choosing a new item explicitly opens a replacement selection. No silent deletion of an existing item.
- Built Different raises both maximum HP and current HP by the granted amount. Weapon level 1 no longer has a spurious 5% cooldown reduction.
- Headless tests run the catalog contract for each of the three solo heroes across all five waves.

**Not yet at Phaser parity:** legendary choice window (six cards, defer/reopen), timer-specific passive effects, exact projectile physics, proc counting, all enemy patterns and event mechanisms, responsive modal layout, full save compatibility. Catalog IDs do not imply that all passive effects have been implemented. These are separate gameplay PRs; `docs/GDD.md` remains authoritative.

Manual review: collect XP, open offers and verify role/rarity; equip 3 weapons and 5 passives, then choose a new item and explicitly select which old item is replaced.
