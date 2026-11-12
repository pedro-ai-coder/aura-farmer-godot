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
    if "--mobile-review" in OS.get_cmdline_user_args():
        await verify_mobile_review()
        return
    if not Appearance.can_start("female","sigma"):
        push_error("Pixel Vixen V2 assets are missing from the PR. Upload the exact atlas, illustrated selection portrait and HUD portrait before accepting this feature; no V1 fallback is permitted.")
        quit(1)
        return
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
        expect(skin.appearance_notice.text == "CHOOSE AN APPEARANCE AND HERO KIT", "Player-facing selection guidance has no asset-readiness counters")
        expect(not game.presentation.home.start_button.disabled, "Pixel Vixen with a real candidate atlas can start at %s" % extent)
        for i in range(3):
            game.presentation.select_hero(i)
            skin.refresh()
            var data: Dictionary = game.HEROES[i]
            var expected: String = Appearance.display_name(str(data["id"]), "female", str(data["name"]))
            expect(skin.hero_parts[i]["name"].text == expected, "Female name shown for selected kit: " + expected)
            expect(not skin.hero_parts[i]["role"].text.contains("PROPOSED"), "Approved source-design labels are not exposed to players: " + expected)
            expect(skin.hero_parts[i]["portrait"].texture != null, "Each female appearance has its own portrait art: " + expected)
            expect(not skin.hero_parts[i]["art_status"].visible, "Complete female art has no pending placeholder: " + expected)
            expect(not game.presentation.home.start_button.disabled, "Every canonical kit can start as female: " + expected)
            expect(data["starter"] in ["no-cap", "keyboard-warrior", "cope-shield"], "Starter weapon is unchanged")
        var previous_runs: int = int(game.profile["runs"])
        expect(not Appearance.can_start("female","unknown"), "Unknown cosmetic packages fail closed")
        expect(game.mode == "heroes", "Availability checks cannot fabricate a run")
        expect(int(game.profile["runs"]) == previous_runs, "An unavailable cosmetic never invents run results")
        var restored: Dictionary = Store.read_data(JSON.parse_string(JSON.stringify(game.profile)))
        expect(restored["appearance"] == "female" and restored["selected"] == "sigma", "Cosmetic persistence does not change canonical hero ID")
        game.presentation.select_hero(0)
        expect(not game.presentation.home.start_button.disabled, "Pixel Vixen remains selectable after other female candidates")
        game.start_run(0)
        expect(game.mode == "playing" and game.hero["id"] == "sigma", "Pixel Vixen starts a real Sigma-kit run")
        expect(game.hero_pose()["sheet"] == "pixel-vixen", "Pixel Vixen uses its own in-world atlas")
        expect(skin.portrait.texture != null, "Pixel Vixen HUD portrait exists")
        game._return_to_menu()
        await click(game.presentation.home.hero_destination)
        await click(skin.appearance_buttons[0])
        expect(game.hero_appearance == "original" and not game.presentation.home.start_button.disabled, "Original play remains available")
        expect(skin.appearance_notice.text == "CHOOSE AN APPEARANCE AND HERO KIT", "Original appearance shows the same player-facing guidance")
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

func review_tap(button: Button) -> void:
    var rect := button.get_global_rect()
    var parent := button.get_parent()
    while parent != null:
        if parent is Control and parent.clip_contents: rect = rect.intersection(parent.get_global_rect())
        parent = parent.get_parent()
    expect(rect.has_area(), "Touch control has a visible region")
    var point := root.get_final_transform()*rect.get_center()
    for pressed in [true,false]:
        var event := InputEventScreenTouch.new()
        event.index=0;event.position=point;event.pressed=pressed
        Input.parse_input_event(event)
        Input.flush_buffered_events()
        await process_frame
        await process_frame

func verify_mobile_review() -> void:
    root.size = Vector2i(844,390)
    var game := TestRun.new()
    root.add_child(game)
    game.set_process(false)
    game.presentation._window_changed(true)
    await process_frame
    expect(game.art.sigma_cpk_atlas != null, "Sigma CPK texture is verified and active")
    expect(game.art.cool_kid_cpk_atlas != null, "Existing Cool Kid CPK texture remains active")
    expect(game.art.pixel_vixen_cpk_atlas != null, "Existing Pixel Vixen CPK texture is active")
    for appearance in ["original","female"]:
        for index in range(3):
            game._return_to_menu()
            game.presentation.open_heroes()
            await process_frame
            await review_tap(game.clean_cut_skin.appearance_buttons[0 if appearance=="original" else 1])
            var button: Button = game.menu_buttons[index]
            game.clean_cut_skin.hero_scroll.ensure_control_visible(button)
            await process_frame
            await process_frame
            await review_tap(button)
            expect(game.hero_index==index and game.hero_appearance==appearance, "Touch selects the requested hero")
            await review_tap(game.presentation.home.start_button)
            expect(game.mode=="playing" and game.hero==game.HEROES[index], "Touch launches an unchanged canonical kit")
            var sheet: String = ["sigma-cpk","cool-kid-cpk","alpha-chad-proposed"][index] if appearance=="original" else ["pixel-vixen","byte-baddie-proposed","block-queen-proposed"][index]
            expect(game.hero_pose()["sheet"]==sheet, "Correct gameplay atlas: "+sheet)
            expect(game.art.cosmetic_portrait(str(game.hero["id"]),appearance)!=null, "Correct portrait available")
    var canonical = preload("res://scripts/hero_animation.gd")
    for event in ["idle","run","attack","hurt","flex-in","flex-loop","flex-out","defeat"]:
        var state := {"time":0.0,"walk":0.1,"moving":event=="run","lost":event=="defeat","defeat":0.4,
            "hurt":0.1 if event=="hurt" else 0.0,"attack":0.1 if event=="attack" else 0.0,
            "flex":(0.1 if event=="flex-out" else 5.0) if event.begins_with("flex") else 0.0,
            "flex_age":0.1 if event=="flex-in" else 1.0,"heading":PI,"facing":PI}
        var pose: Dictionary = game.art.SigmaCPK.pose(state)
        expect(pose["state"]==canonical.pose("sigma",state)["state"], "Sigma preserves state precedence: "+event)
        expect(int(pose["frame"])>=0 and int(pose["frame"])<49, "Sigma frame exists: "+event)
        for candidate in [["cool-kid","female"],["alpha","original"],["alpha","female"]]:
            var proposed: Dictionary = game.ProposedCPK.pose(candidate[0],candidate[1],state)
            expect(proposed["state"]==canonical.pose(candidate[0],state)["state"], "Candidate retains canonical state: "+event)
            expect(int(proposed["frame"])>=0 and int(proposed["frame"])<24, "Candidate cutout frame exists: "+event)
    game.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASS: six real touch selections and run starts at 844x390; three CPK renderers, portraits and Sigma animation states")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
