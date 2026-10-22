extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _spawn(game, kind: String) -> Dictionary:
    game.call("start_run", 0)
    game.set("player_pos", Vector2(800,550))
    game.call("_spawn_enemy", kind, {"pos":Vector2(700,550)})
    var enemy: Dictionary = game.get("enemies")[0]
    enemy["next_attack"] = 0.0
    return enemy

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    var boss := _spawn(game, "boss")
    game.call("_step_enemies", 0.0)
    var slam: Dictionary = game.get("hazard_zones")[0]
    game.set("player_pos", Vector2(700,700))
    game.set("run_time", 0.7)
    game.call("_step_enemies", 0.0)
    _expect(slam["locked"] and Vector2(slam["dir"]).dot(Vector2.DOWN) > 0.99, "Hate Slam tracks until exactly 0.3 seconds before impact")
    var locked: Vector2 = slam["dir"]
    var origin: Vector2 = slam["pos"]
    game.set("player_pos", Vector2(800,550))
    game.set("run_time", 0.9)
    game.call("_step_enemies", 0.0)
    _expect(slam["dir"] == locked and slam["pos"] == origin, "Committed Slam cannot retarget after lock")
    game.set("run_time", 1.5)
    game.call("_step_enemies", 0.1)
    _expect(boss["pos"] == origin, "Big Hater preserves the 1.2-second post-impact recovery")
    game.set("run_time", 2.2)
    game.call("_step_enemies", 0.1)
    _expect(boss["pos"] != origin, "Big Hater can move after recovery ends")
    var reply := _spawn(game, "reply-guy")
    game.call("_step_enemies", 0.0)
    game.set("run_time", 1.0)
    var position: Vector2 = reply["pos"]
    game.call("_step_enemies", 0.1)
    _expect(reply["pos"] == position, "Reply Guy exposes a stationary 1.5-second window after its cone")
    var ohio := _spawn(game, "ohio-express")
    ohio["phase"] = "charge-warning"
    ohio["attack_at"] = 0.0
    ohio["charge_count"] = 2
    game.call("_step_enemies", 0.0)
    var charge_end: float = ohio["charge_until"]
    _expect(is_equal_approx(ohio["recover_until"], charge_end + 2.0), "Third Ohio charge schedules two seconds of recovery")
    game.set("run_time", charge_end + 0.1)
    position = ohio["pos"]
    game.call("_step_enemies", 0.1)
    _expect(ohio["pos"] == position, "Ohio cannot keep charging or chase during recovery")
    var leech := _spawn(game, "fanum-leech")
    game.call("_step_enemies", 0.0)
    _expect(game.get("hazard_zones").size() == 1 and game.get("hazard_zones")[0]["shape"] == "tether", "Leech creates one breakable link")
    game.set("player_pos", Vector2(700,700))
    for time in [0.8,1.8,2.8]:
        game.set("run_time", time)
        game.call("_step_hazards")
    _expect(game.get("hp") == 85.0, "Tether follows its target for exactly three ticks after the warning")
    leech = _spawn(game, "fanum-leech")
    game.call("_step_enemies", 0.0)
    game.set("player_pos", Vector2(1000,550))
    game.set("run_time", 0.2)
    game.call("_step_hazards")
    game.set("player_pos", Vector2(800,550))
    game.set("run_time", 0.8)
    game.call("_step_hazards")
    _expect(game.get("hp") == 100.0 and game.get("hazard_zones").is_empty(), "Leaving 240 units breaks the whole link; returning does not reconnect")
    game.call("start_run", 0)
    game.set("wave", 5)
    game.set("player_pos", Vector2(800,550))
    game.call("_spawn_enemy", "fanum-leech", {"pos":Vector2(700,550)})
    leech = game.get("enemies")[0]
    leech["next_attack"] = 0.0
    game.call("_step_enemies", 0.0)
    _expect(is_equal_approx(game.get("hazard_zones")[0]["damage"], 5.0 * 1.75), "Leech ticks apply the approved common-enemy wave damage scale once")
    game.get("hazard_zones").clear()
    game.call("_spawn_enemy", "copium-puffer", {"pos":Vector2(850,550)})
    var puffer: Dictionary = game.get("enemies").back()
    game.call("_hit_enemy", puffer, 1e6)
    _expect(is_equal_approx(game.get("hazard_zones")[0]["damage"], 12.0 * 1.75), "Puffer death cloud applies common-enemy wave damage scale once")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Boss commitment/recovery, event recovery and breakable three-tick Leech tether")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
