extends SceneTree
## Native review fixtures, never a player save or human/device playthrough.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("capture")
func capture() -> void:
    var args:=OS.get_cmdline_user_args();var extent:=Vector2i(int(args[0]),int(args[1]));var output: String=args[2]
    var states: PackedStringArray=args[3].split(",")
    if DisplayServer.get_name()=="headless":push_error("Native rendering is required");quit(1);return
    root.size=extent;DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.profile["settings"]["reducedMotion"]=true;game.touch_device=extent.x<1000
    var reports: Array=[]
    for state in states:
        game.start_run(0);game.run_time=625;game.wave=5;game.level=20;game.xp=110;game.kills=420
        game.weapons[0]["level"]=4
        game.weapons.append({"id":"ratio-blaster","rarity":"rare","level":3,"timer":0.0})
        game.weapons.append({"id":"brainrot-feed","rarity":"epic","level":4,"timer":0.0})
        for id in ["main-character","terminally-online","built-different","caught-4k","certified-w"]:
            game.passives.append({"id":id,"rarity":game.SoloOfferRulesScript.PASSIVE_DATA[id]["rarity"],"level":1 if id=="main-character" else 4})
        game._recompute_max_hp();game.hp=game.max_hp*0.72;game.shield=40;game.aura=42
        game.run_metrics["damage"]=98765;game.run_metrics["healing"]=342;game.run_metrics["protection"]=180;game.run_metrics["flexes"]=6
        if state=="build":game._toggle_pause();game.presentation.open_build()
        elif state=="options":game._toggle_pause();game.presentation.open_settings("paused")
        elif state=="won":
            game.boss_spawned=true;game._spawn_enemy("boss",{"pos":Vector2(850,680)})
            game._hit_enemy(game.enemies[-1],1000000)
        elif state=="lost":game._deal_damage_to_player(1000000)
        elif state=="boss":
            game.boss_spawned=true;game.run_time=725;game._spawn_enemy("boss",{"pos":Vector2(850,680)})
            game.enemies[-1]["hp"]=17001;game.enemies[-1]["next_attack"]=game.run_time;game._step_enemies(0)
        elif state=="max-level":
            game.run_time=545;game.level=25;game._recompute_max_hp();game.hp=game.max_hp*0.6
            game._gain_xp(855)
        game.presentation._window_changed(true);game._show_ui();game._update_text();game._update_camera(0,true)
        await process_frame;await process_frame
        game.clean_cut_skin.layout_key="";game.clean_cut_skin.refresh();game.queue_redraw()
        await process_frame;await RenderingServer.frame_post_draw
        var image:=root.get_texture().get_image()
        var path: String=output.path_join("%s-%dx%d.png" % [state,extent.x,extent.y])
        if image.save_png(path)!=OK:push_error("Cannot save capture");quit(1);return
        reports.append({"state":state,"mode":game.mode,"requested":[extent.x,extent.y],"readback":str(image.get_size()),"hero":game.hero["id"],"hp":game.hp,"level":game.level,"xp":game.xp,"kills":game.kills,"run_time":game.run_time,"metrics":game.run_metrics.duplicate(true),"weapons":game.weapons.duplicate(true),"passives":game.passives.duplicate(true)})
        print("CAPTURE ",path)
    var report:=FileAccess.open(output.path_join("report-%dx%d-%s.json" % [extent.x,extent.y,args[3].replace(",","-")]),FileAccess.WRITE)
    report.store_string(JSON.stringify(reports,"  "));report.close();game.queue_free();quit()
