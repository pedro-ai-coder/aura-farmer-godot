extends "res://tests/test_female_roster.gd"

## Staged native UI/animation evidence. Save-isolated, never human/device/FPS proof.
const Visuals = preload("res://scripts/approved_visuals.gd")
const Type = preload("res://scripts/clean_cut_typography.gd")
var output: String
var records: Array[Dictionary] = []

class PoseSample extends Node2D:
    var art: RefCounted
    var hero_id: String
    var slot: int
    var rendered := false
    func _draw() -> void:
        rendered=art.draw_hero_pose(self,Vector2.ZERO,hero_id,{"sheet":HeroAppearance.asset_slug(hero_id),"frame":slot,"flip":false})

func save_capture(game: Node2D, state: String, extent: Vector2i) -> void:
    game.presentation._window_changed(true);game._show_ui();game._update_text()
    game._update_camera(0.0,true);game.queue_redraw()
    await process_frame;await process_frame;await RenderingServer.frame_post_draw
    var image:=root.get_texture().get_image()
    var filename: String="%s-%dx%d.png" % [state,extent.x,extent.y]
    expect(image.save_png(output.path_join(filename))==OK,"Native capture saved")
    var kit: Dictionary=game.HEROES[game.hero_index] if game.hero.is_empty() else game.hero
    records.append({"file":filename,"requested_window":[extent.x,extent.y],
        "readback":[image.get_width(),image.get_height()],"mode":game.mode,
        "appearance":game.hero_appearance,"canonical_id":kit["id"],"starter":kit["starter"],
        "flex":kit["flex"],"canonical_hp":kit["hp"],"canonical_speed":kit["speed"],
        "pose":{} if game.hero.is_empty() else game.hero_pose(),
        "selection_texture":game.art.cosmetic_portrait(str(kit["id"]),game.hero_appearance).resource_path,
        "hud_texture":"" if game.mode=="heroes" else game.clean_cut_skin.portrait.texture.resource_path,
        "atlas_texture":game.art.female_art.texture(str(kit["id"]),"atlas").resource_path,
        "position":[game.player_pos.x,game.player_pos.y]})
    print("CAPTURE ",filename)

func gallery_label(parent: Node, text: String, at: Vector2, size: int) -> void:
    var label:=Label.new();label.text=text;label.position=at
    Type.apply(label,"section_header",false,Color("fff4d4"))
    label.add_theme_font_size_override("font_size",size);parent.add_child(label)

func capture_gallery() -> void:
    root.size=Vector2i(1920,1080);root.content_scale_size=Vector2i(1920,1080)
    var board:=Node2D.new();root.add_child(board)
    var background:=ColorRect.new();background.color=Color("091d31");background.size=Vector2(1920,1080);board.add_child(background)
    gallery_label(board,"FEMALE ROSTER · ACTUAL GODOT ATLAS REVIEW",Vector2(36,16),30)
    gallery_label(board,"Staged source poses · canonical gameplay unchanged · candidate art for creator review",Vector2(36,58),18)
    var art:=Visuals.new()
    var samples: Array[PoseSample]=[]
    var names: Array[String]=["IDLE","RUN","ATTACK","HURT","FLEX","DEFEAT"]
    var vixen: Array=[[0,2,4,6],[7,9,11,13],[21,23,25,27],[28,29,31,33],[35,37,39,41],[42,44,46,48]]
    for hero in range(3):
        var id: String=["sigma","cool-kid","alpha"][hero]
        expect(art.prepare_appearance(id,"female"),"Gallery has real female frames")
        gallery_label(board,Appearance.FEMALE_NAMES[id],Vector2(hero*640+40,94),26)
        for row in range(6):
            gallery_label(board,names[row],Vector2(hero*640+20,148+row*147),15)
            for frame in range(4):
                var sample:=PoseSample.new();sample.art=art;sample.hero_id=id
                sample.slot=int(vixen[row][frame]) if hero==0 else row*4+frame
                sample.position=Vector2(hero*640+87+frame*154,265+row*147)
                sample.scale=Vector2.ONE*1.55;board.add_child(sample);samples.append(sample)
    await process_frame;await process_frame;await RenderingServer.frame_post_draw
    for sample in samples: expect(sample.rendered,"Every gallery pose rendered actual atlas pixels")
    expect(root.get_texture().get_image().save_png(output.path_join("atlas-gallery-1920x1080.png"))==OK,"Native gallery saved")
    board.queue_free();await process_frame

