extends SceneTree
const Probe=preload("res://scripts/performance_probe.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var failures: Array[String]=[]
func expect(ok: bool,message: String) -> void:
    if not ok:failures.append(message)
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.start_run(0)
    var rng_before: int=game.rng.state
    var point: Vector2=game.player_pos
    var probe=Probe.new(game,"unit")
    expect(Probe.distribution(PackedFloat64Array()).p95==null,"Unavailable observations remain null")
    var known:=Probe.distribution(PackedFloat64Array([4,1,3,2]))
    expect(known.median==2.5 and known.p95==4,"Quantiles use the documented nearest-rank method")
    for i in range(Probe.CAPACITY+7):
        probe.begin_frame(0.016)
        probe.add(&"hud",i)
        probe.substep()
        probe._commit(false)
    var report: Dictionary=probe.report()
    expect(report.sample_count==3600 and report.total_frames_seen==3607,"Rolling buffer is bounded")
    expect(report.samples.hud_us[0]==7 and report.samples.hud_us[-1]==3606,"Ring wraps in chronological order and clears reused slots")
    expect(report.metrics.substeps.max==1,"Reused substep slots do not accumulate")
    expect(report.delivered_render_fps==null and report.metrics.render_gpu_ms.p95==null,"Headless CPU is never reported as rendered FPS/GPU time")
    expect(report.metrics.input_to_move_ms.samples==0,"Missing input latency is excluded, not reported as -1ms")
    expect(report.metrics.navigation_us.samples==0,"Disabled per-actor instrumentation is unavailable, not 0us")
    probe.begin_frame(0.016);probe.input_received(Vector2.RIGHT)
    probe.movement_applied(point,point+Vector2.RIGHT)
    probe._commit(false)
    report=probe.report()
    expect(report.metrics.input_to_move_ms.samples==1,"One answered owner input yields one latency observation")
    expect(report.metrics.input_to_render_ms.samples==0,"Headless input cannot claim presentation latency")
    expect(game.rng.state==rng_before and game.player_pos==point,"Instrumentation mutates neither gameplay RNG nor movement")
    probe.close();game.queue_free()
    if failures.is_empty():print("PASS: Bounded probe, chronological ring, missing data, quantiles, input timing and RNG isolation");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
