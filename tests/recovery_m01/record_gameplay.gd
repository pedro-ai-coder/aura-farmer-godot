extends "res://tests/test_clean_cut_pointer_input.gd"
## Automated native execution, normal health and canonical spawns. Separate
## controlled navigation segment is explicitly marked; no human/Web QA claim.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func verify() -> void:
    root.size=Vector2i(1280,720)
    var args:=OS.get_cmdline_user_args();var output:=args[0]
    DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    game.presentation._window_changed(true);game._return_to_menu()
    await process_frame;await process_frame
    await click(game.presentation.home.hero_destination)
    await click(game.menu_buttons[0]);await click(game.presentation.home.start_button)
    var title:=Label.new();title.position=Vector2(420,140);title.add_theme_font_size_override("font_size",17)
    title.add_theme_color_override("font_color",Color.WHITE);title.add_theme_constant_override("outline_size",3)
    game.layer.add_child(title)
    var total:=0;var outcomes: Array=[]
    for segment in ["normal","navigation"]:
        if segment=="navigation":
            game.start_run(0);game.spawn_timer=INF;game.weapons.clear()
            game.player_pos=Vector2(780,600)
            for point in [Vector2(540,550),Vector2(570,490),Vector2(880,680),Vector2(910,620)]:
                game._spawn_enemy("npc",{"pos":point})
        title.text="AUTOMATED NATIVE / NORMAL HEALTH" if segment=="normal" else "CONTROLLED COVER NAVIGATION / NO WEAPONS"
        var points: Array=[Vector2(480,450),Vector2(780,430),Vector2(1100,600),Vector2(1050,800),Vector2(760,850),Vector2(450,700)]
        var target_index:=0
        var frame_count:=900 if segment=="normal" else 300
        for frame in range(frame_count):
            if game.mode=="playing":
                var target: Vector2=points[target_index]
                if game.player_pos.distance_to(target)<35:target_index=(target_index+1)%points.size()
                game.touch_direction=(Vector2(points[target_index])-game.player_pos).normalized()
                for tick in range(4):game._process(1.0/60.0)
            elif game.mode in ["choice","legendary"]:
                game.touch_direction=Vector2.ZERO
                await click(game.offer_buttons[0]);await click(game.confirm_button)
            elif game.mode=="replace":await click(game.restart_button)
            else:
                for tick in range(4):game._process(1.0/60.0)
            game.clean_cut_skin.refresh()
            await process_frame;await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_jpg(output.path_join("%s-%04d.jpg" % [segment,frame]),0.85)
            total+=1
            if game.mode=="lost" and frame>90:break
        outcomes.append({"segment":segment,"simulation_time":game.run_time,"mode":game.mode,"hp":game.hp,"kills":game.kills,"level":game.level,"enemies":game.enemies.size()})
    var report:=FileAccess.open(output.path_join("recording.json"),FileAccess.WRITE)
    report.store_string(JSON.stringify({"fps":15,"frames":total,"human":false,"browser":false,"normal_health_unmodified":true,"segments":outcomes},"  "))
    print("RECORDED ",JSON.stringify(outcomes))
    game.queue_free();quit()
