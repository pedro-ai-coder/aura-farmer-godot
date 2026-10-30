extends "res://tests/test_clean_cut_pointer_input.gd"
## Live UI/state contracts, never an artistic acceptance or device benchmark.
const SAVE="user://ui-cohesion-test.json"
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:ProfileStoreScript.save_profile(profile,"user://ui-cohesion-test.json")
func settle(game) -> void:
    game.presentation._window_changed(true);game._update_text()
    await process_frame;await process_frame
    game.clean_cut_skin.refresh()
    await process_frame;await process_frame
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    var skin=game.clean_cut_skin;var hud=skin.gameplay_hud;var aux=skin.auxiliary;var ui=game.presentation
    # Actual level transition and post-cap recovery, including the 20s gate.
    game.start_run(0);game.level=24;game._recompute_max_hp();game.hp=50;game.xp=0
    game._gain_xp(798);await settle(game)
    expect(game.level==25 and game.pending_choices==1,"Level 24 earns exactly one canonical upgrade at 25")
    expect(skin.xp.text=="MAX LV 25" and not skin.xp_frame.visible and not skin.xp_track.visible and not skin.xp_fill.visible and hud.max_level_plate.visible,"Max level hides the normal progression bar and retains a compact cap label")
    var hp_before: float=game.hp;var rng: int=game.rng.state;var cues: int=game.pickup_feedback.size()
    game._gain_xp(855)
    expect(is_equal_approx(game.hp-hp_before,game.max_hp*0.05),"Post-cap XP still heals the real 5% max HP")
    expect(game.level==25 and game.pending_choices==1 and game.pickup_feedback.size()==cues+1,"No fictitious level 26 or extra offer; actual recovery emits a brief cue")
    expect(game.pickup_feedback[-1]["kind"]=="xp-recovery" and game.rng.state==rng,"Recovery cue consumes no gameplay RNG")
    hp_before=game.hp;game._gain_xp(855)
    expect(game.hp==hp_before and game.pickup_feedback.size()==cues+1,"Cooldown blocks both healing and false presentation feedback")
    game._toggle_pause();var clock: float=game.run_time;game._process(0.25)
    expect(game.run_time==clock,"Pause cannot advance the recovery gate")
    game._toggle_pause();game.run_time=20;game._gain_xp(855)
    expect(game.hp>hp_before and game.level==25,"Recovery becomes available after 20 active seconds")
    game.hp=game.max_hp;game.run_time=40;cues=game.pickup_feedback.size();game._gain_xp(855)
    expect(game.pickup_feedback.size()==cues,"Full HP does not advertise an effective heal")
    var reports: Array=[]
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.touch_device=extent.x<1000
        game.web_metrics={"width":extent.x,"height":extent.y,"safe":[24,8,16,12] if extent.x==844 else [0,0,0,0]}
        for mode in ["build","options","won","lost"]:
            game.start_run(0)
            game.weapons.append({"id":"ratio-blaster","rarity":"rare","level":3,"timer":0.0})
            game.weapons.append({"id":"brainrot-feed","rarity":"epic","level":4,"timer":0.0})
            for id in ["main-character","terminally-online","built-different","caught-4k","certified-w"]:game.passives.append({"id":id,"rarity":game.SoloOfferRulesScript.PASSIVE_DATA[id]["rarity"],"level":1})
            game.run_time=625;game.wave=5;game.kills=321;game.run_metrics["damage"]=12345678
            if mode=="build":game._toggle_pause();ui.open_build()
            elif mode=="options":game._toggle_pause();ui.open_settings("paused")
            elif mode=="won":
                game.boss_spawned=true;game._spawn_enemy("boss",{"pos":Vector2(850,680)});game._hit_enemy(game.enemies[-1],1000000)
            else:game._deal_damage_to_player(1000000)
            await settle(game)
            if mode=="build":
                expect(ui.equipment_slots.size()==8,"Build exposes exactly the original three plus five positions")
                for i in range(8):
                    var item: Dictionary=game.weapons[i] if i<3 else game.passives[i-3]
                    var part: Dictionary=ui.equipment_slots[i]
                    expect(part["image"].texture==ui.item_icons.texture("weapon" if i<3 else "passive",item["id"]),"Build uses the exact approved icon for live equipment")
                    expect(part["meta"].text.contains(str(item["rarity"]).to_upper()) and part["meta"].text.contains("LV %d" % item["level"]),"Actual rarity/level combination remains explicit")
                    expect(aux.build_parts[i]["status"].text=="EQUIPPED","Equipped state remains explicit")
                    var texts: Array=[part["label"],part["meta"],aux.build_parts[i]["details"],aux.build_parts[i]["status"]]
                    for label in texts:expect(label.get_minimum_size().y<=label.size.y+1,"Build text fits its live card: "+label.text)
                    for a in range(texts.size()):
                        for b in range(a+1,texts.size()):expect(not texts[a].get_rect().intersects(texts[b].get_rect()),"Build peers %s %s: %s %s / %s %s" % [extent,i,texts[a].text,texts[a].get_rect(),texts[b].text,texts[b].get_rect()])
                if extent.x>=1280:expect(ui.body_content.get_combined_minimum_size().y<=ui.body_scroll.size.y+1,"All eight desktop slots fit without scrolling")
                else:
                    ui.body_scroll.scroll_vertical=10000;await process_frame
                    expect(ui.body_scroll.get_global_rect().intersects(ui.equipment_slots[7]["panel"].get_global_rect()),"Last passive is accessible through mobile internal scrolling")
                game.weapons.clear();game.passives.clear();game._update_text();skin.refresh()
                await process_frame;await process_frame
                for i in range(8):
                    expect(ui.equipment_slots[i]["image"].texture==null and aux.build_parts[i]["status"].text=="OPEN SLOT","Empty capacity retains the same exact eight positions")
            elif mode=="options":
                expect(aux.screen_panel.size.x<=720 and aux.screen_panel.get_rect().get_center().is_equal_approx(skin.view*0.5),"Settings use one bounded centered panel")
                expect(ui.volume_slider.size.x<=656,"Volume no longer stretches across the viewport")
                expect(game.profile["settings"].size()==3,"Fullscreen adds no persistent setting or save-schema field")
                expect(aux.screen_panel.get_global_rect().encloses(ui.back_button.get_global_rect()),"Back stays with the settings panel")
            else:
                expect(aux.result_values.size()==10,"All original statistics remain present")
                expect(aux.result_values[0].text=="10:25" and aux.result_values[3].text==str(game.kills),"Time and kills use actual outcome state")
                expect(aux.result_values[6].text=="%.0f" % game.run_metrics["damage"],"Damage comes from actual run metrics")
                expect(aux.primary_stats.get_child_count()==4 and aux.secondary_stats.get_child_count()==6,"Four primary and six supporting values remain distinct")
                expect(aux.result_portrait.texture==game.art.texture(game.hero["id"]) and aux.result_portrait.visible,"Original selected hero remains visible across layouts")
                expect(aux.caption.text==("BIG HATER DEFEATED" if mode=="won" else "THE STREETS WON THIS ROUND"),"Outcome copy matches actual boss defeat/loss")
                for value in aux.result_values:expect(value.get_line_count()==1 and value.get_theme_font("font").get_string_size(value.text,HORIZONTAL_ALIGNMENT_LEFT,-1,value.get_theme_font_size("font_size")).x<=value.size.x+1,"Result value fits without clipping")
                if extent.x>=1280:expect(aux.result_rows.get_combined_minimum_size().y<=aux.result_scroll.size.y+1,"Desktop results do not need scrolling")
                expect(not game.restart_button.get_global_rect().intersects(game.retry_button.get_global_rect()),"Result actions remain distinct")
            reports.append({"pixels":str(extent),"mode":mode,"view":str(skin.view),"scroll_height":ui.body_scroll.size.y,"content_height":ui.body_content.size.y})
            var safe:=Rect2(ui.position,ui.view).grow(0.5)
            for button in ([ui.back_button] if mode in ["build","options"] else [game.restart_button,game.retry_button]):
                expect(safe.encloses(button.get_global_rect()),"Navigation actions remain inside actual safe-area bounds")
        # Real pointer callbacks preserve retry and menu semantics.
        await click(game.retry_button);expect(game.mode=="playing" and game.run_time==0,"Try Again resets the real run")
        game._deal_damage_to_player(1000000);await process_frame;skin.refresh()
        await click(game.restart_button);expect(game.mode=="menu","Main Menu callback remains functional")
    # Real slider input, keyboard and debounced on-disk settings persistence.
    root.size=Vector2i(1280,720);game.web_metrics={};game.start_run(0);game._toggle_pause();ui.open_settings("paused");await settle(game)
    var run_time: float=game.run_time
    var sound: bool=game.profile["settings"]["sound"];await click(game.sound_button)
    expect(game.profile["settings"]["sound"]!=sound,"Sound changes through the actual button")
    var reduced: bool=game.profile["settings"]["reducedMotion"];await click(game.motion_button)
    expect(game.profile["settings"]["reducedMotion"]!=reduced,"Reduced Motion changes through the actual button")
    ui.volume_slider.value=31;ui.volume_slider.grab_focus()
    var event:=InputEventKey.new();event.keycode=KEY_RIGHT;event.physical_keycode=KEY_RIGHT;event.pressed=true
    root.push_input(event,true);await process_frame;event.pressed=false;root.push_input(event,true)
    expect(ui.volume_slider.value>31,"Keyboard adjusts the actual volume slider")
    await create_timer(0.35).timeout
    var saved=game.ProfileStoreScript.read_data(game.ProfileStoreScript.parse_json(FileAccess.get_file_as_string(SAVE)))
    expect(saved["settings"]==game.profile["settings"] and game.run_time==run_time,"Debounced settings round-trip without advancing a paused run")
    await click(ui.back_button);expect(game.mode=="paused","Settings Back returns to the same paused run")
    game._toggle_pause();game._finish(true);skin.refresh()
    expect(aux.caption.text=="RUN COMPLETE","Unsupported fixture victories never claim a boss kill")
    var args:=OS.get_cmdline_user_args()
    if not args.is_empty():
        var file:=FileAccess.open(args[0],FileAccess.WRITE);file.store_string(JSON.stringify({"layout_cases":reports,"failures":failures},"  "));file.close()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE));game.queue_free()
    if failures.is_empty():print("PASS: UI cohesion six-view matrix, 24-to-25 transition, capped XP healing/cooldown, live equipment/results, keyboard/pointer and isolated settings persistence");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
