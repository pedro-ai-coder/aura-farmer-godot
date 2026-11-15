extends SceneTree
const Study=preload("res://scripts/level_zero_environment_study.gd")
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    root.size=Vector2i(1280,720)
    var study:=Study.new();root.add_child(study);study.set_process(false)
    assert(study.walkable(study.player))
    assert(not study.walkable(Vector2(600,200)))
    assert(not study.walkable(Vector2(120,500)))
    for i in range(310):study.advance_presentation(1.0/60.0)
    assert(study.phase=="traversal" and study.walkable(study.player))
    var origin: Vector2=study.player
    study.player=study.move_feet(study.player,Vector2(6000,0))
    assert(study.walkable(study.player) and study.player.x<1453)
    study.player=origin
    var args:=OS.get_cmdline_user_args()
    if args.size()>0 and DisplayServer.get_name()!="headless":
        await process_frame;await process_frame;await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(args[0])
    assert(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/signal_breaker_garage.tscn")
    study.queue_free();await process_frame
    print("PASS: Separate Level Zero source-space navigation, no boundary tunnelling, rear-entry/camera/countdown/traversal study; operational Garage/Solo unchanged")
    quit()
