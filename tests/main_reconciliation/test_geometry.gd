extends SceneTree
const Before=preload("res://tests/main_reconciliation/baseline_world.gd")
const After=preload("res://scripts/solo_world_rules.gd")
var failures:=0
var comparisons:=0
func compare(point: Vector2,radius: float,delta: Vector2) -> void:
    comparisons+=3
    if Before.in_floor(point,radius)!=After.in_floor(point,radius) or Before.walkable(point,radius)!=After.walkable(point,radius) or Before.move(point,delta,radius)!=After.move(point,delta,radius):
        if failures<5:push_error("Collision mismatch at %s radius %.8f delta %s" % [point,radius,delta])
        failures+=1
func _initialize() -> void:
    var rng:=RandomNumberGenerator.new();rng.seed=724540
    var radii=[0.0,0.00001,0.5,1.0,12.0,15.0,16.0,17.0,19.0,24.0,48.0,57.6]
    for i in range(10000):
        var point:=Vector2(rng.randf_range(100,1400),rng.randf_range(250,1050))
        var delta:=Vector2(rng.randf_range(-40,40),rng.randf_range(-40,40))
        if i%3==0:delta.x=0
        if i%5==0:delta.y=0
        for radius in radii:compare(point,radius,delta)
    # Explicit edge/tangent probes supplement random interior/exterior points.
    for i in range(Before.FLOOR.size()):
        var a: Vector2=Before.FLOOR[i];var b: Vector2=Before.FLOOR[(i+1)%Before.FLOOR.size()]
        var normal: Vector2=(b-a).orthogonal().normalized()
        for radius in radii:
            for t in [0.0,0.25,0.5,0.75,1.0]:
                for epsilon in [-0.001,0.0,0.001]:
                    compare(a.lerp(b,t)+normal*(radius+epsilon),radius,Vector2(0,4))
                    compare(a.lerp(b,t)-normal*(radius+epsilon),radius,Vector2(4,0))
    for cover in Before.COVERS:
        for radius in radii:
            for i in range(72):
                var angle:=float(i)*TAU/72
                for epsilon in [-0.001,0.0,0.001]:compare(cover.pos+Vector2.from_angle(angle)*(cover.radius+radius+epsilon),radius,Vector2(3,3))
    if failures==0:print("PASS: ",comparisons," differential floor/cover/axis collision comparisons against main bc690618");quit()
    else:push_error(str(failures)+" geometry differences");quit(1)
