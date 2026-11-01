extends "res://tests/test_clean_cut_pointer_input.gd"

const Appearance = preload("res://scripts/hero_appearance.gd")
const CanonicalAnimation = preload("res://scripts/hero_animation.gd")
const Store = preload("res://scripts/profile_store.gd")
const Trace = preload("res://tests/frame_pacing/state_trace.gd")

class TestRun extends "res://scripts/solo_run.gd":
    var initial_profile: Dictionary = {}
    func _load_profile() -> void:
        _restore_profile(ProfileStoreScript.defaults() if initial_profile.is_empty() else initial_profile.duplicate(true))
    func _save_profile() -> void: pass

class MissingArt extends "res://scripts/female_appearance_art.gd":
    func has_assets(_hero_id: String) -> bool: return false

func press_enter(button: Button) -> void:
    button.grab_focus()
    for pressed in [true,false]:
        var event := InputEventKey.new()
        event.keycode=KEY_ENTER;event.pressed=pressed
        root.push_input(event,true)
        await process_frame

func visible_point(button: Button) -> Vector2:
    var rect := button.get_global_rect()
    var parent := button.get_parent()
    while parent != null:
        if parent is Control and parent.clip_contents: rect=rect.intersection(parent.get_global_rect())
        parent=parent.get_parent()
    expect(rect.has_area(),"Selection control has a visible interactive region")
    return rect.get_center()

func tap(button: Button) -> void:
    # Input.parse_input_event enters through the window, unlike push_input's
    # local viewport coordinates. Apply the existing responsive stretch.
    var point: Vector2 = root.get_final_transform()*visible_point(button)
    for pressed in [true,false]:
        var event := InputEventScreenTouch.new()
        event.index=0;event.position=point;event.pressed=pressed
        Input.parse_input_event(event)
        Input.flush_buffered_events()
        await process_frame
        await process_frame

func snapshot(game: Node) -> Array:
    var data: Array=[game.rng.state,game.hero]
    for key in Trace.KEYS: data.append(game.get(key))
    return data

