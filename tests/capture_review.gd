extends SceneTree

## Staged rendered evidence, never a balance or human-playtest claim.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func _initialize() -> void: call_deferred("_capture")
func _capture() -> void:
    var args := OS.get_cmdline_user_args()
    var width := int(args[0]) if args.size() > 0 else 1280
    var height := int(args[1]) if args.size() > 1 else 720
    var output := args[2] if args.size() > 2 else "user://review"
    root.size = Vector2i(width,height)
    DirAccess.make_dir_recursive_absolute(output)
    var game = ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.touch_device = width < 1000
    for state in ["menu","character","playing","mobile","obstacles","recovery","station","choice","legendary","paused","build","flex_sigma","flex_cool","flex_alpha","confirm_exit","wave","boss_warning","boss","berserk","last_effort","won","lost","options","profile_import","profile_export","dense"]:
        game.start_run(0)
        if state == "menu" or state == "character":
            game._return_to_menu()
            if state == "character":
                game.presentation.open_heroes()
                game.presentation.select_hero(1)
        elif state in ["playing","mobile","obstacles","recovery","station"]:
            game.player_pos = Vector2(850,565)
            game.pickups.append({"kind":"snack","pos":Vector2(780,580),"xp":0.0})
            game.pickups.append({"kind":"magnet","pos":Vector2(930,580),"xp":0.0})
            game._spawn_enemy("npc",{"pos":Vector2(800,670)})
            if state == "station":
                game.player_pos = Vector2(1100,565)
                game.hp = 50.0
                game.safe_spot_charge = 1.0
        elif state == "options": game.mode = "options"
        elif state == "profile_import" or state == "profile_export":
            game._return_to_menu()
            if state == "profile_import": game._open_profile_import()
            else: game._open_profile_export()
        elif state.begins_with("flex_"):
            game.start_run({"flex_sigma":0,"flex_cool":1,"flex_alpha":2}[state])
            game.player_pos = Vector2(800,565)
            game._spawn_enemy("npc",{"pos":Vector2(870,565)})
            var target: Dictionary = game.enemies.back()
            target["hp"] = 10000.0
            target["max"] = 10000.0
            target["speed"] = 0.0
            target["next_attack"] = 1e9
            game.spawn_timer = 1e9
            game.aura = 100
            game.manual_aim = true
            game.aim_point = target["pos"]
            game._use_flex()
            var frames := 210 if state == "flex_sigma" else 273 if state == "flex_cool" else 333
            for frame in range(frames): game._advance(1.0/60.0)
        elif state == "confirm_exit":
            game._toggle_pause()
            game._request_return_to_menu()
        elif state == "wave":
            game.wave = 2
            game.run_time = 120.0
        elif state == "boss_warning":
            game.run_time = 570.0
        elif state in ["boss","berserk","last_effort"]:
            game.run_time = 600.0
            game._spawn_logic(0.0)
            game.run_time = 602.0
            game._step_enemies(0.0)
            game.run_time = 602.5 if state == "boss" else (720.0 if state == "berserk" else 840.0)
        elif state == "dense":
            game.player_pos = Vector2(850,565)
            for i in range(80): game._spawn_enemy("npc" if i%3 else "hater")
        elif state == "choice":
            game._gain_xp(100.0)
            game._open_choice()
        elif state == "legendary":
            game.run_time = 360.0
            game._open_legendary()
        elif state == "build": game.presentation.open_build()
        elif state == "paused": game._toggle_pause()
        elif state == "won" or state == "lost": game._finish(state == "won")
        game._show_ui()
        if args.has("--focus") and state == "choice":
            game.pick_upgrade(0)
            game.offer_buttons[0].grab_focus()
        game._update_text()
        game._update_camera(0.0,true)
        game.queue_redraw()
        await process_frame
        await process_frame
        await RenderingServer.frame_post_draw
        var image := root.get_texture().get_image()
        var path := output.path_join("%s-%dx%d.png" % [state,width,height])
        if image.save_png(path) != OK:
            push_error("Screenshot write failed: " + path)
            quit(1)
            return
        print("CAPTURE ",path," viewport=",game.get_viewport_rect().size)
    quit(0)
