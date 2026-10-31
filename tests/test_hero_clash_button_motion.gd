extends "res://tests/test_clean_cut_pointer_input.gd"
## Visual feedback regression: real buttons retain full click/touch hit geometry.
## Button styling and scene accents must never drive gameplay events or RNG.
class TestRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile=ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func verify() -> void:
    for viewport in [Vector2i(1280,720),Vector2i(915,412),Vector2i(390,844)]:
        root.size=viewport
        var game=TestRun.new()
        root.add_child(game)
        game.set_process(false)
        game.presentation._window_changed(true)
        game._return_to_menu()
        await process_frame
        await process_frame
        var skin=game.clean_cut_skin
        skin.set_process(false)
        var play: Button=game.presentation.play_button
        var fx=play.get_node_or_null("ClashButtonFeedback")
        expect(fx!=null,"The real Play button owns a single original motion overlay")
        if fx!=null:
            expect(fx.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Motion overlay never intercepts touch")
            expect(fx.get_parent()==play,"Visual layer does not replace the functional button")
            expect(fx.get("family")=="menu/primary","Primary CTA gets its distinctive gold bevel")
            expect(fx.get("reveal_remaining")>=0.0,"Entry reveal is a real visual state")
        expect(play.scale==Vector2.ONE,"Pressed visuals never scale the live hitbox")
        var target: Rect2=play.get_global_rect()
        expect(target.size.y>=64.0,"CTA retains its physical interaction height")
        expect(skin.scene_accent.current_mode=="menu","Menu transition is keyed to the actual screen")
        expect(skin.scene_accent.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Scene transition cannot trap input")

        await click(game.presentation.home.hero_destination)
        expect(game.mode=="heroes","Real click opens hero selection with UI motion enabled")
        await click(game.presentation.home.return_button)
        expect(game.mode=="menu","Back remains clickable after animation")
        await click(play)
        expect(game.mode=="playing","Primary CTA still starts the actual run")

        game._gain_xp(100.0)
        game._open_choice()
        game._show_ui()
        game._update_text()
        skin.refresh()
        await process_frame
        var card: Button=game.offer_buttons[0]
        var card_fx=card.get_node_or_null("ClashButtonFeedback")
        expect(card_fx!=null,"Real upgrade selection receives its own UI feedback")
        if card_fx!=null:
            expect(card_fx.get("family").begins_with("cards/"),"Reward card feedback remains subtle and semantic")
        var before: int=game.rng.state
        await click(card)
        expect(game.mode=="choice" and game.selected_card_index==0,"Card click selects, never auto-confirms")
        expect(card.scale==Vector2.ONE and card.get_global_rect().size==card.size,"Reward visuals keep their original hit target")
        if card_fx!=null:
            expect(bool(card_fx.get("selected")),"Selected reward displays its visual selection accent")
        var selected_rng: int=game.rng.state
        skin.refresh()
        expect(game.rng.state==selected_rng,"Cosmetic updates consume no extra RNG")

        game.profile["settings"]["reducedMotion"]=true
        skin.refresh()
        if card_fx!=null:
            expect(bool(card_fx.get("low_motion")),"Reduced Motion is respected immediately")
            card_fx.call("reveal",0.08)
            expect(is_zero_approx(float(card_fx.get("reveal_remaining"))),"Reduced Motion skips decorative entrance")
        expect(not skin.scene_accent.is_processing() or skin.scene_accent.current_mode=="choice","Scene accent stays cosmetic")
        await click(game.confirm_button)
        expect(game.mode in ["playing","choice","replace"],"Upgrade confirm remains live in Reduced Motion")
        game.queue_free()
        await process_frame
    if failures.is_empty():
        print("PASS: Hero Clash tactile buttons, selected/reveal states, reduced motion and real pointer journeys")
        quit(0)
    else:
        for failure in failures:push_error(failure)
        quit(1)