func verify() -> void:
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent
        var game:=TestRun.new();root.add_child(game);game.set_process(false)
        # Keep the live UI refresh/focus behavior; freeze only simulation time.
        game.presentation._window_changed(true)
        await process_frame
        await click(game.presentation.home.hero_destination)
        await click(game.clean_cut_skin.appearance_buttons[1])
        var skin=game.clean_cut_skin
        for index in range(3):
            var id: String=game.HEROES[index]["id"]
            var button: Button=game.menu_buttons[index]
            skin.hero_scroll.ensure_control_visible(button)
            await process_frame;await process_frame
            if extent.x<1000: await tap(button)
            else: await press_enter(button)
            expect(game.hero_index==index,"Real keyboard/touch selects female kit %s at %s" % [id,extent])
            expect(skin.hero_parts[index]["portrait"].texture.resource_path==Appearance.asset_path(id,"selection"),"Correct female selection illustration")
            expect(not skin.hero_parts[index]["art_status"].visible,"Complete female art has no pending label")
            expect(not game.presentation.home.start_button.disabled,"All three female variants are startable")
            if extent.x<1000: await tap(game.presentation.home.start_button)
            else: await press_enter(game.presentation.home.start_button)
            expect(game.mode=="playing" and game.hero["id"]==id,"Real female run starts with canonical ID")
            if game.mode!="playing":
                push_error("Female start failed at %s; mode=%s; window transform=%s" % [extent,game.mode,root.get_final_transform()])
                quit(1)
                return
            expect(game.hero==game.HEROES[index],"Appearance cannot alter any canonical hero attribute")
            expect(game.hero_pose()["sheet"]==Appearance.asset_slug(id),"Gameplay uses the correct female atlas adapter")
            expect(skin.hero_name.text==Appearance.FEMALE_NAMES[id],"HUD uses the correct female name")
            expect(skin.portrait.texture.resource_path==Appearance.asset_path(id,"hud"),"HUD uses its dedicated female illustration")
            expect(skin.portrait.material==null,"Female HUD cannot inherit male portrait cropping")
            expect(game.art.female_art.texture(id,"atlas").resource_path==Appearance.asset_path(id,"atlas"),"No male/V1 atlas fallback")
            if index>0:
                for frame in range(24):
                    var first: Dictionary=game.art.female_art.frame(id,frame)
                    expect(first["texture"].get_width()>0,"Every required animation pose has a real texture")
                    expect(first["texture"]==game.art.female_art.frame(id,frame)["texture"],"Frames are cached, not reconstructed per frame")
            game._return_to_menu();game.presentation.open_heroes()
            skin.refresh();await process_frame
        await click(skin.appearance_buttons[0])
        for index in range(3):
            game.start_run(index)
            var id: String=game.hero["id"]
            expect(game.hero==game.HEROES[index] and game.hero_pose()["sheet"]=="atlas","Original kit and art stay playable")
            expect(game.art.cosmetic_portrait(id,"original")==game.art.texture(id),"Original portrait identity is preserved")
            game._return_to_menu()
        game.queue_free();await process_frame;await process_frame

    root.size=Vector2i(1600,900)
    for index in range(3):
        var original:=TestRun.new();var female:=TestRun.new()
        root.add_child(original);root.add_child(female)
        original.set_process(false);female.set_process(false)
        female.hero_appearance="female";female.profile["appearance"]="female"
        for game in [original,female]:
            game.start_run(index);game.spawn_timer=INF
            game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(120,0)})
            game.enemies[-1]["hp"]=10000.0;game.enemies[-1]["max"]=10000.0
            game.enemies[-1]["speed"]=0.0;game.enemies[-1]["next_attack"]=1e9
        for frame in range(420):
            for game in [original,female]:
                game.touch_direction=Vector2.RIGHT if frame%40<20 else Vector2.LEFT
                if frame==20: game.aura=100.0;game._use_flex()
                if frame==80: game._deal_damage_to_player(3.0)
                game._advance([1.0/60.0,1.0/30.0,0.008,0.075,0.001][frame%5])
            expect(var_to_bytes(snapshot(original))==var_to_bytes(snapshot(female)),"Original/female simulation, events and RNG match for kit %d frame %d" % [index,frame])
            var pose: Dictionary=female.hero_pose()
            var state: Dictionary={"time":female.run_time,"walk":female.visual_walk,"defeat":female.visual_defeat,"lost":female.mode=="lost","hurt":female.hurt_timer,"flex":female.flex_time,"flex_age":female.flex_age,"attack":female.attack_flash,"heading":female.visual_heading,"moving":female.visual_moving,"facing":female.visual_facing}
            expect(pose["state"]==CanonicalAnimation.pose(str(female.hero["id"]),state)["state"],"Appearance preserves canonical animation/Flex phase")
        original.queue_free();await process_frame
        var id: String=female.hero["id"]
        for won in [false,true]:
            female._finish(won);female._show_ui();female._update_text();female.clean_cut_skin.refresh()
            await process_frame;await process_frame
            var result=female.clean_cut_skin.auxiliary
            expect(result.result_hero.text==Appearance.FEMALE_NAMES[id],"Both result outcomes retain female identity")
            expect(result.result_portrait.texture.resource_path==Appearance.asset_path(id,"selection"),"Results retain the illustrated female portrait")
            expect(female.profile["results"][-1]["hero"]==id,"Result storage retains canonical IDs")
            await click(female.retry_button)
            expect(female.mode=="playing" and female.hero_appearance=="female" and female.hero["id"]==id,"Real Retry preserves appearance and kit")
        var saved: Dictionary=Store.read_data(JSON.parse_string(JSON.stringify(female.profile)))
        expect(saved["selected"]==id and saved["appearance"]=="female","Persisted preference uses canonical ID plus optional appearance")
        female.queue_free();await process_frame
        var restored:=TestRun.new();restored.initial_profile=saved;root.add_child(restored);restored.set_process(false)
        restored.start_run(restored.hero_index)
        expect(restored.mode=="playing" and restored.hero_appearance=="female" and restored.hero["id"]==id,"Restart restores the chosen appearance and original kit")
        restored._return_to_menu();restored.select_appearance("original")
        restored.mode="profile_import"
        expect(restored._import_profile_text(JSON.stringify(saved)),"Existing v2 import remains valid")
        expect(restored.hero_appearance=="female" and restored.HEROES[restored.hero_index]["id"]==id,"Actual import applies appearance and selected canonical ID immediately")
        restored.queue_free();await process_frame

    var missing:=TestRun.new();root.add_child(missing);missing.set_process(false)
    missing.presentation.open_heroes();missing.select_appearance("female")
    missing.art.female_art=MissingArt.new()
    for index in range(3):
        var before: Dictionary=missing.profile.duplicate(true)
        missing.start_run(index)
        expect(missing.mode=="heroes" and missing.profile==before,"Missing required art cannot start or mutate a profile")
        expect(missing.art.cosmetic_portrait(str(missing.HEROES[index]["id"]),"female")==null,"Missing female art never returns a male portrait")
    missing.queue_free()
    expect(not Appearance.can_start("female","byte-baddie") and not Appearance.can_start("female","block-queen"),"Asset slugs never become new gameplay hero IDs")
    if failures.is_empty():
        print("PASS: complete female roster; six-viewport real keyboard/touch start, correct art/HUD/poses, cached frames, exact canonical simulation/RNG, results, Retry/restart/save and fail-closed behavior")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
