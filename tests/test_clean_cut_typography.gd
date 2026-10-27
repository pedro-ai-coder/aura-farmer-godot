extends SceneTree
const Type = preload("res://scripts/clean_cut_typography.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass
var failures: Array[String] = []
func expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
    var game=ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    var skin=game.clean_cut_skin
    skin.set_process(false)
    for font: Font in [Type.BODY,Type.BOLD,Type.SEMIBOLD,Type.DISPLAY]:
        for character in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789éçã→":
            expect(font.has_char(character.unicode_at(0)),"Packaged font covers UI glyph: "+character)
    for id in game.presentation.catalog:
        if not game.WEAPONS.has(id) and not game.PASSIVES.has(id):continue
        var name: String=Type.equipment_name(id,game.presentation.catalog[id]["name"])
        expect(name.split("\n").size() <= 2,"Equipment name uses at most two lines: "+id)
        for line in name.split("\n"):
            expect(Type.font("equipment_label").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x <= 72,"Equipment name fits its slot: "+id)
    for extent in [Vector2i(1280,720),Vector2i(915,412),Vector2i(390,844)]:
        root.size=extent
        game.presentation._window_changed(true)
        game.start_run(0)
        game.max_hp=129.6;game.hp=129.6
        skin.refresh()
        await process_frame
        expect(skin.hp.text=="HP 130 / 130","Numeric HUD preserves fractional rounding")
        for node: Label in [skin.hero_name,skin.hp,skin.shield_label,skin.wave,skin.xp]:
            expect(node.get_theme_font("font").get_font_name().contains("Barlow"),"HUD uses packaged typography")
            expect(node.get_theme_font("font").get_string_size(node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x <= node.size.x,"HUD line fits: "+node.text)
        game._gain_xp(39);game._open_choice();game._show_ui();game._update_text();skin.refresh()
        await process_frame
        expect(skin.heading.get_theme_font("font").get_string_size(skin.heading.text,HORIZONTAL_ALIGNMENT_LEFT,-1,skin.heading.get_theme_font_size("font_size")).x <= skin.heading.size.x,"Upgrade headline fits")
        expect(not skin.heading_shadow.visible,"No duplicate offset lettering")
        for parts in skin.offer_parts.slice(0,3):
            expect(parts["body"].size.y>=80,"Upgrade description retains readable space")
            expect(parts["name"].get_meta("typography_role")=="card_title","Card title uses semantic token")
        game.mode="lost";game._show_ui();game._update_text();skin.refresh()
        await process_frame
        for value: Label in skin.auxiliary.result_values:
            expect(value.get_line_count()==1,"Result value stays on one line: "+value.text)
        expect(skin.auxiliary.result_values.size()==10,"Results expose every original stat")
        expect(skin.auxiliary.result_values[0].text=="00:00","Result values come from actual run")
    var before: int=game.rng.state
    for i in range(10):skin.refresh()
    expect(before==game.rng.state,"Typography does not consume gameplay RNG")
    game.queue_free()
    if failures.is_empty():print("PASS: packaged typography, glyph coverage, equipment fit, HUD and three-viewports hierarchy");quit(0)
    else:
        for failure in failures:push_error(failure)
        quit(1)
