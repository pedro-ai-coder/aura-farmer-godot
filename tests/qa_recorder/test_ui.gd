extends SceneTree
class Review extends "res://qa/review_run.gd":
    pass
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("verify")
func expect(ok: bool,message: String) -> void:
    if not ok:failures.append(message)
func verify() -> void:
    var save_before:=FileAccess.get_file_as_bytes("user://profile_v2.json") if FileAccess.file_exists("user://profile_v2.json") else PackedByteArray()
    var game:=Review.new();root.add_child(game);game.set_process(false)
    for size in [Vector2i(1600,900),Vector2i(1050,810),Vector2i(1280,720),Vector2i(844,390)]:
        root.size=size;game._return_to_menu();game.qa_ui.refresh()
        await process_frame
        expect(game.qa_ui.panel.visible,"QA controls reachable in menu")
        expect(game.qa_ui.panel.position.x+game.qa_ui.panel.size.x<=size.x,"QA toolbar fits "+str(size))
        expect(game.qa_ui.status.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Status cannot steal input")
        var q=game.qa_settings
        for cycle in range(3):
            q.open()
            await process_frame
            await process_frame
            expect(q.visible and q.card.is_visible_in_tree(),"Visible modal opens")
            var state=var_to_bytes([game.mode,game.run_time,game.rng.state,game.profile])
            q.seed_input.get_line_edit().grab_focus()
            var enter:=InputEventKey.new();enter.keycode=KEY_ENTER;enter.pressed=true
            root.push_input(enter,true)
            enter=enter.duplicate();enter.pressed=false;root.push_input(enter,true)
            expect(var_to_bytes([game.mode,game.run_time,game.rng.state,game.profile])==state,"Seed Enter must not start hidden gameplay")
            var escape:=InputEventKey.new();escape.keycode=KEY_ESCAPE;escape.pressed=true
            root.push_input(escape,true)
            escape=escape.duplicate();escape.pressed=false;root.push_input(escape,true)
            await process_frame
            expect(not q.visible and not q.card.is_visible_in_tree() and not q.shade.is_visible_in_tree(),"Escape removes the whole modal")
            expect(get_root().gui_get_focus_owner()!=q.seed_input.get_line_edit(),"Hidden input releases focus")
            expect(var_to_bytes([game.mode,game.run_time,game.rng.state,game.profile])==state,"Closure preserves game and RNG")
        game.qa_ui.start_button.pressed.emit()
        expect(game.recorder.enabled,"Explicit opt-in via control signal")
        game.start_run(0);game.qa_ui.refresh()
        expect(not game.qa_ui.panel.visible,"Toolbar does not occupy gameplay input")
        game._toggle_pause();game.qa_ui.refresh()
        expect(game.qa_ui.panel.visible,"Controls available when paused")
        var time:=game.run_time
        game.qa_ui.marker_button.pressed.emit();game._process(0.25)
        expect(game.run_time==time,"Sync marker and recorder preserve pause")
        game.qa_ui.export_button.pressed.emit()
        expect(not game.recorder.enabled,"User export stops recording")
        expect(FileAccess.file_exists("user://qa-session-export.zip"),"Native export created separately from profile")
        game.qa_ui.discard_button.pressed.emit()
        expect(game.recorder.lines.is_empty() and not game.recorder.enabled,"Explicit clear resets only observer")
    var save_after:=FileAccess.get_file_as_bytes("user://profile_v2.json") if FileAccess.file_exists("user://profile_v2.json") else PackedByteArray()
    expect(save_before==save_after,"Actual review scene never changes persistent profile bytes")
    game.queue_free()
    if failures.is_empty():print("PASS: UI controls, native export, pause/input behavior and bounds at 1600x900 / 844x390 (headless layout, not visual approval)");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
