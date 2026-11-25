extends SceneTree
## Drives the real Solo run with the preview fixture, fixed active steps and native rendering.

const Maps := preload("res://scripts/solo_maps.gd")
const Scenario := preload("res://scripts/review/no_u_scenario.gd")
const Recorder := preload("res://tests/passive_vfx_lab/qa_recorder.gd")
const Probe := preload("res://scripts/performance_probe.gd")
const STEP := 1.0 / 60.0

class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:
        profile = ProfileStoreScript.defaults()
        profile.settings.sound = false

    func _save_profile() -> void:
        pass

    func _toggle_pause() -> void:
        # Native capture can lose window focus while the fixture is rendering.
        _clear_touch()

    func qa_context() -> Dictionary:
        return {"session_type": "scenario", "scenario_id": "no-u-counter-pulse",
            "scenario_config": {"map": map_id, "caption": no_u_review.label()}}

var game: ReviewRun
var recorder := Recorder.new()
var events: Array[Dictionary] = []
var frame := 0
var pulse_frame := -1000


func _initialize() -> void:
    run.call_deferred()


func run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 6 or DisplayServer.get_name() == "headless":
        push_error("Usage: -- <map> <1|2 density> <baseline|candidate|reduced> <capture|measure> <output directory> <commit>")
        quit(2)
        return
    var map := StringName(args[0])
    var treatment := args[2]
    var capture := args[3] == "capture"
    var destination := args[4]
    if not Maps.NAMES.has(map) or DirAccess.make_dir_recursive_absolute(destination) != OK:
        quit(2)
        return
    root.size = Vector2i(1280, 720)
    Engine.max_fps = 0
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    game = ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.clean_cut_skin.set_process(false)
    game.profile.settings.reducedMotion = treatment == "reduced"
    game.open_map_select(0)
    game.no_u_review = Scenario.new(int(args[1]), treatment != "baseline")
    game.start_selected_map(map)
    if capture:
        recorder.start(game, {"commit": args[5]})
        game.no_u_resolved.connect(observe)
    var samples := PackedFloat64Array()
    var burst_samples := PackedFloat64Array()
    var peak_enemies := 0
    var video_frames := 0
    var horizon := 348 if capture else 210
    for step in horizon:
        frame = step + 1
        if game.mode in ["choice", "legendary", "replace"]:
            game.pick_upgrade(0)
            game._confirm_selection()
        var before := Time.get_ticks_usec()
        game._process(STEP)
        game.clean_cut_skin._process(STEP)
        peak_enemies = maxi(peak_enemies, game.enemies.size())
        if not capture:
            await RenderingServer.frame_post_draw
            var elapsed := float(Time.get_ticks_usec() - before)
            if frame > 35:
                samples.append(elapsed)
            if frame in range(75, 104):
                burst_samples.append(elapsed)
            await process_frame
            continue
        var simulation_us := Time.get_ticks_usec() - before
        recorder.frame(game, simulation_us)
        var slow := frame >= 64 and frame <= 114
        if frame % 2 != 0 and not slow:
            continue
        await RenderingServer.frame_post_draw
        var image := root.get_texture().get_image()
        if frame % 2 == 0:
            if image.save_jpg(destination.path_join("frame-%04d.jpg" % video_frames), 0.90) != OK:
                quit(2)
                return
            video_frames += 1
        if slow:
            image.save_jpg(destination.path_join("slow-%03d.jpg" % (frame - 64)), 0.91)
        if frame == pulse_frame + 14:
            image.save_png(destination.path_join("pulse.png"))
        if frame == pulse_frame + 147:
            image.save_png(destination.path_join("normal-weaken-after-boss-expiry.png"))
    if capture:
        recorder.stop(game, "capture complete")
        if recorder.export_zip(destination.path_join("qa-trace.zip"), "Fixed 60 Hz Solo replay, No U QA fixture") != OK:
            quit(2)
            return
    var report := {
        "commit": args[5], "engine": Engine.get_version_info().string,
        "map": map, "density": int(args[1]), "treatment": treatment,
        "adapter": RenderingServer.get_video_adapter_name(), "viewport": [1280, 720],
        "rng": str(game.rng.state), "active_s": game.run_time, "mode": game.mode, "hp": game.hp,
        "kills": game.kills, "damage": game.run_metrics.damage, "peak_enemies": peak_enemies,
        "events": events, "wall_us": Probe.distribution(samples), "pulse_wall_us": Probe.distribution(burst_samples),
    }
    var file := FileAccess.open(destination.path_join("report.json"), FileAccess.WRITE)
    file.store_string(JSON.stringify(report, "  "))
    file.close()
    print(JSON.stringify(report))
    game.free()
    quit(0 if not capture or events.size() == 1 else 1)


func observe(center: Vector2, radius: float, at: float, hits: Array[Dictionary], weakened: Dictionary) -> void:
    pulse_frame = frame
    var contacts: Array[Dictionary] = []
    for hit: Dictionary in hits:
        contacts.append({"id": hit.id, "hp_loss": hit.hp_loss, "pos": [hit.pos.x, hit.pos.y]})
    var event := {"active_s": at, "frame": frame, "center": [center.x, center.y], "radius": radius,
        "contacts": contacts, "weaken": weakened, "arena_enemies": game.enemies.size()}
    events.append(event)
    recorder.event(game, "no_u_resolved", event)
