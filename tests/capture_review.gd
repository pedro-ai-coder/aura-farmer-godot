extends SceneTree

## Staged rendered evidence, never a balance or human-playtest claim.
func _initialize() -> void: call_deferred("_capture")
func _capture() -> void:
    var args := OS.get_cmdline_user_args()
    var width := int(args[0]) if args.size() > 0 else 1280
    var height := int(args[1]) if args.size() > 1 else 720
    var output := args[2] if args.size() > 2 else "user://review"
    root.size = Vector2i(width,height)
    DirAccess.make_dir_recursive_absolute(output)
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    game.touch_device = width < 1000
    for state in ["menu","playing","obstacles","recovery","station","choice","legendary","paused","boss","won","lost","options","profile_import","profile_export","dense"]:
        game.start_run(0)
        if state == "menu": game._return_to_menu()
        elif state in ["playing","obstacles","recovery","station"]:
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
        elif state == "boss":
            game.run_time = 900.0
            game._spawn_logic(0.0)
            game.run_time = 902.0
            game._step_enemies(0.0)
            game.run_time = 902.5
        elif state == "dense":
            game.player_pos = Vector2(850,565)
            for i in range(80): game._spawn_enemy("npc" if i%3 else "hater")
        elif state == "choice":
            game._gain_xp(100.0)
            game._open_choice()
        elif state == "legendary":
            game.run_time = 540.0
            game._open_legendary()
        elif state == "paused": game._toggle_pause()
        elif state == "won" or state == "lost": game._finish(state == "won")
        game._show_ui()
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
