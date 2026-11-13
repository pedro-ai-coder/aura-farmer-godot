extends SceneTree
class Review extends "res://qa/review_run.gd":
    func _ready() -> void:qa_ui_enabled=false;super._ready()
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("measure")
func percentile(values: Array, q: float) -> float:
    var ordered:=values.duplicate();ordered.sort();return ordered[mini(ordered.size()-1,int(ordered.size()*q))]
func measure() -> void:
    var game:=Review.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    var result: Array=[]
    for repetition in range(3):
        for on in ([false,true] if repetition%2==0 else [true,false]):
            for dense in [false,true]:
                game.recorder.stop(game);game.start_run(2);game.rng.seed=451
                if on:game.recorder.start(game,{"commit":"benchmark"})
                # Controlled normal-health replay: no HP, damage or XP grants.
                # Dense fixture spawns legal normal enemies; it is not a normal run.
                if dense:
                    for i in range(90):game._spawn_enemy("npc",{"telegraph":true})
                var times: Array=[]
                for frame in range(180):
                    game.touch_direction=Vector2.from_angle(frame*0.04)
                    # Force 2 Hz at simulated 60 Hz while the runner is accelerated.
                    if on and frame%30==0:game.recorder.next_sample_us=0
                    var started:=Time.get_ticks_usec()
                    game._process(1.0/60.0)
                    times.append(Time.get_ticks_usec()-started)
                result.append({"recording":on,"dense":dense,"repetition":repetition,"mean_us":times.reduce(func(a,b):return a+b,0.0)/times.size(),"p50_us":percentile(times,0.50),"p95_us":percentile(times,0.95),"mode":game.mode,"end_time":game.run_time,"records":game.recorder.lines.size() if on else 0})
    DirAccess.make_dir_recursive_absolute("res://tests/qa_recorder/evidence")
    FileAccess.open("res://tests/qa_recorder/evidence/performance.json",FileAccess.WRITE).store_string(JSON.stringify({"method":"Paired, alternating off/on, three repetitions, 180 canonical 60 Hz steps, forced 2Hz observer sampling. Normal health. CPU simulation + instrumentation only; headless, not rendered FPS.","engine":Engine.get_version_info().string,"results":result},"  "))
    game.queue_free();print("PASS: paired observer performance measurements exported");quit()
