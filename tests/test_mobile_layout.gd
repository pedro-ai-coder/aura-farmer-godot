extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("_verify")
func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var ui = game.presentation
    for physical in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(915,412),Vector2i(844,390),Vector2i(640,360),Vector2i(390,844)]:
        root.size = physical
        ui._window_changed(true)
        game.touch_device = physical.x < 1000
        for state in ["menu","options","playing","legendary","paused","build","won","lost","profile_import"]:
            game.start_run(0)
            if state == "menu": game._return_to_menu()
            elif state == "legendary":
                game.run_time = 360.0
                game._open_legendary()
                game.pick_upgrade(4)
            else: game.mode = state
            game._show_ui()
            await process_frame
            await process_frame
            var bounds: Rect2 = Rect2(ui.position,ui.view).grow(0.5)
            var buttons: Array = [ui.play_button,ui.options_button,ui.back_button,game.confirm_button,game.defer_button,game.pause_button,game.flex_button,game.restart_button,game.retry_button]
            for button: Button in buttons:
                if not button.is_visible_in_tree(): continue
                _expect(bounds.encloses(button.get_global_rect()),"Essential actions remain inside useful viewport: %s %s %s" % [physical,state,button.text])
                var scale: float = float(physical.y)/ui.full_view.y
                _expect(button.size.y*scale >= 44.0-0.5,"Touch targets remain at least 44 physical pixels")
            if state == "build":
                _expect(not game.build_details.visible and ui.equipment_board.visible,"Pause uses equipment slots rather than text rows")
                _expect(ui.equipment_slots.size() == 8,"Pause preserves three weapon and five passive slots")
                _expect(ui.body_content.size.y >= ui.equipment_board.size.y,"Every equipment slot is reachable inside the scroll panel")
                for slot: Dictionary in ui.equipment_slots:
                    _expect(Rect2(Vector2.ZERO,ui.equipment_board.size).encloses(slot["panel"].get_rect()),"Equipment slots fit inside their board")
                var equipped: Dictionary = ui.equipment_slots[0]
                var visible_text: String = equipped["label"].text + ("\n" + equipped["meta"].text if equipped["meta"].is_visible_in_tree() else "")
                _expect(visible_text.contains("LV 1"),"Equipped weapon shows its actual level in visible name/details labels")
                _expect(ui.equipment_slots[2]["label"].text.contains("EMPTY WEAPON"),"Unused weapon slot remains visible")
                _expect(ui.equipment_slots[7]["label"].text.contains("EMPTY PASSIVE"),"Unused passive slot remains visible")
            if state == "playing":
                # Production uses the approved Clean Cut status and progression modules;
                # the hidden legacy bar rectangles are no longer player-visible.
                var clean_cut: Control = game.clean_cut_skin
                _expect(clean_cut != null and clean_cut.visible, "Clean Cut combat HUD is active")
                if clean_cut != null:
                    for bar: Control in [clean_cut.player_plate,clean_cut.xp_frame,clean_cut.wave_frame]:
                        _expect(not bar.get_global_rect().intersects(game.pause_button.get_global_rect()),"Pause cannot obscure visible Clean Cut HP, XP or wave status")
            if state == "legendary": _expect(game.selected_card_index == 4 and ui.card_parts[4]["state"].text.contains("SELECTED"),"Resize/layout preserves selected legendary")
    game.web_metrics = {"safe":[44,20,16,12],"width":390,"height":844}
    root.size = Vector2i(390,844)
    ui._window_changed(true)
    _expect(ui.position.x > 44 and ui.position.y > 20,"Safe areas convert from CSS to logical coordinates")
    game.start_run(0)
    var before: Vector2 = game.camera.zoom
    game.touch_device = true
    game._update_camera(0.0,true)
    before = game.camera.zoom
    game._clear_touch()
    game._update_camera(0.0,true)
    _expect(game.camera.zoom == before,"Releasing the joystick cannot change camera framing")
    game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
    _expect(game.mode == "paused" and not game.touch_active,"Focus loss pauses and releases movement")
    game.queue_free()
    if failures.is_empty(): print("PASS: Six viewport UI bounds, touch targets, safe areas, selection, stable camera and focus pause"); quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
