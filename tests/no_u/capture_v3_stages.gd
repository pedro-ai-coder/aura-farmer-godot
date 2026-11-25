extends "res://tests/no_u/test_reverse_impact.gd"
## Controlled real-resolver tableau, not a normal combat replay. Never changes gameplay code.

func run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 1 or DisplayServer.get_name() == "headless":
        quit(2)
        return
    DirAccess.make_dir_recursive_absolute(args[0])
    root.size = Vector2i(1280, 720)
    var game := ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.clean_cut_skin.set_process(false)
    var layer := CanvasLayer.new()
    root.add_child(layer)
    var caption := Label.new()
    layer.add_child(caption)
    caption.position = Vector2(18, 545)
    caption.add_theme_font_size_override("font_size", 18)
    caption.add_theme_color_override("font_color", Color.WHITE)
    caption.add_theme_color_override("font_outline_color", Color.BLACK)
    caption.add_theme_constant_override("outline_size", 8)
    for map: StringName in Maps.NAMES:
        v2(game, map)
        game._deal_damage_to_player(5.0, game.enemies[0])
        if game.combat_audio.clips.has("no_u_reverse_v3"):
            game.combat_audio.clips["no_u_reverse_v3"].save_to_wav(args[0].path_join("reverse-signature"))
        for stage in [["trigger",0.0],["anticipation",0.0333],["burst",0.1333],
            ["damage-lethal-shield-only",0.0833],["dissipation",0.4],["weaken",0.75],
            ["boss-expiration",2.10],["expiration",4.10],["expired-clean",4.30]]:
            game.run_time = float(stage[1])
            caption.text = "CONTROLLED RESOLVER / V3 / %s / %.2fs\nHP slashes + lethal split / shield-only: no HP accent / broken sword + DOWN = lower ATK" % [stage[0], stage[1]]
            game.queue_redraw()
            await process_frame
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png(args[0].path_join("%s-%s.png" % [map,stage[0]]))
    game.free()
    print("PASS: controlled real-resolver stages on both maps; includes lethal, shield-only and expiry")
    quit()
