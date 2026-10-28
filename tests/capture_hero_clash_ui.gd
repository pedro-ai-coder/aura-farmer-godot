extends SceneTree
## Real production candidate Godot screen fixtures; not a normal interactive run.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func _initialize() -> void: call_deferred("capture")
func capture() -> void:
    var args := OS.get_cmdline_user_args()
    var width := int(args[0]) if args.size() > 0 else 1280
    var height := int(args[1]) if args.size() > 1 else 720
    var output := args[2] if args.size() > 2 else "user://hero-clash-ui-candidate"
    root.size = Vector2i(width,height)
    DirAccess.make_dir_recursive_absolute(output)
    var game = ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.touch_device = width < 1000
    var measurements: Array = []
    for state in ["menu","character","playing","ready","choice","legendary","won","lost"]:
        seed(7301)
        game.start_run(0)
        if state in ["menu","character"]:
            game._return_to_menu()
            if state == "character":
                game.presentation.open_heroes()
                game.presentation.select_hero(1)
        elif state in ["playing","ready"]:
            game.player_pos = Vector2(850,565)
            game._spawn_enemy("npc",{"pos":Vector2(800,670)})
            game.aura = 100 if state == "ready" else 46
            game.weapons.clear();game.passives.clear()
            for id in ["keyboard-warrior","personal-space","brainrot-feed"]:
                game.weapons.append({"id":id,"level":4,"rarity":"common","timer":0.0})
            for id in ["main-character","terminally-online","built-different","absolute-cinema","too-sigma"]:
                game.passives.append({"id":id,"level":4,"rarity":"common"})
        elif state == "choice":
            game._gain_xp(100.0)
            game._open_choice()
        elif state == "legendary":
            game.run_time = 360.0
            game._open_legendary()
        elif state in ["won","lost"]: game._finish(state == "won")
        game._show_ui()
        game._update_text()
        game._update_camera(0.0,true)
        game.queue_redraw()
        await process_frame
        await process_frame
        game.clean_cut_skin.layout_key = ""
        game.clean_cut_skin.refresh()
        await process_frame
        await RenderingServer.frame_post_draw
        var path := output.path_join("%s-%s-%dx%d.png" % ["ui",state,width,height])
        if root.get_texture().get_image().save_png(path) != OK:
            push_error("Screenshot write failed: " + path)
            quit(1)
            return
        measurements.append({"candidate":"ui","state":state,"pixels":[width,height],"logical_viewport":str(game.get_viewport_rect().size),"text":measure(game.clean_cut_skin),"flex_hit_size":str(game.flex_button.size)})
        print("CAPTURE ",path," viewport=",game.get_viewport_rect().size)
        if state in ["character","choice","legendary"]:
            var scroll: ScrollContainer = game.clean_cut_skin.hero_scroll if state == "character" else game.clean_cut_skin.offers_scroll
            if scroll.get_v_scroll_bar().max_value > scroll.size.y:
                scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
                await process_frame
                await process_frame
                await RenderingServer.frame_post_draw
                root.get_texture().get_image().save_png(output.path_join("%s-%s-bottom-%dx%d.png" % ["ui",state,width,height]))
    var report := FileAccess.open(output.path_join("%s-%dx%d.json" % ["ui",width,height]),FileAccess.WRITE)
    report.store_string(JSON.stringify(measurements,"  "))
    quit(0)

func measure(node: Node) -> Array:
    var rows: Array = []
    if node is Label and node.is_visible_in_tree() and not node.text.is_empty():
        rows.append({"role":node.get_meta("typography_role","unassigned"),"text":node.text,"size":str(node.size),"font_px":node.get_theme_font_size("font_size"),"lines":node.get_line_count(),"visible_lines":node.get_visible_line_count(),"line_height":node.get_line_height(),"rect":str(node.get_global_rect())})
    for child in node.get_children(): rows.append_array(measure(child))
    return rows
