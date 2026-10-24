extends SceneTree
## Pointer-routing regression: use real Viewport mouse events, never pressed.emit().
## A former per-frame hide/show cycle cancelled BaseButton press before release.
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("verify")

func expect(ok: bool, description: String) -> void:
    if not ok:
        failures.append(description)

func click(button: Button) -> void:
    expect(button.is_visible_in_tree() and not button.disabled, "Button is interactable: " + button.text)
    var point: Vector2 = button.get_global_rect().get_center()
    var motion := InputEventMouseMotion.new()
    motion.position = point
    motion.global_position = point
    root.push_input(motion, true)
    await process_frame
    var down := InputEventMouseButton.new()
    down.button_index = MOUSE_BUTTON_LEFT
    down.button_mask = MOUSE_BUTTON_MASK_LEFT
    down.position = point
    down.global_position = point
    down.pressed = true
    root.push_input(down, true)
    # The real user holds across frames: the visual refresh must NOT hide the button.
    await process_frame
    await process_frame
    expect(button.is_visible_in_tree(), "Button stays visible across a held mouse press: " + button.text)
    var up := InputEventMouseButton.new()
    up.button_index = MOUSE_BUTTON_LEFT
    up.button_mask = 0
    up.position = point
    up.global_position = point
    up.pressed = false
    root.push_input(up, true)
    await process_frame

func verify() -> void:
    for extent in [Vector2i(1280,720),Vector2i(915,412)]:
        root.size = extent
        var game = load("res://scenes/main.tscn").instantiate()
        root.add_child(game)
        game.set_process(false)
        game.presentation._window_changed(true)
        game._return_to_menu()
        await process_frame
        await process_frame
        expect(game.mode == "menu", "Default game starts on the real Clean Cut main menu")

        await click(game.presentation.home.hero_destination)
        expect(game.mode == "heroes", "Actual pointer click on HERO SELECTION opens heroes at %s" % extent)

        await click(game.presentation.home.return_button)
        expect(game.mode == "menu", "Actual pointer click on BACK returns to the menu at %s" % extent)

        await click(game.presentation.options_button)
        expect(game.mode == "options", "Actual pointer click on SETTINGS opens options at %s" % extent)

        await click(game.presentation.back_button)
        expect(game.mode == "menu", "Actual pointer click on BACK closes options at %s" % extent)

        await click(game.presentation.play_button)
        expect(game.mode == "playing", "Actual pointer click on PLAY starts the run at %s" % extent)
        expect(game.hero_index in [0,1,2] and game.run_time == 0.0, "Play uses a legitimate starting hero and clock")
        game.queue_free()
        await process_frame
        await process_frame
    if failures.is_empty():
        print("PASS: Real viewport mouse clicks activate PLAY/HERO SELECTION/SETTINGS and BACK at desktop and compact viewports")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
