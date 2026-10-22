extends SceneTree

## GDD C.1 mobile touch lifecycle regression for one floating left-side pointer.
var failures: Array[String] = []

func _expect(ok: bool, description: String) -> void:
    if not ok:
        failures.append(description)

func _touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
    var event := InputEventScreenTouch.new()
    event.index = index
    event.position = position
    event.pressed = pressed
    return event

func _drag(index: int, position: Vector2) -> InputEventScreenDrag:
    var event := InputEventScreenDrag.new()
    event.index = index
    event.position = position
    return event

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    root.size = Vector2i(1280,720)
    var game = load("res://scenes/main.tscn").instantiate()
    get_root().add_child(game)
    game.call("start_run", 0)
    game.call("_input", _touch(2, Vector2(180, 350), true))
    _expect(bool(game.get("touch_active")), "Touch inside left playfield activates joystick")
    _expect(int(game.get("touch_index")) == 2, "Touch owner index is tracked")
    var overlay: Control = game.get("touch_joystick")
    _expect(overlay.visible, "Floating control is visible after thumb-down")

    game.call("_input", _drag(4, Vector2(260, 350)))
    _expect((game.get("touch_direction") as Vector2).length() < 0.01, "Other finger cannot steer")
    game.call("_input", _drag(2, Vector2(265, 350)))
    _expect(is_equal_approx((game.get("touch_direction") as Vector2).x, 1.0), "Owning finger steers with clamped axis")
    game.call("_input", _touch(4, Vector2(260, 350), false))
    _expect(bool(game.get("touch_active")), "Other finger release cannot cancel steering")
    game.call("_input", _touch(2, Vector2(265, 350), false))
    _expect(not bool(game.get("touch_active")), "Owner release stops steering")
    _expect((game.get("touch_direction") as Vector2) == Vector2.ZERO, "Release clears movement direction")
    _expect(not overlay.visible, "Release hides thumb overlay")

    game.call("_input", _touch(3, Vector2(250, 400), true))
    game.call("_toggle_pause")
    _expect(game.get("mode") == "paused", "Pause remains functional")
    _expect(not bool(game.get("touch_active")), "Pause clears movement to avoid stuck joystick")
    _expect(not overlay.visible, "Pause hides the floating overlay")
    game.call("_toggle_pause")
    game.call("_input", _touch(5, Vector2(700, 350), true))
    _expect(not bool(game.get("touch_active")), "Right-side button area does not capture joystick")
    game.call("_return_to_menu")
    _expect(not bool(game.get("touch_active")), "Return to menu clears movement")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Floating mobile joystick single-finger ownership, release and pause lifecycle")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
