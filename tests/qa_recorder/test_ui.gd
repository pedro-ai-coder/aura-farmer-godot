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
    for size in [Vector2i(1600,900),Vector2i(844,390)]:
        root.size=size;game._return_to_menu();game.qa_ui.refresh()
        await process_frame
        expect(game.qa_ui.panel.visible,"QA controls reachable in menu")
        expect(game.qa_ui.panel.position.x+game.qa_ui.panel.size.x<=size.x,"QA toolbar fits "+str(size))
        expect(game.qa_ui.status.mouse_filter==Control.MOUSE_FILTER_IGNORE,"Status cannot steal input")
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
