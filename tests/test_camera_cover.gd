extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("_verify")
func _expect(ok: bool, text: String) -> void:
    if not ok: failures.append(text)
func _verify() -> void:
    var framing = load("res://scripts/camera_framing.gd")
    for view in [Vector2(1280,720),Vector2(1920,1080),Vector2(2400,700),Vector2(915,412),Vector2(844,390),Vector2(390,844)]:
        for touch in [false,true]:
            var zoom_value: float = framing.zoom_for(view,touch)
            for target in [Vector2.ZERO,Vector2(1448,1086),Vector2(724,540),Vector2(234,448)]:
                var center: Vector2 = framing.clamp_center(target,view,zoom_value)
                var half: Vector2 = view / zoom_value / 2.0
                _expect(center.x-half.x >= -0.001 and center.y-half.y >= -0.001 and center.x+half.x <= 1448.001 and center.y+half.y <= 1086.001, "Camera view remains inside approved image at every edge and aspect ratio")
    var at60 := Vector2(300,250)
    var at10 := at60
    for i in range(60): at60 = framing.follow(at60,Vector2(900,610),1.0/60.0)
    for i in range(10): at10 = framing.follow(at10,Vector2(900,610),0.1)
    _expect(at60.distance_to(at10) < 0.001,"Camera smoothing is independent of frame rate")
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    var atlas: Texture2D = game.art.texture("enemies")
    var size := atlas.get_size()
    _expect(game.art.cover_region() == Rect2(roundf(size.x/2),roundf(size.y*0.75),floorf(size.x/4),floorf(size.y/4)), "Cover uses exact approved frame 14")
    var world = load("res://scripts/solo_world_rules.gd")
    _expect(world.COVERS[0]["pos"] == Vector2(600,550) and world.COVERS[1]["pos"] == Vector2(940,680), "Cover centers remain unchanged")
    _expect(not world.clear_line(Vector2(520,550),Vector2(680,550)),"Cover still blocks projectile sightlines")
    _expect(world.move(Vector2(550,550),Vector2(25,0)) == Vector2(550,550),"Cover still blocks actor movement")
    game.queue_free()
    if failures.is_empty(): print("PASS: Six viewport camera bounds, time-based follow and exact static-cover sprite/geometry"); quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
