extends "res://tests/test_clean_cut_pointer_input.gd"
## Real pointer regression for the creator's 28 Oct 2026 video issues.
## Preserve canonical exit confirmation, selected identity and live shield values.
class TestRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile=ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func verify() -> void:
    for viewport in [Vector2i(1280,720),Vector2i(915,412),Vector2i(390,844)]:
        root.size=viewport
        var game=TestRun.new()
        root.add_child(game)
        game.set_process(false)
        var skin=game.clean_cut_skin
        skin.set_process(false)
        game.presentation._window_changed(true)
        game._return_to_menu()
        await process_frame
        await process_frame

        var selected_index: int=2
        game.presentation.select_hero(selected_index)
        skin.refresh()
        var selected_id: String=game.HEROES[selected_index]["id"]
        expect(skin.poster_hero.texture==game.art.texture(selected_id),"Menu shows chosen real hero artwork at %s" % viewport)
        if viewport.y>=780 or viewport.x>=700:
            expect(skin.poster_hero.visible,"Selected hero image is actually visible on menu at %s" % viewport)
        await click(game.presentation.home.hero_destination)
        expect(game.mode=="heroes","Real hero-selection destination opens")
        skin.refresh()
        expect(skin.hero_parts[selected_index]["portrait"].texture==game.art.texture(selected_id),"Correct identity on hero-selection card")
        expect(skin.hero_parts[selected_index]["portrait"].visible,"Hero card portrait is not hidden by legacy skin")
        game.presentation.select_hero(1)
        skin.refresh()
        expect(skin.hero_parts[1]["role"].text.contains("SELECTED"),"Selected card has distinct feedback")
        await click(game.presentation.home.start_button)
        expect(game.mode=="playing" and game.hero["id"]=="cool-kid","Start Run preserves actual selected hero and gameplay identity")
        expect(skin.portrait.texture==game.art.texture("cool-kid"),"Actual gameplay HUD renders chosen hero")

        game.hp=67.0
        game.max_hp=110.0
        game.shield=33.0
        game._update_text()
        skin.refresh()
        expect(skin.shield_track.visible and skin.shield_fill.visible,"Live shield has a dedicated track and fill")
        expect(skin.shield_label.text=="SHIELD 33","Shield label reflects genuine game state")
        expect(skin.shield_track.position.y>=skin.hp_fill.get_rect().end.y+1.0,"Shield track does not overlap red HP fill")
        expect(skin.shield_label.position.y>=skin.hp.position.y+skin.hp.size.y,"Shield label does not cover the HP text")
        expect(is_equal_approx(skin.shield_fill.size.x/(skin.shield_track.size.x-6.0),0.3),"Shield bar reflects actual shield / max HP, not simulated progress")
        game.shield=0.0
        skin.refresh()
        expect(is_zero_approx(skin.shield_fill.size.x),"Zero shield is a visibly empty bar")

        game.aura=100.0
        game.flex_lock=0.0
        game.flex_time=0.0
        game._update_text()
        skin.refresh()
        expect(skin.aura_arc.visual_state=="ready" and skin.aura_arc.ready_introduction>0.0,"Fully charged Flex enters an animated READY state")
        expect(game.flex_button.disabled==false,"Animation never activates Flex or disables the actual action")
        skin.aura_arc.set_pressed(true)
        expect(skin.aura_arc.push_target==1.0,"Real circular dial has tactile pressed response")
        skin.aura_arc.set_pressed(false)
        expect(skin.aura_arc.push_target==0.0,"Releasing Flex restores its shape")
        game.profile["settings"]["reducedMotion"]=true
        skin.refresh()
        expect(skin.aura_arc.reduced_motion,"Reduced Motion stops continuous READY pulsing")
        game.profile["settings"]["reducedMotion"]=false

        var old_runs: int=int(game.profile["runs"])
        var old_clock: float=game.run_time
        await click(game.pause_button)
        expect(game.mode=="paused","Pause button opens real pause state")
        await click(game.presentation.secondary.quit_run)
        expect(game.mode=="confirm_exit","QUIT RUN opens visible exit confirmation on click")
        expect(game.confirm_button.get_parent()==skin.auxiliary,"Confirm remains owned by the live secondary input layer")
        expect(game.confirm_button.visible and game.confirm_button.text=="CONFIRM QUIT","Exit confirmation is unmistakable")
        await click(game.restart_button)
        expect(game.mode=="paused" and is_equal_approx(game.run_time,old_clock),"STAY cancels without losing the current run")
        await click(game.presentation.secondary.quit_run)
        expect(game.mode=="confirm_exit","Quit can be requested again after cancel")
        await click(game.confirm_button)
        expect(game.mode=="menu","Real CONFIRM QUIT returns to main menu")
        expect(int(game.profile["runs"])==old_runs,"Abandoned run is not recorded as completed")
        expect(skin.poster_hero.texture==game.art.texture("cool-kid"),"Menu after quit previews previously selected hero")
        game.queue_free()
        await process_frame

    if failures.is_empty():
        print("PASS: Real Quit/STAY/Confirm clicks, hero identity, separate Shield and animated READY Flex on desktop/mobile")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
