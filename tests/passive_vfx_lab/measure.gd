extends SceneTree

const Lab := preload("res://tests/passive_vfx_lab/lab_run.gd")
const Probe := preload("res://scripts/performance_probe.gd")

func _initialize() -> void:
    measure.call_deferred()

func measure() -> void:
    var args := OS.get_cmdline_user_args()
    if DisplayServer.get_name() == "headless" or args.is_empty():
        quit(2)
        return
    root.size = Vector2i(1200, 740)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    Engine.max_fps = 0
    var reports: Array[Dictionary] = []
    for dense in [false, true]:
        for block in 6:
            var game := Lab.new()
            game.candidate = (block % 2 == 1)
            root.add_child(game)
            game.stage("six-to-seven", dense, dense, false, false, false)
            for warmup in 45:
                await process_frame
                await RenderingServer.frame_post_draw
            var probe := Probe.new(game, "candidate" if game.candidate else "baseline", false)
            game.performance_probe = probe
            var draw_burst := PackedFloat64Array()
            var full_frame := PackedFloat64Array()
            for frame in 120:
                var start := Time.get_ticks_usec()
                game.tick()
                await RenderingServer.frame_post_draw
                var wall := Time.get_ticks_usec() - start
                full_frame.append(wall)
                if not game.last_burst.is_empty() and game.run_time < float(game.last_burst.active_s) + 0.48:
                    draw_burst.append(wall)
                await process_frame
            probe.close()
            game.performance_probe = null
            reports.append({"candidate": game.candidate, "dense": dense, "block": block,
                "burst": game.last_burst, "burst_wall_us": Probe.distribution(draw_burst),
                "frame_wall_us": Probe.distribution(full_frame), "frame_wall_samples_us": Array(full_frame),
                "burst_wall_samples_us": Array(draw_burst), "probe": probe.report()})
            game.queue_free()
            await process_frame
    var file := FileAccess.open(args[0], FileAccess.WRITE)
    file.store_string(JSON.stringify({"engine": Engine.get_version_info().string,
        "adapter": RenderingServer.get_video_adapter_name(), "native_synthetic": true,
        "window": [root.size.x, root.size.y], "reports": reports}, "  "))
    file.close()
    quit()
