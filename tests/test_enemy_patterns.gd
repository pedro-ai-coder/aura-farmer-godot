extends SceneTree

## First-stage bestiary and enemy behavior parity contracts from GDD §§11–12.

var problems: Array[String] = []

func _expect(condition: bool, description: String) -> void:
    if not condition:
        problems.append(description)

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var rules = load("res://scripts/solo_enemy_rules.gd")
    _expect(rules.DATA.size() == 17, "Preserve all 17 source bestiary IDs")
    _expect(rules.EVENT_SCHEDULE.size() == 4, "Four approved timed events")
    _expect(rules.spawn_pool(1, 59.99) == ["npc"], "Early wave one contains only NPC")
    var later: Array[String] = rules.spawn_pool(1, 100.0)
    _expect(later.size() == 8 and later.count("hater") == 1, "Hater starts only after 60 seconds")
    _expect(rules.spawn_pool(2, 210.0).has("ratio-ram"), "Wave two contains Ratio Ram")
    _expect(rules.spawn_pool(3, 410.0).has("doomscroller"), "Wave three includes Doomscroller")
    _expect(rules.spawn_pool(4, 650.0).has("ping-sniper"), "Wave four includes Ping Sniper")
    _expect(rules.spawn_pool(5, 770.0).has("comment-mod"), "Wave five includes Comment Mod")
    _expect(not rules.spawn_pool(5, 760.0).has("boss"), "Final boss never appears as common spawn")

    var game = load("res://scenes/main.tscn").instantiate()
    get_root().add_child(game)
    game.call("start_run", 0)
    game.call("_spawn_enemy", "hater")
    var enemies: Array = game.get("enemies")
    _expect(enemies.size() == 1, "Hater spawned")
    if enemies.size() == 1:
        var hater: Dictionary = enemies[0]
        hater["pos"] = game.get("player_pos") + Vector2(200, 0)
        hater["next_attack"] = 0.0
        game.set("run_time", 2.0)
        game.call("_step_enemies", 0.05)
        _expect(hater["phase"] == "warning", "Ranged warning before projectile")
        game.set("run_time", 2.7)
        game.call("_step_enemies", 0.05)
        _expect((game.get("hostile_shots") as Array).size() > 0, "Ranged warning launches projectile")
    game.call("start_run", 0)
    game.set("run_time", 135.0)
    game.call("_spawn_logic", 0.05)
    var events: Array = game.get("enemies")
    var found_event := false
    for enemy in events:
        if enemy["kind"] == "reply-guy":
            found_event = true
    _expect(found_event, "Reply Guy spawns at 2:15")
    game.call("start_run", 0)
    game.set("run_time", 600.0)
    game.call("_spawn_logic", 0.05)
    var bosses: Array = game.get("enemies")
    _expect(bool(game.get("boss_spawned")), "Big Hater spawns at 10:00")
    _expect(bosses.size() == 1 and bosses[0]["kind"] == "boss", "Boss transition retires other mobs")
    if bosses.size() == 1:
        bosses[0]["hp"] = 100.0
        bosses[0]["regen_stamp"] = 720
        game.set("run_time", 721.0)
        game.call("_step_enemies", 0.05)
        _expect(float(bosses[0]["hp"]) > 100.0, "Boss regenerates after 2-minute berserk threshold")
    game.queue_free()
    if problems.is_empty():
        print("PASS: 17 enemy IDs, wave pools, event/boss timing, telegraphed ranged attacks")
        quit(0)
    else:
        for problem in problems:
            push_error(problem)
        quit(1)
