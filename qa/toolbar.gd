extends CanvasLayer
## Non-modal controls appear only outside active gameplay. No input remapping.
var game
var panel: HBoxContainer
var status: Label
var start_button: Button
var export_button: Button
var marker_button: Button
var discard_button: Button
var refresh_in := 0.0
var message := ""
func button(text: String, action: Callable) -> Button:
    var item:=Button.new();item.text=text;item.custom_minimum_size=Vector2(0,44)
    item.focus_mode=Control.FOCUS_NONE;item.pressed.connect(action);panel.add_child(item);return item
func install(owner_game) -> void:
    game=owner_game;layer=100
    panel=HBoxContainer.new();panel.position=Vector2(8,8);add_child(panel)
    start_button=button("Start QA",start)
    marker_button=button("Sync mark",mark)
    export_button=button("Stop + export",export_session)
    discard_button=button("Clear",clear_session)
    status=Label.new();status.mouse_filter=Control.MOUSE_FILTER_IGNORE
    status.add_theme_color_override("font_color",Color.WHITE)
    status.add_theme_color_override("font_shadow_color",Color.BLACK)
    status.add_theme_constant_override("shadow_offset_x",1);status.add_theme_constant_override("shadow_offset_y",1)
    status.add_theme_font_size_override("font_size",13);add_child(status)
    refresh()
func start() -> void:
    if not game.recorder.lines.is_empty():return
    game.recorder.start(game,game.qa_build());game.recorder.mark(game)
    message="";refresh()
func mark() -> void:game.recorder.mark(game);refresh()
func clear_session() -> void:
    # Only after export/stop. Explicit action; never deletes a downloaded file.
    if game.recorder.enabled:return
    game.recorder=game.Recorder.new();message="";refresh()
func export_session() -> void:
    game.recorder.stop(game)
    var path:="user://qa-session-export.zip"
    var error: Error=game.recorder.export_zip(path,FileAccess.get_file_as_string("res://qa/README.md"))
    if error!=OK:message="Export failed (%d); data retained. Retry." % error;refresh();return
    if OS.has_feature("web"):
        JavaScriptBridge.download_buffer(FileAccess.get_file_as_bytes(path),"clutchpunks-qa-session.zip","application/zip")
        DirAccess.remove_absolute(path)
        message="ZIP requested; allow browser downloads. Data retained for retry."
    else:message="Saved: "+ProjectSettings.globalize_path(path)
    refresh()
func _process(delta: float) -> void:
    refresh_in-=delta
    if refresh_in<=0:refresh_in=0.25;refresh()
func refresh() -> void:
    if game==null:return
    var recorder=game.recorder
    panel.visible=game.mode in ["menu","heroes","paused","lost","won"]
    start_button.disabled=recorder.enabled or not recorder.lines.is_empty()
    export_button.disabled=recorder.lines.is_empty()
    marker_button.disabled=not recorder.enabled
    discard_button.disabled=recorder.enabled or recorder.lines.is_empty()
    status.position=Vector2(8,game.get_viewport_rect().size.y-22)
    var seconds: float=recorder.now_ms()/1000.0 if recorder.enabled else recorder.stopped_ms/1000.0
    status.text="QA %s | %06.1fs | MARK %d%s" % ["REC" if recorder.enabled else "FULL — EXPORT" if recorder.full else "OFF",seconds,recorder.marker," | "+message if panel.visible and not message.is_empty() else ""]

    if OS.has_feature("web"):
        # Read-only diagnostics for repeatable browser QA; no command/state injector.
        var controls: Dictionary={}
        if panel.visible:
            for entry in [["start",start_button],["mark",marker_button],["export",export_button],["clear",discard_button]]:
                var rect: Rect2=entry[1].get_global_rect()
                controls[entry[0]]=[rect.position.x,rect.position.y,rect.size.x,rect.size.y]
        JavaScriptBridge.eval("window.__qaReviewState="+JSON.stringify({"mode":game.mode,"recording":recorder.enabled,"controls":controls,"view":[game.get_viewport_rect().size.x,game.get_viewport_rect().size.y],"active_s":game.run_time,"label":status.text}),true)
