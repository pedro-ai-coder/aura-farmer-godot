extends "res://tests/no_u/test_counter_pulse.gd"
## V2 gameplay / V3 presentation contracts use the real incoming/outgoing resolvers, hazards and legal equipment.
const ReverseScenario := preload("res://scripts/review/no_u_reverse_scenario.gd")
class HistoricalRenderer extends "res://scripts/vfx/no_u_reverse_impact.gd":
    func classify(_hits: Array[Dictionary], _survivors: Array[Dictionary]) -> void:
        pass

var recurse := false
var assertions := 0

func check(value: bool, description: String) -> void:
    assertions += 1
    super.check(value, description)

func v2(game: ReviewRun, map: StringName = Maps.RUIN_ALLEY) -> void:
    game._return_to_menu()
    game.open_map_select(0)
    game.no_u_review = ReverseScenario.new(1, true)
    game.start_selected_map(map)
    game.enemies.clear()
    game.next_enemy_id = 1
    game.spawn_timer = INF
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(90, 0)})
    game._spawn_enemy("beta", {"pos": game.player_pos + Vector2(-80, 0), "elite": true})
    game._spawn_enemy("mod-supremo", {"pos": game.player_pos + Vector2(0, 100)})
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(0, -90), "telegraph": true})
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(200.01, 0)})
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(200, 0)})
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(80, 80)})
    game.enemies[1].shield = 1000.0
    game.enemies[-1].hp = 1.0
    game.hp = game.max_hp
    game.shield = 0.0
    events.clear()

