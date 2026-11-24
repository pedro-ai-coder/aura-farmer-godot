extends SceneTree
## Automated input on ordinary Solo rules. Search and capture use the same replay.
const Policy := preload("res://tests/survival_review_policy.gd")
const Maps := preload("res://scripts/solo_maps.gd")
const Probe := preload("res://scripts/performance_probe.gd")
const STEP := 1.0 / 60.0

class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:
        profile = ProfileStoreScript.defaults()
        profile.settings.sound = false
    func _save_profile() -> void:
        pass
    func _toggle_pause() -> void:
        # Camera capture and benchmarking can run in a background native window.
        _clear_touch()

var game: ReviewRun
var frame := 0
var bursts: Array[Dictionary] = []
var acquisition := -1.0
var peak_enemies := 0
var movement := Vector2.ZERO

func _initialize() -> void:
    run.call_deferred()

func run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 5:
        push_error("Usage: -- <map> <seed> <search|capture|measure> <frame> <output directory>")
        quit(2)
        return
    var map := StringName(args[0])
    var seed := int(args[1])
    var action := args[2]
    var focus := int(args[3])
    var out := args[4]
    var candidate := OS.get_environment("CPK_VFX_CANDIDATE") == "1"
    var visual := OS.get_environment("CPK_VFX_VARIANT")
    var neon := visual == "v3"
    candidate = candidate or neon or visual == "v2"
    var reduced := OS.get_environment("CPK_VFX_REDUCED") == "1"
    var qa_loadout := OS.get_environment("CPK_VFX_QA_LOADOUT") == "1"
    if action != "search" and DisplayServer.get_name() == "headless":
        push_error("Native renderer required for capture or timing")
        quit(2)
        return
    root.size = Vector2i(1280, 720)
    Engine.max_fps = 0
    if action == "measure":
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    game = ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.clean_cut_skin.set_process(false)
    game.profile.settings.reducedMotion = reduced
    if candidate:
        game.call("_enable_six_to_seven_review", neon)
    if game.has_signal("passive_burst_resolved") and action != "measure":
        game.connect("passive_burst_resolved", observe)
    game.open_map_select(0)
    game.start_selected_map(map)
    if qa_loadout:
        game._apply_card({"type": "passive", "id": "six-to-seven", "rarity": "epic", "level": 1})
    game.rng.seed = seed
    var begin := maxi(1, focus - 174)
    var end := 43200 if action == "search" else focus + 144
    var probe
    var index := 0
    var wall_times := PackedFloat64Array()
    var burst_times := PackedFloat64Array()
    var output_error := DirAccess.make_dir_recursive_absolute(out)
    if output_error != OK:
        push_error(error_string(output_error))
        quit(2)
        return
    for step_index in end:
        frame = step_index + 1
        if game.mode in ["lost", "won"]:
            break
        drive()
        if acquisition < 0.0 and game._passive_level("six-to-seven") > 0:
            acquisition = game.run_time
        if action == "measure" and frame == begin:
            probe = Probe.new(game, visual if not visual.is_empty() else ("candidate" if candidate else "unchanged-main"))
            game.performance_probe = probe
        var measured := action == "measure" and frame >= begin
        var before := Time.get_ticks_usec() if measured else 0
        game._process(STEP)
        peak_enemies = maxi(peak_enemies, game.enemies.size())
        if frame < begin or action == "search":
            continue
        game.clean_cut_skin._process(STEP)
        if measured:
            await RenderingServer.frame_post_draw
            var elapsed := float(Time.get_ticks_usec() - before)
            wall_times.append(elapsed)
            if frame >= focus and frame < focus + 29:
                burst_times.append(elapsed)
            await process_frame
        elif frame % 2 == 0 or (not visual.is_empty() and absi(frame - focus) <= 32):
            await RenderingServer.frame_post_draw
            var pixels := root.get_texture().get_image()
            if frame % 2 == 0:
                if pixels.save_jpg(out.path_join("frame-%04d.jpg" % index), 0.92) != OK:
                    quit(2)
                    return
                index += 1
            if not visual.is_empty():
                var phase := frame - focus
                if absi(phase) <= 32:
                    pixels.save_jpg(out.path_join("slow-%03d.jpg" % (phase + 32)), 0.92)
                if phase in [0, 3, 8, 16]:
                    pixels.save_png(out.path_join("phase-%02d.png" % phase))
            if absi(frame - (focus + 6)) <= 1:
                pixels.save_png(out.path_join("impact.png"))
            if absi(frame - (focus - 20)) <= 1:
                pixels.save_png(out.path_join("anticipation.png"))
    var report := {"kind": "automated_ordinary_gameplay", "candidate": candidate, "map": str(map),
        "visual": visual, "reduced_motion": reduced, "qa_loadout": qa_loadout, "focus": focus,
        "seed": seed, "seconds": game.run_time, "level": game.level, "acquisition": acquisition,
        "burst_events": bursts, "peak_enemies": peak_enemies, "frames": frame, "rng": game.rng.state,
        "kills": game.kills, "hp": game.hp, "damage": game.run_metrics.damage, "mode": game.mode}
    if probe != null:
        probe.close()
        game.performance_probe = null
        report.merge({"wall_us": Probe.distribution(wall_times), "burst_wall_us": Probe.distribution(burst_times),
            "wall_raw_us": Array(wall_times), "probe": probe.report(false)})
    var file := FileAccess.open(out.path_join("report.json"), FileAccess.WRITE)
    file.store_string(JSON.stringify(report, "  "))
    file.close()
    print("REPLAY ", map, " seed ", seed, " | acquire ", acquisition, " | bursts ", bursts.size(),
        " | max crowd ", peak_enemies, " | time ", game.run_time)
    game.free()
    quit(0)

