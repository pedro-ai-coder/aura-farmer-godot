extends SceneTree
## Staged fixed-seed simulation + native rendering. Not normal play or device FPS.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("measure")
func summary(samples: Array[float]) -> Dictionary:
    samples.sort()
    var total:=0.0
    for value in samples:total+=value
    var mean:=total/samples.size()
    return {"mean_ms":mean,"fps":1000.0/mean,"median_ms":samples[samples.size()/2],"p95_ms":samples[int(samples.size()*0.95)],"p99_ms":samples[int(samples.size()*0.99)],"max_ms":samples.back()}
func measure() -> void:
    root.size=Vector2i(1280,720)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    var game=ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.clean_cut_skin.set_process(false)
    var rows: Array=[]
    for state in ["menu","heroes","opening","dense","choice","legendary","boss"]:
        game.start_run(0);game.rng.seed=451
        if state=="menu":game._return_to_menu()
        elif state=="heroes":game.presentation.open_heroes()
        elif state=="choice":game._gain_xp(39);game._open_choice()
        elif state=="legendary":game.run_time=360;game._open_legendary()
        elif state=="boss":
            game.run_time=720;game.wave=5;game.boss_spawned=true;game.legendary_spent=true
            game._spawn_enemy("boss")
        elif state=="dense":
            for i in range(100):game._spawn_enemy("npc" if i%3 else "hater")
        game._show_ui();game._update_text()
        var timings: Array[float]=[]
        var simulation: Array[float]=[]
        var ui_times: Array[float]=[]
        var previous:=Time.get_ticks_usec()
        for frame in range(150):
            var began:=Time.get_ticks_usec()
            game._process(1.0/60.0)
            var simulated:=Time.get_ticks_usec()
            game.clean_cut_skin.refresh()
            var refreshed:=Time.get_ticks_usec()
            await process_frame
            await RenderingServer.frame_post_draw
            var now:=Time.get_ticks_usec()
            if frame>=30:
                timings.append(float(now-previous)/1000.0)
                simulation.append(float(simulated-began)/1000.0)
                ui_times.append(float(refreshed-simulated)/1000.0)
            previous=now
        rows.append({"scene":state,"frame":summary(timings),"process_including_presenter":summary(simulation),"skin_refresh":summary(ui_times),"enemies":game.enemies.size(),"projectiles":game.player_shots.size(),"final_mode":game.mode})
    var args:=OS.get_cmdline_user_args()
    var report={"scope":"Staged native simulation plus rendering; software Mesa llvmpipe; not Web/device acceptance","viewport":[1280,720],"warmup":30,"samples_per_scene":120,"seed":451,"rows":rows}
    if not args.is_empty():
        var file:=FileAccess.open(args[0],FileAccess.WRITE)
        file.store_string(JSON.stringify(report,"  "))
    print("RECOVERY PROFILE ",JSON.stringify(report))
    game.queue_free();quit()
