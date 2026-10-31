extends SceneTree
## Equivalent seeded development fixtures. Native render completion timing is
## observed only with a real display; headless mode reports CPU and state only.
const Probe=preload("res://scripts/performance_probe.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("measure")
func touch(game,index: int,at: Vector2,pressed: bool) -> void:
    var event:=InputEventScreenTouch.new();event.index=index;event.position=at;event.pressed=pressed
    root.push_input(event,true)
func drag(game,at: Vector2) -> void:
    var event:=InputEventScreenDrag.new();event.index=0;event.position=at
    root.push_input(event,true)
func setup(game,scenario: String) -> void:
    game.start_run(2 if scenario in ["dense","flex"] else 0)
    game.touch_device=true
    game.profile["settings"]["reducedMotion"]=false
    if scenario in ["idle","movement","reversals"]:
        game.enemies.clear();game.weapons.clear();game.spawn_timer=INF;game.player_pos=Vector2(340,600)
    elif scenario=="normal":
        # Canonical early-wave combat with its actual starter/spawner and HP.
        for i in range(8):game._spawn_enemy("npc" if i%3 else "hater")
    elif scenario in ["dense","flex"]:
        game.level=20;game.run_time=540;game.wave=5
        game.event_index=game.SoloEnemyRulesScript.EVENT_SCHEDULE.size()
        game.legendary_spent=true
        game.weapons.assign([{"id":"cope-shield","rarity":"common","level":4,"timer":0.0},{"id":"chad-hands","rarity":"common","level":4,"timer":0.0},{"id":"personal-space","rarity":"common","level":4,"timer":0.0}])
        game.passives.assign([{"id":"built-different","rarity":"common","level":4},{"id":"thick-skin","rarity":"common","level":4},{"id":"terminally-online","rarity":"common","level":4},{"id":"certified-w","rarity":"common","level":4},{"id":"too-sigma","rarity":"legendary","level":1}])
        game._recompute_max_hp();game.hp=game.max_hp
        for i in range(100 if scenario=="dense" else 24):game._spawn_enemy(["npc","npc","hater","beta","ping-sniper"][i%5])
        if scenario=="flex":game.aura=100;game.flex_lock=0
    game._show_ui();game._update_text();game._update_camera(0,true)
func measure() -> void:
    var args:=OS.get_cmdline_user_args()
    var output: String=args[0]
    var pixels:=Vector2i(int(args[1]),int(args[2])) if args.size()>2 else Vector2i(844,390)
    var frames: int=int(args[3]) if args.size()>3 else 300
    var ratio: float=float(args[4]) if args.size()>4 else 1.0
    var native: bool=DisplayServer.get_name()!="headless"
    root.size=pixels
    Engine.max_fps=60 if native else 0
    DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.presentation._window_changed(true)
    await process_frame;await process_frame
    # Native DPR experiment: keep the exact logical viewport/coordinates while
    # changing only the raster extent. This is not an Android/browser emulator.
    var logical: Vector2i=root.content_scale_size
    if ratio!=1.0:
        root.size=Vector2i(Vector2(pixels)*ratio)
        await process_frame
        game.presentation.last_window_size=root.size
        root.content_scale_size=logical
        game.presentation.full_view=Vector2(logical);game.presentation.view=Vector2(logical)
        game.presentation.size=Vector2(logical)
    var all_reports: Array=[]
    var selected: String=args[5] if args.size()>5 else "all"
    var trace: bool=args.has("--trace")
    for scenario in ["idle","movement","reversals","normal","dense","flex"]:
        if selected!="all" and scenario!=selected:continue
        setup(game,scenario)
        await process_frame;await process_frame
        var probe=Probe.new(game,scenario,true);game.performance_probe=probe
        var now:=Time.get_ticks_usec()
        var origin:=Vector2(260,310)
        touch(game,0,origin,true)
        var step_counts: Dictionary={}
        for frame in range(frames):
            var stamp:=Time.get_ticks_usec()
            var delta: float=clampf(float(stamp-now)/1000000.0,0.0,0.25) if native and not trace else ([1.0/60.0,1.0/30.0,0.075,1.0/120.0][frame%4])
            now=stamp
            if scenario=="idle":game.touch_direction=Vector2.ZERO
            elif scenario=="movement":drag(game,origin+Vector2(150,0))
            elif scenario=="reversals":drag(game,origin+Vector2(150 if frame%30<15 else -150,80 if frame%60<30 else -80))
            else:drag(game,origin+Vector2(120*cos(frame*0.014),120*sin(frame*0.014)))
            if scenario=="flex" and frame==30:game._use_flex()
            game._process(delta)
            game.clean_cut_skin._process(delta)
            if native:
                await process_frame
                await RenderingServer.frame_post_draw
            if game.mode!="playing" or (scenario=="movement" and game.run_time>=4.0):break
        touch(game,0,origin,false)
        probe.close()
        var report: Dictionary=probe.report()
        report["fixture"]={"scenario":scenario,"normal_health":true,"controlled_setup":true,"not_human_or_device_testing":true,"requested_frames":frames,"css_extent":[pixels.x,pixels.y],"raster_ratio":ratio,"normal_spawner":scenario in ["normal","dense","flex"],"delta_source":"elapsed native frame time" if native and not trace else "explicit irregular workload trace; simulation time is independent of wall time"}
        all_reports.append(report)
        var file:=FileAccess.open(output.path_join("%s-%dx%d-%.1f.json" % [scenario,pixels.x,pixels.y,ratio]),FileAccess.WRITE);file.store_string(JSON.stringify(report));file.flush();file.close()
        print("MEASURE ",scenario," ",JSON.stringify({"fps":report["delivered_render_fps"],"frames":report["sample_count"],"sim":report["metrics"]["simulation_us"],"draw":report["metrics"]["draw_us"],"hud":report["metrics"]["hud_us"],"enemies":report["metrics"]["enemies_us"],"camera":report["metrics"]["camera_us"],"render":report["metrics"]["render_interval_ms"]}))
        game.performance_probe=null
    var summary:=FileAccess.open(output.path_join("summary-%dx%d-%.1f.json" % [pixels.x,pixels.y,ratio]),FileAccess.WRITE)
    for report in all_reports:report.erase("samples")
    summary.store_string(JSON.stringify(all_reports,"  "));summary.flush();summary.close()
    game.queue_free();quit()
