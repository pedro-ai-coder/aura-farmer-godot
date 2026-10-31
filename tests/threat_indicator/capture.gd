extends "res://tests/ui_cohesion/capture.gd"
## Controlled real-engine fixtures. Never loads or saves a player profile.
var clock_ms:=1000
func capture() -> void:
    var args:=OS.get_cmdline_user_args();var extent:=Vector2i(int(args[0]),int(args[1]));var output: String=args[2]
    if DisplayServer.get_name()=="headless":push_error("Native rendering required");quit(1);return
    root.size=extent;DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.touch_device=extent.x<1000;game.profile["settings"]["reducedMotion"]=true
    if extent.x<1000:game.web_metrics={"width":extent.x,"height":extent.y,"safe":[24,8,16,12]}
    var reports: Array=[]
    for state in args[3].split(","):
        game.start_run(0);game.run_time=135;game.wave=2;game.player_pos=Vector2(1000,600);game.aura=100
        game.presentation._window_changed(true);game._update_camera(0,true);game._show_ui();game._update_text()
        await process_frame;await process_frame
        var skin=game.clean_cut_skin;skin.layout_key="";skin.refresh()
        var overlay=skin.gameplay_hud.threat_overlay
        if overlay.has_method("reset"):overlay.reset()
        var transform: Transform2D=skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
        game._spawn_enemy("reply-guy",{"pos":Vector2(750,500)})
        var boss: Dictionary=game.enemies[-1]
        var bounds: Rect2=overlay.enemy_bounds(boss,transform)
        var target:=Vector2(skin.view.x*0.57,skin.view.y*0.4)
        if state=="slight":target=Vector2(-bounds.size.x*0.08,skin.view.y*0.43)
        elif state=="clipped":target=Vector2(-bounds.size.x*0.58,skin.view.y*0.43)
        elif state in ["offscreen","multiple","priority"]:target=Vector2(-bounds.size.x-64,skin.view.y*0.43)
        elif state in ["occluded","telegraph"]:target=skin.gameplay_hud.modules["TopLeftHeroStatus"].position+Vector2(35,18)
        move_bounds(boss,target,overlay,transform)
        if state in ["multiple","priority"]:
            game._spawn_enemy("mod-supremo",{"pos":Vector2(1200,500)})
            move_bounds(game.enemies[-1],Vector2(-bounds.size.x-70,skin.view.y*0.60),overlay,transform)
        if state in ["priority","telegraph","big-hater"]:
            game.run_time=725;game.wave=5;game.boss_spawned=true
            game._spawn_enemy("boss",{"pos":Vector2(1150,650)})
            if state=="priority":move_bounds(game.enemies[-1],Vector2(-bounds.size.x-120,skin.view.y*0.4),overlay,transform)
            elif state=="telegraph":
                move_bounds(game.enemies[-1],Vector2(18,18),overlay,transform)
                var source: Dictionary=game.enemies[-1]
                game._schedule_hazard(source["pos"],600,1.2,0.1,60,"line",(game.player_pos-Vector2(source["pos"])).normalized(),source)
        if state=="mobile-input":
            game.enemies.clear();game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(80,0)})
            var point: Vector2=skin.shift+skin.view*Vector2(0.4,0.5)
            game._input(touch(0,point,true));var drag:=InputEventScreenDrag.new();drag.index=0;drag.position=point+Vector2(40,0);game._input(drag)
            var flex: Vector2=game.flex_button.get_global_rect().get_center()
            game._input(touch(1,flex,true));game._input(touch(1,flex,false))
        for enemy: Dictionary in game.enemies:
            if not game.FIELD.grow(-float(enemy["radius"])).has_point(enemy["pos"]):push_error("Fixture actor outside canonical field: "+state);quit(1);return
        game._show_ui();game._update_text();skin.layout_key="";skin.refresh()
        if overlay.has_method("sample_at"):
            overlay.sample_at(clock_ms);clock_ms+=400;overlay.sample_at(clock_ms)
        else:skin.gameplay_hud.update_threat_readability(true)
        game.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
        var image:=root.get_texture().get_image();var path: String=output.path_join("%s-%dx%d.png" % [state,extent.x,extent.y])
        if image.save_png(path)!=OK:push_error("Capture failed");quit(1);return
        var states: Array=[]
        for enemy: Dictionary in game.enemies:
            if game.SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"]:states.append({"id":enemy["id"],"kind":enemy["kind"],"position":str(enemy["pos"]),"bounds":str(overlay.enemy_bounds(enemy,transform))})
        reports.append({"state":state,"requested":str(extent),"readback":str(image.get_size()),"safe_view":str(skin.view),"cue":overlay.cue.text if overlay.cue.visible else "","cue_rect":str(overlay.cue.get_rect()),"bosses":states,"rng":str(game.rng.state),"camera":str(game.camera.position),"joystick_owner":game.touch_index,"joystick_active":game.touch_active,"flex_time":game.flex_time})
        print("CAPTURE ",path)
    var file:=FileAccess.open(output.path_join("report-%dx%d.json" % [extent.x,extent.y]),FileAccess.WRITE);file.store_string(JSON.stringify(reports,"  "));file.close();game.queue_free();quit()

func move_bounds(enemy: Dictionary,at: Vector2,overlay,transform: Transform2D) -> void:
    var bounds: Rect2=overlay.enemy_bounds(enemy,transform)
    enemy["pos"]=transform.affine_inverse()*(transform*Vector2(enemy["pos"])+at-bounds.position)

func touch(index: int,at: Vector2,pressed: bool) -> InputEventScreenTouch:
    var event:=InputEventScreenTouch.new();event.index=index;event.position=at;event.pressed=pressed;return event
