extends "res://tests/test_clean_cut_pointer_input.gd"
## Exercise held pointer input on production secondary screens, not signal substitutes.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass

func verify() -> void:
    for extent in [Vector2i(1280,720),Vector2i(915,412),Vector2i(390,844)]:
        root.size=extent
        var game=ReviewRun.new()
        root.add_child(game)
        game.set_process(false)
        var skin=game.clean_cut_skin
        game.presentation._window_changed(true)
        game.start_run(0)
        await process_frame
        await process_frame
        await click(game.pause_button)
        expect(game.mode=="paused", "Pause opens live secondary shell")
        await click(game.presentation.secondary.build)
        expect(game.mode=="build", "Held click opens actual build")
        await click(game.presentation.back_button)
        await click(game.presentation.secondary.settings)
        expect(game.mode=="options", "Held click opens in-run preferences")
        var saved_time: float=game.run_time
        var old_sound: bool=game.profile["settings"]["sound"]
        await click(game.sound_button)
        expect(game.profile["settings"]["sound"]!=old_sound, "Sound click changes real preference exactly once")
        expect(game.run_time==saved_time, "Preferences do not advance combat")
        await click(game.presentation.back_button)
        await click(game.presentation.secondary.quit_run)
        expect(game.mode=="confirm_exit", "Quit opens confirmation")
        await click(game.restart_button)
        expect(game.mode=="paused", "STAY preserves paused run")
        await click(game.presentation.secondary.resume)
        expect(game.mode=="playing", "Resume preserves run")
        # Unchanged frames must not recreate the static layout or style resources.
        skin.refresh();skin.refresh()
        var count: int=skin.layout_count
        var style: StyleBox=game.flex_button.get_theme_stylebox("normal")
        var rng: int=game.rng.state
        for i in range(30):skin.refresh()
        expect(skin.layout_count==count, "Idle frames reuse layout")
        expect(game.rng.state==rng, "UI refresh consumes no gameplay RNG")
        game.presentation.refresh(true)
        skin.refresh()
        expect(game.pause_button.get_theme_stylebox("normal") is StyleBoxTexture, "Native refresh cannot restore legacy skin")
        expect(game.flex_button.get_theme_stylebox("normal")==style, "Flex keeps cached empty style after native refresh")
        expect(game.flex_button.text.is_empty(), "Legacy Flex text cannot overlay artwork")
        expect(not skin.xp.get_rect().intersects(skin.xp_track.get_rect()), "XP caption does not intersect progress bar")
        expect(is_zero_approx(skin.xp_fill.size.x), "Fresh run has no visible XP fill")
        game.xp=19.5
        skin.refresh()
        expect(is_equal_approx(skin.xp_fill.size.x/skin.xp_track.size.x,0.5), "XP fill uses actual level threshold")
        game._finish(false)
        await process_frame
        await click(game.retry_button)
        expect(game.mode=="playing" and game.run_time==0, "Actual retry resets run")
        game.queue_free()
        await process_frame
    if failures.is_empty():
        print("PASS: Clean Cut secondary held-pointer journeys, cache invalidation, XP separation and RNG at three viewports")
        quit(0)
    else:
        for failure in failures:push_error(failure)
        quit(1)
