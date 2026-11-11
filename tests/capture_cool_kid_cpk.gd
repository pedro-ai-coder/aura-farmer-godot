extends "res://tests/test_clean_cut_pointer_input.gd"
## Real-time native gameplay with automated input, not a staged fixture.
## No clock/HP/XP/enemy/stat writes. Only profile persistence is isolated.
class CaptureRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

var game
var output := ""
var captured: Dictionary = {}
var observations: Array = []
var choices := 0
var start_tick := 0

func snapshot() -> Dictionary:
    return {"seconds":game.run_time,"mode":game.mode,"hp":game.hp,"xp":game.total_xp,
        "level":game.level,"kills":game.kills,"choices":choices,"metrics":game.run_metrics.duplicate(true),
        "pose":game.hero_pose(),"rng":game.rng.state}

func capture(label: String) -> void:
    if captured.has(label): return
    captured[label] = true
    await RenderingServer.frame_post_draw
    var path := output.path_join(label+".jpg")
    root.get_texture().get_image().save_jpg(path,0.9)
    var record := snapshot(); record["image"] = label+".jpg"
    observations.append(record)
    print("CAPTURE ",label," ",JSON.stringify(record))

func verify() -> void:
    var args := OS.get_cmdline_user_args()
    output = args[0]
    DirAccess.make_dir_recursive_absolute(output)
    root.size = Vector2i(1280,720)
    game = CaptureRun.new()
    root.add_child(game)
    game.presentation._window_changed(true)
    await process_frame
    await click(game.presentation.home.hero_destination)
    game.presentation.select_hero(1)
    await process_frame
    await capture("01-hero-selection")
    await click(game.presentation.home.start_button)
    await capture("02-normal-start")
    start_tick = Time.get_ticks_msec()
    while Time.get_ticks_msec()-start_tick < 300000:
        await process_frame
        if game.mode in ["lost","won"]:
            await create_timer(0.6).timeout
            await capture("08-result")
            break
        if game.mode == "choice":
            await capture("05-xp-upgrade")
            await click(game.offer_buttons[0])
            await click(game.confirm_button)
            choices += 1
        elif game.mode == "replace":
            await click(game.offer_buttons[0])
            await click(game.confirm_button)
        elif game.mode == "playing":
            # Ordinary movement input: collect nearby XP, then approach targets.
            # After observing a Flex, stop dodging to exercise natural defeat.
            var target: Vector2 = game.player_pos
            var distance := INF
            for drop: Dictionary in game.pickups:
                var gap: float = game.player_pos.distance_to(drop["pos"])
                if gap < distance:
                    distance = gap; target = drop["pos"]
            if distance > 160.0:
                var enemy: Dictionary = game._nearest_target(800.0)
                if not enemy.is_empty():
                    target = enemy["pos"]
                    if game.player_pos.distance_to(target) < 65.0: target = game.player_pos
            game.touch_direction = (target-game.player_pos).normalized() if game.player_pos.distance_to(target) > 8.0 else Vector2.ZERO
            if captured.has("07-flex") and game.run_time > 100.0:
                game.touch_direction = Vector2.ZERO
            if game.aura >= 100.0 and game.flex_lock <= 0.0:
                await click(game.flex_button)
            var pose: Dictionary = game.hero_pose()
            if pose["state"] == "run": await capture("03-movement")
            if pose["state"] == "attack" and game.kills > 0: await capture("04-melee-combat")
            if pose["state"] == "hurt": await capture("06-damage")
            if pose["state"] == "flex-loop": await capture("07-flex")
        if int(game.run_time)%20 == 0 and not captured.has("tick-"+str(int(game.run_time))):
            captured["tick-"+str(int(game.run_time))] = true
            print("PROGRESS ",JSON.stringify(snapshot()))
    var result := snapshot()
    if game.mode in ["lost","won"]:
        game.start_run(1)
        await process_frame
        await capture("09-restart")
    var report := {"engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),
        "game_commit":args[1],"source_sha256":"c50232da6978c9751768319f1f59454cff548173cc0bd5b15f7a1d206f649ddf",
        "kind":"REAL_TIME_NATIVE_GAMEPLAY_AUTOMATED_INPUT","not_human_playtest":true,
        "no_clock_stat_enemy_or_xp_injection":true,"wall_seconds":(Time.get_ticks_msec()-start_tick)/1000.0,
        "final":result,"captures":observations,"input_errors":failures}
    FileAccess.open(output.path_join("gameplay.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
    print("GAMEPLAY_RESULT ",JSON.stringify(report))
    game.queue_free()
    quit(0 if failures.is_empty() and result["mode"] in ["lost","won"] else 1)
