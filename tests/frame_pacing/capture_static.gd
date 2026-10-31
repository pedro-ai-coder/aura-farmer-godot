extends "res://tests/frame_pacing/measure.gd"
## Matched frozen runtime states for pixel comparison, not FPS measurement.
func measure() -> void:
    if DisplayServer.get_name()=="headless":push_error("Capture requires rendering");quit(1);return
    var output: String=OS.get_cmdline_user_args()[0]
    DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.presentation._window_changed(true)
        setup(game,"normal");game.profile["settings"]["reducedMotion"]=true
        game.touch_direction=Vector2.RIGHT
        for i in range(30):game._process(1.0/60.0)
        game.clean_cut_skin.refresh();Input.warp_mouse(Vector2.ZERO)
        await process_frame;await process_frame;await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(output.path_join("hud-%dx%d.png" % [extent.x,extent.y]))
    game.queue_free();quit()
