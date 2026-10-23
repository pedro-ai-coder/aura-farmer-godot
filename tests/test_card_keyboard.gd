extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func key(pressed: bool) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = KEY_ENTER
    event.pressed = pressed
    return event
func verify() -> void:
    root.size = Vector2i(1280,720)
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    game.presentation.open_heroes()
    game._process(0.11)
    game.presentation.open_settings("menu")
    game._process(0.11)
    game._return_to_menu()
    if not game.hero.is_empty() or game.profile["runs"] != 0: failures.append("Fresh auxiliary navigation cannot fabricate a run hero/result")
    game.start_run(0)
    game._gain_xp(40)
    game._open_choice()
    await process_frame
    await process_frame
    game.offer_buttons[0].grab_focus()
    root.push_input(key(true))
    root.push_input(key(false))
    await process_frame
    if game.selected_card_index != 0 or game.pending_choices != 1: failures.append("First Enter on a focused legal card selects it without applying")
    root.push_input(key(true))
    root.push_input(key(false))
    await process_frame
    if game.mode != "playing" or game.pending_choices != 0: failures.append("Second explicit Enter confirms exactly one selected upgrade")
    game.queue_free()
    if failures.is_empty(): print("PASS: Focused card keyboard selection and explicit confirmation"); quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
