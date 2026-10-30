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
            check_edges(skin,hud)
            if hud.desktop:
                var occupied:=0.0
                for region in hud.reserved:occupied+=region.get_area()
                expect(occupied<275406.0*0.82,"Desktop HUD releases at least 18% of its previous reserved area")
                expect(skin.hp.get_theme_font_size("font_size")>=22 and skin.shield_label.get_theme_font_size("font_size")>=18,"Critical desktop health text stays readable")
            elif hud.compact:
                expect(is_equal_approx(game.flex_button.size.x,164),"Mobile circular Flex target retains its existing geometry")
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
            expect(game.max_hp>old_max and skin.xp.text.begins_with("LV %d" % game.level),"Level and max-HP progression stay live")
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
            if hud.desktop:expect(skin.equipment[i]["level"].get_rect().end.y<=skin.equipment[i]["rarity"].position.y,"Desktop level text stays above its rarity stroke")
        game.boss_spawned=true;game.run_time=625
        game._spawn_enemy("boss",{"pos":Vector2(1030,540)})
        game._show_ui();skin.refresh()
        expect(skin.wave.text.begins_with("WAVE ") and hud.wave_clock.text=="10:25" and skin.boss_text.visible,"Centered wave/clock remain separate from live boss information")
        expect(skin.wave.get_theme_font("font").get_string_size(skin.wave.text,HORIZONTAL_ALIGNMENT_LEFT,-1,skin.wave.get_theme_font_size("font_size")).x<=skin.wave.size.x+1,"Boss clock remains unclipped")
        expect(hud.boss_hp.text=="30000 / 30000 HP","Boss HP comes from actual canonical simulation values")
        expect(hud.boss_portrait.texture==game.art.texture("big-hater"),"Original Big Hater master identifies the encounter")
        var boss_module: Control=hud.modules["TopRightBossStatus"]
        var pause_module: Control=hud.modules["TopRightPause"]
        expect(boss_module.get_rect().get_center().x>skin.view.x*0.5 and not boss_module.get_rect().intersects(pause_module.get_rect()),"Boss stays at right edge without displacing Pause")
        game.enemies[-1]["hp"]=17001;game.run_time=720;skin.refresh()
        expect(hud.boss_hp.text=="17001 / 30000 HP" and skin.warning.text=="FULL HATER MODE","Live damage and Berserk phase remain visible within boss module")
        game.run_time=625;skin.refresh()
        for i in range(hud.reserved.size()):
            for j in range(i+1,hud.reserved.size()):expect(not hud.reserved[i].intersects(hud.reserved[j]),"Boss HUD regions remain separate")
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
        expect(skin.auxiliary.pause_panel.visible and skin.auxiliary.pause_dim.visible and not skin.background.visible,"Pause uses a modal over the frozen arena")
        expect(skin.auxiliary.pause_panel.get_rect().get_center().is_equal_approx(skin.view*0.5),"Pause modal stays centered in the usable viewport")
        for button in [game.presentation.secondary.resume,game.presentation.secondary.build,game.presentation.secondary.settings,game.presentation.secondary.quit_run]:
            expect(skin.auxiliary.pause_panel.get_global_rect().encloses(button.get_global_rect()),"Existing Pause actions remain inside the single modal")
        await click(game.presentation.secondary.quit_run)
        expect(game.mode=="confirm_exit","Two-step Quit retained")
        await click(game.restart_button)
        expect(game.mode=="paused","STAY retains run")
        game._toggle_pause();skin.refresh()
        game._deal_damage_to_player(100000)
        expect(game.mode=="lost" and not skin.player_plate.visible,"Death hides gameplay HUD")
    game.start_run(0);skin.refresh()
    game._deal_damage_to_player(20);skin.refresh()
    expect(hud.feedback_state=="damage","Actual damage starts bounded status feedback")
    game._heal_player(5);skin.refresh()
    expect(hud.feedback_state=="healing","Actual healing starts bounded status feedback")
    game._grant_weapon_shield("edge-status",40,4);skin.refresh()
    expect(hud.feedback_state=="shield-gained","Real shield grant is identified separately")
    game._deal_damage_to_player(40);skin.refresh()
    expect(hud.feedback_state=="shield-depleted" and game.shield==0,"Real shield depletion retains its own feedback")
    game.hp=10;skin.refresh();game.run_time+=0.4;hud.tick_feedback()
    expect(hud.feedback_state=="critical" and skin.hp.get_theme_color("font_color")!=hud.PAPER,"Critical HP retains static numeric emphasis with Reduced Motion")
    game.start_run(0);game.spawn_timer=INF;game.hp=50
    var station: Vector2=game.RecoveryRulesScript.SAFE_SPOT
    expect(game._safe_spot_context_label().is_empty(),"Ordinary distant station has no permanent name or countdown")
    game.player_pos=station+Vector2(80,0)
    expect(game._safe_spot_context_label()=="HEAL AVAILABLE","Nearby injured player gets contextual availability")
    game._tick_recovery(1.0)
    expect(game.safe_spot_charge==0,"Presentation proximity does not expand the canonical activation radius")
    game.player_pos=station;game._tick_recovery(1.0)
    expect(game._safe_spot_context_label()=="HEALING 50%","Charge label follows the real two-second activation")
    game._toggle_pause();game._process(0.25)
    expect(game.safe_spot_charge==1.0,"Pause freezes actual healing progress")
    game._toggle_pause();game._tick_recovery(1.0)
    expect(game.hp==75 and game.safe_spot_uses==1 and game.safe_spot_ready_at==90,"Presentation preserves actual heal amount and cooldown")
    expect(game._safe_spot_context_label()=="RECOVERY 90s" and game.pickup_feedback[-1]["text"]=="HP RESTORED","Real healing triggers the short completion cue and contextual cooldown")
    var rng: int=game.rng.state
    for reduced in [true,false]:
        game.profile["settings"]["reducedMotion"]=reduced
        expect(game._safe_spot_context_label()=="RECOVERY 90s","Reduced Motion retains readable state information")
    game.player_pos=station+Vector2(120,0)
    expect(game._safe_spot_context_label().is_empty() and game.rng.state==rng,"Distant cooldown stays subdued without presentation RNG")
    # Resize and synthetic browser safe-area metrics exercise real anchoring,
    # not hand-computed fixture rectangles or physical-device claims.
    for extent in [Vector2i(1366,768),Vector2i(1000,700),Vector2i(720,480),Vector2i(844,390)]:
        root.size=extent;game.touch_device=extent.x<1000
        game.web_metrics={"width":extent.x,"height":extent.y,"safe":[44,8,34,12]}
        game.start_run(2);game.presentation._window_changed(true)
        await process_frame;await process_frame
        skin.refresh();check_edges(skin,hud)
        var safe:=Rect2(game.presentation.position,game.presentation.view)
        for node in [skin.player_plate,skin.wave_frame,game.pause_button,skin.xp_frame,hud.strip,game.flex_button]:
            expect(safe.grow(0.1).encloses(node.get_global_rect()),"Resized live Control stays inside asymmetric safe area: "+str(node.name))
        for i in range(hud.reserved.size()):
            for j in range(i+1,hud.reserved.size()):expect(not hud.reserved[i].intersects(hud.reserved[j]),"Constrained safe-area HUD peers do not overlap")
        var point: Vector2=hud.strip.get_global_rect().get_center()
        expect(game._touch_ui_at(game.layer,point)==null,"Passive equipment rail does not steal terrain input")
    game.queue_free()
    if failures.is_empty():print("PASS: HUD V2 all heroes/six viewports, live damage/heal/shield/XP, 3+5 icons, state lifecycle, geometry cache and real Pause/Quit");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)

