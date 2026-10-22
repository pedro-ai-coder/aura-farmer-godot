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
    for state in ["menu","playing","choice","legendary","paused","won","lost"]:
        game.start_run(0)
        if state == "menu": game._return_to_menu()
        elif state == "playing":
            game.player_pos = Vector2(850,565)
            game.pickups.append({"kind":"snack","pos":Vector2(780,580),"xp":0.0})
            game.pickups.append({"kind":"magnet","pos":Vector2(930,580),"xp":0.0})
            game._spawn_enemy("npc",{"pos":Vector2(800,670)})
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
