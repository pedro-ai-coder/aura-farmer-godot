extends "res://tests/ui_cohesion/capture.gd"
## Small CPU guard for this presentation change. Not rendered FPS/device data.
func capture() -> void:
    root.size=Vector2i(1280,720)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.profile["settings"]["reducedMotion"]=true;game.start_run(0);game.run_time=725
    game.player_pos=Vector2(724,543);game._update_camera(0,true)
    game._spawn_enemy("boss",{"pos":Vector2(300,400)})
    for i in range(99):game._spawn_enemy("npc",{"pos":Vector2(250+(i%10)*90,320+int(i/10)*40)})
    game.boss_spawned=true;game.presentation._window_changed(true);game._show_ui()
    await process_frame;await process_frame
    game.clean_cut_skin.refresh()
    var hud=game.clean_cut_skin.gameplay_hud
    var reports: Array=[]
    for workload in ["100 actors, no hazards","100 actors, three boss hazards"]:
        if workload.ends_with("hazards") and workload.contains("three"):
            for shape in ["cone","line","ring"]:game._schedule_hazard(Vector2(300,400),600 if shape=="line" else 200 if shape=="cone" else 280,1,1,35,shape,Vector2.RIGHT,game.enemies[0])
        for i in range(10):hud.update_threat_readability(true)
        var row: Dictionary={"workload":workload,"actors":game.enemies.size(),"hazards":game.hazard_zones.size()}
        for force in [true,false]:
            var times: Array[float]=[]
            for i in range(120):
                if not force:hud.threat_overlay.next_sample=Time.get_ticks_msec()+1000
                var before: int=Time.get_ticks_usec();hud.update_threat_readability(force)
                times.append(float(Time.get_ticks_usec()-before)/1000.0)
            times.sort();row["actor_sample" if force else "between_actor_samples"]={"median_ms":times[60],"p95_ms":times[114],"p99_ms":times[118]}
        reports.append(row)
    var payload: Dictionary={"environment":"Godot 4.7.2 headless CPU, 1280x720 logical, warmed caches; no rendering FPS, browser, emulator or physical-device claim","samples_per_path":120,"results":reports}
    var args:=OS.get_cmdline_user_args()
    if not args.is_empty():
        var file:=FileAccess.open(args[0],FileAccess.WRITE);file.store_string(JSON.stringify(payload,"  "));file.close()
    print(JSON.stringify(payload));game.queue_free();quit()
