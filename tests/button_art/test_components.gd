extends "res://tests/test_clean_cut_pointer_input.gd"
const Art=preload("res://scripts/hero_clash_button_art.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile=ProfileStoreScript.defaults()
    func _save_profile() -> void: pass
func verify() -> void:
    for family in ["primary","secondary","destructive","selection"]:
        for state in ["normal","hover","focus","pressed","selected","disabled"]:
            var resource: StyleBox=Art.style(family,state)
            expect(resource==Art.style(family,state),"Artwork resources are cached: "+family+"/"+state)
    var cache_count: int=Art.styles.size()
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent
        var game=ReviewRun.new();root.add_child(game);game.set_process(false)
        game.profile["settings"]["reducedMotion"]=true
        game.presentation._window_changed(true);game._return_to_menu()
        await process_frame
        await process_frame
        var skin=game.clean_cut_skin
        var play: Button=game.presentation.play_button
        var original_rect: Rect2=play.get_global_rect()
        var fx=play.get_node("ClashButtonFeedback")
        var physical_scale: Vector2=root.get_final_transform().get_scale()
        print("PLAY TARGET ",extent," logical=",original_rect.size," physical=",original_rect.size*physical_scale," label_px=",play.get_theme_font_size("font_size")*physical_scale.y)
        expect(original_rect.size.x>0 and original_rect.size.y>=64, "Original action target retains at least 64 logical pixels")
        expect(fx.art_family=="primary","Play uses authored primary family")
        expect(fx.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Artwork does not consume input")
        expect(play.get_theme_stylebox("focus") is StyleBoxEmpty,"No legacy focus face behind candidate")
        await click(game.presentation.home.hero_destination)
        expect(game.mode=="heroes","Hero selection remains reachable")
        await click(game.presentation.home.return_button)
        expect(play.get_global_rect()==original_rect,"Artwork preserves original hit rectangle")
        await click(play)
        expect(game.mode=="playing","Real pointer activates Play once")
        game._toggle_pause();game._show_ui();skin.refresh()
        await process_frame
        expect(game.presentation.secondary.quit_run.get_node("ClashButtonFeedback").art_family=="destructive","Quit navigation is explicitly destructive")
        await click(game.presentation.secondary.quit_run)
        expect(game.mode=="confirm_exit","Quit retains confirmation")
        expect(game.confirm_button.get_node("ClashButtonFeedback").art_family=="destructive","Final confirmation retains destructive family")
        await click(game.restart_button)
        expect(game.mode=="paused","Stay preserves the current run")
        await click(game.presentation.secondary.quit_run)
        await click(game.confirm_button)
        expect(game.mode=="menu","Only explicit confirmation abandons the run")
        expect(Art.styles.size()==cache_count,"No recurring artwork resource allocation")
        game.queue_free();await process_frame
    if failures.is_empty():
        print("PASS: 24 cached artwork states, six-resolution real pointer/confirmation, unchanged hit geometry")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
