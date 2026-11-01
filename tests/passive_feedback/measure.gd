extends SceneTree
const Run=preload("res://tests/passive_feedback/review_run.gd")
const Probe=preload("res://scripts/performance_probe.gd")
func _initialize() -> void:call_deferred("measure")
func measure() -> void:
    if DisplayServer.get_name()=="headless":push_error("Rendered cost measurement requires actual renderer");quit(1);return
    var args:=OS.get_cmdline_user_args();root.size=Vector2i(int(args[1]),int(args[2]));Engine.max_fps=0
    var game:=Run.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false);game.touch_device=root.size.x<1000
    var observer=game.passive_feedback
    var reports: Array=[]
    for block in range(6):
        var after: bool=block%2==1
        game.passive_feedback=observer if after else null
        game.prepare("dense");game.profile["settings"]["reducedMotion"]=false
        for enemy: Dictionary in game.enemies:enemy.hp=100000;enemy.max=100000
        for frame in range(45):
            game._process(1.0/60.0);game.clean_cut_skin._process(1.0/60.0)
            await process_frame;await RenderingServer.frame_post_draw
        var probe=Probe.new(game,"after" if after else "before",false);game.performance_probe=probe
        var peak_queue:=0;var peak_rings:=0
        var skin_costs:=PackedFloat64Array()
        for frame in range(120):
            game.touch_direction=Vector2(0,sin(float(frame)/30.0)*0.2)
            game._process(1.0/60.0)
            var ui_started: int=Time.get_ticks_usec()
            game.clean_cut_skin._process(1.0/60.0)
            skin_costs.append(float(Time.get_ticks_usec()-ui_started))
            await process_frame;await RenderingServer.frame_post_draw
            if after:peak_queue=maxi(peak_queue,observer.pending.size());peak_rings=maxi(peak_rings,observer.rings.size())
        probe.close();game.performance_probe=null
        var report: Dictionary=probe.report()
        report["skin_process_us"]=Probe.distribution(skin_costs)
        report["skin_samples_us"]=Array(skin_costs)
        report["comparison"]={"after":after,"alternating_block":block,"fixed_delta":1.0/60.0,"feedback_queue_peak":peak_queue,"feedback_ring_peak":peak_rings,"high_health_canonical_density_fixture":true,"not_physical_device":true}
        reports.append(report)
        print("PERF ",block," ",JSON.stringify({"draw_us":report.metrics.draw_us,"sim_us":report.metrics.simulation_us,"hud_us":report.metrics.hud_us,"process_us":report.metrics.process_us,"gpu_ms":report.metrics.render_gpu_ms,"skin_us":report.skin_process_us}))
    var file:=FileAccess.open(args[0],FileAccess.WRITE);file.store_string(JSON.stringify(reports,"  "));file.close()
    game.queue_free();quit()
