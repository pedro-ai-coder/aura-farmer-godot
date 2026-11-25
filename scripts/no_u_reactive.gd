extends RefCounted
## Exact approved reactive resolver extracted from reviewed 5bb1bbb.
const EnemyRules := preload("res://scripts/solo_enemy_rules.gd")
var resolving := false
var last_activation := -INF

func on_equipment_committed(game, previous_ids: Array) -> void:
    if not "no-u" in previous_ids and game._passive_level("no-u") > 0:
        game.passive_timers["no_u_next"] = 0.0

func on_player_damage(game, old_hp: float, source: Dictionary, hazard: bool) -> void:
    if resolving or game.mode != "playing" or game.hp <= 0.0 or game.hp >= old_hp \
        or game._passive_level("no-u") == 0 or game.run_time == last_activation \
        or game.run_time < float(game.passive_timers.get("no_u_next", 0.0)):
        return
    resolving = true
    last_activation = game.run_time
    var center: Vector2 = game.player_pos
    # Preserve production target eligibility and the documented future-born weaken discrepancy.
    var hits: Array[Dictionary] = game._damage_nearby(200.0, 0.30 * game._base_power(), true)
    var weakened: Dictionary = {}
    for enemy: Dictionary in game.enemies:
        if center.distance_to(enemy["pos"]) <= 200.0:
            var boss: bool = bool(EnemyRules.DATA[enemy["kind"]]["boss"])
            enemy["weaken"] = 0.10 if boss else 0.20
            enemy["weaken_until"] = game.run_time + (2.0 if boss else 4.0)
            weakened[enemy["id"]] = [enemy["weaken"], enemy["weaken_until"]]
    # Reserve before observers: reentrant callbacks cannot trigger a second activation.
    game.passive_timers["no_u_next"] = game.run_time + 15.0
    if game.no_u_vfx != null and game.mode in ["playing", "won"]:
        game.no_u_vfx.classify(hits, game.enemies)
        game.no_u_vfx.incoming(source.get("pos", center), center, hazard)
        game.no_u_vfx.pulse(center, 200.0, game.run_time, hits, weakened)
    if game.combat_audio != null:
        game.combat_audio.play_event("no_u_reverse_v3", game.run_time, 5)
    game.no_u_resolved.emit(center, 200.0, game.run_time, hits, weakened)
    if game.passive_feedback != null:
        game.passive_feedback.notify(game, "no-u", "NO U · REVERSE IMPACT", "RETALIATE / ENEMY ATK ↓20% · BOSS ↓10%")
    resolving = false


