extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)

func _setup(game, id: String, position: Vector2) -> Dictionary:
    game.call("start_run", 1)
    game.set("player_pos", Vector2(700, 550))
    var weapons: Array = game.get("weapons")
    weapons.clear()
    weapons.append({"id": id, "level": 1, "rarity": "common", "timer": 0.0})
    game.call("_spawn_enemy", "npc", {"pos": position})
    var enemy: Dictionary = game.get("enemies")[0]
    enemy["hp"] = 1000.0
    enemy["max"] = 1000.0
    return enemy

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    var enemy := _setup(game, "brainrot-feed", Vector2(850, 550))
    game.call("_fire_weapons", 0.01)
    _expect(enemy["hp"] == 1000.0, "Brainrot has no damage before its delayed explosion")
    game.call("_toggle_pause")
    game.call("_process", 0.50)
    _expect(game.get("run_time") == 0.0, "Pause freezes the pending attack clock")
    _expect(game.get("weapon_areas").size() == 1, "Pause preserves pending attacks")
    game.call("_toggle_pause")
    game.set("run_time", 0.44)
    game.call("_step_weapon_areas")
    _expect(enemy["hp"] == 1000.0, "Brainrot waits the full 0.45 seconds")
    enemy["pos"] = Vector2(1050, 550)
    game.set("run_time", 0.45)
    game.call("_step_weapon_areas")
    _expect(enemy["hp"] == 1000.0, "Brainrot mark stays at the original target position")
    game.set("run_time", 0.58)
    game.call("_step_weapon_areas")
    _expect(game.get("weapon_areas").is_empty(), "Blast is removed after its active window")
    enemy = _setup(game, "ban-hammer", Vector2(780, 550))
    game.call("_fire_weapons", 0.01)
    _expect(enemy["hp"] == 1000.0, "Ban Hammer preserves its windup")
    game.set("run_time", 0.30)
    game.call("_step_weapon_areas")
    _expect(is_equal_approx(enemy["hp"], 1000.0 - 0.90 * 95.0), "Ban Hammer resolves at the approved deadline")
    for id in ["keyboard-warrior", "chad-hands"]:
        enemy = _setup(game, id, Vector2(760, 550))
        game.call("_fire_weapons", 0.01)
        var first_hp: float = enemy["hp"]
        _expect(first_hp < 1000.0, "Paired attack has an immediate first hit")
        _expect(int(game.get("primary_hits")) == 1, "First paired hit triggers one activation")
        game.set("run_time", 0.18)
        game.call("_step_weapon_areas")
        _expect(enemy["hp"] < first_hp, "Paired attack resolves its delayed second hit")
        _expect(int(game.get("primary_hits")) == 1, "Second paired hit cannot duplicate passive activation")
    game.call("start_run", 0)
    _expect(game.get("weapon_areas").is_empty(), "Restart discards delayed attacks")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Fixed blast position, windup, paired hits and shared primary activation")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
