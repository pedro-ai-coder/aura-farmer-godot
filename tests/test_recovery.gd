extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("_verify")
func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func _verify() -> void:
    var rules = load("res://scripts/recovery_rules.gd")
    var generator = load("res://scripts/phaser_rng.gd").new()
    generator.seed = 451
    var expected := [0.5175814211834222,0.9301920812577009,0.4752768068574369,0.8931391111109406,0.4703490608371794,0.1079722554422915,0.6786000374704599,0.614024302456528]
    for value: float in expected: _expect(absf(generator.randf() - value) <= 1e-15,"Mulberry32 matches exact JS reference values")
    generator.seed = 451
    var counts := [0,0,0,0]
    for i in range(10000):
        var roll: float = generator.randf()
        var normal: String = rules.special_for(roll,false)
        var elite: String = rules.special_for(roll,true)
        if normal == "snack": counts[0] += 1
        elif normal == "magnet": counts[1] += 1
        if elite == "snack": counts[2] += 1
        elif elite == "magnet": counts[3] += 1
    _expect(counts == [518,210,1999,804],"Ten thousand seeded normal/elite rolls match Phaser reference counts")
    _expect(rules.special_for(0.05,false) == "magnet" and rules.special_for(0.07,false) == "","Normal probability boundaries are exact")
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.start_run(0)
    game.set_process(false)
    game.rng.seed = 451
    for i in range(1000):
        game._spawn_enemy("npc",{"pos":Vector2(800,550),"elite":i%2 == 0})
        game._hit_enemy(game.enemies.back(),1e6)
    var specials := {"snack":0,"magnet":0}
    var xp_count := 0
    for drop: Dictionary in game.pickups:
        if drop["kind"] == "aura": xp_count += 1
        else: specials[drop["kind"]] += 1
    _expect(specials["snack"] == 5 and specials["magnet"] == 5 and xp_count == 1000,"Oldest-only recycling keeps five of each special and never deletes XP")
    _expect(game.recovery_counts["snacks_spawned"] > 10 and game.recovery_counts["magnets_spawned"] > 10,"Recovery continues spawning over a long kill sequence")
    game.start_run(0)
    game.player_pos = Vector2(700,550)
    game.hp = 20.0
    game.pickups.append({"kind":"snack","pos":Vector2(755,550),"xp":0.0})
    game._collect_drops()
    _expect(game.hp == 38.0,"Snack collects inside 56U and heals exactly 18% max HP")
    game.hp = 99.0
    game.pickups.append({"kind":"snack","pos":game.player_pos,"xp":0.0})
    game._collect_drops()
    _expect(game.hp == 100.0,"Snack healing caps at maximum HP")
    game.pickups.append({"kind":"magnet","pos":Vector2(771,550),"xp":0.0})
    for point in [Vector2(700,550),Vector2(1100,700)]: game.pickups.append({"kind":"aura","pos":point,"xp":5.0})
    game._collect_drops()
    game._collect_drops()
    _expect(game.total_xp == 10.0 and game.pickups.is_empty(),"Magnet collects existing near/far XP exactly once, including snapshot crystals")
    game.player_pos = rules.SAFE_SPOT
    game.hp = 10.0
    game.spawn_timer = 1e9
    for i in range(120): game._advance(1.0/60.0)
    _expect(is_equal_approx(game.hp,35.0) and game.safe_spot_uses == 1,"Safe Spot heals 25% after two continuous seconds")
    _expect(is_equal_approx(game.safe_spot_ready_at,92.0),"Safe Spot starts 90 active seconds of cooldown")
    game._toggle_pause()
    var clock: float = game.run_time
    game._process(0.25)
    _expect(game.run_time == clock and game.safe_spot_ready_at == 92.0,"Pause freezes station cooldown")
    game._toggle_pause()
    game.run_time = 92.0
    game._tick_recovery(1.0)
    game.player_pos = Vector2(700,550)
    game._tick_recovery(0.1)
    _expect(game.safe_spot_charge == 0.0,"Leaving the station cancels accumulated charge")
    game.player_pos = rules.SAFE_SPOT
    game.hp = game.max_hp
    game._tick_recovery(2.0)
    _expect(game.safe_spot_charge == 0.0 and game.safe_spot_uses == 1,"Full health cannot activate or charge the station")
    game.start_run(0)
    _expect(game.safe_spot_uses == 0 and game.safe_spot_ready_at == 0.0 and game.pickup_feedback.is_empty(),"Restart resets station, counters and collection feedback")
    game.player_pos = rules.SAFE_SPOT
    game.hp = 50.0
    game.run_time = 600.0
    game._spawn_logic(0.0)
    game._tick_recovery(2.0)
    _expect(game.hp == 75.0 and game.boss_spawned,"Approved station remains usable during the boss encounter")
    game.queue_free()
    if failures.is_empty(): print("PASS: Exact Phaser seeded drops, caps, collection, Safe Spot lifecycle and boss recovery"); quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
