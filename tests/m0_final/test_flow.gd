extends "res://tests/test_clean_cut_pointer_input.gd"
## Controlled native/headless event-routing tests; never a human Web run.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:ProfileStoreScript.save_profile(profile,"user://m0-final-test-profile.json")
var reports: Array=[]

func settle(game) -> void:
    game._show_ui();game._update_text();game.presentation._window_changed(true)
    await process_frame;await process_frame
    game.clean_cut_skin.refresh()
    await process_frame

func select_visible(game,index: int) -> void:
    var scroll: ScrollContainer=game.clean_cut_skin.offers_scroll
    var button: Button=game.offer_buttons[index]
    scroll.ensure_control_visible(button)
    await process_frame;await process_frame
    var visible: Rect2=button.get_global_rect().intersection(scroll.get_global_rect())
    expect(visible.has_area(),"Every offered card is accessible through actual scrolling: "+str(index))
    var point: Vector2=visible.get_center()
    var motion:=InputEventMouseMotion.new();motion.position=point;motion.global_position=point
    root.push_input(motion,true)
    for held in [true,false]:
        var event:=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT
        event.button_mask=MOUSE_BUTTON_MASK_LEFT if held else 0;event.pressed=held
        event.position=point;event.global_position=point;root.push_input(event,true)
        await process_frame;await process_frame
    expect(game.selected_card_index==index,"Held pointer selects the visible actual card: "+str(index))

func verify_cards(game,count: int,extent: Vector2i) -> void:
    var mode: String=game.mode
    var rng: int=game.rng.state
    var controls: Array=[]
    for i in range(count):controls.append(game.offer_buttons[i].get_rect())
    expect(game.confirm_button.disabled,"No confirmation without explicit selection")
    for i in range(count):
        await select_visible(game,i)
        expect(game.mode==mode and not game.confirm_button.disabled,"Selection stays modal and enables explicit confirmation")
        var footer: Label=game.clean_cut_skin.offer_parts[i]["state"]
        var card: Button=game.offer_buttons[i]
        var width: float=footer.get_theme_font("font").get_string_size(footer.text,HORIZONTAL_ALIGNMENT_LEFT,-1,footer.get_theme_font_size("font_size")).x
        var clearance: float=card.size.x-footer.position.x-footer.size.x
        expect(footer.text=="SELECTED · CONFIRM BELOW" and width<=footer.size.x,"Complete selected copy fits every normal/Legendary/replacement card")
        expect(clearance>=54 and footer.position.x>=16,"Footer remains inside diagonal silhouette")
        expect(card.get_rect()==controls[i],"Selecting never changes the original clickable rectangle")
        reports.append({"viewport":str(extent),"mode":mode,"card":i,"text":footer.text,"text_width":width,"label_width":footer.size.x,"right_clearance":clearance,"font_logical":footer.get_theme_font_size("font_size"),"readback_viewport":str(root.size)})
    expect(game.rng.state==rng,"Scrolling/focus/selection cannot consume gameplay RNG")
    game._process(0.17)
    expect(game.mode==mode,"An open offer cannot continue combat")

func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.touch_device=extent.x<1000
        game.web_metrics={"width":extent.x,"height":extent.y,"safe":[24,8,16,12] if extent.x==844 else [0,0,0,0]}
        game.start_run(0);game._gain_xp(39);game._open_choice();await settle(game)
        var time: float=game.run_time
        await verify_cards(game,3,extent)
        expect(game.run_time==time,"Ordinary offer pauses active simulation")
        await click(game.confirm_button)
        expect(game.mode=="playing" and game.pending_choices==0,"Actual Confirm applies exactly one ordinary choice")
        game.start_run(0);game.run_time=360;game._open_legendary();await settle(game)
        var offers: String=JSON.stringify(game.legendary_offers)
        await verify_cards(game,6,extent)
        await click(game.defer_button)
        expect(game.mode=="playing" and not game.legendary_spent,"Actual Defer does not spend the entitlement")
        await click(game.legendary_button)
        expect(game.mode=="legendary" and JSON.stringify(game.legendary_offers)==offers,"Actual deferred action reopens the same six offers")
        await select_visible(game,0)
        await click(game.confirm_button)
        expect(game.mode=="playing" and game.legendary_spent,"Actual Confirm grants exactly one Legendary")
        game._open_legendary();expect(game.mode=="playing","A consumed Legendary cannot reopen")
        # Five occupied legal passive positions exercise the second replacement row.
        game.start_run(0)
        for id in ["main-character","terminally-online","built-different","caught-4k","thick-skin"]:
            game.passives.append({"id":id,"rarity":"common","level":1})
        game.pending_choices=1
        game._replace_target({"type":"passive","id":"certified-w","rarity":"common","level":1})
        await settle(game);await verify_cards(game,5,extent)
        await click(game.confirm_button)
        expect(game.mode=="playing" and game.passives.size()==5,"Replacement keeps exactly five passive slots")
        expect(game._passive_level("certified-w")==1 and game._passive_level("thick-skin")==0,"Actual replacement confirms the selected existing slot")
        # Terminal transitions and isolated disk persistence are real callbacks,
        # but fixture-supplied lethal damage is not normal-health play acceptance.
        game._deal_damage_to_player(1000000);await settle(game)
        expect(game.mode=="lost","Fatal damage opens actual Run Over")
        await click(game.retry_button)
        expect(game.mode=="playing" and game.run_time==0,"Actual Retry starts a fresh selected hero")
        game.run_time=625;game.boss_spawned=true;game._spawn_enemy("boss",{"pos":Vector2(850,680)})
        game._hit_enemy(game.enemies[-1],1000000);await settle(game)
        expect(game.mode=="won","Actual boss defeat opens Victory")
        var runs: int=game.profile["runs"]
        await click(game.restart_button)
        expect(game.mode=="menu" and game.profile["runs"]==runs,"Result Main Menu does not duplicate outcomes")
    var saved=game.ProfileStoreScript.read_data(game.ProfileStoreScript.parse_json(FileAccess.get_file_as_string("user://m0-final-test-profile.json")))
    expect(saved["runs"]==game.profile["runs"] and saved["results"]==game.profile["results"],"Native isolated profile reload preserves actual outcome records")
    var args:=OS.get_cmdline_user_args()
    if not args.is_empty():
        var file:=FileAccess.open(args[0],FileAccess.WRITE);file.store_string(JSON.stringify(reports,"  "))
    game.queue_free()
    if failures.is_empty():print("PASS: Six viewport actual pointer card selection/scrolling, all selected footers, deferred Legendary, five-slot replacement, outcomes/retry and isolated native save reload");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
