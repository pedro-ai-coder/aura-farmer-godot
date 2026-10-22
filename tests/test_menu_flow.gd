extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _key(code: Key, pressed: bool = true) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = pressed
    return event

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.call("start_run", 0)
    game.call("_gain_xp", 100.0)
    game.call("_open_choice")
    var pending: int = game.get("pending_choices")
    var before: Array = game.get("weapons").duplicate(true)
    game.call("pick_upgrade", 0)
    _expect(game.get("pending_choices") == pending and game.get("weapons") == before, "Selecting a card cannot apply it before confirmation")
    game.call("_input", _key(KEY_W))
    _expect(game.get("blocked_movement").has(KEY_W), "Movement pressed in a modal is suppressed")
    game.call("_input", _key(KEY_W, false))
    _expect(not game.get("blocked_movement").has(KEY_W), "Releasing a suppressed movement key clears it")
    game.call("_confirm_selection")
    _expect(game.get("pending_choices") == pending - 1, "Confirmation consumes exactly one queued choice")
    game.call("start_run", 0)
    game.call("_toggle_pause")
    var time: float = game.get("run_time")
    game.call("_request_return_to_menu")
    _expect(game.get("mode") == "confirm_exit", "Leaving an unfinished run requires explicit confirmation")
    game.call("_process", 0.2)
    _expect(game.get("run_time") == time, "Exit confirmation cannot resume combat underneath")
    game.call("_unhandled_key_input", _key(KEY_ESCAPE))
    _expect(game.get("mode") == "paused", "Escape cancels exit and returns to pause")
    game.call("_request_return_to_menu")
    var runs: int = game.get("profile")["runs"]
    game.call("_confirm_selection")
    _expect(game.get("mode") == "menu" and game.get("profile")["runs"] == runs, "Confirmed abandonment returns to menu without recording a result")
    game.call("_open_profile_export")
    var exported: String = game.get("profile_text").text
    _expect(JSON.parse_string(exported)["version"] == 2, "Save export exposes the transferable v2 profile")
    game.call("_confirm_selection")
    game.call("_open_profile_import")
    var profile: Dictionary = game.get("profile").duplicate(true)
    _expect(not game.call("_import_profile_text", "not json") and game.get("profile") == profile, "Invalid save import leaves profile unchanged")
    _expect(game.call("_import_profile_text", exported), "Exported v2 profile can be imported")
    _expect(game.get("profile")["legacy"]["godotBeforeImport"] == profile.get("legacy", {}).get("godotBeforeImport", profile), "Import preserves the entire previous Godot profile snapshot")
    var sound: bool = game.get("profile")["settings"]["sound"]
    game.call("_toggle_sound")
    _expect(game.get("profile")["settings"]["sound"] != sound, "Sound preference is interactive")
    game.call("_toggle_motion")
    game.call("start_run", 1)
    game.call("_finish", false)
    game.get("retry_button").emit_signal("pressed")
    _expect(game.get("mode") == "playing" and game.get("hero")["id"] == "cool-kid" and game.get("run_time") == 0.0, "Play Again restarts the selected hero with a fresh run")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Explicit choice confirmation, modal input/exit isolation, save transfer/preferences and result retry")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
