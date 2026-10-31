extends "res://tests/frame_pacing/measure.gd"
## Recorded against f6034fc before optimization. Full binary state snapshots
## include positions, collisions, projectiles, event order and seeded RNG.
const KEYS=["mode","player_pos","hp","max_hp","shield","aura","flex_time","flex_lock","flex_age","run_time","level","xp","total_xp","kills","wave","event_index","boss_spawned","terminals_destroyed","terminals_interrupt_until","spawn_timer","hurt_timer","attack_flash","attack_visuals","combat_feedback","pending_choices","selection","legendary_offers","weapons","passives","enemies","player_shots","weapon_areas","weapon_activations","chad_successful_activations","weapon_shields","hostile_shots","hazard_zones","pickups","passive_timers","primary_hits","directional_hits","cook_stacks","cook_expires","aura_hits_bucket","aura_hits_in_bucket","primary_aura_times","max_level_heal_at","sigma_target","next_enemy_id","hero_state","safe_spot_charge","safe_spot_ready_at","safe_spot_uses","recovery_counts","pickup_feedback","run_metrics"]
func expect(ok: bool,message: String) -> void:
    if not ok:failures.append(message)
func key(pressed: bool) -> void:
    var event:=InputEventKey.new();event.physical_keycode=KEY_D;event.keycode=KEY_D;event.pressed=pressed
    Input.parse_input_event(event)
    Input.flush_buffered_events()
func measure() -> void:
    var args:=OS.get_cmdline_user_args()
    var recording: bool=args.size()>0 and args[0]=="--record"
    var path: String=args[1] if recording else "res://tests/frame_pacing/baseline_states.json"
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    var hashes: Dictionary={}
    for fixture in ["normal","dense","flex"]:
        setup(game,fixture)
        var context:=HashingContext.new();context.start(HashingContext.HASH_SHA256)
        for frame in range(360):
            game.touch_direction=Vector2(1 if frame%24<12 else -1,1 if frame%48<24 else -1).normalized()
            if fixture=="flex" and frame==30:game._use_flex()
            game._process([1.0/60.0,1.0/30.0,0.075,1.0/120.0,0.25,0.001][frame%6])
            var state: Array=[game.rng.state,game.camera.position]
            for key in KEYS:state.append(game.get(key))
            context.update(var_to_bytes(state))
        hashes[fixture]=context.finish().hex_encode()
    # Canonical displacement under irregular frames, touch and real keyboard
    # action state, with a release/reversal and a pause/resume in the trace.
    for hero_id in range(3):
        for keyboard in [false,true]:
            game.start_run(hero_id);game.player_pos=Vector2(724,600)
            game.enemies.clear();game.weapons.clear();game.spawn_timer=INF
            var origin: Vector2=game.player_pos;var elapsed:=0.0
            for dt in [0.008,0.033,0.075,0.016,0.12,0.004,0.25]:
                if keyboard:key(true)
                else:game.touch_direction=Vector2.RIGHT
                game._process(dt);elapsed+=dt
            key(false);game.touch_direction=Vector2.ZERO
            expect(absf((game.player_pos-origin).x-float(game.hero.speed)*elapsed)<0.001,"Canonical irregular-frame displacement for hero %d keyboard=%s got=%.6f expected=%.6f" % [hero_id,keyboard,(game.player_pos-origin).x,float(game.hero.speed)*elapsed])
            var stopped: Vector2=game.player_pos;game._process(0.075)
            expect(game.player_pos==stopped,"Release affects the next simulation frame")
            var time_before: float=game.run_time;game._toggle_pause();game._process(0.2)
            expect(game.run_time==time_before and game.player_pos==stopped,"Paused wall time never advances simulation")
            game._toggle_pause();game.touch_direction=Vector2.LEFT;game._process(0.033)
            expect(game.player_pos.x<stopped.x,"Direction reversal responds on the first resumed frame")
    if recording:
        var file:=FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify(hashes,"  "));file.close()
    else:
        var expected: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
        expect(hashes==expected,"Irregular-frame state/RNG/event/camera hashes equal the pre-optimization baseline")
    game.queue_free()
    if failures.is_empty():print("PASS: Irregular-frame state hashes, canonical hero displacement, keyboard/touch, release/reversal and pause/resume ",hashes);quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
