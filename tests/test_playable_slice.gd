extends SceneTree

## Fast headless integration checks for the early playable loop.
## This does not replace a complete 15-minute run or browser/device testing.

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(condition: bool, description: String) -> void:
    if not condition:
        failures.append(description)

func _verify() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn")
    _expect(scene != null, "Godot playable scene could not load")
    if scene == null:
        quit(1)
        return
    var game: Node = scene.instantiate()
    get_root().add_child(game)
    _expect(game.get("mode") == "menu", "Game must start at the hero menu")

    # All three approved solo starters must be playable.
    var ids := ["sigma", "cool-kid", "alpha"]
    var starters := ["no-cap", "keyboard-warrior", "cope-shield"]
    for idx in range(3):
        game.call("start_run", idx)
        var hero: Dictionary = game.get("hero")
        var weapons: Array = game.get("weapons")
        _expect(game.get("mode") == "playing", "Hero selection did not start a run")
        _expect(hero.get("id") == ids[idx], "Incorrect selected hero ID")
        _expect(weapons.size() == 1, "Starter must occupy exactly one weapon slot")
        if weapons.size() == 1:
            _expect(weapons[0].get("id") == starters[idx], "Incorrect starter weapon")

    # Deterministic basic combat should produce a kill and an XP orb.
    game.call("start_run", 0)
    game.call("_spawn_enemy", "npc")
    var enemies: Array = game.get("enemies")
    _expect(enemies.size() == 1, "Enemy spawn failed")
    if enemies.size() == 1:
        var enemy: Dictionary = enemies[0]
        enemy["pos"] = game.get("player_pos") + Vector2(80, 0)
        game.call("_fire_weapons", 0.1)
        for step in range(4):
            game.call("_step_player_shots", 0.025)
        _expect(int(game.get("kills")) == 1, "Starter weapon must be able to defeat a basic enemy")
        _expect((game.get("pickups") as Array).size() >= 1, "Defeated enemy must create an XP orb")

    # XP offers must pause the run, offer choices, and resume after selection.
    game.call("start_run", 1)
    game.call("_gain_xp", 100.0)
    _expect(int(game.get("pending_choices")) > 0, "Experience did not increase the level")
    game.call("_open_choice")
    _expect(game.get("mode") == "choice", "Level-up must pause simulation")
    _expect((game.get("selection") as Array).size() == 3, "Level-up must offer three choices")
    var pending := int(game.get("pending_choices"))
    game.call("pick_upgrade", 0)
    game.call("_confirm_selection")
    _expect(int(game.get("pending_choices")) == pending - 1, "Upgrade selection must consume one offer")

    # Flex is manual, consumes 100 Aura, and uses each hero's duration.
    game.call("start_run", 2)
    game.set("aura", 100.0)
    game.call("_use_flex")
    _expect(float(game.get("aura")) == 0.0, "Flex must consume the filled Aura gauge")
    _expect(float(game.get("flex_time")) > 0.0, "Flex activation must start its duration")
    _expect(float(game.get("shield")) > 0.0, "Alpha Hold must grant a shield")

    # Boss can be spawned and victory is terminal and persisted to the Godot slice profile.
    game.call("start_run", 0)
    game.set("run_time", 900.0)
    game.call("_spawn_logic", 0.05)
    _expect(bool(game.get("boss_spawned")), "Boss must spawn at 15 minutes")
    var boss_enemies: Array = game.get("enemies")
    _expect(boss_enemies.size() == 1, "Boss transition must remove ordinary enemies")
    if boss_enemies.size() == 1:
        _expect(boss_enemies[0].get("kind") == "boss", "Spawned entity must be Big Hater")
        game.set("run_time", 900.8) # Portal arrival must complete before boss damage.
        game.call("_hit_enemy", boss_enemies[0], 30001.0)
        _expect(game.get("mode") == "won", "Defeating Big Hater must end in victory")

    game.queue_free()
    if failures.is_empty():
        print("PASS: Godot solo hero, combat, progression, Flex and boss smoke tests")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
