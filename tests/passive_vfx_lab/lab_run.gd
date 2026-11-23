extends "res://scripts/solo_run.gd"

const BurstVfx := preload("res://tests/passive_vfx_lab/burst_vfx.gd")
const CandidateFeedback := preload("res://tests/passive_vfx_lab/candidate_feedback.gd")
const Builds := preload("res://tests/passive_vfx_lab/scenario_builds.gd")
const Recorder := preload("res://tests/passive_vfx_lab/qa_recorder.gd")
const STEP := 1.0 / 60.0
const START := 2.0
const SEED := 451
const DONE := 600

var candidate := false
var burst_vfx := BurstVfx.new()
var recorder := Recorder.new()
var scenario := ""
var crowded := false
var overlay := false
var frame := 0
var last_burst: Dictionary = {}
var burst_count := 0
var records: Array[Dictionary] = []
var hud_visible := false
var recording := false
var build_sha := "uncommitted"

func _load_profile() -> void:
    profile = ProfileStoreScript.defaults()
    profile["settings"]["masterVolume"] = 0

func _save_profile() -> void:
    pass

func _ready() -> void:
    if candidate:
        passive_feedback = CandidateFeedback.new()
    super._ready()
    set_process(false)
    set_process_input(false)
    clean_cut_skin.set_process(false)
    passive_burst_resolved.connect(_observe_burst)
    get_viewport().size_changed.connect(_on_view_resized)

func stage(id: String, dense: bool, overlap: bool, reduced: bool, with_hud: bool, with_recording: bool = true) -> bool:
    scenario = id
    crowded = dense
    overlay = overlap
    profile["settings"]["reducedMotion"] = reduced
    hud_visible = with_hud
    recording = with_recording
    frame = 0
    burst_count = 0
    last_burst.clear()
    records.clear()
    burst_vfx.clear()
    var data: Dictionary = SoloOfferRulesScript.PASSIVE_DATA[id]
    var role: String = data.role
    if role.is_empty():
        if id in ["built-different", "thick-skin", "certified-w", "so-back", "too-sigma"]:
            role = "tank"
        else:
            role = "ranged"
    var index := ["ranged", "melee", "tank"].find(role)
    start_run(index)
    run_time = START
    rng.seed = SEED
    spawn_timer = INF
    weapons.clear()
    for weapon_id: String in Builds.KIT_WEAPONS[hero.id]:
        weapons.append({"id": weapon_id, "level": 1, "rarity": "common",
            "timer": 0.36 + 0.55 * weapons.size()})
    passives.assign([_item(id)])
    if dense and overlap:
        var extras: Array[String] = ["main-character", "certified-w", "so-back"]
        extras.append("big-chad" if role == "tank" else "let-him-cook" if role == "melee" else "w-wifi")
        if data.rarity != "legendary":
            extras.push_front("no-u")
        for extra in extras:
            if extra != id and passives.size() < 5:
                passives.append(_item(extra))
    if not Builds.valid_build(self, hero.id, {"weapons": weapons, "passives": passives}):
        return false
    if id == "built-different":
        passives.pop_front()
        _apply_card({"type": "passive", "id": id, "level": 1, "rarity": data.rarity})
    _recompute_max_hp()
    var reach: float = 67.0 if role != "ranged" else 151.0
    _target(Vector2(reach, 0), "npc")
    _target(Vector2(reach + 36, -54), "hater")
    _target(Vector2(reach + 43, 46), "npc")
    _target(Vector2(reach + 119, 23), "beta")
    if id == "its-over":
        enemies[0].hp = float(enemies[0].max) * 0.29
    if id == "homie-check":
        hp = max_hp * 0.6
        passive_timers["homie_count"] = 6
    if id == "no-cap-streak":
        directional_hits = 3
    if id == "six-to-seven":
        passive_timers["six_counter"] = 5
    if _passive_level("w-wifi") > 0:
        passive_timers["wifi_next"] = START + 1.05
    if _passive_level("big-chad") > 0:
        passive_timers["big_chad_next"] = START + 1.0
    if _passive_level("no-u") > 0:
        passive_timers["no_u_next"] = START + 1.08
    if dense:
        for index_in_crowd in range(42):
            var offset := Vector2.from_angle(float(index_in_crowd) * 2.399963) * (122.0 + float(index_in_crowd % 8) * 26.0)
            if offset.length() > reach + 6.0 and SoloWorldRulesScript.walkable(player_pos + offset, 18):
                _target(offset, ["npc", "hater", "beta"][index_in_crowd % 3])
        _schedule_hazard(player_pos + Vector2(reach + 120, -115), 390, 1.05, 0.18, 4, "line", Vector2(-1, 0.27).normalized())
    if id in ["so-back", "too-sigma", "big-chad", "cope-harder", "certified-w", "thick-skin"]:
        if id in ["so-back", "too-sigma"]:
            hp = max_hp * 0.34
        _schedule_hazard(player_pos, 60, 1.6, 0.02, max_hp * 0.13)
    if id in ["aura-viral", "absolute-cinema", "w-squad"]:
        aura = 100.0
    _update_camera(0.0, true)
    _show_ui()
    _update_text()
    layer.visible = hud_visible
    _fit_hud()
    if recording:
        recorder.start(self, {"commit": build_sha})
    queue_redraw()
    return true

