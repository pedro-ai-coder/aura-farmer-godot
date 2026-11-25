extends "res://scripts/review/no_u_scenario.gd"
## V4/V3 PRESENTATION / V2 GAMEPLAY. EXPERIMENTAL — NOT CANONICAL — NOT APPROVED FOR PRODUCTION.
## Positive HP loss after mitigation/shields, including environment; survival required.
const ReverseImpact := preload("res://scripts/vfx/no_u_reverse_impact_v3.gd")
var treatment := 3
var contract_case := 0
var input_stage := 0
const CASES := ["LIVE COMBAT", "HP HIT", "SHIELD ONLY", "SIMULTANEOUS", "RECHARGE", "FATAL", "ENVIRONMENT"]

func _init(selected_density: int, counter_pulse: bool, selected_treatment: int = 3, selected_case: int = 0) -> void:
    super(selected_density, counter_pulse)
    treatment = selected_treatment
    contract_case = selected_case

func is_reactive() -> bool:
    return treatment >= 2

var resolving := false
var last_activation := -INF

func label() -> String:
    return "QA / %s / %s / %s" % [["A ORIGINAL", "B COUNTER-PULSE V1", "C REVERSE IMPACT V3 / REACTIVE", "D REVERSE IMPACT V4 / REACTIVE"][treatment], "DENSE" if density == 2 else "NORMAL", CASES[contract_case]]

func prepare(game) -> RefCounted:
    var original := super.prepare(game)
    input_stage = 0
    if not is_reactive():
        return original
    resolving = false
    last_activation = -INF
    game.passive_timers["no_u_next"] = 0.0
    if game.combat_audio != null and game.combat_audio.playback_enabled:
        game.combat_audio.clips["no_u_reverse_v3"] = game.combat_audio.make_clip([0.26, 1050.0, 47.0, 0.40] if treatment == 3 else [0.19, 760.0, 58.0, 0.32])
    if treatment == 3:
        return load("res://scripts/vfx/no_u_reverse_impact_v4.gd").new()
    return ReverseImpact.new()

func on_equipment_committed(game, previous_ids: Array) -> void:
    if is_reactive() and not "no-u" in previous_ids and game._passive_level("no-u") > 0:
        game.passive_timers["no_u_next"] = 0.0

func status_label(game) -> String:
    var remaining := maxf(0.0, float(game.passive_timers.get("no_u_next", 0.0)) - game.run_time)
    var identity := ("NO U V4 · EXP" if treatment == 3 else "NO U V3 · EXP") if is_reactive() else ("NO U A" if treatment == 0 else "NO U B")
    var readiness := "READY ON HP LOSS" if is_reactive() else "PERIODIC READY"
    return "%s / %s" % [identity, readiness if remaining <= 0.0 else "RECHARGE %.1fs" % remaining]

func on_player_damage(game, old_hp: float, source: Dictionary, hazard: bool) -> void:
    if not is_reactive() or resolving or game.mode != "playing" or game.hp <= 0.0 or game.hp >= old_hp \
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
    if OS.has_feature("no_u_review"):
        print("No U V%d trigger: " % (4 if treatment == 3 else 3), JSON.stringify({"at": game.run_time, "hp_loss": old_hp - game.hp,
            "survived": true, "environment": source.is_empty(), "hazard": hazard}))
        report(game, center, 200.0, hits, weakened)
    if game.passive_feedback != null:
        game.passive_feedback.notify(game, "no-u", "NO U · REVERSE IMPACT", "RETALIATE / ENEMY ATK ↓20% · BOSS ↓10%")
    resolving = false


func tick_inputs(game) -> void:
    if contract_case == 0 or game.mode != "playing":
        return
    var due := 1.25 if input_stage == 0 else (2.0 if input_stage == 1 else 16.25)
    if game.run_time < due or input_stage >= (3 if contract_case == 4 else 1):
        return
    input_stage += 1
    var source: Dictionary = game.enemies[0] if not game.enemies.is_empty() else {}
    if contract_case == 2:
        game._grant_weapon_shield("so-back", 100.0, 2.0)
    if contract_case == 6:
        game._schedule_hazard(game.player_pos, 50.0, 0.0, 2.0, 10.0)
    else:
        for hit in (3 if contract_case == 3 else 1):
            game._deal_damage_to_player(1000000.0 if contract_case == 5 else 10.0, source)
    print("No U QA input: ", JSON.stringify({"case": CASES[contract_case], "stage": input_stage,
        "at": game.run_time, "hp": game.hp, "shield": game.shield, "mode": game.mode}))
