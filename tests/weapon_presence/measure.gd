extends SceneTree
const ReviewRun=preload("res://tests/weapon_presence/review_run.gd")
const Probe=preload("res://scripts/performance_probe.gd")
func _initialize() -> void:call_deferred("measure")
func measure() -> void:
    if DisplayServer.get_name()=="headless":push_error("Native renderer required for render cost evidence");quit(1);return
    var args:=OS.get_cmdline_user_args();root.size=Vector2i(int(args[1]),int(args[2]));Engine.max_fps=0
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    var observer=game.weapon_presentation
    var reports: Array=[]
    for block in range(4):
        var after:=block%2==1
        game.weapon_presentation=observer if after else null
        game.fixture("cope-shield","female",true)
        game.profile["settings"]["reducedMotion"]=false
        game.legendary_spent=true
        # Canonical-density controlled stress, not a normal-health human run.
        for frame in range(45):
            game._process(1.0/60.0);game.clean_cut_skin._process(1.0/60.0)
            await process_frame;await RenderingServer.frame_post_draw
        var probe=Probe.new(game,"after" if after else "before",false)
        game.performance_probe=probe
        var peak_impacts:=0;var peak_gestures:=0
        for frame in range(120):
            game.touch_direction=Vector2(0,sin(float(frame)/30.0)*0.2)
            game._process(1.0/60.0);game.clean_cut_skin._process(1.0/60.0)
            await process_frame;await RenderingServer.frame_post_draw
            if after:
                var impacts:=0;var gestures:=0
                for effect in observer.impacts:
                    if game.run_time<float(effect["until"]):impacts+=1
                for effect in observer.gestures:
                    if game.run_time<float(effect["until"]):gestures+=1
                peak_impacts=maxi(peak_impacts,impacts);peak_gestures=maxi(peak_gestures,gestures)
        probe.close();game.performance_probe=null
        var report: Dictionary=probe.report()
        report["comparison"]={"after":after,"alternating_block":block,"fixed_delta":1.0/60.0,"new_impact_peak":peak_impacts,"new_gesture_peak":peak_gestures,"high_health_controlled_dense_fixture":true,"not_physical_device":true}
        reports.append(report)
        print("PERF ",block," ",JSON.stringify({"draw_us":report.metrics.draw_us,"sim_us":report.metrics.simulation_us,"gpu_ms":report.metrics.render_gpu_ms,"draw_calls":report.metrics.draw_calls}))
    var file:=FileAccess.open(args[0],FileAccess.WRITE);file.store_string(JSON.stringify(reports,"  "));file.close()
    game.queue_free();quit()
