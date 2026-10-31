extends "res://tests/frame_pacing/measure.gd"
## Native elapsed-time recording, separate from benchmarks. Image readback and
## PNG capture add overhead; timestamps preserve it rather than hiding it in a
## constant-FPS movie. Scripted input is not human or Android validation.
func measure() -> void:
    if DisplayServer.get_name()=="headless":push_error("Recording requires rendering");quit(1);return
    var args:=OS.get_cmdline_user_args();var output: String=args[0]
    var scenario: String=args[1] if args.size()>1 else "movement"
    var screen_capture: bool=args.has("--screen-capture")
    DirAccess.make_dir_recursive_absolute(output)
    root.size=Vector2i(844,390);root.position=Vector2i.ZERO;Engine.max_fps=60
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.presentation._window_changed(true);setup(game,scenario)
    await process_frame;await process_frame
    if screen_capture:
        var ready:=FileAccess.open(output.path_join("ready"),FileAccess.WRITE);ready.store_string("ready");ready.close()
        var deadline:=Time.get_ticks_msec()+10000
        while not FileAccess.file_exists(output.path_join("capturing")):
            if Time.get_ticks_msec()>deadline:push_error("Screen recorder did not start");quit(1);return
            await process_frame
        await create_timer(0.2).timeout
    var samples: Array=[];var origin:=Vector2(260,310);var capture_extent:=Vector2i.ZERO
    touch(game,0,origin,true)
    var start:=Time.get_ticks_usec();var previous:=start
    while Time.get_ticks_usec()-start<4000000 and game.mode=="playing":
        var now:=Time.get_ticks_usec();var delta:=float(now-previous)/1000000.0;previous=now
        if scenario=="movement":drag(game,origin+Vector2(150,0))
        else:drag(game,origin+Vector2(120*cos(float(now-start)/1000000),120*sin(float(now-start)/1000000)))
        game._process(delta);game.clean_cut_skin._process(delta)
        await process_frame;await RenderingServer.frame_post_draw
        var stamp:=Time.get_ticks_usec()
        var filename: String="frame-%04d.png" % samples.size()
        if not screen_capture:
            var image:=root.get_texture().get_image();capture_extent=image.get_size()
            image.save_png(output.path_join(filename))
        samples.append({"file":filename,"seconds":float(stamp-start)/1000000,"delta_s":delta,"world_position":[game.player_pos.x,game.player_pos.y],"camera":[game.camera.position.x,game.camera.position.y],"enemies":game.enemies.size()})
    touch(game,0,origin,false)
    var file:=FileAccess.open(output.path_join("recording.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify({"scenario":scenario,"source":"Actual native Godot rendering, elapsed frame delta, scripted routed touch","not_benchmark":true,"limitations":"External X11 video capture adds observer overhead; 30fps movie sampling is not engine FPS. Not Android, browser or human playtesting." if screen_capture else "PNG readback adds stalls. VFR encoding retains observed capture timing. Not Android, browser or human playtesting.","requested_window":[844,390],"capture_pixels":[844,390] if screen_capture else [capture_extent.x,capture_extent.y],"external_screen_capture":screen_capture,"frames":samples},"  "));file.close()
    game.queue_free();quit()