func check_edges(skin,hud) -> void:
    var status: Control=hud.modules["TopLeftHeroStatus"]
    var wave: Control=hud.modules["TopCenterWaveTimer"]
    var pause: Control=hud.modules["TopRightPause"]
    var xp: Control=hud.modules["BottomLeftXP"]
    var rail: Control=hud.modules["BottomCenterEquipment"]
    var flex: Control=hud.modules["BottomRightFlex"]
    expect(status.position.is_equal_approx(Vector2(4,4)),"Hero status anchors to safe upper-left corner")
    expect(is_equal_approx(wave.get_rect().get_center().x,skin.view.x*0.5),"Wave uses true safe-viewport center")
    expect(is_equal_approx(pause.get_rect().end.x,skin.view.x-4) and is_equal_approx(pause.position.y,4),"Pause stays at extreme upper-right")
    expect(is_equal_approx(xp.position.x,4),"XP stays on safe left edge")
    expect(is_equal_approx(rail.get_rect().get_center().x,skin.view.x*0.5) and is_equal_approx(rail.get_rect().end.y,skin.view.y-4),"3+5 equipment rail anchors to bottom-center")
    expect(is_equal_approx(flex.get_rect().end.x,skin.view.x-6),"Circular Flex anchors to safe right edge")
    if not hud.stacked_bottom:
        expect(is_equal_approx(xp.get_rect().end.y,skin.view.y-4) and is_equal_approx(flex.get_rect().end.y,skin.view.y-6),"XP and Flex share bottom boundary on supported landscape")
    else:
        expect(xp.get_rect().end.y<=rail.position.y-6 and flex.get_rect().end.y<=rail.position.y-6,"Constrained fallback is directly attached above bottom rail")
    for i in range(8):
        expect(skin.equipment[i]["frame"].get_parent()==rail,"Eight independent slots belong to one centered rail")
        expect(is_equal_approx(skin.equipment[i]["frame"].position.y,4),"Weapons and passives share one baseline")
    expect(hud.weapon_group.text=="WEAPONS" and hud.passive_group.text=="PASSIVES","Three and five slots retain clear group labels")