func _item(id: String) -> Dictionary:
    return {"id": id, "level": 1, "rarity": SoloOfferRulesScript.PASSIVE_DATA[id].rarity}

func _target(offset: Vector2, kind: String) -> void:
    _spawn_enemy(kind, {"pos": player_pos + offset})
    var enemy: Dictionary = enemies.back()
    # Synthetic durability and starting positions keep the comparison reproducible.
    enemy.hp = 460.0
    enemy.max = 460.0
    enemy.speed = 0.0

func _update_camera(_delta: float, _snap: bool = false) -> void:
    # Same review framing for both replays, with room for the full blast.
    var view := get_viewport_rect().size
    var zoom_value := maxf(CameraFramingScript.zoom_for(view), minf(view.x / 570.0, view.y / 420.0))
    var focus := player_pos + Vector2(103, 0)
    camera.zoom = Vector2.ONE * zoom_value
    camera.position = CameraFramingScript.clamp_center(focus, view, zoom_value)

func tick() -> void:
    if frame >= DONE:
        return
    frame += 1
    if frame == 57 and scenario in ["aura-viral", "absolute-cinema", "w-squad"]:
        _use_flex()
    var started := Time.get_ticks_usec() if recording else 0
    super._process(STEP)
    if hud_visible:
        _fit_hud()
        clean_cut_skin._process(STEP)
    if recording:
        recorder.frame(self, Time.get_ticks_usec() - started)

func show_hud(value: bool) -> void:
    hud_visible = value
    layer.visible = value
    if value:
        _fit_hud()

func _on_view_resized() -> void:
    if hud_visible:
        _fit_hud.call_deferred()

func _fit_hud() -> void:
    # Solo normally targets the entire Window. Each lab HUD fits its own viewport.
    var arena := get_viewport_rect().size
    if presentation.view == arena and clean_cut_skin.view == arena:
        return
    presentation.position = Vector2.ZERO
    presentation.full_view = arena
    presentation.view = arena
    presentation.size = arena
    touch_joystick.size = arena
    presentation.refresh(true)
    clean_cut_skin.refresh()

func qa_context() -> Dictionary:
    return {"session_type": "synthetic_scenario", "scenario_id": scenario, "sim_start_time": START,
        "scenario_config": {"dense": crowded, "overlap": overlay, "candidate": candidate,
            "reduced_motion": bool(profile.settings.reducedMotion), "fixed_simulation_hz": 60}}

func _observe_burst(id: StringName, center: Vector2, radius: float, at: float, hits: Array[Dictionary]) -> void:
    burst_count += 1
    var encoded: Array[Dictionary] = []
    for hit in hits:
        var point: Vector2 = hit.position
        encoded.append({"id": hit.id, "position": [point.x, point.y], "hp_lost": hit.hp_lost})
    last_burst = {"id": str(id), "center": [center.x, center.y], "radius": radius,
        "active_s": at, "frame": frame, "contacts": encoded}
    records.append(last_burst)
    if recording:
        recorder.event(self, "passive_burst_resolved", last_burst)
    if candidate and mode == "playing":
        burst_vfx.burst(center, radius, at, hits)

func _draw_recovery() -> void:
    super._draw_recovery()
    if candidate and mode == "playing":
        if int(passive_timers.get("six_counter", 0)) == 6 and _passive_level("six-to-seven") > 0:
            burst_vfx.draw_armed(self, player_pos)
        burst_vfx.draw_ground(self, run_time, bool(profile.settings.reducedMotion))

func _draw_combat_feedback() -> void:
    super._draw_combat_feedback()
    if candidate and mode == "playing":
        burst_vfx.draw_contacts(self, run_time, bool(profile.settings.reducedMotion))
