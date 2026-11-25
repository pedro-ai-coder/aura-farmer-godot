extends SceneTree

const Maps := preload("res://scripts/solo_maps.gd")
const Scenario := preload("res://scripts/review/no_u_scenario.gd")
const CounterPulse := preload("res://scripts/vfx/no_u_counter_pulse.gd")
const Builds := preload("res://tests/passive_vfx_lab/scenario_builds.gd")
const STEP := 1.0 / 60.0

class ReviewRun extends "res://scripts/solo_run.gd":
    var profile_writes := 0

    func _load_profile() -> void:
        profile = ProfileStoreScript.defaults()
        profile.settings.sound = false

    func _save_profile() -> void:
        profile_writes += 1

var failures := 0
var events: Array[Dictionary] = []
var paired_frames := 0


func _initialize() -> void:
    run.call_deferred()


func check(value: bool, description: String) -> void:
    if not value:
        failures += 1
        push_error(description)


func start(game: ReviewRun, map: StringName, density: int, enabled: bool) -> void:
    game._return_to_menu()
    game.open_map_select(0)
    game.no_u_review = Scenario.new(density, enabled)
    game.start_selected_map(map)


func state(game: ReviewRun) -> Array:
    return [game.run_time, game.rng.state, game.player_pos, game.mode, game.enemies, game.weapons,
        game.passives, game.hp, game.shield, game.aura, game.kills, game.total_xp, game.primary_hits,
        game.spawn_timer, game.next_enemy_id, game.run_metrics, game.passive_timers, game.pickups,
        game.player_shots, game.hostile_shots, game.hazard_zones, game.weapon_areas, game.profile]


func observe(center: Vector2, radius: float, at: float, hits: Array[Dictionary], weakened: Dictionary) -> void:
    events.append({"center": center, "radius": radius, "at": at, "hits": hits, "weakened": weakened})


func boundary_fixture(game: ReviewRun, map: StringName) -> void:
    start(game, map, 1, true)
    game.enemies.clear()
    game.next_enemy_id = 1
    game.spawn_timer = INF
    game.run_time = 14.99
    game.passive_timers.no_u_next = 15.0
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(200, 0)})
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(200.01, 0)})
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(80, 0), "elite": true})
    game._spawn_enemy("mod-supremo", {"pos": game.player_pos + Vector2(0, 155)})
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(-95, 0), "telegraph": true})
    game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(0, -100)})
    game.enemies[2].shield = 1000.0
    game.enemies[5].hp = 1.0


