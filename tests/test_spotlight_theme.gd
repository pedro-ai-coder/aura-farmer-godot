extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var ui = game.presentation
    if not ui.subtitle.get_theme_font("font").get_font_name().contains("Inter"): failures.append("V5 body typography uses licensed Inter")
    if ui.options_button.get_theme_stylebox("normal").bg_color != Color("1f3e63"): failures.append("V5 secondary action uses navy-blue chassis")
    var tokens: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/art/hero_spotlight_v5_tokens.json"))
    if ui.options_button.get_theme_stylebox("normal").bg_color != Color(tokens["palette"]["panel.blue"]): failures.append("Theme follows the canonical V5 token file")
    if ui.options_button.get_theme_stylebox("pressed").shadow_size != 0: failures.append("Pressed state removes the physical shadow")
    if ui.options_button.get_theme_stylebox("focus").border_width_left < 3: failures.append("Keyboard focus has an explicit outline")
    game.start_run(0)
    game._gain_xp(100)
    game._open_choice()
    game.pick_upgrade(0)
    if game.offer_buttons[0].get_theme_stylebox("normal").border_color != Color("4ea3ff"): failures.append("Selected card has a distinct sky rim")
    if game.presentation.card_parts[0]["state"].text.find("SELECTED") < 0: failures.append("Selection also has text, not color alone")
    root.size = Vector2i(915,412)
    ui._window_changed(true)
    game.pick_upgrade(0)
    await process_frame
    await process_frame
    if ui.card_scroll.scroll_vertical != 0: failures.append("Compact selected card retains name and rarity at the top")
    game.queue_free()
    if failures.is_empty(): print("PASS: Hero Spotlight typography and semantic actions"); quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
