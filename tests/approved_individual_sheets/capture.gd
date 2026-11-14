extends SceneTree
## Actual native renderer readback, isolated from creator saves.
class CaptureRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile=ProfileStoreScript.defaults()
    func _save_profile() -> void: pass
var records: Array = []
func _initialize() -> void: call_deferred("capture")
func shot(game: Node2D, filename: String) -> void:
    game.presentation._window_changed(true)
    game._show_ui();game._update_text();game.clean_cut_skin.refresh()
    game.queue_redraw()
    await process_frame;await process_frame;await RenderingServer.frame_post_draw
    var image:=root.get_texture().get_image()
    var folder:=OS.get_cmdline_user_args()[0]
    if image.save_png(folder.path_join(filename))!=OK:
        push_error("Cannot save native renderer evidence");quit(1);return
    records.append({"file":filename,"mode":game.mode,"kit":game.HEROES[game.hero_index]["id"],"appearance":game.hero_appearance,"size":[image.get_width(),image.get_height()],"portrait":game.art.cosmetic_portrait(str(game.HEROES[game.hero_index]["id"]),game.hero_appearance).resource_path})
func capture() -> void:
    var folder:=OS.get_cmdline_user_args()[0]
    DirAccess.make_dir_recursive_absolute(folder)
    root.size=Vector2i(1280,720)
    var game:=CaptureRun.new();root.add_child(game)
    game.set_process(false);game.clean_cut_skin.set_process(false)
    for appearance in ["original","female"]:
        game.select_appearance(appearance)
        for index in range(3):
            game.hero_index=index;game.mode="heroes"
            var id: String=game.HEROES[index]["id"]
            await shot(game,"selection-%s-%s.png" % [id,appearance])
            game.start_run(index)
            if game.mode!="playing":push_error("Approved identity cannot start");quit(1);return
            game.touch_direction=Vector2.RIGHT
            for frame in range(30):game._advance(1.0/60.0)
            await shot(game,"playing-%s-%s.png" % [id,appearance])
            game._return_to_menu()
    game.hero_index=0;game.select_appearance("female");game.mode="heroes"
    for extent in [Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent
        await shot(game,"vixen-selection-%dx%d.png" % [extent.x,extent.y])
        game.start_run(0)
        await shot(game,"vixen-playing-%dx%d.png" % [extent.x,extent.y])
        game._return_to_menu();game.mode="heroes"
    var output:=FileAccess.open(folder.path_join("native-captures.json"),FileAccess.WRITE)
    output.store_string(JSON.stringify({"renderer":RenderingServer.get_current_rendering_method(),"display":DisplayServer.get_name(),"captures":records},"  "))
    game.queue_free()
    print("PASS: actual native renderer captured six approved identities in selection/gameplay plus compact/portrait views")
    quit()
