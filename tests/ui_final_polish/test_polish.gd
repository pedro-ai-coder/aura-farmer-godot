extends "res://tests/test_clean_cut_pointer_input.gd"
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass

func settle(game) -> void:
    game.presentation._window_changed(true);game._show_ui();game._update_text();game._update_camera(0,true)
    await process_frame;await process_frame
    game.clean_cut_skin.layout_key="";game.clean_cut_skin.refresh()

func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    var skin=game.clean_cut_skin;var hud=skin.gameplay_hud;var overlay=hud.threat_overlay
    var rows: Array=[]
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.touch_device=extent.x<1000
        game.web_metrics={"width":extent.x,"height":extent.y,"safe":[24,8,16,12]}
        game.start_run(0);game.player_pos=Vector2(724,543);await settle(game)
        var safe:=Rect2(skin.shift,skin.view)
        for state in ["charging","ready","active","recovery","disabled"]:
            game.aura=42 if state=="charging" else 100
            game.flex_time=4 if state=="active" else 0;game.flex_lock=20 if state=="recovery" else 0
            game.hp=0 if state=="disabled" else game.max_hp
            game._update_text();skin.refresh()
            expect(skin.aura_arc.visual_state==state,"Actual Flex state: "+state)
            expect(safe.encloses(game.flex_button.get_global_rect().grow(hud.FLEX_BLEED)),"Full READY rays and hit target fit asymmetric safe insets: "+str(extent))
            expect(game.flex_button.get_global_rect().is_equal_approx(skin.aura_arc.get_global_rect()),"Visual dial and real touch target share the same rectangle")
            expect(safe.encloses(skin.flex_caption.get_global_rect()),"Ability caption stays inside the safe viewport")
        game.hp=game.max_hp;game.aura=42;game.flex_lock=0
        game.boss_spawned=true;game.run_time=725;await settle(game)
        var transform: Transform2D=skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
        var status: Rect2=hud.modules["TopLeftHeroStatus"].get_rect()
        var point:=Vector2(status.get_center().x,status.end.y+55)
        game._spawn_enemy("boss",{"pos":transform.affine_inverse()*point})
        game.enemies[-1]["hp"]=17001
        game._update_text();skin.refresh();hud.update_threat_readability(true)
        var boss: Dictionary=game.enemies[-1]
        var bounds: Rect2=overlay.enemy_bounds(boss,transform)
        expect(Rect2(Vector2.ZERO,skin.view).encloses(bounds),"Controlled actor overlaps HUD without viewport clipping")
        expect(overlay.actor_hits==1 and overlay.cue.visible and not overlay.clipped_boss,"HUD occlusion is distinguished from clipping")
        expect(skin.player_plate.self_modulate.a<0.2 and not skin.portrait.visible and not skin.hero_name.visible,"Only obscuring decoration yields to the actual threat")
        expect(skin.hp.self_modulate.a==1 and skin.hp.has_theme_stylebox_override("normal"),"Essential HP remains opaque with a tight contrast surface")
        expect(hud.boss_hp.text=="17001 / 30000 HP" and skin.warning.text=="FULL HATER MODE","Live HP and canonical Berserk remain accurate")
        expect(hud.boss_rect.get_center().x==skin.view.x*0.5 and hud.boss_rect.size.y<88,"Boss stays centered with a smaller vertical footprint")
        for id in ["TopLeftHeroStatus","TopCenterWaveTimer","TopRightPause"]:expect(not hud.boss_rect.intersects(hud.modules[id].get_rect()),"Boss does not overlap peer HUD: "+id)
        boss["pos"]=transform.affine_inverse()*Vector2(22,60)
        var facing: Vector2=(game.player_pos-Vector2(boss["pos"])).normalized()
        game._schedule_hazard(boss["pos"],600,1.2,0.1,60,"line",facing,boss)
        var simulation: String=var_to_str([game.enemies,game.hazard_zones,game.rng.state,game.player_pos,game.camera.position,game.camera.zoom,game.run_time,game.hp])
        hud.update_threat_readability(true)
        expect(overlay.clipped_boss and overlay.cue.visible and overlay.cue.text.ends_with("EDGE"),"Near-edge clipping has an honest contextual cue "+str(extent))
        expect(overlay.cue.get_line_count()==1 and overlay.cue.get_theme_font("font").get_string_size(overlay.cue.text,HORIZONTAL_ALIGNMENT_LEFT,-1,overlay.cue.get_theme_font_size("font_size")).x<=overlay.cue.size.x+1,"Context cue remains a single complete line")
        expect(not overlay.traces.is_empty(),"Actual hostile boundaries are re-exposed above HUD decoration")
        for trace in overlay.traces:
            var covered:=false
            for region in overlay.regions:
                if region.grow(0.1).encloses(Rect2(trace["points"][0],Vector2.ZERO)) and region.grow(0.1).encloses(Rect2(trace["points"][1],Vector2.ZERO)):covered=true;break
            expect(covered,"Replayed boundary segments are restricted to actual HUD coverage")
            for p in trace["points"]:
                var world: Vector2=transform.affine_inverse()*p
                expect(absf((world-Vector2(boss["pos"])).cross(facing))<0.1,"Warning remains on its actual world-space attack line")
        for i in range(25):hud.update_threat_readability(true)
        expect(var_to_str([game.enemies,game.hazard_zones,game.rng.state,game.player_pos,game.camera.position,game.camera.zoom,game.run_time,game.hp])==simulation,"Readability changes no simulation, camera, RNG, HP, timing or hazard data")
        var geometry: int=hud.geometry_count;var samples: int=overlay.sampling_count
        for i in range(30):hud.update_threat_readability()
        expect(hud.geometry_count==geometry and overlay.sampling_count<=samples+1,"Overlap sampling is bounded and never reconstructs HUD geometry")
        for region in hud.reserved:expect(not overlay.cue.get_rect().intersects(region),"Context cue avoids permanent HUD")
        expect(overlay.mouse_filter==Control.MOUSE_FILTER_IGNORE and overlay.cue.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Threat presentation owns no input")
        expect(game._touch_ui_at(game.layer,overlay.cue.get_global_rect().get_center())==null,"Context cue does not prevent a terrain-origin joystick")
        # Tracking and camera presentation must stay live between actor samples.
        var original: PackedVector2Array=overlay.traces[0]["points"]
        boss["pos"]+=Vector2(1,1);game.hazard_zones[0]["pos"]+=Vector2(1,1)
        overlay.next_sample=Time.get_ticks_msec()+1000;hud.update_threat_readability()
        expect(overlay.traces[0]["points"]!=original,"Danger boundary follows the current world transform between 20 Hz actor checks")
        # All existing hostile shapes retain their real timing and geometry.
        for shape in ["circle","cone","ring","tether"]:
            game.hazard_zones.clear();game._schedule_hazard(boss["pos"],200,1,1,35,shape,facing,boss)
            hud.update_threat_readability(true)
            expect(game.hazard_zones[0]["shape"]==shape and game.hazard_zones[0]["at"]==726,"No hazard rule changes for "+shape)
        game.hazard_zones.clear();game.enemies.clear();hud.update_threat_readability(true)
        expect(not overlay.cue.visible and overlay.traces.is_empty() and skin.player_plate.self_modulate.a==1 and skin.portrait.visible,"Quiet play restores the original HUD without constant warnings")
        # Bottom equipment/Flex can also cover real enemy silhouettes.
        game._spawn_enemy("npc",{"pos":transform.affine_inverse()*hud.modules["BottomCenterEquipment"].get_rect().get_center()})
        hud.update_threat_readability(true);expect(overlay.faded[5],"Equipment decoration yields to a covered ordinary enemy")
        for parts in skin.equipment:
            if parts["level"].text.is_empty():expect(not parts["level"].has_theme_stylebox_override("normal"),"Empty slots do not create opaque contrast surfaces")
        game.enemies[0]["pos"]=transform.affine_inverse()*(hud.modules["BottomRightFlex"].position+Vector2(80,120))
        hud.update_threat_readability(true);expect(skin.aura_arc.body_alpha<0.2,"Flex yields its body while preserving its ring, values and target")
        game._toggle_pause();await process_frame;skin.refresh();hud.update_threat_readability(true)
        expect(not overlay.visible and skin.aura_arc.body_alpha==1,"Pause clears threat visuals and restores the control")
        await click(game.presentation.secondary.settings);await settle(game)
        var aux=skin.auxiliary;var ui=game.presentation
        expect(game.mode=="options" and aux.screen_panel.size.y<=view_limit(skin,432),"Settings height follows actual two/one-column content")
        var controls: Array=[ui.volume_label,ui.volume_slider,game.sound_button,game.motion_button,aux.fullscreen_button,aux.fullscreen_status]
        for i in range(controls.size()):
            for j in range(i+1,controls.size()):expect(not controls[i].get_rect().intersects(controls[j].get_rect()),"Settings controls have distinct content rectangles")
        expect(aux.fullscreen_button.get_node("ClashButtonFeedback").art_family==game.sound_button.get_node("ClashButtonFeedback").art_family,"Native Fullscreen uses the same secondary family")
        expect(aux.fullscreen_status.get_rect().end.y<=ui.body_content.size.y+1,"Fullscreen status remains accessible within content")
        await click(ui.back_button);expect(game.mode=="paused","Settings Back preserves pause")
        rows.append({"viewport":str(extent),"safe_view":str(skin.view),"boss_bounds":str(bounds),"settings_height":aux.screen_panel.size.y,"sampling":"20 Hz actor checks; live hostile boundaries; no HUD reconstruction"})
    var args:=OS.get_cmdline_user_args()
    if not args.is_empty():
        var file:=FileAccess.open(args[0],FileAccess.WRITE);file.store_string(JSON.stringify({"cases":rows,"failures":failures},"  "));file.close()
    game.queue_free()
    if failures.is_empty():print("PASS: Six-viewport actual threat geometry, hostile clipping, unchanged simulation, five Flex states/safe insets and compact Settings");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)

func view_limit(skin, two_columns_height: float) -> float:
    return minf(two_columns_height+76 if skin.view.x-96<560 else two_columns_height,skin.view.y-32)
