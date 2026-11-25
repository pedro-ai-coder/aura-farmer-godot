extends RefCounted
## Opt-in fixture. Real enemies, legal equipment, active Solo combat.

const CounterPulse := preload("res://scripts/vfx/no_u_counter_pulse.gd")
const World := preload("res://scripts/solo_world_rules.gd")
const EnemyRules := preload("res://scripts/solo_enemy_rules.gd")
const DENSE_ENEMIES := ["hater", "beta", "doomscroller", "ratio-ram", "copium-puffer", "ping-sniper"]

var density: int
var candidate: bool


func _init(selected_density: int, counter_pulse: bool) -> void:
    density = selected_density
    candidate = counter_pulse


func label() -> String:
    return "QA / NO U / %s / %s" % ["DENSE" if density == 2 else "NORMAL",
        "COUNTER-PULSE" if candidate else "BASELINE"]


func prepare(game) -> RefCounted:
    game._apply_card({"type": "passive", "id": "no-u", "rarity": "legendary", "level": 1})
    if game._passive_level("no-u") != 1:
        push_error("No U review loadout failed the Solo equipment rules")
        return null
    # Prime only the first pulse. Later activations run on the normal 15 s clock.
    game.passive_timers["no_u_next"] = 1.25
    _place(game, "mod-supremo", Vector2(102, -40))
    _place(game, "beta", Vector2(145, 27), true)
    var vulnerable := _place(game, "npc", Vector2(48, 134))
    if not vulnerable.is_empty():
        vulnerable["hp"] = 8.0
    _place(game, "beta", Vector2(-91, -75))
    _place(game, "copium-puffer", Vector2(-136, 99))
    _place(game, "ping-sniper", Vector2(231, 12))
    if density == 2:
        for index in 30:
            var angle := TAU * index / 30.0 + 0.11
            var distance := 142.0 + 38.0 * (index % 3)
            var kind: String = DENSE_ENEMIES[index % DENSE_ENEMIES.size()]
            var point: Vector2 = game.player_pos + Vector2.from_angle(angle) * distance
            if World.walkable(point, float(EnemyRules.DATA[kind]["radius"]), game.map_geometry):
                game._spawn_enemy(kind, {"pos": point, "add": true})
    return CounterPulse.new() if candidate else null


func _place(game, kind: String, offset: Vector2, elite: bool = false) -> Dictionary:
    var radius := float(EnemyRules.DATA[kind]["radius"]) * (1.2 if elite else 1.0)
    for index in 12:
        var point: Vector2 = game.player_pos + offset.rotated(TAU * index / 12.0)
        if World.walkable(point, radius, game.map_geometry):
            game._spawn_enemy(kind, {"pos": point, "elite": elite, "add": true})
            return game.enemies[-1]
    return {}


func report(game, center: Vector2, radius: float, hits: Array[Dictionary], weakened: Dictionary) -> void:
    print("No U QA pulse: ", JSON.stringify({"map": game.map_id, "density": density,
        "candidate": candidate, "reduced_motion": game.profile.settings.reducedMotion,
        "center": [center.x, center.y], "radius": radius, "at": game.run_time,
        "contacts": hits.size(), "weakened": weakened.size()}))
