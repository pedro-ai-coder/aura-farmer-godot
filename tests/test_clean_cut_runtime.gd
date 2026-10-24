extends SceneTree
## Production-mode smoke: the actual default Godot game mounts only approved art.
var failures: Array[String] = []

func check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)

func _initialize() -> void:
    call_deferred("verify")

func verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var skin: Control = game.clean_cut_skin
    check(skin != null, "Default entry must install approved Clean Cut live skin")
    if skin == null:
        quit(1)
        return
    skin.set_process(false)
    check(skin.art.rows.size() == 84, "Exactly 84 creator-approved runtime visual resources")
    for id: String in skin.art.rows:
        check(skin.art.texture(id) is Texture2D, "Imported approved texture is loadable: " + id)

    for extent in [Vector2i(1600,900), Vector2i(915,412), Vector2i(390,844)]:
        root.size = extent
        game.presentation._window_changed(true)
        game._return_to_menu()
        skin.refresh()
        check(skin.visible and game.presentation.visible == false, "Live Clean Cut menu is active")
        check(game.presentation.play_button.visible, "Real PLAY button is visible")
        check(game.presentation.play_button.get_parent() == skin, "PLAY reuses the original action")
        var rng_before: int = game.rng.state
        skin.refresh()
        check(game.rng.state == rng_before, "Menu drawing does not advance gameplay RNG")

        game.presentation.open_heroes()
        skin.refresh()
        check(game.mode == "heroes", "Live hero selection remains selectable")
        check(game.menu_buttons.size() == 3 and game.menu_buttons[2].visible, "Three original hero controls retained")
        game.menu_buttons[1].pressed.emit()
        skin.refresh()
        check(game.hero_index == 1, "Hero selection preserves actual hero state")

        game.start_run(0)
        # One legal level-up: avoid opening a second queued upgrade after Confirm.
        game._gain_xp(39)
        game._open_choice()
        game._show_ui()
        game._update_text()
        skin.refresh()
        check(game.mode == "choice" and game.selection.size() == 3, "Three genuine upgrades render")
        check(game.offer_buttons[0].visible and game.confirm_button.visible, "Live selection/confirm controls render")
        game.offer_buttons[0].pressed.emit()
        skin.refresh()
        check(not game.confirm_button.disabled, "Explicit confirmation retains current selected card")
        game.confirm_button.pressed.emit()
        skin.refresh()
        check(game.mode == "playing", "Confirm correctly returns to gameplay")

        game.run_time = 360.0
        game._open_legendary()
        game._update_text()
        skin.refresh()
        check(game.legendary_offers.size() == 6, "Six canonical legendary offers")
        check(game.defer_button.visible, "Actual deferred legendary choice remains available")
        check(game.touch_joystick.OUTER_RADIUS == 80.0, "Approved larger circular joystick retained")
        game.defer_button.pressed.emit()
        skin.refresh()
        check(game.mode == "playing", "Defer correctly resumes actual simulation")

    game.queue_free()
    if failures.is_empty():
        print("PASS: Production Clean Cut 84 approved assets, live five-flow controls and unchanged RNG across three viewports")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
