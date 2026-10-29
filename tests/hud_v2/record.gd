extends "res://tests/test_clean_cut_pointer_input.gd"
## Automated 30-second native run, canonical spawns/normal health. Never human/Web QA.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func verify() -> void:
    root.size=Vector2i(1280,720)
    var output: String=OS.get_cmdline_user_args()[0]
    DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    game.presentation._window_changed(true);game._return_to_menu()
    await process_frame;await process_frame
    await click(game.presentation.home.hero_destination)
    await click(game.menu_buttons[0]);await click(game.presentation.home.start_button)
    var title:=Label.new();title.position=Vector2(430,170)
    title.add_theme_font_size_override("font_size",16)
    title.add_theme_color_override("font_color",Color.WHITE)
    title.add_theme_constant_override("outline_size",3)
    title.text="AUTOMATED NATIVE / NORMAL HEALTH / HUD V2"
    title.mouse_filter=Control.MOUSE_FILTER_IGNORE
    game.layer.add_child(title)
    var points: Array=[Vector2(480,450),Vector2(780,430),Vector2(1100,600),Vector2(1050,800),Vector2(760,850),Vector2(450,700)]
    var target_index:=0
    var paused_frames:=0
    for frame in range(465):
        if frame==150:await click(game.pause_button)
        if frame==165:await click(game.presentation.secondary.resume)
        if game.mode=="playing":
            if game.player_pos.distance_to(points[target_index])<35:target_index=(target_index+1)%points.size()
            game.touch_direction=(Vector2(points[target_index])-game.player_pos).normalized()
            for tick in range(4):game._process(1.0/60.0)
        elif game.mode in ["choice","legendary"]:
            game.touch_direction=Vector2.ZERO
            await click(game.offer_buttons[0]);await click(game.confirm_button)
        elif game.mode=="replace":await click(game.restart_button)
        elif game.mode=="paused":paused_frames+=1
        game.clean_cut_skin.refresh()
        await process_frame;await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_jpg(output.path_join("frame-%04d.jpg" % frame),0.86)
    var report: Dictionary={"human":false,"browser":false,"physical_device":false,"fps":15,"frames":465,"normal_health_unmodified":true,"scripted_steering":true,"pause_resume_real_pointer":paused_frames==15,"simulation_time":game.run_time,"hp":game.hp,"kills":game.kills,"level":game.level,"mode":game.mode}
    var file:=FileAccess.open(output.path_join("recording.json"),FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "))
    print("RECORDED ",JSON.stringify(report))
    game.queue_free();quit(1 if not failures.is_empty() else 0)
