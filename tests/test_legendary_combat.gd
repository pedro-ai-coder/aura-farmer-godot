extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)

func _setup(game, id: String, count: int = 0) -> Dictionary:
    game.call("start_run", 1)
    game.set("player_pos", Vector2(700, 550))
    var weapons: Array = game.get("weapons")
    weapons.clear()
    weapons.append({"id": id, "level": 1, "rarity": "legendary", "timer": 0.0})
    var counts: Dictionary = game.get("weapon_activations")
    counts[id] = count
    game.call("_spawn_enemy", "npc", {"pos": Vector2(760, 550)})
    var enemy: Dictionary = game.get("enemies")[0]
    enemy["hp"] = 1000.0
    enemy["max"] = 1000.0
    return enemy

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    var enemy := _setup(game, "ratio-blaster", 3)
    game.call("_fire_weapons", 0.01)
    var shots: Array = game.get("player_shots")
    _expect(shots.size() == 3, "Fourth legendary Ratio activation schedules two secondary shots")
    game.call("_step_player_shots", 0.01)
    _expect(shots[1]["pos"] == Vector2(700, 550), "Delayed secondary does not move before its deadline")
    game.set("run_time", 0.20)
    game.call("_step_player_shots", 0.08)
    _expect(is_equal_approx(enemy["hp"], 1000.0 - 0.40 * 95.0 * 2.6), "Ratio secondary projectiles apply approved damage")
    _expect(game.get("primary_hits") == 1, "Ratio secondaries cannot duplicate primary procs")
    enemy = _setup(game, "no-cap")
    game.call("_fire_weapons", 0.01)
    game.call("_step_player_shots", 0.08)
    var after_primary: float = enemy["hp"]
    game.set("run_time", 0.69)
    game.call("_step_weapon_areas")
    _expect(enemy["hp"] == after_primary, "No Cap line waits 0.7s")
    game.set("run_time", 0.70)
    game.call("_step_weapon_areas")
    _expect(is_equal_approx(after_primary - float(enemy["hp"]), 0.25 * 95.0 * 2.6), "No Cap line applies secondary damage")
    _expect(game.get("primary_hits") == 1, "No Cap secondary does not proc passives")
    enemy = _setup(game, "brainrot-feed")
    enemy["radius"] = 30.0
    game.call("_fire_weapons", 0.01)
    game.set("run_time", 0.45)
    game.call("_step_weapon_areas")
    after_primary = enemy["hp"]
    game.set("run_time", 0.75)
    game.call("_step_weapon_areas")
    _expect(is_equal_approx(after_primary - float(enemy["hp"]), 0.15 * 95.0 * 2.6), "Overlapping Feed secondary circles share hit memory")
    _expect(game.get("primary_hits") == 1, "Feed side impacts cannot duplicate procs")
    enemy = _setup(game, "keyboard-warrior", 2)
    game.call("_fire_weapons", 0.01)
    game.set("run_time", 0.24)
    game.call("_step_weapon_areas")
    _expect(is_equal_approx(enemy["hp"], 1000.0 - (0.36 + 0.25) * 95.0 * 2.6), "Third Keyboard activation includes the legendary finisher")
    _expect(game.get("primary_hits") == 1, "Paired strikes and finisher share one primary proc")
    enemy = _setup(game, "ban-hammer")
    game.call("_fire_weapons", 0.01)
    game.set("run_time", 0.30)
    game.call("_step_weapon_areas")
    after_primary = enemy["hp"]
    game.set("run_time", 0.80)
    game.call("_step_weapon_areas")
    _expect(is_equal_approx(after_primary - float(enemy["hp"]), 0.30 * 95.0 * 2.6), "Hammer fissure resolves 0.5s after primary impact")
    enemy = _setup(game, "chad-hands")
    game.set("chad_successful_activations", 2)
    game.call("_fire_weapons", 0.01)
    game.set("run_time", 0.18)
    game.call("_step_weapon_areas")
    _expect(is_equal_approx(enemy["hp"], 1000.0 - (0.22 + 0.60) * 95.0 * 2.6), "Third successful legendary Hands attack replaces second punch with enhanced slam")
    _expect(game.get("primary_hits") == 1, "Hands slam cannot duplicate primary activation")
    enemy = _setup(game, "touch-grass", 2)
    game.call("_fire_weapons", 0.01)
    _expect(is_equal_approx(enemy["hp"], 1000.0 - 0.40 * 1.25 * 95.0 * 2.6), "Third Grass activation applies enhanced damage")
    _expect(is_equal_approx(enemy.get("slow", 0.0), 0.25) and enemy.get("slow_until") == 2.0, "Enhanced Grass applies the approved slow and duration")
    enemy = _setup(game, "cope-shield", 2)
    game.call("_fire_weapons", 0.01)
    _expect(is_equal_approx(game.get("shield"), 110.0 * (0.04 * 2.6 + 0.05)), "Third Shield strike scales its own shield by rarity but Unbothered by support only")
    game.set("run_time", 2.0)
    game.call("_expire_weapon_shields")
    _expect(is_equal_approx(game.get("shield"), 110.0 * 0.05), "Cope Shield expires at two seconds without removing Unbothered")
    game.set("run_time", 3.0)
    game.call("_expire_weapon_shields")
    _expect(is_zero_approx(game.get("shield")), "Unbothered expires at three seconds")
    enemy = _setup(game, "personal-space", 1)
    game.call("_fire_weapons", 0.01)
    _expect(is_equal_approx(game.get("shield"), 110.0 * 0.04), "Every second legendary pulse grants the GDD 4% support shield without rarity scaling")
    _expect(is_equal_approx(enemy.get("weaken", 0.0), 0.08), "Personal Space weakens common enemies")
    # Legal Tank loadouts: support modifiers apply once; offensive passives do not.
    for id in ["cope-shield","personal-space"]:
        game.start_run(2)
        game.player_pos = Vector2(700,550)
        game.weapons.clear()
        game.weapons.append({"id":id,"level":1,"rarity":"legendary","timer":0.0})
        game.passives.append_array([{"id":"certified-w","level":2,"rarity":"common"},{"id":"cope-harder","level":3,"rarity":"common"},{"id":"main-character","level":4,"rarity":"common"}])
        game.weapon_activations[id] = 2 if id == "cope-shield" else 1
        game._spawn_enemy("npc",{"pos":Vector2(760,550)})
        game.enemies[0]["hp"] = 1000.0
        game.enemies[0]["max"] = 1000.0
        game._fire_weapons(0.01)
        var support := 1.12 * 1.24
        var source := "unbothered" if id == "cope-shield" else "my-aura"
        var coefficient := 0.05 if id == "cope-shield" else 0.04
        _expect(is_equal_approx(game.weapon_shields[source]["remaining"],140.0*coefficient*support),"Legal Tank legendary support shield matches GDD HP x S and support modifiers: " + id)
        if id == "cope-shield":
            _expect(is_equal_approx(game.weapon_shields["cope-shield"]["remaining"],140.0*0.04*2.6*support),"Own Cope Shield retains its approved rarity scaling")
        var deadline: float = game.weapon_shields[source]["until"]
        game._toggle_pause()
        game._advance(5.0)
        _expect(game.run_time == 0.0 and game.weapon_shields[source]["until"] == deadline,"Pause freezes the actual legendary support shield")
        game._toggle_pause()
        game.run_time = 3.0
        game._expire_weapon_shields()
        _expect(is_zero_approx(game.shield),"Legendary support and own shields expire on their original clocks")
    # A third successful activation can begin with a missed first punch.
    # Its circular slam must resolve once, including targets visited before the trigger.
    for rarity in ["common","legendary"]:
        for reverse in [false,true]:
            game.start_run(2)
            game.player_pos = Vector2(800,700)
            game.weapons.clear()
            game.weapons.append({"id":"chad-hands","level":1,"rarity":rarity,"timer":0.0})
            game.chad_successful_activations = 2
            game.manual_aim = true
            game.aim_point = Vector2(800,500)
            game._spawn_enemy("npc",{"pos":Vector2(800,580)})
            var wide: Dictionary = game.enemies.back()
            game._spawn_enemy("npc",{"pos":Vector2(880,700)})
            var near: Dictionary = game.enemies.back()
            for rival: Dictionary in game.enemies:
                rival["hp"] = 1000.0
                rival["max"] = 1000.0
            if reverse: game.enemies.reverse()
            game._fire_weapons(0.01)
            _expect(wide["hp"] == 1000.0 and near["hp"] == 1000.0 and game.chad_successful_activations == 2 and game.primary_hits == 0,"Missed opening punch cannot deal damage or qualify the combo")
            near["pos"] = Vector2(800,640)
            game.run_time = 0.18
            game._step_weapon_areas()
            var expected := 90.0 * (0.60*2.60 if rarity == "legendary" else 0.40)
            _expect(is_equal_approx(1000.0-float(near["hp"]),expected),"Late-triggered Hands slam applies its GDD coefficient once: " + rarity)
            _expect(is_equal_approx(1000.0-float(wide["hp"]),expected),"Late slam reaches the outer target independently of enemy order: " + rarity)
            _expect(game.chad_successful_activations == 3 and game.primary_hits == 1 and game.aura == 1.0,"Late multi-target slam remains one successful activation and one proc/Aura event")
            game._step_weapon_areas()
            _expect(is_equal_approx(1000.0-float(near["hp"]),expected) and game.primary_hits == 1,"Repeated area steps cannot hit or proc the same target again")
    game.call("start_run", 2)
    game.set("shield", 5.0)
    game.call("_grant_weapon_shield", "cope-shield", 10.0, 2.0)
    game.call("_grant_weapon_shield", "cope-shield", 10.0, 2.0)
    _expect(is_equal_approx(game.get("shield"), 15.0), "Refreshing a weapon shield cannot stack itself")
    game.call("_deal_damage_to_player", 10.0 / 0.85)
    game.set("run_time", 2.0)
    game.call("_expire_weapon_shields")
    _expect(is_equal_approx(game.get("shield"), 5.0), "Expiry does not remove unrelated shield after a weapon shield absorbs damage")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Legendary projectile delays, secondary damage/proc isolation, shared hit memory and third-hit transformations")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
