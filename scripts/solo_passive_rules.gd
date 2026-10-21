class_name SoloPassiveRules
extends RefCounted

## Shared GDD §9 passive arithmetic. Pure functions: never mutate combat state.

static func level(items: Array, id: String) -> int:
    for item in items:
        if item["id"] == id:
            return int(item["level"])
    return 0

static func weapon_frequency(items: Array, timers: Dictionary, time: float, position: Vector2) -> float:
    var base: float = 0.05 * float(level(items, "terminally-online"))
    var viral: int = level(items, "aura-viral")
    if viral > 0 and time < float(timers.get("viral_until", -1.0)):
        base = maxf(base, 0.12 + 0.06 * float(viral - 1))
    var wifi: int = level(items, "w-wifi")
    if wifi > 0 and time < float(timers.get("wifi_until", -1.0)) and position.distance_to(timers.get("wifi_center", position)) <= 160.0:
        base = maxf(base, 0.08 + 0.04 * float(wifi - 1))
    return minf(1.0, base)

static func weapon_damage(items: Array, run_level: int, flex: bool, time: float, timers: Dictionary, cook_stacks: int, cook_expires: float) -> float:
    var damage: float = 1.0 + 0.01 * float(run_level - 1) + 0.06 * float(level(items, "main-character"))
    if level(items, "absolute-cinema") > 0:
        damage *= 1.25
        if flex:
            damage *= 1.20
    if level(items, "w-squad") > 0 and time < float(timers.get("w_squad_until", -1.0)):
        damage *= 1.10
    var cook: int = level(items, "let-him-cook")
    if cook > 0 and time < cook_expires:
        damage *= 1.0 + float(mini(cook_stacks, 5)) * (0.02 + 0.01 * float(cook))
    return damage

static func damage_to_target(items: Array, target: Dictionary, player_pos: Vector2) -> float:
    var value := 1.0
    var hands: int = level(items, "hands-on-sight")
    if hands > 0 and player_pos.distance_to(target["pos"]) <= 150.0:
        value *= 1.0 + 0.07 * float(hands)
    var over: int = level(items, "its-over")
    if over > 0 and float(target["hp"]) < float(target["max"]) * 0.30:
        value *= 1.0 + 0.15 + 0.10 * float(over - 1)
    return value

static func area_scale(items: Array) -> float:
    return 1.0 + 0.06 * float(level(items, "big-meme"))

static func ranged_range_scale(items: Array) -> float:
    return 1.0 + 0.08 * float(level(items, "timeline"))

static func support_scale(items: Array, tank: bool = false) -> float:
    var scale: float = 1.0 + 0.06 * float(level(items, "certified-w"))
    if tank:
        scale *= 1.0 + 0.08 * float(level(items, "cope-harder"))
    if level(items, "w-squad") > 0:
        scale *= 1.25
    return scale
