extends SceneTree
## Native review fixture shared by the V4 baseline and V4.1 candidate. Does not
## write profiles. "movie" is an automated ordinary early run. Other figures
## with explicit enemy counts or actor placement are synthetic.
const Maps = preload("res://scripts/solo_maps.gd")
const Probe = preload("res://scripts/performance_probe.gd")
const World = preload("res://scripts/solo_world_rules.gd")
const DT := 1.0 / 60.0
const SITES := [
    Vector2(444, 410), Vector2(1010, 424), Vector2(352, 702), Vector2(1028, 718),
]

class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:
        profile = ProfileStoreScript.defaults()
    func _save_profile() -> void:
        pass

var game: ReviewRun
var output: String
var failed := false

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 2 or DisplayServer.get_name() == "headless":
        push_error("Run with a native display and pass an output directory plus stills, benchmark or movie")
        quit(1)
        return
    output = args[0]
    DirAccess.make_dir_recursive_absolute(output)
    root.size = Vector2i(1280, 720)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    Engine.max_fps = 0
    game = ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.clean_cut_skin.set_process(false)
    game.map_id = Maps.MSG_FACTORY
    await process_frame
    if args[1] == "benchmark":
        await benchmark()
    elif args[1] == "stills":
        await stills()
    elif args[1] == "movie":
        await movie()
    else:
        failed = true
    quit(1 if failed else 0)

func render() -> void:
    await process_frame
    await RenderingServer.frame_post_draw

func resume_fixture() -> void:
    # Window changes between automated native passes can trigger Auto Pause.
    if game.mode == "paused":
        game._toggle_pause()

func screenshot(name: String) -> void:
    await render()
    await render()
    if root.get_texture().get_image().save_png(output.path_join(name + ".png")) != OK:
        push_error("Could not save " + name)
        failed = true

func stage(count: int) -> void:
    game.start_run(0)
    game.profile["settings"]["reducedMotion"] = false
    game.player_pos = Vector2(764, 530)
    game.spawn_timer = INF
    for i in range(count):
        game._spawn_enemy(["npc", "beta", "ping-sniper", "hater", "npc"][i % 5])
    if game.enemies.size() != count:
        push_error("Fixture could not spawn %d enemies (got %d)" % [count, game.enemies.size()])
        failed = true
    game._update_camera(0.0, true)
    game.queue_redraw()

func benchmark() -> void:
    var reports := []
    for count: int in [6, 30, 100]:
        stage(count)
        for frame in range(24):
            game.queue_redraw()
            await render()
        resume_fixture()
        var probe := Probe.new(game, "factory-%d" % count)
        game.performance_probe = probe
        for frame in range(180):
            resume_fixture()
            game.touch_direction = Vector2.from_angle(frame * 0.036)
            game._process(DT)
            await render()
        probe.close()
        game.performance_probe = null
        var report := probe.report(false)
        report["initial_enemy_count"] = count
        report["simulation_delta_seconds"] = DT
        report["vsync"] = DisplayServer.window_get_vsync_mode()
        report["session_type"] = "performance_fixture"
        reports.append(report)
        if report.sample_count != 180:
            push_error("Benchmark collected incomplete data for %d enemies" % count)
            failed = true
        elif report.delivered_render_fps == null or report.metrics.render_interval_ms.p95 == null:
            push_error("Benchmark collected no rendered intervals")
            failed = true
        else:
            print("Benchmark %d: %.2f FPS, P95 %.2f ms, enemies median %.0f" % [
                count, report.delivered_render_fps, report.metrics.render_interval_ms.p95, report.metrics.enemies.median])
    var file := FileAccess.open(output.path_join("performance.json"), FileAccess.WRITE)
    file.store_string(JSON.stringify(reports, "  "))

func stills() -> void:
    for count: int in [6, 30, 100]:
        stage(count)
        for frame in range(90 if count < 100 else 140):
            game.touch_direction = Vector2.from_angle(frame * 0.038)
            game._process(DT)
        await screenshot("combat-%03d" % count)
    stage(0)
    game.layer.hide()
    game.player_pos = Vector2(970, 353)
    game._update_camera(0.0, true)
    for time: float in [0.0, 0.75, 1.5, 12.0]:
        game.run_time = time
        game.queue_redraw()
        await screenshot("press-%04d" % roundi(time * 100.0))
    game.profile["settings"]["reducedMotion"] = true
    for time: float in [0.75, 1.5]:
        game.run_time = time
        game.queue_redraw()
        await screenshot("press-reduced-%04d" % roundi(time * 100.0))
    game.run_time = 0.0
    game.player_pos = Vector2(1216, 495)
    game._update_camera(0.0, true)
    game.queue_redraw()
    await screenshot("terminal")
    for i in range(SITES.size()):
        for side: int in [-1, 1]:
            game.player_pos = SITES[i] + Vector2(0, 86 * side)
            if not World.walkable(game.player_pos, 16.0, game.map_geometry):
                push_error("Occlusion fixture is outside the walkable floor")
                failed = true
            game._update_camera(0.0, true)
            game.queue_redraw()
            await screenshot("cover-%d-%s" % [i + 1, "behind" if side < 0 else "front"])

func movie() -> void:
    game.start_run(0)
    # Normal spawner, starter, HP, hit outcomes and camera. Scripted direction
    # only. If a level choice opens, confirm the first legal offer.
    var route := [
        Vector2(740, 356), Vector2(905, 336), Vector2(1135, 350),
        Vector2(1230, 476), Vector2(1155, 559), Vector2(841, 544),
        Vector2(684, 734), Vector2(503, 785), Vector2(232, 762),
        Vector2(207, 526), Vector2(258, 475), Vector2(520, 510),
    ]
    var waypoint := 0
    var previous_time := 0.0
    for frame in range(600):
        resume_fixture()
        var target: Vector2 = route[waypoint % route.size()]
        if game.player_pos.distance_to(target) < 10.0:
            waypoint += 1
            target = route[waypoint % route.size()]
        game.touch_direction = game.player_pos.direction_to(target)
        if game.mode == "choice":
            game.selected_card_index = 0
            game._confirm_selection()
        game._process(1.0 / 30.0)
        await render()
        previous_time = game.run_time
    print("Automated normal run: %.2fs active, %d route points, %.1f HP remaining" % [previous_time, waypoint, game.hp])
    if waypoint < 8 or previous_time < 18.0:
        push_error("Recorded run did not exercise enough of the route")
        failed = true
