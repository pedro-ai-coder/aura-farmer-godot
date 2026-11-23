extends SceneTree
## Actual normal-health runtime, no pixel readback or video encoder overhead.
const Review=preload("res://scripts/cool_kid_review.gd")
func _initialize() -> void:call_deferred("measure")
func distribution(values: Array) -> Dictionary:
    var ordered:=values.duplicate();ordered.sort()
    return {"median":ordered[ordered.size()/2],"p95":ordered[int(ordered.size()*0.95)],"max":ordered[-1],"samples":ordered.size()}
func measure() -> void:
    root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720);Engine.max_fps=0
    var game:=Review.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    var reports: Array=[]
    for trial in range(3):
        for candidate in ([false,true] if trial%2==0 else [true,false]):
            game.start_run(1);game.art.cool_kid_rig.enabled=candidate
            var intervals: Array=[];var samples: Array=[]
            for frame in range(150):
                var stamp:=Time.get_ticks_usec()
                game.touch_direction=Vector2.RIGHT if (frame/30)%2==0 else Vector2.LEFT
                game._process(1.0/60.0);game.clean_cut_skin._process(1.0/60.0)
                var sample_start:=Time.get_ticks_usec()
                if candidate:game.art.cool_kid_rig.sample(str(game.hero_pose()["state"]),game.hero_animation_state())
                var cpu:=Time.get_ticks_usec()-sample_start
                game._review_label();game.queue_redraw()
                await process_frame;await RenderingServer.frame_post_draw
                if frame>=30:intervals.append((Time.get_ticks_usec()-stamp)/1000.0);samples.append(cpu)
            reports.append({"trial":trial,"candidate":candidate,"frame_ms":distribution(intervals),"sample_us":distribution(samples),"raw_frame_ms":intervals})
    var data: Dictionary={"source":"native Godot 4.7.2 / Mesa llvmpipe / 1280x720; alternating normal-runtime trials; no capture readback","simulation":"fixed 60Hz workload for comparability; frame intervals are actual wall time","device_60fps_acceptance":"NOT_RUN: software cloud host is not target hardware","results":reports}
    FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE).store_string(JSON.stringify(data,"  "))
    print(JSON.stringify(data));game.queue_free();quit()
