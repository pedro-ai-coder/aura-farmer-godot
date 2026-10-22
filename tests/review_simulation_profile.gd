extends SceneTree

## Controlled full-simulation CPU workload; never a balance or rendered-FPS claim.
class ProfileRun extends "res://scripts/solo_run.gd":
    var timings: Dictionary = {}
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass
    func _deal_damage_to_player(_amount: float, _source: Dictionary = {}, _contact: bool = false, _hazard: bool = false) -> void: pass
    func _gain_xp(_amount: float) -> void: pass
    func _advance(dt: float) -> void:
        var start := Time.get_ticks_usec()
        super._advance(dt)
        timings["simulation_us"] = int(timings.get("simulation_us",0))+Time.get_ticks_usec()-start
    func _step_enemies(dt: float) -> void:
        var start := Time.get_ticks_usec()
        super._step_enemies(dt)
        timings["enemy_ai_us"] = Time.get_ticks_usec()-start
    func _step_player_shots(dt: float) -> void:
        var start := Time.get_ticks_usec()
        super._step_player_shots(dt)
        timings["projectiles_us"] = Time.get_ticks_usec()-start
    func _step_weapon_areas() -> void:
        var start := Time.get_ticks_usec()
        super._step_weapon_areas()
        timings["weapon_areas_us"] = int(timings.get("weapon_areas_us",0))+Time.get_ticks_usec()-start
    func _collect_drops() -> void:
        var start := Time.get_ticks_usec()
        super._collect_drops()
        timings["pickups_us"] = Time.get_ticks_usec()-start
    func _draw() -> void:
        var start := Time.get_ticks_usec()
        super._draw()
        timings["draw_submission_us"] = Time.get_ticks_usec()-start

func _initialize() -> void: call_deferred("_measure")
func summary(values: Array) -> Dictionary:
    var ordered := values.duplicate()
    ordered.sort()
    var total := 0.0
    for value in ordered: total += float(value)
    return {"mean_us":total/ordered.size(),"p50_us":ordered[int(ordered.size()*0.5)],"p95_us":ordered[int(ordered.size()*0.95)],"p99_us":ordered[int(ordered.size()*0.99)]}
func _measure() -> void:
    root.size = Vector2i(1280,720)
    var rendered := DisplayServer.get_name() != "headless"
    var game := ProfileRun.new()
    root.add_child(game)
    game.set_process(false)
    var results: Array = []
    for fixture in [[30,15],[100,50],[300,150]]:
        game.start_run(0)
        game.spawn_timer = INF
        game.event_index = 4
        for i in range(fixture[0]):
            var angle := i*2.399963
            game._spawn_enemy(["npc","hater","reply-goblin","beta"][i%4],{"pos":Vector2(750,610)+Vector2(cos(angle)*330,sin(angle)*190)*(0.3+0.7*sqrt(float(i)/fixture[0]))})
            game.enemies.back()["hp"] = 1e9
            game.enemies.back()["max"] = 1e9
        for i in range(200): game.pickups.append({"kind":"aura","xp":5.0,"pos":Vector2(900+i%20*3,750+i/20*3)})
        var samples: Dictionary = {}
        var long_frames := 0
        var rendered_long_frames := 0
        var cold_draw_max := 0
        var cold_frame_max := 0
        var counts: Dictionary = {"enemies":[],"projectiles":[],"effects":[],"pickups":[],"player_projectiles":[],"hostile_projectiles":[]}
        var previous := Time.get_ticks_usec()
        for frame in range(240):
            while game.player_shots.size() < int(fixture[1]): game._queue_player_shot("ratio-blaster",Vector2.from_angle(game.player_shots.size()*2.4+game.run_time),0.01,500,1)
            game.touch_direction = Vector2.from_angle(game.run_time*0.3)
            game.timings.clear()
            var start := Time.get_ticks_usec()
            game._process(1.0/60.0)
            game.timings["process_cpu_us"] = Time.get_ticks_usec()-start
            var refill_start := Time.get_ticks_usec()
            while game.player_shots.size() < int(fixture[1]): game._queue_player_shot("ratio-blaster",Vector2.from_angle(game.player_shots.size()*2.4+game.run_time),0.01,500,1)
            game.timings["fixture_refill_us"] = Time.get_ticks_usec()-refill_start
            if rendered:
                await process_frame
                await RenderingServer.frame_post_draw
                var now := Time.get_ticks_usec()
                game.timings["frame_interval_us"] = now-previous
                previous = now
            if frame < 40:
                cold_draw_max = maxi(cold_draw_max,int(game.timings.get("draw_submission_us",0)))
                cold_frame_max = maxi(cold_frame_max,int(game.timings.get("frame_interval_us",0)))
            if frame >= 40:
                counts["enemies"].append(game.enemies.size())
                counts["player_projectiles"].append(game.player_shots.size())
                counts["hostile_projectiles"].append(game.hostile_shots.size())
                counts["projectiles"].append(game.player_shots.size()+game.hostile_shots.size())
                counts["effects"].append(game.attack_visuals.size()+game.weapon_areas.size()+game.hazard_zones.size())
                counts["pickups"].append(game.pickups.size())
                for key in game.timings:
                    if not samples.has(key): samples[key] = []
                    samples[key].append(game.timings[key])
                if int(game.timings["simulation_us"])>33333: long_frames += 1
                if int(game.timings.get("frame_interval_us",0))>33333: rendered_long_frames += 1
        var metrics: Dictionary = {}
        for key in samples: metrics[key] = summary(samples[key])
        var count_ranges: Dictionary = {}
        for key in counts: count_ranges[key] = {"min":counts[key].min(),"max":counts[key].max()}
        results.append({"count_ranges":count_ranges,"cold_draw_max_us":cold_draw_max,"cold_frame_max_us":cold_frame_max,"rendered_over_33ms":rendered_long_frames,"nominal_enemies":fixture[0],"nominal_projectiles":fixture[1],"final_enemies":game.enemies.size(),"final_projectiles":game.player_shots.size(),"final_effects":game.attack_visuals.size()+game.weapon_areas.size()+game.hazard_zones.size(),"final_pickups":game.pickups.size(),"simulation_over_33ms":long_frames,"samples":200,"metrics":metrics})
    var report := {"engine":Engine.get_version_info()["string"],"cpu":OS.get_processor_name() if FileAccess.file_exists("/proc/cpuinfo") else "unavailable in sandbox","display":DisplayServer.get_name(),"viewport":[1280,720],"rendered":rendered,"scope":"controlled full-simulation workload; damage/XP isolated; no physical device or balance acceptance","results":results}
    print("SIMULATION PROFILE ",JSON.stringify(report))
    var args := OS.get_cmdline_user_args()
    if args.size()>0:
        var file := FileAccess.open(args[0],FileAccess.WRITE)
        file.store_string(JSON.stringify(report,"  "))
    game.queue_free()
    quit()
