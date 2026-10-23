extends SceneTree

## Render real fallback UI only. No candidate import, promotion or simulated approval.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func _initialize() -> void: call_deferred("capture")
func capture() -> void:
    var args := OS.get_cmdline_user_args()
    if args.is_empty(): quit(1); return
    var output: String = args[0]
    DirAccess.make_dir_recursive_absolute(output)
    var game := ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    var records: Array = []
    for extent: Vector2i in [Vector2i(1600,900),Vector2i(1280,720),Vector2i(1920,1080),Vector2i(915,412),Vector2i(390,844)]:
        root.size = extent
        game.presentation._window_changed(true)
        for state in ["choice","choice_selected","legendary","legendary_selected","build_empty","build_full","replacement","hud"]:
            game.start_run(0)
            game.touch_device = extent.x < 1000
            if state in ["build_full","replacement","hud"]:
                game.weapons.clear()
                for id in ["ratio-blaster","no-cap","brainrot-feed"]: game.weapons.append({"id":id,"level":1,"rarity":"common","timer":0.0})
                game.passives.clear()
                for id in ["main-character","terminally-online","built-different","thick-skin","caught-4k"]: game.passives.append({"id":id,"level":1,"rarity":"common"})
                game._recompute_max_hp()
            if state.begins_with("choice"):
                game._gain_xp(100)
                game._open_choice()
                if state.ends_with("selected"): game.pick_upgrade(0); game.offer_buttons[0].grab_focus()
            elif state.begins_with("legendary"):
                game.run_time = 360.0
                game._open_legendary()
                if state.ends_with("selected"): game.pick_upgrade(0); game.offer_buttons[0].grab_focus()
            elif state.begins_with("build"): game.presentation.open_build()
            elif state == "replacement": game._replace_target({"type":"weapon","id":"ratio-blaster","rarity":"legendary","level":1})
            game._show_ui()
            game._update_text()
            game._update_camera(0.0,true)
            game.queue_redraw()
            await process_frame
            await process_frame
            await RenderingServer.frame_post_draw
            var image := root.get_texture().get_image()
            var file := "%s-%dx%d.jpg" % [state,extent.x,extent.y]
            if image.save_jpg(output.path_join(file),0.85) != OK: quit(1); return
            records.append({"file":file,"actual_pixels":[image.get_width(),image.get_height()],"requested_pixels":[extent.x,extent.y],"state":state,"approved_icons":0,"candidate_art_activated":false})
            print("CAPTURE ",file," actual=",image.get_size())
    var file := FileAccess.open(output.path_join("captures.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify(records,"  ")+"\n")
    quit(0)
