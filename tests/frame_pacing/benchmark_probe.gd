extends "res://tests/frame_pacing/measure.gd"
func measure() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    var times: Dictionary={"enabled":[],"disabled":[]}
    for trial in range(6):
        for enabled in ([false,true] if trial%2==0 else [true,false]):
            setup(game,"dense")
            var probe=Probe.new(game,"overhead") if enabled else null
            game.performance_probe=probe
            var start:=Time.get_ticks_usec()
            for frame in range(240):
                game.touch_direction=Vector2.from_angle(frame*0.014)
                game._process([1.0/60.0,1.0/30.0,0.075,1.0/120.0][frame%4])
            var elapsed:=Time.get_ticks_usec()-start
            times["enabled" if enabled else "disabled"].append(elapsed/1000.0)
            if probe!=null:probe.close()
            game.performance_probe=null
    var report={"source":"headless paired diagnostic-overhead benchmark; no rendered FPS","frames_per_trial":240,"trials":6,"enabled_ms":Probe.distribution(PackedFloat64Array(times.enabled)),"disabled_ms":Probe.distribution(PackedFloat64Array(times.disabled)),"raw_ms":times}
    if OS.get_cmdline_user_args().size():
        var file:=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
    print(JSON.stringify(report));game.queue_free();quit()
