extends "res://tests/test_clean_cut_pointer_input.gd"

## Cosmetic choice uses live Godot buttons. Female starts remain gated until
## their exact approved animated runtime resources are actually available.
const Appearance = preload("res://scripts/hero_appearance.gd")
const Store = preload("res://scripts/profile_store.gd")

class TestRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:
        profile = ProfileStoreScript.defaults()
    func _save_profile() -> void:
        pass

func verify() -> void:
    expect(Appearance.normalize("unknown") == "original", "Unrecognized appearance fails safely to original")
    expect(Appearance.normalize(0) == "original", "Malformed cosmetic preference cannot become a hero ID")
    expect(Appearance.display_name("sigma","female","THE SIGMA") == "PIXEL VIXEN", "Sigma remains the Pixel Vixen gameplay kit")
    expect(Appearance.display_name("cool-kid","female","COOL KID") == "BYTE BADDIE", "Cool Kid remains Byte Baddie gameplay kit")
    expect(Appearance.display_name("alpha","female","ALPHA CHAD") == "BLOCK QUEEN", "Alpha remains Block Queen gameplay kit")
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size = extent
        var game = TestRun.new()
        root.add_child(game)
        game.set_process(false)
        var skin = game.clean_cut_skin
        skin.set_process(false)
        game.presentation._window_changed(true)
        await process_frame
        expect(game.hero_appearance == "original", "Existing profiles default to original artwork")
        await click(game.presentation.home.hero_destination)
        expect(game.mode == "heroes", "Actual hero-selection screen opens at %s" % extent)
        await click(skin.appearance_buttons[1])
        expect(game.hero_appearance == "female" and game.profile["appearance"] == "female", "Female appearance is selected and stored at %s" % extent)
        expect(game.presentation.home.start_button.disabled, "Unapproved female atlases cannot be played at %s" % extent)
        for i in range(3):
            game.presentation.select_hero(i)
            skin.refresh()
            var data: Dictionary = game.HEROES[i]
            var expected: String = Appearance.display_name(str(data["id"]), "female", str(data["name"]))
            expect(skin.hero_parts[i]["name"].text == expected, "Female name shown for selected kit: " + expected)
            expect(skin.hero_parts[i]["portrait"].texture == null, "Never show a male portrait as female: " + expected)
            expect(skin.hero_parts[i]["art_status"].visible, "Candidate art availability is explicit")
            expect(data["starter"] in ["no-cap", "keyboard-warrior", "cope-shield"], "Starter weapon is unchanged")
        var previous_runs: int = int(game.profile["runs"])
        game.start_run(2)
        expect(game.mode == "heroes", "Keyboard/programmatic start cannot bypass the missing-art gate")
        expect(int(game.profile["runs"]) == previous_runs, "An unavailable cosmetic never invents run results")
        var restored: Dictionary = Store.read_data(JSON.parse_string(JSON.stringify(game.profile)))
        expect(restored["appearance"] == "female" and restored["selected"] == "sigma", "Cosmetic persistence does not change canonical hero ID")
        await click(skin.appearance_buttons[0])
        expect(game.hero_appearance == "original" and not game.presentation.home.start_button.disabled, "Original play remains available")
        game.presentation.select_hero(2)
        game.start_run(2)
        expect(game.mode == "playing" and game.hero["id"] == "alpha", "Original gameplay still starts with canonical Alpha ID")
        expect(game.hero["starter"] == "cope-shield" and game.hero["hp"] == 140.0, "Cosmetic choice does not alter equipment or stats")
        game.queue_free()
        await process_frame
        await process_frame
    if failures.is_empty():
        print("PASS: six-viewport cosmetic choice, canonical kit parity, safe art gate and backwards-compatible preference")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
