extends "res://tests/threat_indicator/capture.gd"
## Offline real Godot recording of controlled actor trajectories, not human play
## or measured delivered FPS. Gameplay rules/camera are never edited by fixture.
func capture() -> void:
    var output: String=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(output)
    root.size=Vector2i(1280,720)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.profile["settings"]["reducedMotion"]=true;game.touch_device=false
    game.web_metrics={}
    game.start_run(0);game.run_time=135;game.wave=2;game.aura=100;game.player_pos=Vector2(1000,600)
    game.presentation._window_changed(true);game._update_camera(0,true);game._show_ui();game._update_text()
    await process_frame;await process_frame
    var skin=game.clean_cut_skin;skin.layout_key="";skin.refresh()
    var hud=skin.gameplay_hud;var overlay=hud.threat_overlay
    var transform: Transform2D=skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
    game._spawn_enemy("reply-guy",{"pos":Vector2(750,500)})
    var reply: Dictionary=game.enemies[-1];var mod: Dictionary={};var final_boss: Dictionary={}
    var actor_size: Vector2=overlay.enemy_bounds(reply,transform).size
    var normal:=Vector2(skin.view.x*0.52,skin.view.y*0.43)
    var slight:=Vector2(-actor_size.x*0.08,skin.view.y*0.43)
    var covered: Vector2=hud.modules["TopLeftHeroStatus"].position+Vector2(35,18)
    var outside:=Vector2(-actor_size.x-64,skin.view.y*0.43)
    var frames: Array=[];var changes: Array=[];var last_key: String=""
    overlay.reset()
    for frame in range(390):
        var stage: String="visible" if frame<60 else "slight boundary motion" if frame<120 else "HUD occlusion" if frame<180 else "offscreen departure" if frame<240 else "two event bosses" if frame<270 else "Big Hater priority" if frame<330 else "stable return"
        var at: Vector2=normal
        if frame>=60 and frame<120:at=normal.lerp(slight,clampf((frame-60)/24.0,0,1))+Vector2(sin(frame)*2,0)
        elif frame>=120 and frame<180:at=slight.lerp(covered,clampf((frame-120)/12.0,0,1))+Vector2(sin(frame)*2,0)
        elif frame>=180:at=covered.lerp(outside,clampf((frame-180)/36.0,0,1))
        move_bounds(reply,at,overlay,transform)
        if frame==240:
            game._spawn_enemy("mod-supremo",{"pos":Vector2(1250,500)});mod=game.enemies[-1]
        if not mod.is_empty():move_bounds(mod,Vector2(-actor_size.x-70,skin.view.y*0.60),overlay,transform)
        if frame==270:
            game.boss_spawned=true;game.wave=5;game._spawn_enemy("boss",{"pos":Vector2(1200,600)});final_boss=game.enemies[-1]
        if not final_boss.is_empty():move_bounds(final_boss,Vector2(-actor_size.x-120,skin.view.y*0.4),overlay,transform)
        if frame>=330:
            move_bounds(reply,outside.lerp(Vector2(skin.view.x*0.30,skin.view.y*0.40),clampf((frame-330)/15.0,0,1)),overlay,transform)
            move_bounds(mod,Vector2(-actor_size.x-70,skin.view.y*0.60).lerp(Vector2(skin.view.x*0.48,skin.view.y*0.48),clampf((frame-330)/15.0,0,1)),overlay,transform)
            move_bounds(final_boss,Vector2(-actor_size.x-120,skin.view.y*0.4).lerp(Vector2(skin.view.x*0.68,skin.view.y*0.40),clampf((frame-330)/15.0,0,1)),overlay,transform)
        game.run_time=(725 if frame>=270 else 135)+float(frame)/30.0
        game._show_ui();game._update_text();skin.refresh();overlay.sample_at(frame*1000/30);game.queue_redraw()
        var text: String=overlay.cue.text if overlay.cue.visible else ""
        var key: String=str([text,overlay.current_phase,overlay.current_id])
        if key!=last_key:changes.append({"frame":frame,"seconds":float(frame)/30,"case":stage,"text":text,"phase":overlay.current_phase,"id":overlay.current_id});last_key=key
        frames.append({"frame":frame,"case":stage,"text":text,"phase":overlay.current_phase,"id":overlay.current_id,"anchor":str(overlay._anchor)})
        await process_frame
    var file:=FileAccess.open(output.path_join("recording.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify({"description":"Actual Godot fixed-30-fps offline recording, controlled trajectories; not human gameplay or device FPS","frames":frames,"changes":changes},"  "));file.close()
    print("RECORDING_CHANGES ",JSON.stringify(changes));game.queue_free();quit()
