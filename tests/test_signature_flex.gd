extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func fresh(game, index: int) -> void:
    game.start_run(index)
    game.player_pos = Vector2(700,550)
    game.weapons.clear()
    game.spawn_timer = 1e9
func enemy_at(game, pos: Vector2, kind: String = "npc") -> Dictionary:
    game._spawn_enemy(kind,{"pos":pos})
    var enemy: Dictionary = game.enemies.back()
    enemy["hp"] = 10000.0
    enemy["max"] = 10000.0
    enemy["speed"] = 0.0
    enemy["next_attack"] = 1e9
    return enemy
func activate(game) -> void:
    game.aura = 100
    game._use_flex()
func verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    fresh(game,1)
    var enemy := enemy_at(game,Vector2(760,550))
    activate(game)
    game._deal_damage_to_player(10,enemy,true)
    check(is_equal_approx(game.hp,101.925),"CTRL + CHAOS reduces common contact by fifteen percent, without immunity")
    game._deal_damage_to_player(10,enemy)
    check(is_equal_approx(game.hp,92.425),"Projectiles/direct non-contact attacks do not receive Flex reduction")
    game._deal_damage_to_player(10,enemy,false,true)
    check(is_equal_approx(game.hp,82.925),"Special hazards retain full damage")
    var boss := enemy_at(game,Vector2(790,550),"boss")
    game.run_time = 1
    game._deal_damage_to_player(10,boss,true)
    check(is_equal_approx(game.hp,73.425),"Boss contact retains full damage")
    check(game.hero["flex"] == "CTRL + CHAOS","Cool Kid displays approved signature name")
    fresh(game,1)
    var targets: Array[Dictionary] = []
    for i in range(6): targets.append(enemy_at(game,Vector2(760,550)))
    game.enemies.reverse()
    game.manual_aim = true
    game.aim_point = Vector2(900,550)
    activate(game)
    game.flex_age = 0.349
    game._step_signature_flex()
    check(targets[0]["hp"] == 10000,"No beat before its boundary")
    game.flex_age = 0.35
    game._step_signature_flex()
    check(is_equal_approx(targets[0]["hp"],9981) and targets[5]["hp"] == 10000,"Beat selects five targets with stable ID ties")
    game._step_signature_flex()
    check(is_equal_approx(targets[0]["hp"],9981),"Repeating the same boundary cannot double-hit")
    game.flex_age = 3.85
    game._step_signature_flex()
    check(game.hero_state["flex_beats"] == 6 and game.hero_state["flex_success"] == 6,"All six independent beats count once")
    game.flex_age = 4.5
    game._step_signature_flex()
    check(is_equal_approx(targets[0]["hp"],10000-6*19-1.05*95),"Six successful beats earn the exact capped finisher")
    check(is_equal_approx(targets[5]["hp"],10000-1.05*95),"Finisher hits each legal target once")
    check(game.aura == 0 and game.primary_aura_times.is_empty(),"Secondary Flex hits never generate primary Aura")
    fresh(game,1)
    activate(game)
    game.flex_age = 3.85
    game._step_signature_flex()
    enemy = enemy_at(game,Vector2(760,550))
    game.manual_aim = true
    game.aim_point = Vector2(900,550)
    game.flex_age = 4.5
    game._step_signature_flex()
    check(is_equal_approx(enemy["hp"],10000-0.45*95),"Missed beats cannot charge ENTER")
    fresh(game,0)
    activate(game)
    check(game.aura == 100 and game.flex_lock == 0,"Sigma without target remains ready")
    enemy = enemy_at(game,Vector2(760,550))
    var other := enemy_at(game,Vector2(640,550))
    activate(game)
    var activation := {}
    game._weapon_hit(enemy,10,true,activation)
    game._weapon_hit(enemy,10,true,activation)
    check(game.hero_state["verdict_count"] == 1 and is_equal_approx(enemy["hp"],9972),"Paired primary hits gain focused damage but count one activation")
    game._weapon_hit(other,10,false,{})
    check(other["hp"] == 9990,"Secondary hits do not inherit focused damage")
    game._weapon_hit(enemy,10,true,{})
    game._weapon_hit(enemy,10,true,{})
    check(is_equal_approx(enemy["hp"],10000-56-75),"Third primary activation resolves one 0.75P Verdict")
    game._weapon_hit(enemy,10,true,{})
    check(is_equal_approx(enemy["hp"],10000-70-75),"Verdict fires at most once per Flex")
    fresh(game,0)
    enemy = enemy_at(game,Vector2(760,550))
    other = enemy_at(game,Vector2(780,550))
    activate(game)
    game._weapon_hit(enemy,10,true,{})
    game._weapon_hit(enemy,10,true,{})
    enemy["hp"] = 1
    game._weapon_hit(enemy,10,true,{})
    check(other["hp"] == 10000 and game.hero_state["flex_finisher"],"Lethal third primary confirms Verdict without redirecting its damage")
    fresh(game,0)
    enemy = enemy_at(game,Vector2(760,550))
    other = enemy_at(game,Vector2(780,550))
    activate(game)
    game._weapon_hit(enemy,100000,true,{})
    game._weapon_hit(other,10,true,{})
    check(game.sigma_target == other and game.hero_state["verdict_count"] == 2,"Legitimate retarget retains activation successes")
    fresh(game,2)
    enemy = enemy_at(game,Vector2(760,550))
    game._grant_weapon_shield("existing",10,20)
    activate(game)
    game._deal_damage_to_player(20,enemy,true)
    check(is_equal_approx(game.hero_state["flex_absorbed"],3.6),"Only actual absorption from named Flex shield charges countershock")
    check(is_equal_approx(game.hp,140),"Other shields and Flex source both protect normally")
    var before: float = enemy["hp"]
    game.flex_age = 5.5
    game._step_signature_flex()
    check(is_equal_approx(before-enemy["hp"],(0.8+0.5+2*3.6/140)*90),"Two pending slams and attributed countershock use approved P")
    check(Vector2(enemy["pos"]).distance_to(Vector2(760,550)) <= 40.0001,"Countershock push is capped at forty units")
    fresh(game,2)
    boss = enemy_at(game,Vector2(760,550),"boss")
    activate(game)
    check(not boss.has("taunt_until"),"Boss cannot be taunted")
    game.hero_state["flex_absorbed"] = 10000
    game.flex_age = 5.5
    game._step_signature_flex()
    check(boss["pos"] == Vector2(760,550) and boss["stagger"] == 10,"Boss receives stagger, never push")
    check(is_equal_approx(boss["hp"],10000-(1.2+1.0)*90),"Countershock respects one-P cap")
    var age: float = game.flex_age
    game.mode = "paused"
    game._advance(1)
    check(game.flex_age == age,"Pause freezes signature scheduler")
    game.mode = "playing"
    game._finish(false)
    check(game.flex_time == 0 and game.sigma_target.is_empty(),"Defeat cancels signature state")
    fresh(game,1)
    boss = enemy_at(game,Vector2(760,550),"boss")
    boss["hp"] = 1
    game.manual_aim = true
    game.aim_point = Vector2(900,550)
    activate(game)
    game.flex_age = 0.35
    game._step_signature_flex()
    check(game.mode == "won" and not game.hero_state.has("flex_beats") and game.hero_state.get("flex_outline",{}).is_empty(),"Lethal Flex strike cannot restore effects after victory cleanup")
    fresh(game,1)
    activate(game)
    check(game.hero_state["flex_beats"] == 0 and game.hero_state["flex_success"] == 0,"Fresh activation resets combo")
    game.queue_free()
    if failures.is_empty(): print("PASS: Signature timing, caps, mitigation, attribution, retarget, proc isolation and lifecycle"); quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
