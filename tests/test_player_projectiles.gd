extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.call("start_run", 0)
    game.set("player_pos", Vector2(700, 550))
    game.call("_spawn_enemy", "npc", {"pos": Vector2(850, 550)})
    var enemy: Dictionary = game.get("enemies")[0]
    enemy["hp"] = 1000.0
    var initial_hp: float = enemy["hp"]
    game.call("_fire_weapons", 0.01)
    _expect(enemy["hp"] == initial_hp, "Firing cannot deal instant ranged damage")
    _expect(game.get("player_shots").size() == 1, "No Cap creates a travelling projectile")
    game.call("_step_player_shots", 0.05)
    _expect(enemy["hp"] == initial_hp, "A distant enemy is not hit before projectile arrival")
    for i in range(3):
        game.call("_step_player_shots", 0.05)
    _expect(enemy["hp"] < initial_hp, "Projectile damages enemy at arrival")
    var after_hit: float = enemy["hp"]
    game.call("_step_player_shots", 0.01)
    _expect(enemy["hp"] == after_hit, "Piercing projectile cannot hit the same enemy twice")
    game.call("start_run", 0)
    _expect(game.get("player_shots").is_empty(), "Restart clears projectiles")
    game.set("player_pos", Vector2(550, 550))
    game.call("_spawn_enemy", "npc", {"pos": Vector2(650, 550)})
    game.call("_fire_weapons", 0.01)
    _expect(game.get("player_shots").is_empty(), "Auto aim cannot shoot through Ruin Alley cover")
    game.call("start_run", 0)
    game.set("player_pos", Vector2(700, 550))
    game.call("_spawn_enemy", "npc", {"pos": Vector2(850, 550)})
    game.call("_fire_weapons", 0.01)
    game.set("run_time", 600.0)
    game.call("_spawn_logic", 0.0)
    _expect(game.get("player_shots").is_empty(), "Boss transition discards surviving player projectiles")
    _expect(game.get("weapon_areas").is_empty(), "Boss transition discards pending weapon areas")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Player projectile travel, collision, hit memory, restart and cover")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
