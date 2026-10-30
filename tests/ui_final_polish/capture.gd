extends "res://tests/ui_cohesion/capture.gd"
## Same controlled states before/after; original actors and real hazard renderer.
func capture() -> void:
    var args:=OS.get_cmdline_user_args()
    var extent:=Vector2i(int(args[0]),int(args[1]));var output: String=args[2]
    if DisplayServer.get_name()=="headless":push_error("Native rendering required");quit(1);return
    root.size=extent;DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.profile["settings"]["reducedMotion"]=true;game.touch_device=extent.x<1000
    var reports: Array=[]
    for state in args[3].split(","):
        game.start_run(0);game.run_time=725;game.wave=5;game.level=25;game.aura=42
        if state=="mobile":
            game.web_metrics={"width":extent.x,"height":extent.y,"safe":[24,8,16,12]};game.aura=100
        game.player_pos=Vector2(724,543);game._update_camera(0,true)
        game.presentation._window_changed(true);game._show_ui();game._update_text()
        await process_frame;await process_frame
        var skin=game.clean_cut_skin;skin.layout_key="";skin.refresh()
        var transform: Transform2D=skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
        if state in ["near-hud","clipped","boss","mobile"]:
            var point: Vector2=Vector2(150,195) if state=="near-hud" else Vector2(22,60) if state=="clipped" else skin.view*Vector2(0.62,0.55)
            game.boss_spawned=true;game._spawn_enemy("boss",{"pos":transform.affine_inverse()*point})
            game.enemies[-1]["hp"]=17001
            var boss: Dictionary=game.enemies[-1]
            var facing: Vector2=(game.player_pos-Vector2(boss["pos"])).normalized()
            game._schedule_hazard(boss["pos"],600,1.2,0.1,60,"line",facing,boss)
        elif state=="options":game._toggle_pause();game.presentation.open_settings("paused")
        elif state=="paused":game._toggle_pause()
        elif state=="build":game._toggle_pause();game.presentation.open_build()
        elif state=="ready":game.aura=100
        game._show_ui();game._update_text();skin.layout_key="";skin.refresh();game.queue_redraw()
        if skin.gameplay_hud.has_method("update_threat_readability"):skin.gameplay_hud.update_threat_readability(true)
        await process_frame;await RenderingServer.frame_post_draw
        var image:=root.get_texture().get_image()
        var path: String=output.path_join("%s-%dx%d.png" % [state,extent.x,extent.y])
        if image.save_png(path)!=OK:push_error("Capture failed");quit(1);return
        var report: Dictionary={"state":state,"requested":str(extent),"readback":str(image.get_size()),"safe_view":str(skin.view),"flex_hit":str(game.flex_button.get_global_rect()),"settings_panel":str(skin.auxiliary.screen_panel.get_rect())}
        if not game.enemies.is_empty():
            var bounds:=actor_bounds(game,game.enemies[0],transform)
            var hits: Array=[]
            for id in skin.gameplay_hud.modules:
                var module: Control=skin.gameplay_hud.modules[id]
                if module.visible and bounds.intersects(module.get_rect()):hits.append(id)
            report.merge({"boss_bounds":str(bounds),"viewport_clipped":not Rect2(Vector2.ZERO,skin.view).encloses(bounds),"hud_intersections":hits,"hazard_shape":"line","hazard_world_pos":str(game.hazard_zones[0]["pos"]),"hazard_direction":str(game.hazard_zones[0]["dir"]),"boss_world_pos":str(game.enemies[0]["pos"]),"rng":str(game.rng.state)})
        reports.append(report);print("CAPTURE ",path)
    var file:=FileAccess.open(output.path_join("report-%dx%d.json" % [extent.x,extent.y]),FileAccess.WRITE)
    file.store_string(JSON.stringify(reports,"  "));file.close();game.queue_free();quit()

func actor_bounds(game, enemy: Dictionary, transform: Transform2D) -> Rect2:
    var kind: String=game.art.enemy_visual_kind(enemy,game.run_time)
    var frame: int=game.art.enemy_pose_frame(enemy,game.run_time,-1)
    var image: Texture2D=game.art.enemy_frame(kind,frame)
    var data: Dictionary=game.art.enemy_frame_cache[kind+":"+str(frame)]
    var scale: float=float(enemy["radius"])*(2.6 if game.SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"] else 3.1)/float(data["height"])
    var facing: float=-1.0 if cos(float(enemy["angle"]))< -0.05 else 1.0
    var pose: Dictionary=enemy.get("attack_pose",{})
    if not pose.is_empty() and game.run_time<float(pose["end"]):facing=-1.0 if cos(float(pose["angle"]))< -0.05 else 1.0
    return transform*Transform2D(0,Vector2(scale*facing,scale),0,enemy["pos"])*Rect2(-Vector2(data["pivot"]),image.get_size())
