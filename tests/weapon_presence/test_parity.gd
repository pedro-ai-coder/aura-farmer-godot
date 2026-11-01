extends SceneTree
const ReviewRun=preload("res://tests/weapon_presence/review_run.gd")
const Trace=preload("res://tests/frame_pacing/state_trace.gd")
const IDS=["no-cap","ratio-blaster","brainrot-feed","keyboard-warrior","ban-hammer","touch-grass","cope-shield","chad-hands","personal-space"]
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("verify")
func snapshot(game) -> PackedByteArray:
    var values: Array=[game.rng.state,game.camera.position,game.hero,game.hero_appearance]
    for key in Trace.KEYS:values.append(game.get(key))
    return var_to_bytes(values)
func verify() -> void:
    var before:=ReviewRun.new();before.weapon_presentation=null
    var after:=ReviewRun.new()
    root.add_child(before);root.add_child(after)
    before.set_process(false);after.set_process(false)
    before.clean_cut_skin.set_process(false);after.clean_cut_skin.set_process(false)
    var comparisons:=0
    for id in IDS:
        for appearance in ["original","female"]:
            for legendary in [false,true]:
                for game in [before,after]:
                    game.fixture(id,appearance)
                    game.weapons[0]["level"]=1 if legendary else 4
                    game.weapons[0]["rarity"]="legendary" if legendary else "common"
                    game.rng.seed=451
                    for enemy in game.enemies:enemy["hp"]=100000;enemy["max"]=100000;enemy["born"]=0
                for frame in range(96):
                    var dt: float=[0.008,0.033,0.075,0.016,0.12,0.004][frame%6]
                    for game in [before,after]:
                        game.touch_direction=Vector2(0,-1 if frame<24 else 1 if frame<48 else 0)*0.2
                        game._process(dt)
                        game.hero_pose() # Presentation must not mutate source/state.
                    if snapshot(before)!=snapshot(after):
                        failures.append("Canonical state/RNG changed: %s/%s/legendary=%s frame=%d" % [id,appearance,legendary,frame]);break
                    comparisons+=1
    before.queue_free();after.queue_free()
    if failures.is_empty():print("PASS: ",comparisons," exact per-frame simulation comparisons, nine weapons x both appearances x common L4/legendary, unchanged targets/damage/events/cadence/collisions/RNG");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
