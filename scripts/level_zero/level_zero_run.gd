extends "res://scripts/solo_run.gd"
## Content adapter: shared movement, combat, XP, Aura, offers and RNG.
const Candidate = preload("res://scripts/level_zero/candidate_v1.gd")
const VisualAssets = preload("res://scripts/level_zero/visual_assets_v1.gd")
var visual_assets = VisualAssets.new()
var intro_layer: CanvasLayer
var review_badge: Label
var normal_button: Button

func wave_count() -> int:
    return Candidate.WAVE_COUNT

func encounter_at() -> float:
    return Candidate.BOSS_AT

func encounter_kind() -> String:
    return Candidate.BOSS_ID

func encounter_events() -> Array:
    return []

func encounter_warning() -> String:
    if boss_spawned: return "PROTOTYPE / EXPERIMENTAL"
    if run_time >= Candidate.WARNING_AT:
        return "PROTOTYPE IN %ds" % ceili(Candidate.BOSS_AT-run_time)
    return ""

func enemy_definition(kind: String) -> Dictionary:
    return Candidate.BOSS if kind == Candidate.BOSS_ID else super.enemy_definition(kind)

func _save_profile() -> void:
    # Read preferences, never write production data from this review scene.
    pass

func record_result(_result: Dictionary) -> void:
    pass

func _check_legendary_window() -> void:
    # V3 first offer belongs to wave four, which this candidate never enters.
    pass

func presentation_copy(key: String, fallback: String) -> String:
    return {
        "home":"LEVEL ZERO / SIGNAL BREACH\nEXPERIMENTAL PRIVATE REVIEW",
        "boss_art":Candidate.VISUAL_KIND,
        "boss_name":"HATER IMITATION",
        "title_won":"IMITATION DOWN!",
        "title_lost":"ATTEMPT ENDED",
        "result_caption":"Prototype defeated. Big Hater is still out there.",
        "subtitle_won":"Big Hater is still out there. Season 1 is not available here yet.",
        "subtitle_lost":"Your next attempt starts fresh. No rewards or progress saved.",
        "subtitle_options":"Review preferences apply to this session only."
    }.get(key, fallback)

func _ready() -> void:
    super._ready()
    var badge_layer := CanvasLayer.new()
    badge_layer.layer = 90
    add_child(badge_layer)
    review_badge = Label.new()
    review_badge.text = "LEVEL ZERO · EXPERIMENTAL v0.1 · PLACEHOLDER ART"
    review_badge.add_theme_font_size_override("font_size", 12)
    review_badge.add_theme_color_override("font_outline_color", Color.BLACK)
    review_badge.add_theme_constant_override("outline_size", 5)
    review_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
    badge_layer.add_child(review_badge)
    normal_button = Button.new()
    normal_button.text = "NORMAL RUIN ALLEY"
    normal_button.pressed.connect(_open_normal)
    badge_layer.add_child(normal_button)
    _layout_review()

func _layout_review() -> void:
    var view := get_viewport_rect().size
    review_badge.position = Vector2(12, view.y-20)
    normal_button.position = Vector2(view.x-220,view.y-66)
    normal_button.size = Vector2(208,40)
    normal_button.visible = mode == "menu"

func _process(delta: float) -> void:
    super._process(delta)
    _layout_review()

func _open_normal() -> void:
    if OS.has_feature("web"):
        JavaScriptBridge.eval("location.assign(location.pathname)", true)
    else:
        get_tree().change_scene_to_file("res://scenes/main.tscn")

func start_run(index: int) -> void:
    super.start_run(index)
    if mode != "playing": return
    mode = "intro"
    _show_ui()
    intro_layer = CanvasLayer.new()
    intro_layer.layer = 100
    add_child(intro_layer)
    var backdrop := ColorRect.new()
    backdrop.color = Color("101723")
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    intro_layer.add_child(backdrop)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    intro_layer.add_child(center)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    center.add_child(column)
    var title := Label.new()
    title.text = "SIGNAL BREACH / EXPERIMENTAL"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    column.add_child(title)
    var story := Label.new()
    story.text = Candidate.INTRO
    story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    story.custom_minimum_size.x = minf(620, get_viewport_rect().size.x-48)
    column.add_child(story)
    var begin := Button.new()
    begin.text = "SKIP / ENTER LEVEL ZERO"
    begin.custom_minimum_size.y = 48
    begin.pressed.connect(_begin_encounter)
    column.add_child(begin)
    var back := Button.new()
    back.text = "RETURN TO MENU"
    back.custom_minimum_size.y = 44
    back.pressed.connect(func():
        intro_layer.queue_free()
        _return_to_menu())
    column.add_child(back)
    begin.grab_focus()

func _begin_encounter() -> void:
    if mode != "intro": return
    intro_layer.queue_free()
    mode = "playing"
    _clear_touch()
    _show_ui()

func _spawn_enemy(kind: String, special: Dictionary = {}) -> void:
    super._spawn_enemy(kind, special)
    if kind == Candidate.BOSS_ID and not enemies.is_empty():
        var enemy: Dictionary = enemies.back()
        enemy["visual_kind"] = Candidate.VISUAL_KIND
        enemy["prototype_next"] = run_time + Candidate.FIRST_ATTACK_DELAY
        enemy["next_attack"] = INF
        enemy["next_aux"] = INF

func _enemy_auxiliary(enemy: Dictionary, facing: Vector2) -> void:
    if enemy["kind"] != Candidate.BOSS_ID:
        super._enemy_auxiliary(enemy, facing)
        return
    if run_time < float(enemy["prototype_next"]): return
    var slam: bool = int(enemy["attack_slot"]) % 2 == 0
    var attack: Dictionary = Candidate.SLAM if slam else Candidate.BEAM
    _schedule_hazard(enemy["pos"], attack["radius"], attack["delay"], attack["active"], attack["damage"], "cone" if slam else "line", facing, enemy)
    # Direction locks at the start of the tell, with no tracking or hidden retarget.
    enemy["recover_from"] = run_time
    enemy["recover_until"] = run_time + float(attack["delay"]) + float(attack["active"])
    enemy["prototype_next"] = run_time + Candidate.ATTACK_INTERVAL
    enemy["attack_slot"] = int(enemy["attack_slot"]) + 1

# Only EXPERIMENTAL Level Zero may consume staged candidate visuals.
# These overrides never adjust actor positions, collisions, the world or RNG.
func _draw_stage_backdrop() -> bool:
    return visual_assets.draw_background(self, FIELD) or super._draw_stage_backdrop()

func _draw_stage_details() -> void:
    visual_assets.draw_foreground(self, FIELD)

func _draw_stage_enemy_visual(enemy: Dictionary, reaction: Vector2) -> bool:
    if str(enemy.get("kind", "")) == Candidate.BOSS_ID:
        if visual_assets.draw_imitation(self, enemy, reaction):
            return true
    return super._draw_stage_enemy_visual(enemy, reaction)

func _draw_stage_defeated_visual(enemy: Dictionary, death_age: float) -> void:
    if str(enemy.get("kind", "")) == Candidate.BOSS_ID:
        if visual_assets.draw_imitation(self, enemy, Vector2.ZERO, maxf(0.0, 1.0 - death_age / 0.8)):
            return
    super._draw_stage_defeated_visual(enemy, death_age)
