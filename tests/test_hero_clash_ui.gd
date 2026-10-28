extends SceneTree
## Godot-only UI candidate smoke, not a human/Web/mobile performance acceptance.
var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)

func _initialize() -> void:
    call_deferred("verify")

func verify() -> void:
    var game=load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var skin=game.clean_cut_skin
    skin.set_process(false)
    for viewport in [Vector2i(1600,900),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=viewport
        game.presentation._window_changed(true)
        game._return_to_menu()
        skin.refresh()
        check(skin.candidate_brand.visible and not skin.wordmark.visible,"Isolated brand candidate visible on menu: %s" % viewport)
        check(skin.candidate_brand.size.x > 200.0,"Candidate brand has readable menu footprint")
        check(game.presentation.play_button.visible,"The real PLAY action remains accessible")
        game.start_run(0)
        game.aura=42.0
        game.flex_time=0.0
        game.flex_lock=0.0
        game._update_text()
        skin.refresh()
        check(skin.aura_arc.visible and skin.aura_arc.visual_state=="charging","Charging circle renders in real HUD")
        check(is_equal_approx(skin.aura_arc.progress,0.42),"Aura ring uses canonical Aura")
        check(absf(game.flex_button.size.x-game.flex_button.size.y)<0.1,"Flex action has circular-square geometry")
        check(skin.aura_arc.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Dial does not steal touch input")
        check(skin.flex_title.text=="FLEX" and skin.flex_status.text=="AURA 42%","Text identifies action and charge")
        check(not skin.flex_image.visible,"Rejected target icon remains absent")
        check(not skin.equipment[0]["name"].visible,"Equipment names do not obscure gameplay")
        game.aura=100.0
        game._update_text()
        skin.refresh()
        check(skin.aura_arc.visual_state=="ready" and skin.aura_arc.progress>=1.0,"Gold Aura READY ring at 100%")
        check(skin.flex_status.text=="READY" and not game.flex_button.disabled,"Ready Flex is tappable")
        game.flex_time=2.0
        game.flex_lock=18.0
        game._update_text()
        skin.refresh()
        check(skin.aura_arc.visual_state=="active","Active state visually distinct")
        game.flex_time=0.0
        game.aura=0.0
        skin.refresh()
        check(skin.aura_arc.visual_state=="recovery","Cooldown visually distinct")
        game.start_run(0)
        game._gain_xp(39.0)
        game._open_choice()
        game._show_ui()
        game._update_text()
        skin.refresh()
        check(game.mode=="choice" and game.offer_buttons[0].visible,"Three real upgrades available")
        var parts: Dictionary=skin.offer_parts[0]
        if viewport.x>=844 and viewport.y<=412:
            check(game.offer_buttons[0].size.y <= skin.offers_scroll.size.y,"Full first mobile-landscape reward is visible without initial scrolling")
            check(skin.heading.size.y <= 54.0,"Compact heading frees space for actual rewards")
        check(parts["rim"].visible and parts["icon_plate"].visible,"Reward has semantic frame and icon backing")
        check(parts["icon"].texture!=null,"Actual approved item icon retained")
        check(parts["body"].get_rect().end.y<=parts["state"].position.y+1.0,"Body does not collide with state")
        game.offer_buttons[0].pressed.emit()
        skin.refresh()
        check(game.selected_card_index==0 and not game.confirm_button.disabled,"Real selection and confirm remain functional")
        game.confirm_button.pressed.emit()
        game.run_time=360.0
        game._open_legendary()
        game._update_text()
        skin.refresh()
        check(game.legendary_offers.size()==6 and game.offer_buttons[5].visible,"Six canonical legendary choices retained")
        check(game.defer_button.visible and game.confirm_button.visible,"Legendary actions accessible")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Hero Clash UI candidate brand, circular Aura Flex, clear equipment and reward controls")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
