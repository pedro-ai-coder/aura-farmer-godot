extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var ui = game.presentation
    check(not game.menu_buttons[0].is_visible_in_tree(),"Hero cards belong to separate selection")
    for viewport in [Vector2i(1600,900),Vector2i(1280,720),Vector2i(1920,1080),Vector2i(915,412),Vector2i(640,360),Vector2i(390,844)]:
        root.size = viewport
        ui._window_changed(true)
        game._return_to_menu()
        await process_frame
        await process_frame
        var bounds: Rect2 = Rect2(ui.position,ui.view).grow(1)
        for action: Button in [ui.play_button,ui.home.hero_destination,ui.options_button]:
            check(action.is_visible_in_tree() and bounds.encloses(action.get_global_rect()),"Home destinations fit %s" % viewport)
            check(action.size.y*float(viewport.y)/ui.full_view.y >= 47.5,"Home actions retain 48px physical targets")
        ui.home.hero_destination.grab_focus()
        var enter := InputEventKey.new()
        enter.keycode = KEY_ENTER
        enter.pressed = true
        game._input(enter)
        check(game.mode == "menu","Enter on HEROES focus does not bypass GUI and start a run")
        ui.home.hero_destination.emit_signal("pressed")
        check(game.mode == "heroes" and game.run_time == 0,"HEROES opens selection without starting simulation")
        for i in range(3):
            game.menu_buttons[i].emit_signal("pressed")
            check(game.hero_index == i and game.mode == "heroes","Each real starter selects without premature play")
            check(ui.home.summaries[i].text.contains(game.HEROES[i]["flex"]),"Signature label comes from current hero definition")
            var help: String = ui.catalog[game.HEROES[i]["id"]]["flex_help"]
            check(not help.is_empty() and ui.home.summaries[i].text.contains(help),"Every starter exposes its canonical Flex help without hover")
            check(game.menu_buttons[i].tooltip_text.contains("100 Aura"),"Keyboard/mouse tooltip retains shared activation requirements")
        await process_frame
        await process_frame
        check(bounds.encloses(ui.home.start_button.get_global_rect()),"Selection START remains in viewport %s; rect=%s bounds=%s" % [viewport,ui.home.start_button.get_global_rect(),bounds])
        var focused: Control = game.get_viewport().gui_get_focus_owner()
        check(focused == null or focused.is_visible_in_tree(),"Focus cannot remain on hidden home actions")
        ui.home.start_button.emit_signal("pressed")
        check(game.mode == "playing" and game.hero["id"] == "alpha","START begins selected Alpha with real gameplay")
    game.queue_free()
    if failures.is_empty(): print("PASS: Six viewport home, selection, current signatures, focus and real start"); quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
