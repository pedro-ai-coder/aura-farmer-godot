extends "res://tests/test_clean_cut_pointer_input.gd"
## Data/lifecycle and actual Control geometry, not an art-approval assertion.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    var skin=game.clean_cut_skin
    var hud=skin.gameplay_hud
    skin.set_process(false)
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.presentation._window_changed(true)
        for hero in range(3):
            game.start_run(hero);game.presentation._window_changed(true)
            await process_frame;await process_frame
            skin.refresh()
            expect(skin.portrait.texture==game.art.texture(game.HEROES[hero]["id"]),"Approved hero source identity remains exact")
            expect(skin.hero_name.text==str(game.hero["name"]).to_upper(),"Live hero name")
            expect(skin.flex_caption.text==str(game.hero["flex"]).to_upper(),"Canonical live ability name")
            for node in [skin.hero_name,skin.hp,skin.shield_label,skin.wave,skin.xp,skin.flex_status,skin.flex_caption]:
                expect(node.get_theme_font("font").get_string_size(node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x<=node.size.x+1.0,"Unclipped live text: "+node.text+" "+str(extent))
            for region in hud.reserved:expect(Rect2(Vector2.ZERO,skin.view).encloses(region),"Reserved HUD region is in safe viewport")
            for i in range(hud.reserved.size()):
                for j in range(i+1,hud.reserved.size()):expect(not hud.reserved[i].intersects(hud.reserved[j]),"HUD peers remain separate")
            var scale: Vector2=root.get_final_transform().get_scale()
            expect(game.pause_button.size.y*scale.y>=48,"Pause target retains GDD physical size")
            expect(game.flex_button.size.y*scale.y>=100,"Circular Flex remains a generous independent target")
            expect(absf(game.flex_button.size.x-game.flex_button.size.y)<0.1,"Flex keeps circular-square bounds")
            var rng: int=game.rng.state
            var geometry: int=hud.geometry_count
            for i in range(30):
                game.hp=game.max_hp*float(100-i)/100.0;game.aura=i*3
                skin.refresh()
            expect(hud.geometry_count==geometry,"HP/Aura updates do not rebuild geometry")
            expect(game.rng.state==rng,"HUD consumes no gameplay RNG")
            game.hp=game.max_hp;game._grant_weapon_shield("hud-regression",game.max_hp*0.4,4)
            var before: float=game.shield
            game._deal_damage_to_player(10)
            skin.refresh()
            expect(game.shield<before and is_equal_approx(game.hp,game.max_hp),"Real shield absorption still protects HP")
            expect(skin.shield_label.text=="SHIELD %d" % ceili(game.shield),"Absorption reaches live label")
            game.shield=0;game._deal_damage_to_player(20);skin.refresh()
            expect(skin.hp.text=="HP %d / %d" % [ceili(game.hp),ceili(game.max_hp)],"Actual HP damage reaches HUD")
            game._heal_player(7);skin.refresh()
            expect(skin.hp.text.begins_with("HP %d" % ceili(game.hp)),"Actual healing reaches HUD")
            var old_max: float=game.max_hp
            game._gain_xp(100);game._update_text();skin.refresh()
            expect(game.max_hp>old_max and skin.xp.text.begins_with("LEVEL %d" % game.level),"Level and max-HP progression stay live")
            game.aura=9;game.flex_time=0;game.flex_lock=0;game._update_text();skin.refresh()
            expect(is_equal_approx(skin.aura_arc.progress,0.09) and skin.flex_status.text=="AURA 9%","Actual 9% ring")
            game.aura=100;game._update_text();skin.refresh()
            expect(skin.aura_arc.visual_state=="ready" and skin.flex_status.text=="READY","100 Aura enters gold READY")
            expect(not skin.aura_arc.is_processing(),"Reduced Motion makes READY static")
            game.flex_time=4;game.flex_lock=28;skin.refresh()
            expect(skin.aura_arc.visual_state=="active" and skin.flex_status.text.contains("4.0s"),"Active uses canonical timer")
            game.flex_time=0;skin.refresh()
            expect(skin.aura_arc.visual_state=="recovery" and skin.flex_status.text.contains("28s"),"Recovery uses canonical timer")
        # Confirm the exact canonical eight-slot ordering with approved icons.
        game.start_run(0)
        game.weapons.append({"id":"ratio-blaster","rarity":"rare","level":2,"timer":0.0})
        game.weapons.append({"id":"brainrot-feed","rarity":"epic","level":3,"timer":0.0})
        for id in ["main-character","terminally-online","caught-4k","certified-w","aura-viral"]:game.passives.append({"id":id,"rarity":game.SoloOfferRulesScript.PASSIVE_DATA[id]["rarity"],"level":2})
        game._update_text();skin.refresh()
        expect(skin.equipment.size()==8,"Exactly 3+5 positions")
        for i in range(8):
            var item: Dictionary=game.weapons[i] if i<3 else game.passives[i-3]
            expect(skin.equipment[i]["icon"].texture==game.presentation.item_icons.texture("weapon" if i<3 else "passive",item["id"]),"Exact approved icon and item ordering")
        var station: Vector2=game.RecoveryRulesScript.SAFE_SPOT
        var label_at: Vector2=hud.safe_label_origin(station,Vector2(96,24))
        expect(station==Vector2(1100,565) and game.RecoveryRulesScript.SAFE_RADIUS==68,"World recovery geometry remains canonical")
        if label_at.is_finite():
            var transform: Transform2D=skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
            var label_rect: Rect2=transform*Rect2(label_at,Vector2(96,24))
            for region in hud.reserved:expect(not label_rect.intersects(region),"Safe Spot label yields to HUD")
        # Real held pointer across refresh, actual pause and confirmation callbacks.
        await click(game.pause_button)
        expect(game.mode=="paused","V2 Pause retains actual pointer behavior")
        await click(game.presentation.secondary.quit_run)
        expect(game.mode=="confirm_exit","Two-step Quit retained")
        await click(game.restart_button)
        expect(game.mode=="paused","STAY retains run")
        game._toggle_pause();skin.refresh()
        game._deal_damage_to_player(100000)
        expect(game.mode=="lost" and not skin.player_plate.visible,"Death hides gameplay HUD")
    game.queue_free()
    if failures.is_empty():print("PASS: HUD V2 all heroes/six viewports, live damage/heal/shield/XP, 3+5 icons, state lifecycle, geometry cache and real Pause/Quit");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
