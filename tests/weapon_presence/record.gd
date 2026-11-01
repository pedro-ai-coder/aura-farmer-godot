extends SceneTree
const ReviewRun=preload("res://tests/weapon_presence/review_run.gd")
const IDS=["no-cap","keyboard-warrior","cope-shield","ratio-blaster","brainrot-feed","ban-hammer","touch-grass","chad-hands","personal-space"]
func _initialize() -> void:call_deferred("record")
func record() -> void:
    var args:=OS.get_cmdline_user_args()
    var before:=args[0]=="before";var extent:=Vector2i(int(args[1]),int(args[2]));var output: String=args[3]
    var suite: String=args[4]
    var sources: Dictionary={}
    for path in ["scripts/solo_run.gd","scripts/weapon_presentation.gd","scripts/weapon_attachments.gd","scripts/approved_visuals.gd"]:sources[path]=FileAccess.get_sha256("res://"+path)
    if DisplayServer.get_name()=="headless":push_error("Actual rendering required");quit(1);return
    root.size=extent;DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new()
    # Production has no user-facing review switch. The optional adapter can be
    # removed in this isolated test to reproduce the unmodified legacy drawing.
    if before and "weapon_presentation" in game:game.set("weapon_presentation",null)
    root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.touch_device=extent.x<1000
    var title:=Label.new();title.position=Vector2(30,110)
    game.Typography.apply(title,"hud_secondary");title.add_theme_font_size_override("font_size",18)
    title.mouse_filter=Control.MOUSE_FILTER_IGNORE;game.layer.add_child(title)
    await process_frame;await process_frame
    var reports: Array=[]
    var entries: Array=[]
    if suite=="dense":entries.append(["cope-shield","original"])
    elif suite=="legendary":entries.assign([["ratio-blaster","original"],["touch-grass","female"],["chad-hands","female"]])
    else:
        for id in IDS:
            for appearance in ["original","female"]:
                if suite=="starters" and id not in IDS.slice(0,3):continue
                if suite=="remaining" and (id in IDS.slice(0,3) or appearance=="original"):continue
                entries.append([id,appearance])
    for entry in entries:
        var id: String=entry[0];var appearance: String=entry[1]
        game.fixture(id,appearance,suite=="dense")
        if suite=="dense":
            game._spawn_enemy("ping-sniper",{"pos":Vector2(1080,610)})
            var sniper: Dictionary=game.enemies[-1]
            sniper["locked_direction"]=(game.player_pos-Vector2(sniper["pos"])).normalized()
            game._spawn_hostile_shot(sniper)
        if suite=="legendary":
            game.weapons[0]["rarity"]="legendary"
            game.hp=10000;game.max_hp=10000
            for enemy in game.enemies:enemy["hp"]=100000;enemy["max"]=100000
        title.text=("BEFORE" if before else "AFTER")+" / "+id.to_upper()+" / "+appearance.to_upper()+" / SCRIPTED NATIVE"
        if suite=="legendary":title.text+=" / LEGENDARY / PROTECTED FIXTURE"
        var events: Array=[]
        for frame in range(150 if suite=="legendary" else 90):
            game.touch_direction=Vector2(0,-1 if frame<24 else 1 if frame<48 else 0)*0.22
            game._process(1.0/30.0);game.clean_cut_skin._process(1.0/30.0)
            game.queue_redraw()
            await process_frame;await RenderingServer.frame_post_draw
            if frame in [6,8,12,16,25,48,72]:
                var screen:=DisplayServer.screen_get_image(0)
                var image:=screen.get_region(Rect2i(DisplayServer.window_get_position(),DisplayServer.window_get_size()))
                var name:="%s-%s-%s-%s-%dx%d-%02d.png" % [args[0],suite,id,appearance,extent.x,extent.y,frame]
                if image.save_png(output.path_join(name))!=OK:push_error("Screenshot write failed");quit(1);return
                events.append({"frame":frame,"image":name,"pose":game.hero_pose(),"active_shots":game.player_shots.size(),"areas":game.weapon_areas.size(),"damage":game.run_metrics.damage,"rng":game.rng.state})
        reports.append({"id":id,"appearance":appearance,"samples":events,"final_rng":game.rng.state,"damage":game.run_metrics.damage,"kills":game.kills})
    var file:=FileAccess.open(output.path_join("%s-%s-%dx%d.json" % [args[0],suite,extent.x,extent.y]),FileAccess.WRITE)
    file.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"source_sha256":sources,"fixed_simulation_fps":30,"not_delivered_fps_or_human_gameplay":true,"states":reports},"  "));file.close()
    print("CAPTURE ",args[0]," ",suite," ",extent);game.queue_free();quit()
