extends SceneTree
class Run extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("run_test")
func run_test() -> void:
    var native := OS.get_cmdline_user_args().has("--native-evidence")
    if native:
        root.size=Vector2i(1280,720);Engine.max_fps=60
    var captured: Dictionary={}
    var game:=Run.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.hero_appearance="original";game.start_run(1)
    var rig=game.art.cool_kid_rig
    rig.enabled=OS.get_cmdline_user_args().has("--candidate")
    if not rig.prepare():push_error(rig.reason);quit(1);return
    var digest:=HashingContext.new();digest.start(HashingContext.HASH_SHA256)
    var samples: Dictionary={};var frames:=0
    var start:=Time.get_ticks_usec()
    for i in range(10800):
        if game.mode in ["choice","replace","legendary"]:
            game.pick_upgrade(0);game._confirm_selection()
        if game.mode!="playing":break
        # Scripted ordinary controls; unchanged starter, spawner, HP and seed.
        game.touch_direction=Vector2.from_angle(float(i/180)*PI/4.0)
        if game.aura>=100.0:game._use_flex()
        game._process(1.0/60.0)
        var c: Dictionary=game.hero_animation_state()
        var state: String=game.hero_pose()["state"]
        samples[state]=int(samples.get(state,0))+1
        if rig.enabled:rig.sample(state,c)
        digest.update(var_to_bytes([game.player_pos,game.hp,game.rng.state,game.enemies,game.kills,game.aura,game.run_time,game.weapons]))
        frames+=1
        if native:
            game.clean_cut_skin._process(1.0/60.0)
            await process_frame
            if not captured.has(state) and rig.supports("cool-kid","original",state,c):
                await RenderingServer.frame_post_draw
                var output: String=OS.get_cmdline_user_args()[-1]
                DirAccess.make_dir_recursive_absolute(output)
                root.get_texture().get_image().save_png(output.path_join(state+".png"))
                captured[state]={"frame":i,"time":game.run_time,"rig_active":true}
                print("CAPTURE ",state," ",JSON.stringify(captured[state]))
    var report: Dictionary={"scenario":"automated normal Cool Kid run; no injected enemies, stats or state","candidate":rig.enabled,"seed":468,"frames":frames,"seconds":game.run_time,"aura":game.aura,"kills":game.kills,"mode":game.mode,"states":samples,"hash":digest.finish().hex_encode(),"captured":captured,"cpu_wall_ms":(Time.get_ticks_usec()-start)/1000.0}
    print(JSON.stringify(report));game.queue_free();quit()
