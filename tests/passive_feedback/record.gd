extends SceneTree
const Run=preload("res://tests/passive_feedback/review_run.gd")
const SOURCES=["scripts/solo_run.gd","scripts/passive_feedback.gd","scripts/passive_feedback_view.gd","scripts/clean_cut_skin.gd","scripts/clean_cut_secondary.gd"]
func _initialize() -> void:call_deferred("record")
func record() -> void:
    if DisplayServer.get_name()=="headless":push_error("Actual native rendering required");quit(1);return
    var args:=OS.get_cmdline_user_args()
    var before: bool=args[0]=="before";var extent:=Vector2i(int(args[1]),int(args[2]));var output: String=args[3]
    var suite: String=args[4]
    var sources: Dictionary={}
    for path in SOURCES:sources[path]=FileAccess.get_sha256("res://"+path)
    root.size=extent;DirAccess.make_dir_recursive_absolute(output)
    var game:=Run.new()
    if before:game.passive_feedback=null
    root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false);game.touch_device=extent.x<1000
    await process_frame;await process_frame
    var reports: Array=[]
    var entries: Array=["acquired","level","timed-active","timed-expired","stack-low","stack-six","stack-burst","healing","shield","absorption","legendary","cinema-flex","wsquad-flex","too-sigma","no-u","dense","build"] if suite=="all" else ["acquired","stack-six","legendary"] if suite=="clip" else ["stack-burst"]
    for entry: String in entries:
        game.prepare(entry)
        game.profile["settings"]["reducedMotion"]=suite=="reduced"
        var frames: int=190 if entry=="timed-expired" else 100 if entry in ["healing","absorption"] else 75 if suite=="clip" else 35
        if entry=="build":game.mode="build";game._show_ui()
        for frame in range(frames):
            # These are actual canonical methods/events, not forged UI states.
            if entry=="absorption" and frame==6:game._deal_damage_to_player(4)
            if entry=="build" and frame==10:game.presentation.body_scroll.scroll_vertical=400
            if entry=="dense":game.touch_direction=Vector2(0,0.15)
            game._process(1.0/30.0);game.clean_cut_skin._process(1.0/30.0);game.queue_redraw()
            var capture_frame: bool=frame==17 or frame==frames-1 or (entry in ["stack-burst","dense"] and frame==10) or (entry in ["healing","absorption"] and frame==50) or (entry=="no-u" and frame==3)
            # Snapshot suites sample real rendered states sparsely; the movie
            # records every simulation step. Neither is a frame-rate benchmark.
            if suite=="clip" or capture_frame:
                await process_frame;await RenderingServer.frame_post_draw
            if capture_frame:
                var screen:=DisplayServer.screen_get_image(0)
                var shot:=screen.get_region(Rect2i(DisplayServer.window_get_position(),DisplayServer.window_get_size()))
                var filename: String="%s-%s-%s-%dx%d-%03d.png" % [args[0],suite,entry,extent.x,extent.y,frame]
                shot.save_png(output.path_join(filename))
                var feedback: Dictionary={} if before else {"current":game.passive_feedback.current,"statuses":game.passive_feedback.statuses,"pending":game.passive_feedback.pending,"rings":game.passive_feedback.rings}.duplicate(true)
                reports.append({"file":filename,"frame":frame,"mode":game.mode,"time":game.run_time,"feedback":feedback,"hp":game.hp,"shield":game.shield,"damage":game.run_metrics.damage,"rng":game.rng.state,"cook":game.cook_stacks,"timers":game.passive_timers.duplicate(true)})
    var report:=FileAccess.open(output.path_join("%s-%s-%dx%d.json" % [args[0],suite,extent.x,extent.y]),FileAccess.WRITE)
    report.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"source_sha256":sources,"fixed_simulation_fps":30,"native_scripted_not_human_or_physical_device":true,"render_sampling":"every step for movie; sparse real-rendered snapshots otherwise","states":reports},"  "));report.close()
    print("CAPTURE ",args[0]," ",suite," ",extent);game.queue_free();quit()
