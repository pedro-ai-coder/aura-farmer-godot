extends SceneTree
## Actual native Compatibility rendering, matched frozen gameplay fixtures.
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
    var args:=OS.get_cmdline_user_args()
    if DisplayServer.get_name()=="headless":
        push_error("A rendered display is required for pickup evidence");quit(1);return
    var before:=args[0]=="before"
    var extent:=Vector2i(int(args[1]),int(args[2]))
    var output: String=args[3]
    root.size=extent
    DirAccess.make_dir_recursive_absolute(output)
    var game=load("res://tests/pickup_refresh/before_run.gd" if before else "res://tests/pickup_refresh/review_run.gd").new()
    root.add_child(game)
    game.set_process(false);game.clean_cut_skin.set_process(false)
    game.touch_device=extent.x<1000
    await process_frame;await process_frame
    var report: Array=[]
    for dense in [false,true]:
        game.fixture(dense)
        await process_frame;await process_frame
        await RenderingServer.frame_post_draw
        var framebuffer:=root.get_texture().get_image()
        # Capture the actual X11 client area. The engine's fractional canvas
        # scaling can round its internal readback one pixel below window width.
        # No resampling or invented padding is applied to the screenshots.
        var screen:=DisplayServer.screen_get_image(0)
        var window_rect:=Rect2i(DisplayServer.window_get_position(),DisplayServer.window_get_size())
        if screen==null or not Rect2i(Vector2i.ZERO,screen.get_size()).encloses(window_rect):
            push_error("Actual window readback unavailable");quit(1);return
        var image:=screen.get_region(window_rect)
        var name:="%s-%s-%dx%d" % [args[0],"dense" if dense else "arena",extent.x,extent.y]
        if image.save_png(output.path_join(name+".png"))!=OK:
            push_error("Screenshot write failed");quit(1);return
        var drops: Array=[]
        for drop in game.pickups:drops.append({"kind":drop.kind,"xp":drop.xp,"pos":[drop.pos.x,drop.pos.y],"phase":drop.get("phase",0)})
        report.append({"image":name+".png","requested":[extent.x,extent.y],"readback":[image.get_width(),image.get_height()],"framebuffer_readback":[framebuffer.get_width(),framebuffer.get_height()],"capture":"actual X11 client rectangle, no resampling","pickups":game.pickups.size(),"enemies":game.enemies.size(),"shots":game.hostile_shots.size(),"fixture_sha256":JSON.stringify(drops).sha256_text(),"rng_state":game.rng.state,"renderer":RenderingServer.get_video_adapter_name(),"human_or_device_test":false})
        print("CAPTURE ",name," ",image.get_size())
    var file:=FileAccess.open(output.path_join("%s-%dx%d.json" % [args[0],extent.x,extent.y]),FileAccess.WRITE)
    file.store_string(JSON.stringify(report,"  "));file.close()
    game.queue_free();quit()
