extends SceneTree
## Validate the creator-approved Clean Cut production visuals and semantic UI states.
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func expect(ok: bool, description: String) -> void:
    if not ok: failures.append(description)
func verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var ui = game.presentation
    var skin: Control = game.clean_cut_skin
    expect(skin != null, "Clean Cut production skin is installed")
    expect(ui.subtitle.get_theme_font("font").get_font_name().contains("Inter"), "Licensed Inter retained for body typography")
    var tokens: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/art/hero_spotlight_v5_tokens.json"))
    expect(Color(tokens["palette"]["panel.blue"]) == Color("1f3e63"), "Approved navy blue token is preserved")
    if skin != null:
        skin.set_process(false)
        skin.refresh()
        var normal: StyleBox = ui.options_button.get_theme_stylebox("normal")
        var pressed: StyleBox = ui.options_button.get_theme_stylebox("pressed")
        var focus: StyleBox = ui.options_button.get_theme_stylebox("focus")
        expect(normal is StyleBoxTexture, "Menu uses creator-approved image-backed Clean Cut chassis")
        expect(pressed is StyleBoxTexture and focus is StyleBoxTexture, "Pressed and keyboard focus use distinct approved artwork")
        if normal is StyleBoxTexture:
            expect(normal.texture == skin.art.texture("menu/secondary-idle"), "Secondary menu button uses approved idle image")
        if pressed is StyleBoxTexture:
            expect(pressed.texture == skin.art.texture("menu/secondary-pressed"), "Pressed action uses approved tactile artwork")
        if focus is StyleBoxTexture:
            expect(focus.texture == skin.art.texture("menu/secondary-focus"), "Focus has its own keyboard-visible artwork")
        game.start_run(0)
        game._gain_xp(100)
        game._open_choice()
        game.pick_upgrade(0)
        skin.refresh()
        var id: String = game.selection[0]["id"]
        var category: String = "weapon" if game.WEAPONS.has(id) else "passive"
        var selected: StyleBox = game.offer_buttons[0].get_theme_stylebox("normal")
        expect(selected is StyleBoxTexture, "Selected card uses the correct illustrated frame")
        if selected is StyleBoxTexture:
            expect(selected.texture == skin.art.texture("cards/"+category+"-selected"), "Weapon/passive selected art is category-aware")
        expect(ui.card_parts[0]["state"].text.contains("SELECTED"), "Selected item retains a textual, accessible state label")
        root.size = Vector2i(915,412)
        ui._window_changed(true)
        skin.refresh()
        await process_frame
        await process_frame
        expect(skin.offers_scroll.scroll_vertical == 0, "Compact first selected offer remains reachable")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Approved Clean Cut Inter, palette, artwork-backed button states, category cards and compact selection")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
