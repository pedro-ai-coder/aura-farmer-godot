extends "res://tests/test_clean_cut_pointer_input.gd"

## Actual native review fixtures, isolated from player saves. Not a human or
## physical-device playthrough. Run with a native Compatibility renderer.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

var output: String
var records: Array[Dictionary] = []

func capture(game: Node2D, state: String, extent: Vector2i) -> void:
    game.presentation._window_changed(true)
    game._show_ui()
    game._update_text()
    game._update_camera(0.0, true)
    game.queue_redraw()
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var image := root.get_texture().get_image()
    var filename := "%s-%dx%d.png" % [state, extent.x, extent.y]
    # The existing responsive canvas can round the readback down by one pixel.
    # Keep its actual layout pipeline; record both sizes instead of resampling.
    expect((image.get_size() - extent).abs().x <= 1 and (image.get_size() - extent).abs().y <= 1,
        "Physical capture is within existing canvas rounding: " + filename)
    expect(image.save_png(output.path_join(filename)) == OK, "Capture saved: " + filename)
    var kit: Dictionary = game.HEROES[game.hero_index] if game.hero.is_empty() else game.hero
    records.append({"file": filename, "mode": game.mode,
        "requested_window": [extent.x, extent.y],
        "readback": [image.get_width(), image.get_height()],
        "logical_viewport": [game.get_viewport_rect().size.x, game.get_viewport_rect().size.y],
        "appearance": game.hero_appearance,
        "canonical_hero": kit["id"], "starter": kit["starter"],
        "flex": kit["flex"], "pose": {} if game.hero.is_empty() else game.hero_pose(),
        "selection_texture": game.clean_cut_skin.hero_parts[0]["portrait"].texture.resource_path,
        "hud_texture": "" if game.clean_cut_skin.portrait.texture == null else game.clean_cut_skin.portrait.texture.resource_path,
        "atlas_texture": game.art._vixen_atlas().resource_path,
        "player_position": [game.player_pos.x, game.player_pos.y]})
    print("CAPTURE ", filename)

func verify() -> void:
    if DisplayServer.get_name() == "headless":
        push_error("Rendered evidence requires a native display; headless output is not a screenshot")
        quit(1)
        return
    var args := OS.get_cmdline_user_args()
    output = args[0]
    DirAccess.make_dir_recursive_absolute(output)
    for extent in [Vector2i(1920,1080), Vector2i(1600,900), Vector2i(1280,720),
            Vector2i(915,412), Vector2i(844,390), Vector2i(390,844)]:
        root.size = extent
        var game := ReviewRun.new()
        root.add_child(game)
        game.set_process(false)
        game.clean_cut_skin.set_process(false)
        game.touch_device = extent.x < 1000
        game.presentation._window_changed(true)
        await process_frame
        await click(game.presentation.home.hero_destination)
        await click(game.clean_cut_skin.appearance_buttons[1])
        expect(game.hero_appearance == "female", "Actual appearance button selects female")
        var portrait: Texture2D = game.clean_cut_skin.hero_parts[0]["portrait"].texture
        expect(portrait.resource_path == game.art.VIXEN_V2_PORTRAIT_PATH,
            "Selection binds the exact V2 illustration")
        await capture(game, "selection", extent)
        await click(game.presentation.home.start_button)
        expect(game.mode == "playing" and game.hero["id"] == "sigma", "Real start button starts Sigma")
        expect(game.hero["starter"] == "no-cap" and game.hero["flex"] == "Deadpan Verdict", "Canonical kit is preserved")
        expect(game.hero_pose()["sheet"] == "pixel-vixen", "World actor uses V2 adapter")
        expect(game.art._vixen_atlas().resource_path == game.art.VIXEN_V2_ATLAS_PATH, "World actor loads the V2 atlas")
        expect(game.clean_cut_skin.portrait.texture.resource_path == game.art.VIXEN_V2_HUD_PATH, "HUD binds its separate V2 illustration")
        expect(game.clean_cut_skin.portrait.material == null, "V2 HUD illustration bypasses the male crop shader")
        await capture(game, "idle", extent)
        var before: Vector2 = game.player_pos
        game.touch_direction = Vector2.RIGHT
        for frame in range(12): game._advance(1.0/60.0)
        expect(game.player_pos.x > before.x, "Actual simulation moves Pixel Vixen")
        expect(game.hero_pose()["state"] == "run", "Moving actor renders the V2 run row")
        await capture(game, "moving", extent)
        game.touch_direction = Vector2.ZERO
        # Sigma requires a living target for Deadpan Verdict. This canonical
        # fixture supplies one, rather than changing activation semantics.
        game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(160, 0)})
        game.aura = 100.0
        game._use_flex()
        for frame in range(18): game._advance(1.0/60.0)
        expect(str(game.hero_pose()["state"]).begins_with("flex"), "Canonical Flex renders the V2 Flex row")
        await capture(game, "flex", extent)
        game._finish(false)
        await capture(game, "lost", extent)
        game.queue_free()
        await process_frame
        await process_frame
    var report := FileAccess.open(output.path_join("runtime.json"), FileAccess.WRITE)
    report.store_string(JSON.stringify({"engine": Engine.get_version_info()["string"],
        "display": DisplayServer.get_name(), "renderer": RenderingServer.get_video_adapter_name(),
        "evidence_type": "staged_native_runtime_not_browser_or_device_test",
        "failures": failures, "captures": records}, "  "))
    report.close()
    if failures.is_empty():
        print("PASS: exact V2 selection/HUD/atlas bindings, native six-viewport captures, real pointer start, movement and canonical Flex")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
