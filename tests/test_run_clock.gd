extends SceneTree

# Independent boundary expectations from canonical GDD §§5.3, 10, 12, 25.1.
var failures: Array[String] = []
func _initialize() -> void: call_deferred("_verify")
func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    for index in range(1,5):
        game.start_run(0)
        game.legendary_spent = true
        game.wave = index
        game.run_time = index*120.0-0.02
        game.spawn_timer = 1e9
        game._advance(0.01)
        _expect(game.wave == index,"Wave cannot start before its two-minute boundary")
        game._advance(0.02)
        _expect(game.wave == index+1 and game.total_xp == 0.0,"Wave boundary creates a collectible rather than granting direct XP")
        _expect(game.pickups.size() == 1 and game.pickups[0]["xp"] == float(40*(index+1)),"Exactly one crystal holds the canonical transition reward")
        var crystal: Dictionary = game.pickups[0]
        _expect(game.SoloWorldRulesScript.walkable(crystal["pos"]),"Transition reward remains reachable")
        game.player_pos = crystal["pos"]
        game._collect_drops()
        game._collect_drops()
        _expect(game.total_xp == float(40*(index+1)) and game.pickups.is_empty(),"Collection credits transition XP exactly once")
    for pair in [[135.0,"reply-guy"],[255.0,"mod-supremo"],[375.0,"ohio-express"],[495.0,"doomscroll-prime"]]:
        game.start_run(0)
        game.event_index = int((float(pair[0])-135.0)/120.0)
        game.spawn_timer = 1e9
        game.run_time = float(pair[0])-0.01
        game._spawn_logic(0.0)
        _expect(game.enemies.is_empty(),"Event cannot start before its canonical deadline")
        game.run_time = float(pair[0])
        game._spawn_logic(0.0)
        _expect(game.enemies.size() == 1 and game.enemies[0]["kind"] == pair[1],"Exact event enters fifteen seconds into its wave")
        game._spawn_logic(0.0)
        _expect(game.enemies.size() == 1,"Event entry is one-shot")
    game.start_run(0)
    game.run_time = 599.99
    game.spawn_timer = 1e9
    game.event_index = 4
    game._spawn_logic(0.0)
    _expect(not game.boss_spawned,"Final boss cannot arrive before 10:00")
    game.run_time = 600.0
    game._spawn_logic(0.0)
    _expect(game.boss_spawned and game.enemies.size() == 1 and game.enemies[0]["kind"] == "boss","Big Hater arrives at exactly 10:00")
    if game.enemies.is_empty():
        for failure in failures: push_error(failure)
        quit(1)
        return
    var boss: Dictionary = game.enemies[0]
    boss["born"] = 0.0
    boss["next_attack"] = 1e9
    boss["hp"] = 1000.0
    game.run_time = 719.99
    game._step_enemies(0.0)
    _expect(boss["hp"] == 1000.0,"No regeneration before two minutes of boss combat")
    game.run_time = 720.0
    game._step_enemies(0.0)
    _expect(boss["hp"] == 1030.0,"Recoverable berserk starts exactly at 12:00")
    game._hit_enemy(boss,100.0)
    _expect(is_equal_approx(boss["hp"],965.0),"Berserk keeps approved 35 percent resistance")
    _expect(game.mode == "playing","Berserk never forces a scripted loss")
    _expect(game.SoloClock.warning(569.99).is_empty() and game.SoloClock.warning(570.0) == "BIG HATER IN 30s","Final-boss warning starts at 9:30")
    _expect(game.SoloClock.warning(660.0) == "BERSERK IN 60s" and game.SoloClock.warning(690.0) == "BERSERK IN 30s" and game.SoloClock.warning(710.0) == "BERSERK IN 10s","Berserk warnings follow the canonical combat clock")
    _expect(game.SoloClock.warning(840.0).contains("LAST PUSH"),"Last-effort message starts after two minutes of recoverable berserk")
    var rules = load("res://scripts/solo_enemy_rules.gd")
    _expect(rules.spawn_pool(1,59.99) == ["npc"] and rules.spawn_pool(1,60.0).has("hater"),"Hater entry moves coherently to 1:00")
    for time in [359.99,360.0,479.99,480.0,594.99,595.0]:
        game.start_run(0)
        game.run_time = time
        game._open_legendary()
        _expect((game.mode == "legendary") == (time >= 360.0 and time < 595.0),"Legendary manual access respects 6:00 through 9:55 exclusive")
    game.queue_free()
    if failures.is_empty(): print("PASS: Exact canonical wave, event, Hater, boss, berserk and legendary boundaries"); quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
