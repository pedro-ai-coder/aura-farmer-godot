extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func verify() -> void:
    root.size = Vector2i(1280,720)
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    game.start_run(1)
    game.run_time = 123
    game.kills = 17
    game._toggle_pause()
    var ui = game.presentation
    check(ui.secondary.pause_panel.is_visible_in_tree() and not ui.body_scroll.visible,"Pause is one compact navigation shell")
    ui.secondary.settings.emit_signal("pressed")
    check(game.mode == "options" and not game.import_button.visible,"In-run settings cannot silently import/abandon the active run")
    ui.volume_slider.value = 37
    check(is_equal_approx(game.profile["settings"]["masterVolume"],0.37),"Master volume controls the actual persistent preference")
    game._advance(1)
    check(game.run_time == 123,"Settings freezes the simulation clock")
    ui.back_button.emit_signal("pressed")
    check(game.mode == "paused","Settings Back returns to pause")
    ui.secondary.build.emit_signal("pressed")
    check(game.mode == "build" and ui.equipment_board.visible and ui.equipment_slots.size() == 8,"Build is an actual three-plus-five inspection destination")
    ui.back_button.emit_signal("pressed")
    ui.secondary.quit_run.emit_signal("pressed")
    check(game.mode == "confirm_exit" and game.restart_button.text == "STAY","Quit has explicit STAY action")
    game.restart_button.emit_signal("pressed")
    check(game.mode == "paused" and game.run_time == 123,"STAY returns to pause without resuming combat")
    ui.secondary.resume.emit_signal("pressed")
    check(game.mode == "playing","Resume uses the existing run state")
    game._finish(false)
    check(ui.secondary.result_title.text == "RUN OVER","Defeat cannot display victory title")
    check(ui.secondary.result_stats.text.contains("02:03") and ui.secondary.result_stats.text.contains("17"),"Results use actual time/kills")
    for viewport in [Vector2i(1280,720),Vector2i(915,412),Vector2i(640,360),Vector2i(390,844)]:
        root.size = viewport
        ui._window_changed(true)
        await process_frame
        await process_frame
        var bounds := Rect2(ui.position,ui.view).grow(1)
        check(bounds.encloses(game.retry_button.get_global_rect()),"Replay remains in bounds at %s" % viewport)
        game.start_run(0)
        game._toggle_pause()
        await process_frame
        await process_frame
        check(bounds.encloses(ui.secondary.pause_panel.get_global_rect()),"Compact pause remains in bounds at %s" % viewport)
        game.mode = "playing"
        game._finish(false)
    game.retry_button.emit_signal("pressed")
    check(game.mode == "playing" and game.run_time == 0,"Replay resets only run-scoped state")
    game.queue_free()
    if failures.is_empty(): print("PASS: Compact pause/build/settings/quit/results and responsive replay"); quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
