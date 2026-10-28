extends SceneTree

# Regression for the actual deferred-legendary action under the live skin.
# No gameplay values or offer generation rules are changed by this fixture.
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("verify")

func check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func click(button: Button) -> void:
    var point := button.get_global_rect().get_center()
    var motion := InputEventMouseMotion.new()
    motion.position = point
    motion.global_position = point
    root.push_input(motion, true)
    for held in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
        event.position = point
        event.global_position = point
        event.pressed = held
        root.push_input(event, true)
        await process_frame
        await process_frame

func verify() -> void:
    for extent in [Vector2i(1280,720), Vector2i(915,412), Vector2i(390,844)]:
        root.size = extent
        var game = load("res://scenes/main.tscn").instantiate()
        root.add_child(game)
        game.set_process(false)
        game.presentation._window_changed(true)
        game.start_run(0)
        await process_frame
        check(not game.legendary_button.is_visible_in_tree(), "No legendary action before its window")
        game.run_time = game.SoloClock.LEGENDARY_FIRST
        game._open_legendary()
        await process_frame
        var offers: String = JSON.stringify(game.legendary_offers)
        await click(game.defer_button)
        check(game.mode == "playing", "Defer resumes gameplay")
        check(game.legendary_button.is_visible_in_tree(), "Deferred legendary is reachable at %s" % extent)
        var bounds := Rect2(game.presentation.position, game.presentation.view)
        check(bounds.encloses(game.legendary_button.get_global_rect()), "Legendary action stays inside safe UI bounds")
        check(not game.legendary_button.get_global_rect().intersects(game.flex_button.get_global_rect()), "Legendary action does not overlap Flex")
        await click(game.legendary_button)
        check(game.mode == "legendary", "Held pointer click reopens deferred legendary at %s" % extent)
        check(JSON.stringify(game.legendary_offers) == offers, "Reopening never rerolls the offers")
        if game.mode == "legendary":
            game._defer_legendary()
        game.run_time = game.SoloClock.LEGENDARY_DEADLINE
        await process_frame
        check(not game.legendary_button.is_visible_in_tree(), "Action expires at the canonical deadline")
        game.run_time = game.SoloClock.LEGENDARY_FIRST
        game.legendary_spent = true
        await process_frame
        check(not game.legendary_button.is_visible_in_tree(), "Spent legendary cannot be reopened")
        game.queue_free()
        await process_frame
    if failures.is_empty():
        print("PASS: Deferred legendary remains visible, clickable, unchanged and deadline-bound across three viewports")
        quit(0)
    else:
        for message in failures:
            push_error(message)
        quit(1)