func verify() -> void:
    if DisplayServer.get_name()=="headless":push_error("Native rendering is required");quit(1);return
    output=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(output)
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent
        var game:=TestRun.new();root.add_child(game);game.set_process(false)
        game.touch_device=extent.x<1000;game.presentation._window_changed(true)
        await process_frame;await process_frame
        await click(game.presentation.home.hero_destination)
        await click(game.clean_cut_skin.appearance_buttons[1])
        await save_capture(game,"female-selection",extent)
        for index in range(3):
            var id: String=game.HEROES[index]["id"];var slug:=Appearance.asset_slug(id)
            var button: Button=game.menu_buttons[index]
            game.clean_cut_skin.hero_scroll.ensure_control_visible(button)
            await process_frame;await process_frame
            if extent.x<1000:await tap(button)
            else:await press_enter(button)
            if extent.x<1000:await tap(game.presentation.home.start_button)
            else:await press_enter(game.presentation.home.start_button)
            if game.mode!="playing" or game.hero.get("id")!=id:
                push_error("Native selection/start did not use the requested canonical hero");quit(1);return
            await save_capture(game,slug+"-idle",extent)
            game.touch_direction=Vector2.RIGHT
            for frame in range(24):game._process(1.0/60.0)
            await save_capture(game,slug+"-moving",extent)
            game.touch_direction=Vector2.ZERO
            game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(60,0)})
            game.enemies[-1]["hp"]=10000.0;game.enemies[-1]["max"]=10000.0
            game.enemies[-1]["speed"]=0.0;game.enemies[-1]["next_attack"]=1e9
            game.weapons[0]["timer"]=0.0;game._fire_weapons(0.01)
            await save_capture(game,slug+"-attack",extent)
            game._deal_damage_to_player(30.0)
            await save_capture(game,slug+"-hurt",extent)
            for frame in range(14):game._process(1.0/60.0)
            game.aura=100.0;game._update_text();game.clean_cut_skin.refresh()
            await process_frame;await click(game.flex_button)
            for frame in range(18):game._process(1.0/60.0)
            expect(str(game.hero_pose()["state"]).begins_with("flex"),"Actual canonical Flex uses the female signature state")
            await save_capture(game,slug+"-flex",extent)
            game._deal_damage_to_player(1000000.0)
            expect(game.mode=="lost","Actual lethal damage reaches defeat")
            await save_capture(game,slug+"-defeat",extent)
            await click(game.retry_button)
            game.boss_spawned=true;game._spawn_enemy("boss",{"pos":game.player_pos+Vector2(150,0)})
            game._hit_enemy(game.enemies[-1],1000000.0)
            expect(game.mode=="won","Boss-kill fixture reaches canonical victory")
            await save_capture(game,slug+"-victory",extent)
            game._return_to_menu();game.presentation.open_heroes()
            await process_frame;await process_frame
        game.queue_free();await process_frame;await process_frame
    await capture_gallery()
    var report:=FileAccess.open(output.path_join("runtime.json"),FileAccess.WRITE)
    report.store_string(JSON.stringify({"engine":Engine.get_version_info()["string"],"display":DisplayServer.get_name(),
        "renderer":RenderingServer.get_video_adapter_name(),"evidence_type":"staged_native_fixtures_not_browser_device_or_human_playthrough",
        "failures":failures,"captures":records},"  "));report.close()
    if failures.is_empty():print("PASS: all three real female variants, 132 native six-viewport UI/gameplay/result captures and 72 atlas-gallery poses");quit(0)
    else:
        for failure in failures:push_error(failure)
        quit(1)