func run() -> void:
    var game := ReviewRun.new()
    var twin := ReviewRun.new()
    for item: ReviewRun in [game, twin]:
        root.add_child(item)
        item.set_process(false)
    check(game.map_select.no_u_treatment == 3, "V4 picker default")
    game.no_u_resolved.connect(observe)
    for map: StringName in Maps.NAMES:
        v2(game, map)
        check(game.no_u_vfx.get_script().resource_path.ends_with("no_u_reverse_impact_v4.gd"), "V4 default renderer")
        check("Survive HP loss" in game.PassiveFeedbackScript.describe(game,"no-u",1), "Reactive inspection text")
        check("Survive HP loss" in game.PassiveFeedbackScript.brief("no-u",1,game), "Reactive acquisition notice")
        check("V4" in game.no_u_review.status_label(game), "V4 readiness identity")
        check(game.passive_timers.no_u_next == 0.0, "Acquisition must start ready")
        game._deal_damage_to_player(0.0)
        game._deal_damage_to_player(-10.0)
        check(events.is_empty() and game.hp == game.max_hp, "Nonpositive damage triggered V2")
        game.run_time = 20.0
        game._tick_passives(STEP)
        check(events.is_empty(), "V2 must not fire periodically")
        v2(game, map)
        game.shield = 100.0
        game._deal_damage_to_player(10.0, game.enemies[0])
        check(events.is_empty() and game.hp == game.max_hp and game.passive_timers.no_u_next == 0.0,
            "Fully absorbed hit activated or consumed cooldown")
        game.shield = 5.0
        game._deal_damage_to_player(10.0, game.enemies[0])
        check(events.size() == 1 and game.hp == game.max_hp - 5.0 and game.passive_timers.no_u_next == 15.0,
            "Partial absorption must resolve HP first, then activate")
        if events.size() == 1:
            var hit_ids: Array = events[0].hits.map(func(hit): return hit.id)
            check(hit_ids == [1, 3, 6, 7], "Shield/future/lethal/radius effective HP recipients changed")
            check(events[0].weakened.keys() == [1,2,3,4,6], "Weaken eligibility changed")
            check(events[0].weakened[1] == [0.2, 4.0] and events[0].weakened[3] == [0.1, 2.0], "Weaken values")
        check(game.no_u_vfx._lethal.keys() == [7], "Lethal feedback must identify only removed HP recipients")
        check(game.no_u_vfx._contacts.size() == 4 and not game.enemies[1].pos in game.no_u_vfx._contacts,
            "Shield-only enemy received damage accents")
        var renderer: RefCounted = game.no_u_vfx
        check(not renderer.has_weaken_marker(game.enemies[3], 0.0)
            and renderer.has_weaken_marker(game.enemies[3], float(game.enemies[3].born)), "Future-born discrepancy was changed")
        for spec in [[1.999, 2, 9.0], [2.0, 2, 10.0], [3.999, 0, 8.0], [4.0, 0, 10.0]]:
            game.run_time = spec[0]
            game.hp = game.max_hp
            game._deal_damage_to_player(10.0, game.enemies[spec[1]])
            check(is_equal_approx(game.max_hp-game.hp, spec[2]), "Outgoing weaken expiry boundary")
        game.run_time = 14.999
        game._deal_damage_to_player(1.0)
        check(events.size() == 1, "Cooldown fired early")
        game.run_time = 15.0
        game._deal_damage_to_player(1.0)
        check(events.size() == 2 and game.passive_timers.no_u_next == 30.0, "Cooldown readiness boundary")
        game._deal_damage_to_player(1.0)
        check(events.size() == 2, "Simultaneous hit duplicated activation")
        game._toggle_pause()
        game._process(0.25)
        check(game.run_time == 15.0, "Pause changed active cooldown")
        game._toggle_pause()
        v2(game, map)
        game.no_u_resolved.connect(func(_c, _r, _t, _h, _w):
            if recurse:
                game.passive_timers.no_u_next = 0.0 # deliberately bypass cooldown to exercise recursion guard
                game._deal_damage_to_player(1.0))
        recurse = true
        game._deal_damage_to_player(1.0)
        recurse = false
        check(events.size() == 1 and not game.no_u_review.resolving, "Recursive damage produced another pulse")
        v2(game, map)
        game.hp = 1.0
        game._deal_damage_to_player(1000.0, game.enemies[0])
        check(events.is_empty() and game.mode == "lost" and game.hp == 0.0 and game.passive_timers.no_u_next == 0.0,
            "Fatal hit activated or prevented defeat")
        game.start_run(0)
        check(game.no_u_vfx._at == -INF and game.passive_timers.no_u_next == 0.0, "Retry retained stale state")
        v2(game, map)
        game._schedule_hazard(game.player_pos, 50.0, 0.0, 2.0, 10.0)
        game._step_hazards()
        check(events.size() == 1, "Source-less environmental hazard must meet experimental HP-loss rule")
        v2(game, map)
        game.enemies.clear()
        game._spawn_enemy("hater", {"pos": game.player_pos + Vector2(10, 0)})
        var attacker: Dictionary = game.enemies[-1]
        attacker.hp = 1.0
        attacker.phase = "warning"
        attacker.attack_at = 0.0
        attacker.locked_direction = Vector2.RIGHT
        game._step_enemies(0.0)
        check(events.size() == 1 and game.hostile_shots.is_empty() and not game.enemies.has(attacker),
            "Attacker killed by retaliation emitted a posthumous attack")
        v2(game, map)
        game.enemies.clear()
        game._deal_damage_to_player(1.0)
        check(events.size() == 1 and events[0].hits.is_empty() and game.passive_timers.no_u_next == 15.0,
            "Eligible empty pulse must still start cooldown")
        v2(game, map)
        game.enemies.clear()
        game._spawn_enemy("boss", {"pos": game.player_pos + Vector2(100,0)})
        game.enemies[-1].hp = 1.0
        game._deal_damage_to_player(1.0)
        check(game.mode == "won" and game.no_u_vfx._contacts.size() == 1 and events.size() == 1,
            "Lethal outgoing feedback did not survive victory")
        for density in [1,2]:
            for item: ReviewRun in [game,twin]:
                item._return_to_menu()
                item.open_map_select(0)
                item.no_u_review = ReverseScenario.new(density,true)
                item.start_selected_map(map)
            twin.no_u_vfx = HistoricalRenderer.new()
            for frame in 1200:
                if frame % 120 == 60:
                    for item: ReviewRun in [game,twin]: item._deal_damage_to_player(1.0)
                game._process(STEP)
                twin._process(STEP)
                if state(game) != state(twin):
                    check(false,"V2 deterministic state diverged %s/%d/%d" % [map,density,frame])
                    break
                paired_frames += 1
    game._return_to_menu()
    check(game.no_u_review == null and game.no_u_vfx == null and game.profile_writes == 0
        and twin.profile_writes == 0, "Experiment leaked state/progression")
    game.free(); twin.free()
    print("Reverse Impact V4 / V2 parity: %d assertions, %d identical-input paired frames; failures: %d" % [assertions, paired_frames, failures])
    quit(1 if failures else 0)

