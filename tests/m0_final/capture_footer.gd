extends SceneTree
## Actual Godot rendering of controlled canonical offer fixtures.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("capture")
func capture() -> void:
    if DisplayServer.get_name()=="headless":push_error("Native rendering required");quit(1);return
    var args:=OS.get_cmdline_user_args();var extent:=Vector2i(int(args[0]),int(args[1]));var output: String=args[2]
    DirAccess.make_dir_recursive_absolute(output);root.size=extent
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.profile["settings"]["reducedMotion"]=true;game.touch_device=extent.x<1000
    var reports: Array=[]
    for state in ["upgrade","legendary","legendary-last"]:
        game.start_run(2)
        if state=="upgrade":game._gain_xp(39);game._open_choice()
        else:game.run_time=360;game._open_legendary()
        game.pick_upgrade(5 if state=="legendary-last" else 0)
        game._show_ui();game._update_text();game.presentation._window_changed(true)
        await process_frame;await process_frame
        game.clean_cut_skin.layout_key="";game.clean_cut_skin.refresh()
        if state=="legendary-last":game.clean_cut_skin.offers_scroll.scroll_vertical=10000
        await process_frame;await process_frame;await RenderingServer.frame_post_draw
        var image:=root.get_texture().get_image()
        var file: String=output.path_join("%s-%dx%d.png" % [state,extent.x,extent.y])
        if image.save_png(file)!=OK:push_error("Native capture failed");quit(1);return
        var footers: Array=[]
        for i in range(3 if state=="upgrade" else 6):
            var label: Label=game.clean_cut_skin.offer_parts[i]["state"];var button: Button=game.offer_buttons[i]
            footers.append({"card":i,"text":label.text,"text_width":label.get_theme_font("font").get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,label.get_theme_font_size("font_size")).x,"label_rect":str(label.get_rect()),"label_width":label.size.x,"right_clearance":button.size.x-label.position.x-label.size.x,"font":label.get_theme_font_size("font_size"),"font_physical":label.get_theme_font_size("font_size")*root.get_final_transform().get_scale().y,"button_rect":str(button.get_rect())})
        reports.append({"state":state,"requested":str(extent),"readback":str(image.get_size()),"mode":game.mode,"selected":game.selected_card_index,"offers":game.selection if state=="upgrade" else game.legendary_offers,"rng":str(game.rng.state),"footers":footers})
    var report:=FileAccess.open(output.path_join("report-%dx%d.json" % [extent.x,extent.y]),FileAccess.WRITE)
    report.store_string(JSON.stringify(reports,"  "));game.queue_free();quit()
