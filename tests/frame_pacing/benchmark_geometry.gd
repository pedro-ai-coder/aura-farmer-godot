extends SceneTree
const Before=preload("res://tests/frame_pacing/baseline_world.gd")
const After=preload("res://scripts/solo_world_rules.gd")
const Probe=preload("res://scripts/performance_probe.gd")
func _initialize() -> void:
    var rng:=RandomNumberGenerator.new();rng.seed=724540
    var points:=PackedVector2Array();var deltas:=PackedVector2Array()
    while points.size()<4096:
        var point:=Vector2(rng.randf_range(180,1310),rng.randf_range(300,980))
        if Before.walkable(point,24):
            points.append(point);deltas.append(Vector2(rng.randf_range(-3,3),rng.randf_range(-3,3)))
    var before:=PackedFloat64Array();var after:=PackedFloat64Array();var checksum:=Vector2.ZERO
    for trial in range(10):
        for version in ([Before,After] if trial%2==0 else [After,Before]):
            var start:=Time.get_ticks_usec()
            for iteration in range(8):
                for i in range(points.size()):checksum+=version.move(points[i],deltas[i],24)
            var elapsed:=Time.get_ticks_usec()-start
            if version==Before:before.append(elapsed/1000.0)
            else:after.append(elapsed/1000.0)
    var report={"source":"headless paired CPU benchmark, not rendered FPS","calls_per_trial":32768,"trials":10,"order":"alternating before/after","seed":724540,"radius":24,"before_ms":Probe.distribution(before),"after_ms":Probe.distribution(after),"before_samples_ms":Array(before),"after_samples_ms":Array(after),"checksum":str(checksum)}
    if OS.get_cmdline_user_args().size():
        var f:=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close()
    print(JSON.stringify(report));quit()
