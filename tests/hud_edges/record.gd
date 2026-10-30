extends SceneTree
## Actual native gameplay, scripted keyboard routing and real pause/resume.
## Never saves a player profile; the external movie is not a frame-rate benchmark.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("record")
func key(code: int,pressed: bool) -> void:
    var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=pressed
    Input.parse_input_event(event);Input.flush_buffered_events()
func record() -> void:
    if DisplayServer.get_name()=="headless":push_error("A rendering display is required");quit(1);return
    var output: String=OS.get_cmdline_user_args()[0]
    root.size=Vector2i(1280,720);root.position=Vector2i.ZERO;Engine.max_fps=60
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.start_run(0);game.touch_device=false
    for at in [Vector2(960,610),Vector2(1080,700),Vector2(630,740)]:game._spawn_enemy("npc",{"pos":at})
    game.presentation._window_changed(true)
    await process_frame;await RenderingServer.frame_post_draw
    var ready:=FileAccess.open(output.path_join("ready"),FileAccess.WRITE);ready.store_string("ready");ready.close()
    var deadline:=Time.get_ticks_msec()+10000
    while not FileAccess.file_exists(output.path_join("capturing")):
        if Time.get_ticks_msec()>deadline:push_error("No screen recorder");quit(1);return
        await process_frame
    game.set_process(true)
    var trace: Array=[]
    for segment in [{"key":KEY_D,"seconds":1.4},{"key":KEY_A,"seconds":1.4},{"key":KEY_W,"seconds":1.1},{"key":KEY_S,"seconds":1.1},{"key":0,"seconds":0.4}]:
        if segment.key:key(segment.key,true)
        await create_timer(segment.seconds).timeout
        if segment.key:key(segment.key,false)
        trace.append({"mode":game.mode,"simulation_time":game.run_time,"position":str(game.player_pos),"hp":game.hp,"aura":game.aura})
    game._toggle_pause();var paused_time: float=game.run_time
    await create_timer(0.8).timeout
    if game.run_time!=paused_time:push_error("Pause advanced simulation");quit(1);return
    game._toggle_pause();await create_timer(0.8).timeout
    var report:=FileAccess.open(output.path_join("demo.json"),FileAccess.WRITE)
    report.store_string(JSON.stringify({"source":"Godot 4.7.2 Compatibility native software rendering","input":"Scripted real keyboard events; actual game _process and pause callbacks","not_human_or_browser_or_device_validation":true,"video_sampling_fps":30,"sampling_is_not_engine_fps":true,"trace":trace,"paused_simulation_time":paused_time,"final_simulation_time":game.run_time},"  "));report.close()
    game.queue_free();quit()
