extends SceneTree

const Maps := preload("res://scripts/solo_maps.gd")
const STEP := 1.0 / 60.0
const WEAPONS := ["no-cap", "ratio-blaster", "brainrot-feed"]

class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:
        profile = ProfileStoreScript.defaults()
    func _save_profile() -> void:
        pass

var failures := 0
var events: Array[Dictionary] = []

func _initialize() -> void:
    run.call_deferred()

func check(value: bool, description: String) -> void:
    if not value:
        failures += 1
        push_error(description)

func fixture(game: ReviewRun, map: StringName, weapon: int) -> Vector2:
    game.mode = "menu"
    game.open_map_select(0)
    game.start_selected_map(map)
    game._apply_card({"type": "passive", "id": "six-to-seven", "rarity": "epic", "level": 1})
    check(game._passive_level("six-to-seven") == 1, "Real acquisition did not commit")
    game.spawn_timer = INF
    game.weapons.clear()
    for index in WEAPONS.size():
        game.weapons.append({"id": WEAPONS[index], "rarity": "common", "level": 1, "timer": 0.0 if index == weapon else INF})
    game.passive_timers.six_counter = 6
    var center := game.player_pos + Vector2(151, 0)
    for offset: Vector2 in [Vector2.ZERO, Vector2(0, 90), Vector2(90.1, 0), Vector2(55, -35)]:
        game._spawn_enemy("npc", {"pos": center + offset})
        game.enemies[-1].speed = 0.0
        game.enemies[-1].hp = 900.0
        game.enemies[-1].max = 900.0
    game.enemies[-1].shield = 900.0
    game.enemies[-1].shield_until = INF
    return center

func state(game: ReviewRun) -> Array:
    return [game.run_time, game.rng.state, game.enemies, game.weapons, game.passives,
        game.passive_timers, game.run_metrics, game.primary_hits, game.aura, game.hp,
        game.shield, game.pickups, game.kills, game.mode, game.profile]

func run() -> void:
    var before := ReviewRun.new()
    var after := ReviewRun.new()
    root.add_child(before)
    root.add_child(after)
    before.set_process(false)
    after.set_process(false)
    check(before.six_to_seven_vfx == null and not before.passive_burst_resolved.has_connections(), "Ordinary boot must leave renderer and burst observer off")
    after._enable_six_to_seven_review()
    after._enable_six_to_seven_review()
    check(after.six_to_seven_vfx != null and after.passive_burst_resolved.get_connections().size() == 1, "Review presentation must connect exactly once")
    after.passive_burst_resolved.connect(observe)
    for map: StringName in Maps.NAMES:
        for slot in WEAPONS.size():
            events.clear()
            fixture(before, map, slot)
            var center := fixture(after, map, slot)
            for frame in 65:
                before._process(STEP)
                after._process(STEP)
                check(state(before) == state(after), "Presentation changed combat or RNG for %s slot %d frame %d" % [map, slot, frame])
            check(events.size() == 1, "Expected one real burst for %s slot %d" % [map, slot])
            if events.is_empty():
                continue
            var event := events[0]
            check(event.id == &"six-to-seven" and event.center == center and event.radius == 90.0, "Source or extent changed")
            var contacts: Array = event.hits
            check(contacts.size() == 2, "Only the target and the 90 U boundary contact may receive marks")
            for hit: Dictionary in contacts:
                check(hit.position.distance_to(center) <= 90.0 and is_equal_approx(hit.hp_lost, 35.0), "Incorrect effective HP loss")
            var rendered = after.six_to_seven_vfx.slots[0]
            check(rendered.center == center and rendered.radius == 90.0 and rendered.count == 2, "Renderer did not receive resolved result")
            check(after.passive_feedback.rings.is_empty(), "Legacy candidate ring leaked")
            check(after.passive_timers.six_counter == 0, "Lockout gained a count")
            after.passive_feedback.ring(after, center, 200.0, "no-u")
            check(after.passive_feedback.rings.size() == 1 and after.passive_feedback.rings[0].id == "no-u", "Unrelated rings changed")
    var canvas_source := FileAccess.get_file_as_string("res://scripts/solo_run.gd").get_slice("func _draw() -> void:", 1).get_slice("func _draw_danger_geometry()", 0)
    check(canvas_source.find("six_to_seven_vfx.draw_ground") < canvas_source.find("_draw_depth_actors()"), "Ground VFX must draw below actors")
    var contact_layer := canvas_source.find("six_to_seven_vfx.draw_contacts")
    check(contact_layer > canvas_source.find("_draw_depth_actors()")
        and contact_layer < canvas_source.find("_draw_enemy_aim_warning(enemy)")
        and contact_layer < canvas_source.rfind("_draw_danger_geometry()")
        and contact_layer < canvas_source.find("for shot: Dictionary in hostile_shots"), "Threat layers must draw above VFX")
    check(canvas_source.contains('draw_ground(self, six_vfx_time, bool(profile["settings"]["reducedMotion"]))')
        and canvas_source.contains('draw_contacts(self, six_vfx_time, bool(profile["settings"]["reducedMotion"]))'), "Both VFX layers must respect Reduced Motion")
    events.clear()
    var center := fixture(after, Maps.MSG_FACTORY, 0)
    after._primary_activation(center)
    var at := after.run_time
    after._toggle_pause()
    after._process(0.25)
    check(after.mode == "paused" and after.run_time == at and after.six_to_seven_vfx.slots[0].at == at, "Pause changed active VFX state")
    after._toggle_pause()
    after._process(STEP)
    check(after.mode == "playing" and after.run_time > at, "Resume did not restore active time")
    after.start_run(0)
    check(after.map_id == Maps.MSG_FACTORY and after.six_to_seven_vfx.slots[0].at == -INF, "Factory retry retained a burst or lost its map")
    center = fixture(after, Maps.MSG_FACTORY, 0)
    after._primary_activation(center)
    after._finish(false)
    check(after.six_to_seven_vfx.slots[0].at == -INF, "Defeat retained a burst")
    center = fixture(after, Maps.RUIN_ALLEY, 0)
    after._spawn_enemy("boss", {"pos": center})
    after.enemies[-1].hp = 1.0
    after._primary_activation(center)
    check(after.mode == "won" and after.six_to_seven_vfx.slots[0].at == after.run_time, "Killing burst lost after victory transition")
    after._process(0.1)
    check(after.finish_visual_age > 0.0, "Winning burst does not receive the result presentation clock")
    after._return_to_menu()
    check(after.six_to_seven_vfx.slots[0].at == -INF, "Menu retained victory burst")
    before.free()
    after.free()
    print("Six to Seven integration: 390 paired frames, both maps, all weapon slots, exact contacts, acquisition and lifecycle; failures: ", failures)
    quit(1 if failures else 0)

func observe(id: StringName, center: Vector2, radius: float, at: float, hits: Array[Dictionary]) -> void:
    events.append({"id": id, "center": center, "radius": radius, "at": at, "hits": hits})
