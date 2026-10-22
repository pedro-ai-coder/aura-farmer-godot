extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _enemy(game, kind: String, point: Vector2) -> Dictionary:
    game.call("_spawn_enemy", kind, {"pos": point})
    return game.get("enemies").back()

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    for kind in ["hater", "ping-sniper"]:
        game.call("start_run", 0)
        game.set("player_pos", Vector2(700,550))
        var ranged := _enemy(game, kind, Vector2(850,550))
        ranged["next_attack"] = 0.0
        game.call("_step_enemies", 1.0 / 60.0)
        _expect(ranged["pos"].x > 850.0, "Ranged enemy retreats when inside preferred range")
        _expect(Vector2(ranged["locked_direction"]).dot(Vector2.LEFT) > 0.99, "Retreating ranged enemy locks aim at the player, independent of movement")
        var locked: Vector2 = ranged["locked_direction"]
        game.set("player_pos", Vector2(800,700))
        game.set("run_time", 0.6 if kind == "hater" else 1.2)
        game.call("_step_enemies", 0.0)
        _expect(game.get("hostile_shots").size() == 1 and game.get("hostile_shots")[0]["dir"] == locked, "Warning emits one projectile in its committed direction")
    game.call("start_run", 0)
    game.set("player_pos", Vector2(680,550))
    var hater := _enemy(game, "hater", Vector2(520,550))
    hater["next_attack"] = 0.0
    game.call("_step_enemies", 0.0)
    _expect(hater["phase"] == "" and game.get("hostile_shots").is_empty(), "Hater waits when solid cover blocks acquisition")
    game.get("hostile_shots").append({"pos":Vector2(520,550), "dir":Vector2.RIGHT, "speed":800.0, "remaining":800.0, "damage":10.0, "radius":7.0, "source":hater})
    game.call("_step_hostile_shots", 0.2)
    _expect(game.get("hostile_shots").is_empty() and game.get("hp") == 100.0, "Swept projectile path cannot tunnel through cover and damage the player")
    game.call("start_run", 0)
    game.set("player_pos", Vector2(700,550))
    var ram := _enemy(game, "ratio-ram", Vector2(850,550))
    ram["next_attack"] = 0.0
    game.call("_step_enemies", 0.0)
    _expect(is_equal_approx(ram["attack_at"], 0.9), "Ratio Ram preserves the canonical 0.9-second warning")
    game.set("run_time", 0.8)
    game.call("_step_enemies", 0.0)
    _expect(ram["phase"] == "charge-warning", "Ratio Ram cannot charge before its warning completes")
    game.set("run_time", 0.9)
    game.call("_step_enemies", 0.0)
    _expect(ram["phase"] == "charging", "Ratio Ram begins its fixed-direction charge at the deadline")
    game.call("start_run", 1)
    game.set("player_pos", Vector2(700,550))
    var doom := _enemy(game, "doomscroller", Vector2(850,550))
    doom["next_attack"] = 0.0
    doom["weaken"] = 0.20
    doom["weaken_until"] = 10.0
    game.call("_step_enemies", 0.0)
    _expect(game.get("hazard_zones")[0]["source"] == doom, "Persistent zones retain their caster for damage modifiers")
    game.set("run_time", 1.0)
    game.call("_step_hazards")
    _expect(is_equal_approx(game.get("hp"), 110.0 - 8.0 * 0.8 * 0.95), "Source weakness applies to a persistent zone after mitigation")
    game.get("hazard_zones").clear()
    var puffer := _enemy(game, "copium-puffer", Vector2(750,550))
    game.call("_hit_enemy", puffer, 10000.0)
    _expect(game.get("hazard_zones")[0]["source"] == puffer, "Death cloud retains source attribution after removal")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Committed ranged aim, swept cover collision, canonical charge warning and persistent source attribution")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
