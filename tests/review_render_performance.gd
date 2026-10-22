extends SceneTree

# Stable render-load benchmark, not a survival fixture or a reference-device result.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func _initialize() -> void: call_deferred("_measure")
func _measure() -> void:
    var args := OS.get_cmdline_user_args()
    var width := int(args[0]) if args.size() > 0 else 1280
    var height := int(args[1]) if args.size() > 1 else 720
    root.size = Vector2i(width,height)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    Engine.max_fps = 0
    var game = ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.start_run(0)
    game.enemies.clear()
    for i in range(300):
        var angle := i*2.399963
        var point := Vector2(750,610)+Vector2(cos(angle)*340,sin(angle)*230)*(0.2+0.8*sqrt(float(i)/300))
        game._spawn_enemy(["npc","hater","reply-goblin","beta"][i%4],{"pos":point})
        game.enemies.back()["anim_moving"] = true
    for i in range(150):
        game.player_shots.append({"pos":Vector2(750,610)+Vector2.from_angle(i*TAU/150)*200,"direction":Vector2.from_angle(i*TAU/150),"radius":7.0,"id":"ratio-blaster","remaining":500.0,"damage":1.0,"pierce":1,"hit":[]})
    var intervals: Array[float] = []
    var previous := Time.get_ticks_usec()
    for frame in range(240):
        game.run_time += 1.0/60.0
        for enemy: Dictionary in game.enemies: enemy["anim_walk"] = frame/6.0
        game.queue_redraw()
        await process_frame
        await RenderingServer.frame_post_draw
        var now := Time.get_ticks_usec()
        if frame >= 40: intervals.append(float(now-previous)/1000)
        previous = now
    intervals.sort()
    var total := 0.0
    for value in intervals: total += value
    print("RENDER BENCHMARK ",JSON.stringify({"viewport":[width,height],"enemies":game.enemies.size(),"projectiles":game.player_shots.size(),"samples":intervals.size(),"mean_ms":total/intervals.size(),"p50_ms":intervals[intervals.size()/2],"p95_ms":intervals[int(intervals.size()*0.95)],"fps":1000.0/(total/intervals.size()),"scope":"render-only stable fixture, software OpenGL, no device acceptance"}))
    if args.size() > 2: root.get_texture().get_image().save_png(args[2].path_join("stress-%dx%d.png" % [width,height]))
    game.queue_free()
    quit()
