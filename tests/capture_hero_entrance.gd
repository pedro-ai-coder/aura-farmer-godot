extends SceneTree
## Real Godot Movie Maker render through Garage, map selection and live gameplay.

var game
var frames := 0
var play_frames := 0
var stills: String

func _initialize() -> void:
    call_deferred("_record")

func _record() -> void:
    var args := OS.get_cmdline_user_args()
    var stills_index := args.find("--stills")
    if stills_index >= 0 and stills_index + 1 < args.size():
        stills = args[stills_index + 1]
    if "--mobile" in args:
        var mobile := Vector2i(390, 844) if "--portrait" in args else Vector2i(844, 390)
        root.content_scale_size = mobile
        root.size = mobile
        await process_frame
    var garage = load("res://scenes/signal_breaker_garage.tscn").instantiate()
    root.add_child(garage)
    game = garage.game
    game.profile.settings.reducedMotion = "--reduced-motion" in args
    game.profile.settings.sound = true
    game.profile.settings.masterVolume = 1.0
    game._apply_preferences()
    garage.select_identity(3 if "--vixen" in args else 1)
    garage.start_selected()
    game.touch_device = "--mobile" in args
    game.map_select._select(game.SoloMaps.MSG_FACTORY if "--factory" in args else game.SoloMaps.RUIN_ALLEY)
    game.map_select._start_run()
    process_frame.connect(_sample)

func _sample() -> void:
    frames += 1
    if game.mode == "entrance":
        assert(game.combat_audio.current_wave == 0)
    if not stills.is_empty() and frames in [34, 118, 154, 254, 337]:
        _capture(frames)
    if game.mode == "playing":
        play_frames += 1
        if play_frames == 1:
            assert(game.combat_audio.current_wave == 1)
        if play_frames == 66:
            print("CAPTURE PASS: ", game.hero_entrance.hero_name, " / ", game.map_id,
                " / Wave ", game.combat_audio.current_wave, " / gameplay clock ", game.run_time,
                " / viewport ", root.get_visible_rect().size)
            process_frame.disconnect(_sample)
            game.get_parent().queue_free()
            await process_frame
            quit()
    if frames > 420:
        push_error("Cinematic did not hand off to gameplay")
        quit(1)

func _capture(frame: int) -> void:
    await RenderingServer.frame_post_draw
    var image := root.get_texture().get_image()
    var result := image.save_png(stills.path_join("frame-%03d.png" % frame))
    if result != OK:
        push_error("Could not write native capture: %s" % error_string(result))
