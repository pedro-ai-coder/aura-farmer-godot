class_name GameRules
extends RefCounted

## This foundation contains only approved GDD constants, not the full catalog.

const MAX_WEAPONS: int = 3
const MAX_PASSIVES: int = 5
const DEFAULT_MOVE_SPEED: float = 180.0
const PLAYER_COLLISION_RADIUS: float = 16.0
const RARITY_LEVEL_CAPS: Dictionary = {
    "common": 4,
    "rare": 3,
    "epic": 2,
    "legendary": 1,
}

static func level_cap(rarity: String) -> int:
    return int(RARITY_LEVEL_CAPS.get(rarity, 0))

static func can_equip(weapon_count: int, passive_count: int) -> bool:
    return weapon_count >= 0 and weapon_count <= MAX_WEAPONS and passive_count >= 0 and passive_count <= MAX_PASSIVES
