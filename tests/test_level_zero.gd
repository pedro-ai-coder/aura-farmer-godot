extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
    call_deferred("verify")
func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func verify() -> void:
    var normal = load("res://scenes/main.tscn").instantiate()
    root.add_child(normal)
    normal.set_process(false)
    check(normal.wave_count()==5 and normal.encounter_at()==600.0 and normal.encounter_kind()=="boss", "Normal schedule unchanged")
    check(normal.encounter_events().size()==4, "Normal events unchanged")
    normal.queue_free()
    var game = load("res://scenes/level_zero.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var original_profile: Dictionary = game.profile.duplicate(true)
    for appearance in ["original", "female"]:
        game.hero_appearance = appearance
        for kit in range(3):
            game._return_to_menu()
            game.start_run(kit)
            check(game.mode=="intro" and game.run_time==0, "All kits/appearances enter paused story")
            check(game.hero_index==kit and game.hero.get("id")==game.HEROES[kit]["id"], "Requested kit really starts: %s/%d" % [appearance,kit])
            game._begin_encounter()
            check(game.mode=="playing" and game.weapons.size()==1 and game.passives.is_empty(), "Actual starter loadout")
            check(game.weapons[0]["id"]==game.HEROES[kit]["starter"], "Requested kit starter weapon")
            check(game.rng.seed==451+17*kit, "Canonical seed")
            await process_frame
    check(game.wave_count()==3 and game.encounter_events().is_empty(), "Isolated schedule")
    game.run_time=119.99
    game._advance(0.02)
    check(game.wave==2 and game.pickups.any(func(d): return d.get("xp")==80), "V3 first phase and XP crystal")
    game.run_time=239.99
    game._advance(0.02)
    check(game.wave==3, "Third wave at 240")
    game.run_time=359.99
    game._advance(0.02)
    check(game.boss_spawned and game.wave==3, "Prototype at 360, no fourth wave")
    check(game.legendary_offers.is_empty(), "No wave-four legendary")
    var boss: Dictionary = game.enemies[0]
    check(boss["kind"]==game.Candidate.BOSS_ID and boss["max"]==2400, "Distinct prototype")
    check(game.art.enemy_visual_kind(boss,900)=="beta", "Distinct placeholder beyond berserk time")
    game.mode="playing" # Transition XP can legitimately pause for a choice.
    game.run_time=363.0
    game._step_enemies(0.0)
    check(game.hazard_zones.size()==1 and game.hazard_zones[0]["shape"]=="cone", "Telegraphed slam")
    var facing: Vector2 = game.hazard_zones[0]["dir"]
    game.player_pos+=Vector2(300,0)
    game._step_enemies(0.0)
    check(game.hazard_zones[0]["dir"]==facing, "No retarget")
    game.run_time=367.0
    game._step_enemies(0.0)
    check(game.hazard_zones.back()["shape"]=="line", "Second attack beam")
    boss["hp"]=1200.0
    game.run_time=900.0
    game._step_enemies(0.0)
    check(boss["hp"]==1200 and game.enemies.size()==1, "No regeneration or adds")
    game._hit_enemy(boss,1200)
    check(game.mode=="won", "Actual boss death wins")
    check(game.profile.get("runs")==original_profile.get("runs"), "No normal profile result")
    game.start_run(0)
    game._begin_encounter()
    check(game.run_time==0 and not game.boss_spawned and game.hazard_zones.is_empty(), "Clean replay")
    game._deal_damage_to_player(99999)
    check(game.mode=="lost", "HP depletion loses")
    game._return_to_menu()
    check(game.mode=="menu", "Menu return")
    game.queue_free()
    for message in failures: push_error(message)
    print("LEVEL_ZERO: %s" % ("PASS" if failures.is_empty() else "FAIL"))
    quit(0 if failures.is_empty() else 1)