func run() -> void:
    var baseline := ReviewRun.new()
    var candidate := ReviewRun.new()
    for game: ReviewRun in [baseline, candidate]:
        root.add_child(game)
        game.set_process(false)
    check(baseline.map_select.qa == null and baseline.no_u_vfx == null, "Ordinary boot enabled review")
    for map: StringName in Maps.NAMES:
        for density in [1, 2]:
            start(baseline, map, density, false)
            start(candidate, map, density, true)
            check(Builds.valid_build(candidate, candidate.hero.id, {"weapons": candidate.weapons, "passives": candidate.passives})
                and candidate.legendary_spent and candidate._passive_level("no-u") == 1, "Illegal review equipment")
            var saw_pulse := false
            for frame in 360:
                baseline._process(STEP)
                candidate._process(STEP)
                if state(baseline) != state(candidate):
                    check(false, "State diverged on %s density %d frame %d" % [map, density, frame])
                    break
                paired_frames += 1
                if candidate.no_u_vfx._at >= 0.0:
                    saw_pulse = true
                    check(candidate.passive_feedback.rings.is_empty(), "Duplicate legacy No U ring")
            check(saw_pulse, "Review fixture did not activate")
    candidate.no_u_resolved.connect(observe)
    boundary_fixture(candidate, Maps.MSG_FACTORY)
    var origin := candidate.player_pos
    candidate._tick_passives(STEP)
    check(events.is_empty(), "Pulse triggered before 15 s")
    candidate.run_time = 15.0
    candidate._tick_passives(STEP)
    check(events.size() == 1 and candidate.passive_timers.no_u_next == 30.0, "Pulse cadence changed")
    if events.size() != 1:
        baseline.free()
        candidate.free()
        quit(1)
        return
    var event := events[0]
    var contacts: Dictionary = {}
    for hit: Dictionary in event.hits:
        contacts[hit.id] = hit.hp_loss
    var stamped: Dictionary = event.weakened
    check(event.center == origin and event.radius == 200.0, "Incorrect source/radius")
    check(contacts.size() == 3 and is_equal_approx(contacts.get(1, 0.0), candidate._base_power() * 0.30)
        and contacts.has(4) and contacts.get(6) == 1.0, "Incorrect effective or lethal damage contacts")
    check(stamped.size() == 4 and stamped.get(1) == [0.20, 19.0] and stamped.get(3) == [0.20, 19.0]
        and stamped.get(4) == [0.10, 17.0] and stamped.get(5) == [0.20, 19.0],
        "Incorrect weaken recipients, strengths or durations")
    var shielded := candidate.enemies[2]
    var boss := candidate.enemies[3]
    var future := candidate.enemies[4]
    var renderer: RefCounted = candidate.no_u_vfx
    check(renderer._contacts.size() == 3 and renderer._origin == origin and renderer._radius == 200.0, "Candidate did not consume real results")
    check(shielded.hp == shielded.max and shielded.shield < 1000.0 and renderer.has_weaken_marker(shielded, 15.0),
        "Fully absorbed hit must show weaken without damage feedback")
    check(not renderer.has_weaken_marker(future, 15.0) and renderer.has_weaken_marker(future, float(future.born)),
        "Existing future-born weaken must first become visible on birth")
    check(renderer.has_weaken_marker(boss, 16.999) and not renderer.has_weaken_marker(boss, 17.0)
        and renderer.has_weaken_marker(shielded, 18.999) and not renderer.has_weaken_marker(shielded, 19.0),
        "Boss and normal marks must expire at their own authoritative boundaries")
    var retained := shielded.duplicate()
    retained.weaken = 0.08
    retained.weaken_until = 21.0
    check(not renderer.has_weaken_marker(retained, 16.0), "Another source inherited the No U mark")
    candidate._toggle_pause()
    candidate._process(0.25)
    check(candidate.mode == "paused" and candidate.run_time == 15.0
        and renderer.has_weaken_marker(shielded, candidate.run_time), "Pause advanced or cleared the active effect")
    candidate._toggle_pause()
    candidate._finish(false)
    check(candidate.mode == "lost" and renderer._at == -INF, "Defeat retained the effect")
    candidate.start_run(0)
    check(candidate.map_id == Maps.MSG_FACTORY and candidate._passive_level("no-u") == 1
        and candidate.no_u_vfx != renderer and candidate.no_u_vfx._at == -INF, "Retry retained stale effect or lost the scenario")
    events.clear()
    boundary_fixture(candidate, Maps.RUIN_ALLEY)
    candidate.enemies.clear()
    candidate.run_time = 15.0
    candidate._spawn_enemy("boss", {"pos": candidate.player_pos + Vector2(100, 0)})
    candidate.enemies[-1].hp = 1.0
    candidate._tick_passives(STEP)
    check(candidate.mode == "won" and candidate.no_u_vfx._at == 15.0 and candidate.no_u_vfx._contacts.size() == 1,
        "Lethal pulse did not survive the victory transition")
    candidate._process(0.10)
    check(candidate.finish_visual_age > 0.0, "Victory visual clock did not advance")
    candidate._return_to_menu()
    check(candidate.no_u_vfx == null and candidate.no_u_review == null and candidate.profile_writes == 0
        and baseline.profile_writes == 0, "QA run wrote the profile or menu retained the scenario")
    var hits: Array[Dictionary] = []
    for index in 100:
        hits.append({"id": index, "pos": Vector2(index, 0), "hp_loss": 1.0})
    renderer.pulse(origin, 200.0, 0.0, hits, {})
    check(renderer._contacts.size() == CounterPulse.MAX_CONTACTS, "Renderer exceeded contact pool")
    var draw := FileAccess.get_file_as_string("res://scripts/solo_run.gd").get_slice("func _draw() -> void:", 1)
    check(draw.find("no_u_vfx.draw_ground") < draw.find("_draw_depth_actors()")
        and draw.find("no_u_vfx.draw_contacts") > draw.find("_draw_depth_actors()")
        and draw.find("no_u_vfx.draw_weakened") < draw.find("_draw_enemy_aim_warning(enemy)")
        and draw.find("no_u_vfx.draw_weakened") < draw.find("for shot: Dictionary in hostile_shots")
        and draw.find("no_u_vfx.draw_weakened") < draw.find("_draw_danger_geometry()", draw.find("no_u_vfx.draw_weakened")),
        "No U effects violated draw priority")
    baseline.free()
    candidate.free()
    print("No U Counter-Pulse: %d paired frames, both maps and densities, HP loss, independent expiry and lifecycle; failures: %d" % [paired_frames, failures])
    quit(1 if failures else 0)
