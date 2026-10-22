extends SceneTree

class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

var failures: Array[String] = []
func _initialize() -> void: call_deferred("_verify")
func _verify() -> void:
    var game := ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    var cases := [
        ["reply-goblin",Vector2(643,550),Vector2(433.70169,618.88306)],
        ["npc",Vector2(646,550),Vector2(433.70169,618.88306)],
        ["beta",Vector2(992,680),Vector2(773.70169,748.88306)],
        ["npc",Vector2(554,550),Vector2(766.2983,618.88306)],
        ["beta",Vector2(888,680),Vector2(1106.2983,611.11694)],
        ["npc",Vector2(831,950),Vector2(280,740)],
        ["beta",Vector2(830,935),Vector2(300,735)]
    ]
    for fixture: Array in cases:
        game.start_run(0)
        game.player_pos = fixture[2]
        game._spawn_enemy(fixture[0],{"pos":fixture[1]})
        var enemy: Dictionary = game.enemies.back()
        var start: Vector2 = enemy["pos"]
        var seeded_state: int = game.rng.state
        var old: Vector2 = start
        var maximum_blocked := 0.0
        var blocked := 0.0
        for frame in range(1800):
            game.run_time += 1.0/60.0
            game._step_enemies(1.0/60.0)
            var position: Vector2 = enemy["pos"]
            if position.distance_to(old) > float(enemy["speed"])/60.0+0.002:
                failures.append("Navigation exceeded approved movement speed")
            if not game.SoloWorldRulesScript.walkable(position,float(enemy["radius"])):
                failures.append("Navigation crossed collision geometry: "+str(fixture))
                break
            if position.distance_to(game.player_pos) <= float(enemy["radius"])+20: break
            blocked = blocked+1.0/60.0 if position.distance_to(old)<0.01 else 0.0
            maximum_blocked = maxf(maximum_blocked,blocked)
            old = position
        if game.rng.state != seeded_state: failures.append("Pursuit consumed gameplay RNG")
        var reached: bool = Vector2(enemy["pos"]).distance_to(game.player_pos) <= float(enemy["radius"])+20
        print("PURSUIT ",JSON.stringify({"kind":fixture[0],"start":[start.x,start.y],"target":[game.player_pos.x,game.player_pos.y],"end":[enemy["pos"].x,enemy["pos"].y],"reached":reached,"max_blocked_seconds":maximum_blocked}))
        if not reached: failures.append("Pursuit remains blocked: "+str(fixture))
        if maximum_blocked>2: failures.append("Pursuit blocked for more than two active seconds")
    for reason in ["terminal","ranged_band","stagger","recovery","boss_telegraph","charge"]:
        game.start_run(0)
        game.player_pos = Vector2(1000,550)
        var kind := "terminal" if reason == "terminal" else "hater" if reason == "ranged_band" else "boss" if reason in ["stagger","boss_telegraph"] else "ratio-ram" if reason == "charge" else "npc"
        game._spawn_enemy(kind,{"pos":Vector2(740,550) if reason == "ranged_band" else Vector2(650,550)})
        var enemy: Dictionary = game.enemies.back()
        if reason == "stagger": enemy["stagger_until"] = 3.0
        if reason == "recovery":
            enemy["recover_from"] = 0.0
            enemy["recover_until"] = 2.0
        if reason == "boss_telegraph": game._schedule_hazard(game.player_pos,100,1.0,0.2,10,"circle",Vector2.RIGHT,enemy)
        if reason == "charge":
            enemy["phase"] = "charging"
            enemy["locked_direction"] = Vector2.LEFT
            enemy["charge_until"] = 10.0
        var before: Vector2 = enemy["pos"]
        game._step_enemies(1.0/60.0)
        if reason == "charge":
            if enemy["pos"].y != before.y: failures.append("Committed charge was steered around cover")
        elif enemy["pos"] != before: failures.append("Intentional stationary phase moved: "+reason)
    game.queue_free()
    if failures.is_empty():
        print("PASS: Actual enemy pursuit around both covers and concave floor corners preserves geometry")
        quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
