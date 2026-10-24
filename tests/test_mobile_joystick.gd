extends SceneTree

## GDD Annex C.1: free terrain, UI priority, independent pointer ownership and lifecycle.
var failures: Array[String] = []
func expect(ok: bool, description: String) -> void:
    if not ok: failures.append(description)
func touch(index: int, at: Vector2, pressed: bool, canceled: bool = false) -> InputEventScreenTouch:
    var event := InputEventScreenTouch.new()
    event.index = index; event.position = at; event.pressed = pressed; event.canceled = canceled
    return event
func drag(index: int, at: Vector2) -> InputEventScreenDrag:
    var event := InputEventScreenDrag.new()
    event.index = index; event.position = at
    return event
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
    root.size = Vector2i(1280,720)
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    for extent in [Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size = extent
        game.presentation._window_changed(true)
        game.start_run(0)
        var field: Rect2 = game._touch_playfield()
        for fraction: Vector2 in [Vector2(0.08,0.45),Vector2(0.5,0.45),Vector2(0.92,0.45),Vector2(0.5,0.04)]:
            var point := field.position+field.size*fraction
            game._input(touch(2,point,true))
            expect(game.touch_active,"Free terrain left/center/right/top activates at %s" % extent)
            expect(game.touch_direction == Vector2.ZERO,"Clamped visual cannot create initial movement")
            game._input(drag(2,point+Vector2(119,0)))
            expect(is_equal_approx(game.touch_direction.length(),1),"Saturation stays normalized without speed changes")
            expect(game.touch_joystick.OUTER_RADIUS == 80 and game.touch_joystick.THUMB_RADIUS == 35,"Approved enlarged circular geometry")
            var center: Vector2 = game.touch_joystick.center
            var footprint: float = game.touch_joystick.FOOTPRINT*game.touch_joystick.geometry_scale
            expect(field.grow(0.1).encloses(Rect2(center-Vector2.ONE*footprint,Vector2.ONE*footprint*2)),"Full visual footprint fits safe bounds")
            game._input(touch(2,point,false))
            expect(not game.touch_active and not game.touch_joystick.visible and game.touch_direction == Vector2.ZERO,"Owner release clears axis and visual")
        var free := field.position+field.size*Vector2(0.5,0.45)
        var flex: Vector2 = game.flex_button.get_global_rect().get_center()
        var pause: Vector2 = game.pause_button.get_global_rect().get_center()
        game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(80,0)})
        game.aura = 100
        game._show_ui()
        game._input(touch(4,flex,true))
        expect(not game.touch_active,"Flex-down never starts movement")
        game._input(drag(4,free))
        expect(not game.touch_active,"UI-origin drag never becomes movement")
        game._input(touch(4,free,false))
        expect(game.aura == 100,"Dragging away cancels UI action")
        game.aura = 0;game._show_ui()
        game._input(touch(9,flex,true))
        game.aura = 100;game._show_ui()
        game._input(touch(9,flex,false))
        expect(game.aura == 100,"Disabled-on-down button cannot arm itself while held")
        game._input(touch(2,free,true))
        game._input(drag(2,free+Vector2(40,0)))
        var original: Vector2 = game.touch_direction
        game._input(touch(4,free+Vector2(100,0),true))
        game._input(drag(4,free+Vector2(200,0)))
        game._input(touch(4,free,false))
        expect(game.touch_index == 2 and game.touch_direction == original,"Another terrain finger cannot steal or stop movement")
        game._input(touch(5,flex,true))
        game._input(touch(5,flex,false))
        expect(game.flex_time > 0 and game.touch_index == 2 and game.touch_direction == original,"Second finger activates Flex independently")
        game._input(touch(2,free,false,true))
        expect(not game.touch_active,"Pointer cancellation releases movement")
        game._input(touch(6,pause,true))
        expect(not game.touch_active,"Pause-down cannot become movement")
        game._input(touch(6,pause,false))
        expect(game.mode == "paused" and not game.touch_active,"Touch release activates actual Pause once")
        game._input(touch(7,free,true)); game._input(drag(7,free+Vector2(100,0)))
        expect(not game.touch_active,"Menus and modals cannot move")
        game._toggle_pause()
        game._input(touch(8,free,true))
        game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
        expect(game.mode == "paused" and not game.touch_active,"Focus loss clears movement")
        game._toggle_pause()
        game._input(touch(8,free,true))
        game.presentation._window_changed(true)
        expect(not game.touch_active,"Viewport/orientation invalidation clears pointer")
        game._input(touch(8,free,true));game.start_run(0)
        expect(not game.touch_active,"Restart clears pointer")
        game._gain_xp(100);game._open_choice()
        game._input(touch(8,free,true))
        expect(not game.touch_active,"Upgrade cards block movement everywhere")
    # Actual SceneTree event routing, not only direct handler calls.
    root.size = Vector2i(1280,720)
    game.presentation._window_changed(true)
    game.start_run(0)
    game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(80,0)})
    game.aura = 100;game._show_ui()
    await process_frame
    var center: Vector2 = game._touch_playfield().get_center()
    var action: Vector2 = game.flex_button.get_global_rect().get_center()
    root.push_input(touch(0,center,true),true)
    root.push_input(drag(0,center+Vector2(60,0)),true)
    root.push_input(touch(1,action,true),true)
    root.push_input(touch(0,center,false),true)
    expect(not game.touch_active and game.touch_ui_pointers.has(1),"Movement release preserves independent held UI pointer")
    root.push_input(touch(1,action,false),true)
    expect(game.run_metrics["flexes"] == 1,"Real routed second-finger button release activates exactly one Flex")
    var emulated := InputEventMouseButton.new()
    emulated.device = InputEvent.DEVICE_ID_EMULATION;emulated.button_index=MOUSE_BUTTON_LEFT;emulated.position=action;emulated.pressed=true
    root.push_input(emulated,true)
    expect(root.is_input_handled(),"Touch mouse emulation is consumed to prevent duplicate GUI actions")
    game.start_run(0)
    game.web_metrics={"safe":[44,20,16,12],"width":390,"height":844,"touch":true,"fullscreen":false}
    root.size=Vector2i(390,844);game.presentation._window_changed(true)
    var safe_field: Rect2=game._touch_playfield()
    game._input(touch(1,safe_field.get_center(),true))
    expect(game.touch_active,"Denied fullscreen and safe-area metrics still permit movement")
    game._input(touch(1,Vector2.ZERO,false))
    var key := InputEventKey.new(); key.keycode=KEY_D;key.pressed=true
    game._input(key)
    expect(not game.blocked_movement.has(KEY_D),"Desktop keyboard remains independent")
    game._return_to_menu()
    expect(not game.touch_active and game.touch_ui_pointers.is_empty(),"Exit clears all pointer ownership")
    game.queue_free()
    if failures.is_empty(): print("PASS: Full-playfield circular joystick, UI priority, multitouch, safe areas and lifecycle");quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
