extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    for hero in range(3):
        game.call("start_run", hero)
        var total := 0.0
        for wave in range(2, 6):
            game.set("run_time", float((wave - 1) * 180) - 0.01)
            game.set("spawn_timer", 1e9)
            game.call("_advance", 0.02)
            total += float(40 * wave)
            _expect(is_equal_approx(game.get("total_xp"), total), "Every hero receives the four exact wave XP rewards once")
            var safety := 0
            while game.get("mode") != "playing" and safety < 100:
                game.call("pick_upgrade", 0)
                game.call("_confirm_selection")
                safety += 1
            _expect(safety < 100, "Queued normal/legendary choices can finish through the real confirmation flow")
        game.set("run_time", 899.99)
        game.call("_advance", 0.02)
        _expect(game.get("boss_spawned"), "Every hero reaches Big Hater through the game timeline")
        while game.get("mode") != "playing":
            game.call("pick_upgrade", 0)
            game.call("_confirm_selection")
        var boss: Dictionary = {}
        for enemy: Dictionary in game.get("enemies"):
            if enemy["kind"] == "boss": boss = enemy
        game.set("run_time", 1081.0)
        boss["hp"] = 100.0
        boss["regen_stamp"] = 1080
        game.call("_step_enemies", 0.0)
        _expect(boss["hp"] > 100.0, "Berserk does not force a defeat and regeneration remains active")
        game.call("_hit_enemy", boss, 100000.0)
        _expect(game.get("mode") == "won", "Every starter can resolve the controlled timeline to a persisted victory")
        var frozen: float = game.get("run_time")
        game.call("_advance", 1.0)
        _expect(game.get("run_time") == frozen, "Victory is terminal")
    game.call("start_run", 0)
    game.set("player_pos", Vector2(700,550))
    game.call("_spawn_enemy", "npc", {"pos":Vector2(760,550), "telegraph":true, "elite":true})
    var elite: Dictionary = game.get("enemies")[0]
    game.call("_hit_enemy", elite, 1000.0)
    _expect(elite["hp"] == 35.0 * 2.5 and elite["shield"] == 35.0 * 2.5 * 0.20, "Portal enemies are not damageable before arrival; elite has one shield modifier")
    _expect(game.call("_nearest_target").is_empty(), "Auto aim cannot target a portal")
    game.set("run_time", 0.8)
    _expect(not game.call("_nearest_target").is_empty(), "Portal becomes targetable at its exact deadline")
    game.call("_hit_enemy", elite, 1000.0)
    _expect(game.get("pickups").size() == 1 and game.get("pickups")[0]["xp"] == 60.0, "Elite retains its approved XP and deterministic first kill has no special drop")
    game.call("start_run", 0)
    game.set("player_pos", Vector2(700,550))
    game.set("hp", 1000000.0)
    for i in range(300):
        game.call("_spawn_enemy", "npc", {"pos":Vector2(1050 + i % 10, 600 + i % 8)})
        game.get("enemies").back()["hp"] = 1000000.0
    for i in range(150):
        game.call("_queue_player_shot", "no-cap", Vector2.RIGHT, 1.0, 600.0, 1000)
    var started := Time.get_ticks_usec()
    for i in range(60):
        game.set("run_time", float(i + 1) / 60.0)
        game.call("_step_enemies", 1.0 / 60.0)
        game.call("_step_player_shots", 1.0 / 60.0)
    print("HEADLESS CPU SAMPLE: 300 enemies / 150 initial projectiles, 60 simulation iterations, ", (Time.get_ticks_usec() - started) / 1000.0, " ms; not rendered FPS or device acceptance")
    _expect(game.get("enemies").size() == 300, "Stress fixture does not silently delete enemies")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Controlled three-hero wave/boss/victory timeline, portal/elite/drop contracts and headless stress fixture")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
