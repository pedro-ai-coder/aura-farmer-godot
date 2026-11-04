extends "res://tests/test_clean_cut_pointer_input.gd"
## Keep presentation refresh live: direct callbacks cannot detect stolen focus.

func intro_button(game: Node, caption: String) -> Button:
    for node in game.intro_layer.find_children("*", "Button", true, false):
        if node.text == caption: return node
    return null

func key(code: Key) -> void:
    for pressed in [true,false]:
        var event := InputEventKey.new()
        event.keycode = code
        event.pressed = pressed
        root.push_input(event,true)
        await process_frame
        await process_frame

func tap(button: Button) -> void:
    var point: Vector2 = root.get_final_transform()*button.get_global_rect().get_center()
    for pressed in [true,false]:
        var event := InputEventScreenTouch.new()
        event.index = 0
        event.position = point
        event.pressed = pressed
        Input.parse_input_event(event)
        Input.flush_buffered_events()
        await process_frame
        await process_frame

func settle_intro(game: Node) -> void:
    for frame in range(20): await process_frame
    expect(game.mode == "intro" and game.run_time == 0, "Intro pauses simulation")
    expect(root.gui_get_focus_owner() == intro_button(game,"SKIP / ENTER LEVEL ZERO"), "Intro retains focus after shared UI refresh")

func verify() -> void:
    var profile_path := "user://profile_v2.json"
    var profile_existed := FileAccess.file_exists(profile_path)
    var profile_before := FileAccess.get_file_as_bytes(profile_path) if profile_existed else PackedByteArray()
    for extent in [Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390)]:
        root.size = extent
        var game = load("res://scenes/level_zero.tscn").instantiate()
        root.add_child(game)
        game.start_run(0)
        await settle_intro(game)
        await click(intro_button(game,"SKIP / ENTER LEVEL ZERO"))
        expect(game.mode == "playing", "Real pointer input exits the intro at %s" % extent)
        game._return_to_menu()
        game.start_run(0)
        await settle_intro(game)
        await key(KEY_ENTER)
        expect(game.mode == "playing", "Real Enter exits the intro at %s" % extent)
        game._return_to_menu()
        game.start_run(0)
        await settle_intro(game)
        await key(KEY_TAB)
        expect(root.gui_get_focus_owner() == intro_button(game,"RETURN TO MENU"), "Tab stays within intro controls")
        await key(KEY_ENTER)
        expect(game.mode == "menu", "Keyboard return restores the menu")
        game.start_run(0)
        await settle_intro(game)
        await tap(intro_button(game,"SKIP / ENTER LEVEL ZERO"))
        expect(game.mode == "playing", "Real touch exits the intro at %s" % extent)
        game._return_to_menu()
        game.start_run(0)
        await settle_intro(game)
        await click(intro_button(game,"RETURN TO MENU"))
        expect(game.mode == "menu", "Pointer return restores the menu")
        expect(game.presentation_focus_root() == game.clean_cut_skin, "Shared menu focus restored")
        game.queue_free()
        await process_frame
    expect(FileAccess.file_exists(profile_path) == profile_existed, "Level Zero never creates a production profile")
    if profile_existed:
        expect(FileAccess.get_file_as_bytes(profile_path) == profile_before, "Level Zero leaves profile bytes unchanged")
    for failure in failures: push_error(failure)
    print("LEVEL_ZERO_INPUT: %s" % ("PASS" if failures.is_empty() else "FAIL"))
    quit(0 if failures.is_empty() else 1)
