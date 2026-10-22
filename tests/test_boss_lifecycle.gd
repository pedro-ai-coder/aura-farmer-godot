extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)

func _spawn(game, kind: String) -> Dictionary:
    game.call("start_run", 0)
    game.set("player_pos", Vector2(800, 550))
    game.call("_spawn_enemy", kind, {"pos": Vector2(700, 450)})
    return game.get("enemies")[0]

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    var boss := _spawn(game, "boss")
    game.set("run_time", 1000.0)
    boss["stagger"] = 80.0
    game.call("_schedule_hazard", Vector2(700,450), 100.0, 1.0, 0.2, 10.0, "circle", Vector2.RIGHT, boss)
    game.call("_schedule_hazard", Vector2(700,450), 100.0, 0.0, 2.0, 10.0, "circle", Vector2.RIGHT, boss)
    game.call("_stagger_enemy", boss, 15.0)
    game.call("_stagger_enemy", boss, 15.0)
    _expect(boss["stagger_until"] == 1003.0, "Stagger fills at 100 and exposes for three seconds")
    _expect(boss["stagger_locked"] == 1023.0, "Stagger refill lock starts after exposure")
    _expect(game.get("hazard_zones").size() == 1, "Stagger cancels preparation but preserves active damage")
    game.call("_stagger_enemy", boss, 100.0)
    _expect(boss["stagger"] == 0.0, "Stagger cannot refill during its lock")
    game.set("run_time", 1081.0)
    boss["stagger_until"] = 1082.0
    boss["regen_stamp"] = 1080
    boss["hp"] = 1000.0
    boss["next_attack"] = 1e9
    game.call("_step_enemies", 0.0)
    _expect(boss["hp"] == 1000.0, "Exposed berserk boss cannot regenerate")
    game.call("_hit_enemy", boss, 100.0)
    _expect(is_equal_approx(boss["hp"], 1000.0 - 100.0 * 0.65 * 1.15), "Exposure and berserk resistance multiply")
    game.set("run_time", 1082.0)
    var before: float = boss["hp"]
    game.call("_step_enemies", 0.0)
    _expect(is_equal_approx(boss["hp"], before + 30.0), "Boss regeneration resumes after exposure")
    boss = _spawn(game, "boss")
    game.call("_hit_enemy", boss, 20000.0)
    _expect(boss["ring_phase"] and boss["beam_phase"], "Boss thresholds latch when crossed")
    boss["hp"] = 30000.0
    boss["attack_slot"] = 2
    boss["next_attack"] = 0.0
    game.call("_step_enemies", 0.0)
    _expect(game.get("hazard_zones").size() == 2, "Healing cannot remove the double-ring phase")
    boss = _spawn(game, "boss")
    for i in range(3):
        boss["next_attack"] = 0.0
        boss["attack_slot"] = 3
        game.call("_step_enemies", 0.0)
    var adds: Array = []
    for enemy: Dictionary in game.get("enemies"):
        if enemy.get("add", false): adds.append(enemy)
    _expect(adds.size() == 8, "Big Hater has at most eight living solo adds")
    game.set("run_time", 1.0)
    for enemy: Dictionary in adds:
        _expect(enemy["xp"] == 0, "Final boss adds cannot grant XP")
        game.call("_hit_enemy", enemy, 100000.0)
    _expect(game.get("pickups").is_empty(), "Final boss adds cannot drop farmable resources")
    _expect(boss["exposed_until"] == 4.0, "Defeating an add Hype Bot opens the three-second damage window")
    var reply := _spawn(game, "reply-guy")
    reply["next_attack"] = 0.0
    game.call("_step_enemies", 0.0)
    _expect(reply["next_attack"] == 4.0 and game.get("enemies").size() == 1, "Reply cone is separate from twelve-second adds")
    game.set("run_time", 12.0)
    reply["next_attack"] = 1e9
    game.call("_step_enemies", 0.0)
    _expect(game.get("enemies").size() == 5, "Reply adds fire independently of its primary timer")
    var mod := _spawn(game, "mod-supremo")
    mod["next_attack"] = 1e9
    mod["hp"] = 1000.0
    game.call("_step_enemies", 0.0)
    game.call("_step_enemies", 0.0)
    _expect(game.get("enemies").size() == 3, "Mod half-health reinforcement triggers once without waiting for attack")
    game.call("start_run", 0)
    game.call("_schedule_hazard", Vector2(700,550), 280.0, 1.0, 1.5, 25.0, "ring", Vector2.RIGHT)
    var ring: Dictionary = game.get("hazard_zones")[0]
    game.set("run_time", 1.0)
    _expect(not game.call("_hazard_contains", ring, Vector2(780,550)), "Ring has a safe forward opening")
    _expect(game.call("_hazard_contains", ring, Vector2(620,550)), "Ring begins at radius 80")
    game.set("run_time", 1.75)
    _expect(not game.call("_hazard_contains", ring, Vector2(620,550)), "Ring leaves its old radius")
    _expect(game.call("_hazard_contains", ring, Vector2(520,550)), "Ring expands to radius 180 halfway through")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Stagger, berserk regeneration/exposure, threshold latching, capped adds, independent event timers and expanding safe-gap ring")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
