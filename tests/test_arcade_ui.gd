extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("_verify")
func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func _inside(control: Control, bounds: Rect2) -> bool:
    return bounds.encloses(control.get_global_rect())
func _verify() -> void:
    root.size = Vector2i(1280,720)
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var ui = game.presentation
    _expect(game.mode == "menu" and not game.sound_button.visible and ui.options_button.visible,"Home groups settings behind their own navigation")
    ui.home.hero_destination.emit_signal("pressed")
    game.menu_buttons[1].emit_signal("pressed")
    _expect(game.mode == "heroes" and game.hero_index == 1,"Hero card selects without prematurely starting")
    ui.home.start_button.emit_signal("pressed")
    _expect(game.mode == "playing" and game.hero["id"] == "cool-kid","Explicit Play starts the selected hero")
    game._return_to_menu()
    ui.options_button.emit_signal("pressed")
    _expect(game.mode == "options" and game.sound_button.visible and game.import_button.visible,"Options exposes persistent preferences and profile transfer")
    ui.back_button.emit_signal("pressed")
    game._open_profile_import()
    game._import_profile_text("invalid")
    _expect(ui.subtitle.text.contains("INVALID SAVE") and not ui.error_message.is_empty(),"Invalid import has visible persistent feedback")
    game.start_run(0)
    game._gain_xp(100.0)
    game._open_choice()
    await process_frame
    await process_frame
    ui.refresh()
    _expect(game.offer_buttons[0].visible and game.offer_buttons[2].visible and not game.offer_buttons[3].visible,"Normal selection keeps exactly three cards")
    game.pick_upgrade(1)
    _expect(ui.card_parts[1]["state"].text.contains("SELECTED") and not game.confirm_button.disabled,"Selected state and explicit confirmation remain visible")
    for i in range(3):
        var parts: Dictionary = game.clean_cut_skin.offer_parts[i]
        _expect(parts["body"].get_rect().end.y <= parts["state"].position.y+1.0,"Visible Clean Cut normal effects do not overlap selection labels")
    game._confirm_selection()
    game.start_run(0)
    game.run_time = 360.0
    game._open_legendary()
    await process_frame
    await process_frame
    ui.refresh()
    _expect(game.legendary_offers.size() == 6 and game.offer_buttons[5].visible,"Legendary selection retains all six choices")
    _expect(ui.card_content.size.y <= ui.card_scroll.size.y + 1.0,"Desktop legendary grid fits in two complete rows")
    _expect(not game.confirm_button.get_global_rect().intersects(game.defer_button.get_global_rect()),"Legendary footer actions never overlap")
    _expect(_inside(game.confirm_button,Rect2(Vector2.ZERO,ui.view)),"Confirm remains within the useful viewport")
    for i in range(6):
        var parts: Dictionary = game.clean_cut_skin.offer_parts[i]
        _expect(parts["body"].get_rect().end.y <= parts["state"].position.y+1.0,"Visible Clean Cut legendary effects do not collide with selection labels: %s body=%s state=%s" % [parts["name"].text,parts["body"].get_rect(),parts["state"].get_rect()])
        _expect(parts["body"].tooltip_text == ui.card_parts[i]["body"].text,"Full actual legendary effect remains accessible without trimming source data")
    root.size = Vector2i(915,412)
    ui._window_changed(true)
    game.start_run(0)
    game._gain_xp(100.0)
    game._open_choice()
    await process_frame
    await process_frame
    _expect(is_equal_approx(game.offer_buttons[0].position.y,game.offer_buttons[2].position.y),"All three normal choices share one landscape row at 915x412")
    # Exercise the reusable card against the longest real catalog descriptions.
    for id: String in ui.catalog:
        if not game.WEAPONS.has(id) and not game.PASSIVES.has(id): continue
        var parts: Dictionary = ui.card_parts[0]
        parts["name"].text = ui.catalog[id]["name"]
        parts["body"].text = ui.catalog[id].get("description","")
        ui.OfferCard.layout(parts,Vector2(300,416),false,"rare","WEAPON" if game.WEAPONS.has(id) else "PASSIVE","LV 1/3")
        await process_frame
        _expect(parts["body"].get_minimum_size().y <= 124,"Normal catalog effect fits the card: " + id)
        _expect(parts["body"].get_rect().end.y <= parts["comparison"].position.y,"Effect and current-to-new comparison stay separate: " + id)
        _expect(parts["meta"].text == "RARE" and not parts["category"].text.is_empty(),"Rarity and category remain explicit text")
        ui.OfferCard.layout(parts,Vector2(340,288),false,"rare","PASSIVE","LV 1/3")
        await process_frame
        await process_frame
        _expect(parts["body"].get_rect().end.y <= parts["comparison"].position.y,"Compact catalog effect and comparison stay separate: " + id)
        _expect(parts["comparison"].get_rect().end.y <= parts["state"].position.y,"Compact comparison stays above selected state: " + id)
    game.start_run(0)
    game.run_time = 360
    game._open_legendary()
    ui.refresh()
    for i in range(6):
        var parts: Dictionary = ui.card_parts[i]
        var id: String = game.legendary_offers[i]["id"]
        _expect(parts["meta"].text == "LEGENDARY","All six cards have a text rarity band")
        _expect(game.offer_buttons[i].tooltip_text.contains(parts["body"].text),"Tooltip preserves the actual legendary effect: " + id)
    game.queue_free()
    if failures.is_empty(): print("PASS: Arcade home/options, explicit hero play, import feedback, readable cards and six-choice footer"); quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
