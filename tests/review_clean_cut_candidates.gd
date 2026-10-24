extends SceneTree
## Manual native review entry point only. Production main_scene is unchanged.
const CandidateSkin=preload("res://tests/clean_cut_review/skin.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _use_clean_cut_skin() -> bool: return false
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var args:=OS.get_cmdline_user_args()
    var source:=ProjectSettings.globalize_path("res://")
    var output: String=args[0] if args.size()>0 else "user://clean-cut-review"
    var baseline:=args.has("--baseline")
    var check_only:=args.has("--check")
    DirAccess.make_dir_recursive_absolute(output)
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    var skin
    if not baseline:
        skin=CandidateSkin.new();skin.install(game,source);skin.set_process(false)
    if args.has("--interactive"):
        root.size=Vector2i(1600,900);game.presentation._window_changed(true)
        game._return_to_menu();game.set_process(true)
        if not baseline:skin.set_process(true);skin.refresh()
        return
    var records: Array=[]
    for extent in [Vector2i(1600,900),Vector2i(1280,720),Vector2i(1920,1080),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.presentation._window_changed(true)
        for target: String in ["menu","heroes","playing","choice","legendary","choice_selected","legendary_last","flex_sigma","flex_cool-kid","flex_alpha","boss","joystick","ready_sigma","ready_cool-kid","ready_alpha","recovery_sigma","recovery_cool-kid","recovery_alpha"]:
            game.start_run(0)
            game.touch_device=extent.x<1000
            if target=="menu":game._return_to_menu()
            elif target=="heroes":game._return_to_menu();game.presentation.open_heroes()
            elif target.begins_with("choice"):
                game._gain_xp(100);game._open_choice()
                if target.ends_with("selected"):game.pick_upgrade(0)
            elif target.begins_with("legendary"):
                game.run_time=360;game._open_legendary()
                if target.ends_with("last"):game.pick_upgrade(5)
            elif target=="boss":
                game.run_time=600;game.boss_spawned=true;game._spawn_enemy("boss",{"pos":game.player_pos+Vector2(100,0)})
            elif target=="joystick":
                game.touch_device=true
                var down:=InputEventScreenTouch.new();down.index=11;down.pressed=true;down.position=game.presentation.position+game.presentation.view*Vector2(0.65,0.55);game._input(down)
                var drag:=InputEventScreenDrag.new();drag.index=11;drag.position=down.position+Vector2(70,20);game._input(drag)
            elif target.begins_with("ready_") or target.begins_with("recovery_"):
                var id:=target.trim_prefix("ready_").trim_prefix("recovery_")
                game.start_run({"sigma":0,"cool-kid":1,"alpha":2}[id]);game.aura=100 if target.begins_with("ready_") else 0;game.flex_lock=1.5 if target.begins_with("recovery_") else 0
            elif target.begins_with("flex_"):
                var id:=target.trim_prefix("flex_")
                game.start_run({"sigma":0,"cool-kid":1,"alpha":2}[id])
                game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(80,0)})
                game.enemies[0]["hp"]=10000;game.enemies[0]["max"]=10000
                game.aura=100;game._use_flex();game._advance(0.2)
            game._show_ui();game._update_text();game._update_camera(0,true);game.queue_redraw()
            var before:=JSON.stringify([game.rng.state,game.hp,game.run_time,game.weapons,game.passives,game.selection,game.legendary_offers])
            if not baseline:skin.refresh()
            if before!=JSON.stringify([game.rng.state,game.hp,game.run_time,game.weapons,game.passives,game.selection,game.legendary_offers]):
                push_error("Candidate presentation changed simulation/RNG");quit(1);return
            if game.PASSIVES.size()!=23:push_error("Candidate skin changed content availability");quit(1);return
            if check_only:continue
            await process_frame
            await process_frame
            if not baseline:skin.refresh()
            await RenderingServer.frame_post_draw
            if not baseline:skin.refresh()
            await process_frame
            await process_frame
            await RenderingServer.frame_post_draw
            var image:=root.get_texture().get_image()
            var name: String="%s-%dx%d.jpg" % [target,extent.x,extent.y]
            image.save_jpg(output.path_join(name),0.9)
            records.append({"file":name,"actual_pixels":[image.get_width(),image.get_height()],"logical_view":[skin.view.x,skin.view.y] if not baseline else [game.presentation.view.x,game.presentation.view.y],"requested_pixels":[extent.x,extent.y],"mode":game.mode,"candidate_art":not baseline,"creator_approved":false,"real_hero":str(game.hero.get("id","")),"offer_count":game.selection.size() if game.mode=="choice" else game.legendary_offers.size() if game.mode=="legendary" else 0})
            print("CANDIDATE REVIEW ",name)
    var file:=FileAccess.open(output.path_join("captures.json"),FileAccess.WRITE);file.store_string(JSON.stringify(records,"  ")+"\n")
    if not baseline:
        var sources:=FileAccess.open(output.path_join("used-resources.json"),FileAccess.WRITE);sources.store_string(JSON.stringify(skin.art.used,"  ")+"\n")
    print("PASS: Five-screen live candidate composition, actual offers/hero/Flex and unchanged simulation; not production approval")
    quit(0)
