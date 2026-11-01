extends SceneTree
const Run=preload("res://tests/weapon_presence/review_run.gd")
const Trace=preload("res://tests/frame_pacing/state_trace.gd")
var failures: Array[String]=[]
var comparisons:=0
func _initialize() -> void:call_deferred("verify")
func snapshot(game) -> PackedByteArray:
    var values: Array=[game.rng.state,game.camera.position,game.hero,game.hero_appearance,game.profile]
    for key in Trace.KEYS:values.append(game.get(key))
    return var_to_bytes(values)
func verify() -> void:
    var before:=Run.new();before.passive_feedback=null
    var after:=Run.new()
    root.add_child(before);root.add_child(after)
    for game in [before,after]:game.set_process(false);game.clean_cut_skin.set_process(false)
    var covered: Dictionary={}
    var hashes: Dictionary={}
    for index in range(3):
        for appearance in ["original","female"]:
            var cases: Array=[]
            for id in after.PASSIVES:
                var data: Dictionary=after.SoloOfferRulesScript.PASSIVE_DATA[id]
                if str(data.role).is_empty() or data.role==after.HEROES[index].role:
                    cases.append([id]);covered[id]=true
            cases.append(["main-character","certified-w","so-back","six-to-seven","w-squad"])
            var context:=HashingContext.new();context.start(HashingContext.HASH_SHA256)
            for ids: Array in cases:
                for game in [before,after]:
                    game.hero_appearance=appearance;game.start_run(index)
                    game.enemies.clear();game.spawn_timer=INF;game.run_time=9.95
                    game.rng.seed=451;game.manual_aim=true;game.aim_point=game.player_pos+Vector2(200,0)
                    for id: String in ids:
                        var rarity: String=game.SoloOfferRulesScript.PASSIVE_DATA[id].rarity
                        game.passives.append({"id":id,"rarity":rarity,"level":game.CAP_LEVELS[rarity]})
                    game._recompute_max_hp();game.hp=game.max_hp
                    game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(65,0)})
                    for enemy: Dictionary in game.enemies:enemy.hp=100000;enemy.max=100000;enemy.born=0
                for frame in range(48):
                    var dt: float=[0.008,0.033,0.075,0.016,0.12,0.25][frame%6]
                    for game in [before,after]:
                        game.touch_direction=Vector2.ZERO
                        if frame==3:game.aura=100;game._use_flex()
                        if frame==8:game._deal_damage_to_player(game.max_hp*0.85)
                        if frame in [12,13,14,15,16,17,18,19]:game._primary_activation(game.player_pos+Vector2(65,0))
                        if frame in [24,26]:game._toggle_pause()
                        game._process(dt);game.hero_pose()
                    var a:=snapshot(before);var b:=snapshot(after)
                    if a!=b:
                        failures.append("State/RNG/profile divergence hero=%d/%s passives=%s frame=%d" % [index,appearance,ids,frame]);break
                    context.update(a);comparisons+=1
            hashes["%d/%s" % [index,appearance]]=context.finish().hex_encode()
    if covered.size()!=23:failures.append("All 23 canonical identities must have real parity traces")
    before.queue_free();after.queue_free()
    if failures.is_empty():print("PASS: ",comparisons," full state/RNG/profile frame comparisons, all 23 passives, six appearances, irregular frames, real Flex/primary/heal/shield, pause. SHA256 ",JSON.stringify(hashes));quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
