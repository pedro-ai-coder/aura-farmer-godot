extends "res://tests/ui_cohesion/capture.gd"
const Baseline=preload("res://tests/threat_indicator/baseline_overlay.gd")
## Component CPU comparison, not rendered FPS or mobile/device measurements.
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
    var baseline:=Baseline.new();game.clean_cut_skin.add_child(baseline);baseline.install(hud)
    var rows: Array=[]
    for workload in ["100 actors, no hazards","100 actors, three boss hazards"]:
        if workload.contains("three"):
            for shape in ["cone","line","ring"]:game._schedule_hazard(Vector2(300,400),600 if shape=="line" else 200 if shape=="cone" else 280,1,1,35,shape,Vector2.RIGHT,game.enemies[0])
        for overlay in [baseline,hud.threat_overlay]:
            overlay.sample(true)
        # Both steady-state cues and trimmed artwork caches are warm.
        await create_timer(0.35).timeout
        for overlay in [baseline,hud.threat_overlay]:
            for i in range(10):overlay.sample(true)
            var row: Dictionary={"workload":workload,"implementation":"baseline-05bcef2" if overlay==baseline else "recovery","actors":game.enemies.size(),"hazards":game.hazard_zones.size(),"cue_steady":overlay.cue.visible}
            for force in [true,false]:
                var times: Array[float]=[]
                for i in range(240):
                    if not force:overlay.next_sample=Time.get_ticks_msec()+1000
                    var start: int=Time.get_ticks_usec();overlay.sample(force)
                    times.append(float(Time.get_ticks_usec()-start)/1000.0)
                times.sort();row["actor_sample" if force else "between_samples"]={"median_ms":times[120],"p95_ms":times[228],"p99_ms":times[237]}
            rows.append(row)
    var payload: Dictionary={"baseline":"05bcef23ae0f040795cacd88e42542b55bc6488e","environment":"Godot 4.7.2 headless CPU, 1280x720 logical, same live state and warmed caches; no browser, physical-device or rendering-FPS claim","samples_per_path":240,"results":rows}
    var file:=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);file.store_string(JSON.stringify(payload,"  "));file.close()
    print(JSON.stringify(payload));game.queue_free();quit()
