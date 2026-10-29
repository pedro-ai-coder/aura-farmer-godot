extends SceneTree
## Actual native Godot fixtures. Never modifies player saves; not human/device play.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("capture")
func capture() -> void:
    var args:=OS.get_cmdline_user_args()
    var extent:=Vector2i(int(args[0]),int(args[1]))
    var output: String=args[2]
    var baseline: bool=args.has("--baseline")
    root.size=extent
    DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    game.touch_device=extent.x<1000
    game.clean_cut_skin.set_process(false)
    var states: Array=["start","partial","shield","low-hp","midgame","full-build","ready","active","recovery","boss","safe-near-ui","cool-kid","alpha","pause-focus","pause-pressed","paused"]
    if baseline:states=["start","full-build","ready","boss"]
    var reports: Array=[]
    for state in states:
        game.start_run(1 if state=="cool-kid" else 2 if state=="alpha" else 0)
        game.run_time=9;game.aura=9
        if state=="partial":game.hp=game.max_hp*0.63
        if state=="shield":game.hp=game.max_hp*0.7;game.shield=game.max_hp*0.4
        if state=="low-hp":game.hp=game.max_hp*0.12
        if state in ["midgame","full-build"]:
            game.run_time=245;game.wave=3;game.level=9;game.xp=48
            game._recompute_max_hp();game.hp=game.max_hp
            game.weapons.append({"id":"ratio-blaster","rarity":"rare","level":3,"timer":0.0})
            if state=="full-build":game.weapons.append({"id":"brainrot-feed","rarity":"epic","level":4,"timer":0.0})
            for id in (["main-character","terminally-online","caught-4k","certified-w","aura-viral"] if state=="full-build" else ["main-character","terminally-online"]):
                game.passives.append({"id":id,"rarity":game.SoloOfferRulesScript.PASSIVE_DATA[id]["rarity"],"level":2})
        if state=="ready":game.aura=100;game.flex_lock=0
        if state=="active":game.aura=0;game.flex_time=4.2;game.flex_lock=28.2
        if state=="recovery":game.aura=0;game.flex_time=0;game.flex_lock=12.0
        if state=="boss":
            game.run_time=625;game.boss_spawned=true;game.shield=40
            game._spawn_enemy("boss",{"pos":Vector2(1030,540)})
        if state=="safe-near-ui":game.player_pos=Vector2(870,390)
        game.presentation._window_changed(true)
        game._show_ui();game._update_text();game._update_camera(0.0,true)
        await process_frame;await process_frame
        var skin=game.clean_cut_skin;skin.layout_key="";skin.refresh()
        if state=="pause-focus":game.pause_button.grab_focus();skin.refresh()
        elif state=="pause-pressed":game.touch_ui_pointers[8]=game.pause_button;skin.refresh()
        elif state=="paused":game._toggle_pause();skin.refresh()
        game.queue_redraw()
        await process_frame;await process_frame;await RenderingServer.frame_post_draw
        var file: String=output.path_join("%s-%dx%d.png" % [state,extent.x,extent.y])
        if root.get_texture().get_image().save_png(file)!=OK:push_error("Capture failed "+file);quit(1);return
        var metrics: Dictionary={"state":state,"pixels":[extent.x,extent.y],"logical_view":[skin.view.x,skin.view.y],"hero":game.hero["id"],"hp":game.hp,"max_hp":game.max_hp,"shield":game.shield,"aura":game.aura,"mode":game.mode,"weapons":game.weapons.duplicate(true),"passives":game.passives.duplicate(true),"controls":[]}
        for node in [skin.hero_name,skin.hp,skin.shield_label,skin.wave,skin.xp,skin.flex_title,skin.flex_status,skin.flex_caption,game.pause_button,game.flex_button]:
            var rect: Rect2=root.get_final_transform()*node.get_global_rect()
            metrics["controls"].append({"node":str(node.name),"rect":[rect.position.x,rect.position.y,rect.size.x,rect.size.y],"text":node.text,"physical_font_px":node.get_theme_font_size("font_size")*root.get_final_transform().get_scale().y})
        reports.append(metrics)
        print("CAPTURE ",file)
    var report:=FileAccess.open(output.path_join("report-%dx%d.json" % [extent.x,extent.y]),FileAccess.WRITE)
    report.store_string(JSON.stringify(reports,"  "))
    game.queue_free();quit()