func drive() -> void:
    if game.mode in ["choice", "legendary"]:
        var cards: Array = game.selection if game.mode == "choice" else game.legendary_offers
        var index := 0
        var score := -INF
        for slot in cards.size():
            var card: Dictionary = cards[slot]
            var id: String = card.get("id", "")
            var weight := 10.0
            if str(card.get("type", "")).contains("weapon"):
                weight = 120.0 if card.type == "weapon" else 85.0
            if id in ["caught-4k", "main-character", "built-different"]:
                weight = 95.0
            if id == "six-to-seven":
                weight = 1000.0
            if weight > score:
                score = weight
                index = slot
        game.pick_upgrade(index)
        game._confirm_selection()
    elif game.mode == "replace":
        game.pick_upgrade(0)
        game._confirm_selection()
    elif game.mode == "playing":
        if frame % 4 == 1:
            var radial := (game.player_pos - Vector2(740, 620)) / Vector2(370, 205)
            var angle := radial.angle() + 0.65
            var patrol := Vector2(740, 620) + Vector2(cos(angle) * 370, sin(angle) * 205)
            movement = Policy.movement(game, Policy.goal(game, patrol))
            var aim := Policy.aim_target(game)
            game.manual_aim = not aim.is_empty()
            if game.manual_aim:
                game.aim_point = aim.pos
        game.touch_direction = movement
        if game.aura >= 100 and not game.enemies.is_empty():
            game._use_flex()

func observe(id: StringName, center: Vector2, radius: float, at: float, hits: Array[Dictionary]) -> void:
    if id != &"six-to-seven":
        return
    var contacts: Array[Dictionary] = []
    for hit in hits:
        var point: Vector2 = hit.position
        contacts.append({"id": hit.id, "position": [point.x, point.y], "hp_lost": hit.hp_lost})
    bursts.append({"frame": frame, "active_time": at, "center": [center.x, center.y],
        "radius": radius, "enemies": game.enemies.size(), "hits": contacts})
