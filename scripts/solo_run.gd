extends Node2D

const SoloClock = preload("res://scripts/solo_clock.gd")
const EnemyNavigationScript = preload("res://scripts/enemy_navigation.gd")
const HeroAnimationScript = preload("res://scripts/hero_animation.gd")
const WebPlatformScript = preload("res://scripts/web_platform.gd")
const ArcadePresentationScript = preload("res://scripts/arcade_presentation.gd")
const RecoveryRulesScript = preload("res://scripts/recovery_rules.gd")
const PhaserRngScript = preload("res://scripts/phaser_rng.gd")
const CameraFramingScript = preload("res://scripts/camera_framing.gd")
const ProfileStoreScript = preload("res://scripts/profile_store.gd")
const ApprovedVisualsScript = preload("res://scripts/approved_visuals.gd")
const FloatingJoystickScript = preload("res://scripts/floating_joystick.gd")
const WeaponVisualsScript = preload("res://scripts/weapon_visuals.gd")
const SoloOfferRulesScript = preload("res://scripts/solo_offer_rules.gd")
const SoloEnemyRulesScript = preload("res://scripts/solo_enemy_rules.gd")
const SoloWorldRulesScript = preload("res://scripts/solo_world_rules.gd")
const SoloPassiveRulesScript = preload("res://scripts/solo_passive_rules.gd")
## Initial GDD-grounded playable solo slice.
## Procedural debug visuals and simplified enemy patterns are NOT final approved art or combat parity.

const HEROES := [
    {"id": "sigma", "name": "THE SIGMA", "role": "ranged", "hp": 100.0, "speed": 180.0, "power": 100.0, "resist": 0.0, "starter": "no-cap", "flex": "Deadpan Verdict", "duration": 6.0, "color": Color(0.95, 0.71, 0.28)},
    {"id": "cool-kid", "name": "COOL KID", "role": "melee", "hp": 110.0, "speed": 190.0, "power": 95.0, "resist": 0.05, "starter": "keyboard-warrior", "flex": "CTRL + CHAOS", "duration": 5.0, "color": Color(0.37, 0.69, 0.96)},
    {"id": "alpha", "name": "ALPHA CHAD", "role": "tank", "hp": 140.0, "speed": 160.0, "power": 90.0, "resist": 0.15, "starter": "cope-shield", "flex": "Giga Chad Rampage", "duration": 6.0, "color": Color(0.82, 0.45, 0.69)}
]
const WEAPONS := {
    "ratio-blaster": {"name": "Ratio Blaster", "role": "ranged", "interval": 0.65, "range": 520.0, "power": 0.20, "shape": "shot"},
    "no-cap": {"name": "No Cap", "role": "ranged", "interval": 1.60, "range": 600.0, "power": 0.50, "shape": "line"},
    "brainrot-feed": {"name": "Brainrot Feed", "role": "ranged", "interval": 3.0, "range": 480.0, "power": 0.65, "shape": "blast"},
    "keyboard-warrior": {"name": "Keyboard Warrior", "role": "melee", "interval": 0.75, "range": 95.0, "power": 0.36, "shape": "cone"},
    "ban-hammer": {"name": "Ban Hammer", "role": "melee", "interval": 2.40, "range": 125.0, "power": 0.90, "shape": "cone"},
    "touch-grass": {"name": "Touch Grass", "role": "melee", "interval": 1.50, "range": 145.0, "power": 0.40, "shape": "cone"},
    "cope-shield": {"name": "Cope Shield", "role": "tank", "interval": 2.00, "range": 100.0, "power": 0.45, "shape": "cone"},
    "chad-hands": {"name": "Chad Hands", "role": "tank", "interval": 1.20, "range": 90.0, "power": 0.44, "shape": "cone"},
    "personal-space": {"name": "Personal Space", "role": "tank", "interval": 2.80, "range": 135.0, "power": 0.40, "shape": "pulse"}
}
const PASSIVES := [
    "main-character", "terminally-online", "built-different", "thick-skin", "caught-4k",
    "big-meme", "timeline", "hands-on-sight", "cope-harder", "certified-w",
    "no-cap-streak", "w-wifi", "let-him-cook", "homie-check", "big-chad",
    "its-over", "aura-viral", "so-back", "six-to-seven",
    "absolute-cinema", "w-squad", "too-sigma", "no-u"
]
const WAVE_NAMES := ["FIRST POST", "COMMENT SECTION", "GOING VIRAL", "CANCEL STORM", "FINAL RATIO"]
const WAVE_HP := [1.0, 1.30, 1.65, 2.05, 2.50]
const WAVE_DAMAGE := [1.0, 1.15, 1.30, 1.50, 1.75]
const WAVE_DENSITY := [1.0, 1.20, 1.40, 1.65, 1.90]
const FIELD := Rect2(0.0, 0.0, 1448.0, 1086.0)
const COVERS := [Vector2(600.0, 550.0), Vector2(940.0, 680.0)]
const CAP_LEVELS := {"common": 4, "rare": 3, "epic": 2, "legendary": 1}
const RARITY_POWER := {"common": 1.0, "rare": 1.5, "epic": 2.0, "legendary": 2.6}
var art = ApprovedVisualsScript.new()
var movement_direction := Vector2.DOWN
var defeated_visuals: Array[Dictionary] = []
var finish_visual_age := 0.0
var visual_walk := 0.0
var visual_defeat := 0.0
var visual_heading := 0.0
var visual_direction_known := false
var visual_moving := false
var visual_facing := 0.0
var mode := "menu"
var hero: Dictionary = {}
var player_pos := Vector2(724.0, 540.0)
var hp := 100.0
var max_hp := 100.0
var shield := 0.0
var aura := 0.0
var flex_time := 0.0
var flex_lock := 0.0
var flex_age := 0.0
var run_time := 0.0
var level := 1
var xp := 0.0
var total_xp := 0.0
var kills := 0
var wave := 1
var event_index := 0
var boss_spawned := false
var terminals_destroyed := 0
var terminals_interrupt_until := 0.0
var spawn_timer := 0.7
var hurt_timer := 0.0
var attack_flash := 0.0
var attack_visuals: Array[Dictionary] = []
var attack_target := Vector2.ZERO
var pending_choices := 0
var selection: Array[Dictionary] = []
var replace_card: Dictionary = {}
var replace_options: Array[Dictionary] = []
var legendary_offers: Array[Dictionary] = []
var legendary_spent := false
var legendary_first_shown := false
var legendary_second_shown := false
var weapons: Array[Dictionary] = []
var passives: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var player_shots: Array[Dictionary] = []
var weapon_areas: Array[Dictionary] = []
var weapon_activations: Dictionary = {}
var chad_successful_activations := 0
var weapon_shields: Dictionary = {}
var hostile_shots: Array[Dictionary] = []
var hazard_zones: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var passive_timers: Dictionary = {}
var primary_hits := 0
var directional_hits := 0
var cook_stacks := 0
var cook_expires := 0.0
var aura_hits_bucket := -1
var aura_hits_in_bucket := 0
var primary_aura_times: Array[float] = []
var max_level_heal_at := 0.0
var sigma_target: Dictionary = {}
var rng = PhaserRngScript.new()
var hero_index := 0
var profile: Dictionary = ProfileStoreScript.defaults()
var run_id := ""
var run_metrics: Dictionary = {"damage": 0.0, "healing": 0.0, "protection": 0.0, "flexes": 0, "flex_damage": 0.0, "flex_prevented": 0.0, "flex_absorbed": 0.0, "flex_finishers": 0}
var storage_available := true
var manual_aim := false
var aim_point := Vector2.ZERO
var next_enemy_id := 1
var hero_state: Dictionary = {}
var touch_active := false
var touch_index := -1
var touch_origin := Vector2.ZERO
var touch_direction := Vector2.ZERO
var touch_joystick: Control
var camera: Camera2D
var layer: CanvasLayer
var headline: Label
var metrics: Label
var notice: Label
var menu_buttons: Array[Button] = []
var hero_portraits: Array[TextureRect] = []
var modal_dim: ColorRect
var hud_top: ColorRect
var hud_bottom: ColorRect
var offer_buttons: Array[Button] = []
var flex_button: Button
var pause_button: Button
var restart_button: Button
var legendary_button: Button
var defer_button: Button
var status_timer := 0.0
var selected_card_index := -1
var confirm_button: Button
var retry_button: Button
var sound_button: Button
var motion_button: Button
var import_button: Button
var export_button: Button
var build_details: Label
var profile_text: TextEdit
var blocked_movement: Dictionary = {}
var presentation
var touch_device := OS.has_feature("mobile")
var web_metrics: Dictionary = {}
var platform_poll := 0.0
var safe_spot_charge := 0.0
var safe_spot_ready_at := 0.0
var safe_spot_uses := 0
var recovery_counts: Dictionary = {}
var pickup_feedback: Array[Dictionary] = []

func _ready() -> void:
    rng.seed = 451
    _load_profile()
    WebPlatformScript.install()
    web_metrics = WebPlatformScript.metrics()
    touch_device = touch_device or bool(web_metrics.get("touch",false))
    camera = Camera2D.new()
    camera.enabled = true
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = int(FIELD.size.x)
    camera.limit_bottom = int(FIELD.size.y)
    add_child(camera)
    layer = CanvasLayer.new()
    add_child(layer)
    touch_joystick = FloatingJoystickScript.new()
    touch_joystick.position = Vector2.ZERO
    touch_joystick.size = Vector2(1280.0, 720.0)
    touch_joystick.mouse_filter = Control.MOUSE_FILTER_IGNORE
    touch_joystick.visible = false
    layer.add_child(touch_joystick)
    hud_top = ColorRect.new()
    hud_top.color = Color(0.055, 0.07, 0.11, 0.91)
    hud_top.position = Vector2.ZERO
    hud_top.size = Vector2(1280.0, 100.0)
    hud_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(hud_top)
    hud_bottom = ColorRect.new()
    hud_bottom.color = Color(0.055, 0.07, 0.11, 0.87)
    hud_bottom.position = Vector2(0.0, 615.0)
    hud_bottom.size = Vector2(1280.0, 105.0)
    hud_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(hud_bottom)
    modal_dim = ColorRect.new()
    modal_dim.color = Color(0.03, 0.04, 0.07, 0.73)
    modal_dim.position = Vector2.ZERO
    modal_dim.size = Vector2(1280.0, 720.0)
    modal_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(modal_dim)
    headline = _make_label(Vector2(25, 18), 26)
    metrics = _make_label(Vector2(25, 53), 17)
    notice = _make_label(Vector2(235, 145), 28)
    for i in range(3):
        var menu_b = _make_button("", Vector2(115 + 350 * i, 527), Vector2(330, 73))
        menu_b.pressed.connect(start_run.bind(i))
        menu_buttons.append(menu_b)
        var portrait := TextureRect.new()
        portrait.position = Vector2(158 + 350 * i, 272)
        portrait.size = Vector2(245, 244)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.texture = art.texture(HEROES[i]["id"])
        portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
        layer.add_child(portrait)
        hero_portraits.append(portrait)
        var offer_b = _make_button("", Vector2(325, 288 + 82 * i), Vector2(630, 68))
        offer_b.pressed.connect(pick_upgrade.bind(i))
        offer_buttons.append(offer_b)
    for extra in range(3, 5):
        var extra_offer = _make_button("", Vector2(325, 288 + 82 * extra), Vector2(630, 68))
        extra_offer.pressed.connect(pick_upgrade.bind(extra))
        offer_buttons.append(extra_offer)
    var sixth_offer = _make_button("", Vector2(325, 625), Vector2(630, 68))
    sixth_offer.pressed.connect(pick_upgrade.bind(5))
    offer_buttons.append(sixth_offer)
    legendary_button = _make_button("LEGENDARY [L]", Vector2(737, 635), Vector2(246, 65))
    legendary_button.pressed.connect(_open_legendary)
    defer_button = _make_button("DECIDE LATER", Vector2(500, 614), Vector2(280, 64))
    defer_button.pressed.connect(_defer_legendary)
    flex_button = _make_button("FLEX [SPACE]", Vector2(1002, 635), Vector2(245, 65))
    flex_button.pressed.connect(_use_flex)
    pause_button = _make_button("PAUSE [P]", Vector2(1083, 20), Vector2(168, 46))
    pause_button.pressed.connect(_toggle_pause)
    restart_button = _make_button("RETURN TO MENU", Vector2(465, 593), Vector2(350, 58))
    restart_button.pressed.connect(_request_return_to_menu)
    confirm_button = _make_button("CONFIRM", Vector2(500, 614), Vector2(280, 64))
    confirm_button.pressed.connect(_confirm_selection)
    retry_button = _make_button("PLAY AGAIN", Vector2(465, 520), Vector2(350, 58))
    retry_button.pressed.connect(func(): start_run(hero_index))
    sound_button = _make_button("", Vector2(25, 110), Vector2(220, 46))
    sound_button.pressed.connect(_toggle_sound)
    motion_button = _make_button("", Vector2(25, 164), Vector2(220, 64))
    motion_button.pressed.connect(_toggle_motion)
    import_button = _make_button("IMPORT SAVE", Vector2(25, 236), Vector2(220, 46))
    import_button.pressed.connect(_open_profile_import)
    export_button = _make_button("SAVE DATA", Vector2(25, 290), Vector2(220, 46))
    export_button.pressed.connect(_open_profile_export)
    build_details = _make_label(Vector2(285, 285), 18)
    profile_text = TextEdit.new()
    profile_text.position = Vector2(260, 265)
    profile_text.size = Vector2(760, 300)
    layer.add_child(profile_text)
    presentation = ArcadePresentationScript.new(self)
    presentation.install()
    _apply_preferences()
    _show_ui()
    _update_text()

func _make_label(pos: Vector2, font_size: int) -> Label:
    var label = Label.new()
    label.position = pos
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color(0.96, 0.95, 0.86))
    layer.add_child(label)
    return label

func _make_button(caption: String, pos: Vector2, dimensions: Vector2) -> Button:
    var button = Button.new()
    button.text = caption
    button.position = pos
    button.size = dimensions
    button.add_theme_font_size_override("font_size", 19)
    layer.add_child(button)
    _style_button(button)
    return button

func _style_button(button: Button) -> void:
    for state in ["normal", "hover", "pressed", "disabled"]:
        var style := StyleBoxFlat.new()
        style.bg_color = Color(0.11, 0.16, 0.25, 0.94)
        if state == "hover" or state == "pressed":
            style.bg_color = Color(0.22, 0.35, 0.50, 0.99)
        if state == "disabled":
            style.bg_color = Color(0.13, 0.14, 0.17, 0.85)
        style.border_color = Color(0.87, 0.67, 0.29, 0.85)
        style.set_border_width_all(2)
        style.set_corner_radius_all(10)
        button.add_theme_stylebox_override(state, style)
    button.add_theme_color_override("font_color", Color(0.98, 0.95, 0.82))
    button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
    button.add_theme_font_size_override("font_size", 19)

func _show_ui() -> void:
    var card_mode := mode == "choice" or mode == "replace" or mode == "legendary"
    confirm_button.visible = card_mode or mode == "confirm_exit" or mode == "profile_import" or mode == "profile_export"
    confirm_button.disabled = card_mode and selected_card_index < 0
    confirm_button.text = "LEAVE RUN" if mode == "confirm_exit" else ("IMPORT" if mode == "profile_import" else ("CLOSE" if mode == "profile_export" else "CONFIRM"))
    confirm_button.position = Vector2(790, 614) if mode == "legendary" else Vector2(500, 614)
    defer_button.position = Vector2(395, 614)
    retry_button.visible = mode == "won" or mode == "lost"
    sound_button.visible = mode == "menu" or mode == "paused"
    motion_button.visible = sound_button.visible
    sound_button.text = "SOUND: ON" if profile["settings"]["sound"] else "SOUND: OFF"
    motion_button.text = "REDUCED MOTION: ON" if profile["settings"]["reducedMotion"] else "REDUCED MOTION: OFF"
    import_button.visible = mode == "menu"
    export_button.visible = mode == "menu"
    profile_text.visible = mode == "profile_import" or mode == "profile_export"
    profile_text.editable = mode == "profile_import"
    build_details.visible = mode == "paused"
    var lines := "WEAPONS\n"
    for item: Dictionary in weapons: lines += "%s  %s LV %d\n" % [WEAPONS[item["id"]]["name"], str(item["rarity"]).to_upper(), int(item["level"])]
    lines += "\nPASSIVES\n"
    for item: Dictionary in passives: lines += "%s  LV %d\n" % [SoloOfferRulesScript.PASSIVE_DATA[item["id"]]["name"], int(item["level"])]
    build_details.text = lines
    hud_top.visible = mode != "menu"
    hud_bottom.visible = mode == "playing" or mode == "paused"
    modal_dim.visible = mode != "menu" and mode != "playing"
    for i in range(3):
        hero_portraits[i].visible = mode == "menu"
        menu_buttons[i].visible = mode == "menu"
        menu_buttons[i].text = "%d   %s   ·   %s" % [i + 1, HEROES[i]["name"], HEROES[i]["flex"]]
    for i in range(offer_buttons.size()):
        _style_button(offer_buttons[i])
        if card_mode and i == selected_card_index:
            var selected_style: StyleBoxFlat = offer_buttons[i].get_theme_stylebox("normal").duplicate()
            selected_style.bg_color = Color(0.30, 0.39, 0.20, 1.0)
            offer_buttons[i].add_theme_stylebox_override("normal", selected_style)
        offer_buttons[i].visible = (mode == "choice" and i < selection.size()) or (mode == "replace" and i < replace_options.size()) or (mode == "legendary" and i < legendary_offers.size())
        if mode == "legendary":
            offer_buttons[i].position = Vector2(72.0 + 582.0 * (i % 2), 254.0 + 92.0 * int(i / 2))
            offer_buttons[i].size = Vector2(548.0, 76.0)
            if i < legendary_offers.size():
                offer_buttons[i].text = "%d   %s" % [i + 1, legendary_offers[i]["label"]]
        else:
            offer_buttons[i].position = Vector2(325.0, 268.0 + 74.0 * i)
            offer_buttons[i].size = Vector2(630.0, 67.0)
            if mode == "choice" and i < selection.size():
                offer_buttons[i].text = "%d   %s" % [i + 1, selection[i]["label"]]
            elif mode == "replace" and i < replace_options.size():
                offer_buttons[i].text = "%d   REPLACE %s" % [i + 1, replace_options[i]["label"]]
    legendary_button.visible = mode == "playing" and run_time >= SoloClock.LEGENDARY_FIRST and run_time < SoloClock.LEGENDARY_DEADLINE and not legendary_spent and not legendary_offers.is_empty()
    defer_button.visible = mode == "legendary"
    flex_button.visible = mode == "playing"
    pause_button.visible = mode == "playing" or mode == "paused"
    pause_button.text = "RESUME [P]" if mode == "paused" else "PAUSE [P]"
    restart_button.visible = mode == "replace" or mode == "lost" or mode == "won" or mode == "paused" or mode == "confirm_exit" or mode == "profile_import" or mode == "profile_export"
    restart_button.text = "BACK" if mode == "replace" else "CANCEL" if mode == "confirm_exit" or mode == "profile_import" or mode == "profile_export" else "RETURN TO MENU"
    restart_button.size = Vector2(300, 58) if mode == "replace" or mode == "confirm_exit" or mode == "profile_import" or mode == "profile_export" else Vector2(350, 58)
    restart_button.position = Vector2(160, 614) if mode == "replace" or mode == "confirm_exit" or mode == "profile_import" or mode == "profile_export" else Vector2(465, 593)
    if presentation != null: presentation.refresh(true)

func _update_text() -> void:
    if mode in ["menu","heroes"] or hero.is_empty():
        headline.text = "AURA FARMER"
        headline.position = Vector2(82, 40)
        headline.add_theme_font_size_override("font_size", 54)
        metrics.text = "RUIN ALLEY  ·  FIVE WAVES  ·  ONE BIG HATER  ·  STARTER SOLO DEMO"
        metrics.position = Vector2(86, 120)
        notice.text = "CHOOSE YOUR ENERGY"
        notice.position = Vector2(448, 204)
        if presentation != null: presentation.refresh()
        return
    headline.position = Vector2(25, 16)
    headline.add_theme_font_size_override("font_size", 26)
    metrics.position = Vector2(25, 55)
    notice.position = Vector2(345, 184)
    headline.text = "%s   /   %s   /   %02d:%02d" % [hero["name"], "BIG HATER" if boss_spawned else WAVE_NAMES[wave - 1], int(run_time) / 60, int(run_time) % 60]
    var flex_label = "READY" if aura >= 100.0 and flex_lock <= 0.0 else "%.0f / 100" % aura
    metrics.text = "HP %.0f/%.0f   Shield %.0f   LV %d   XP %.0f/%.0f   Aura %s   Kills %d   Weapons %d/3   Passives %d/5" % [hp, max_hp, shield, level, xp, float(30 + 8 * level + level * level), flex_label, kills, weapons.size(), passives.size()]
    flex_button.disabled = aura < 100.0 or flex_lock > 0.0
    if mode == "confirm_exit":
        notice.text = "LEAVE THIS RUN? PROGRESS IS NOT RECORDED"
    elif mode == "profile_import":
        notice.text = "PASTE A PHASER V2 OR V1 PROFILE, THEN CONFIRM"
    elif mode == "profile_export":
        notice.text = "COPY YOUR SAVE DATA"
    elif mode == "choice":
        notice.text = "LEVEL %d — CHOOSE AN UPGRADE" % level
    elif mode == "legendary":
        notice.text = "ONE LEGENDARY PER RUN · CHOOSE OR DEFER"
    elif mode == "replace":
        notice.text = "CHOOSE AN EQUIPPED ITEM TO REPLACE"
    elif mode == "paused":
        notice.text = "PAUSED"
    elif mode == "lost":
        notice.text = "DEFEAT  /  REACHED WAVE %d" % wave
    elif mode == "won":
        notice.text = "VICTORY  /  BIG HATER DEFEATED"
    elif flex_time > 0.0:
        notice.text = "%s  %.1fs" % [hero["flex"], flex_time]
    else:
        notice.text = "MOUSE AIM [M]" if manual_aim else ""
    if presentation != null: presentation.refresh()

func start_run(index: int) -> void:
    if index < 0 or index >= HEROES.size():
        return
    hero_index = index
    selected_card_index = -1
    run_id = Crypto.new().generate_random_bytes(16).hex_encode()
    run_metrics = {"damage": 0.0, "healing": 0.0, "protection": 0.0, "flexes": 0, "flex_damage": 0.0, "flex_prevented": 0.0, "flex_absorbed": 0.0, "flex_finishers": 0}
    profile["selected"] = HEROES[index]["id"]
    _save_profile()
    hero = HEROES[index].duplicate(true)
    hero_state = {"moving_since": -1.0, "stopped_since": -1.0, "lock_id": -1, "lock_since": 0.0, "lock_lost": 0.0, "certified": false, "certified_ready": 0.0, "flex_boss_damage": 0.0, "last_contact": -1000.0}
    next_enemy_id = 1
    player_pos = Vector2(724, 540)
    movement_direction = Vector2.DOWN
    defeated_visuals.clear()
    finish_visual_age = 0.0
    visual_walk = 0.0
    visual_defeat = 0.0
    visual_heading = 0.0
    visual_direction_known = false
    visual_moving = false
    visual_facing = 0.0
    hp = hero["hp"]
    max_hp = hp
    shield = 0.0
    weapon_shields.clear()
    aura = 0.0
    flex_time = 0.0
    flex_lock = 0.0
    flex_age = 0.0
    hurt_timer = 0.0
    attack_flash = 0.0
    attack_visuals.clear()
    _clear_touch()
    run_time = 0.0
    level = 1
    xp = 0.0
    total_xp = 0.0
    kills = 0
    wave = 1
    event_index = 0
    boss_spawned = false
    terminals_destroyed = 0
    terminals_interrupt_until = 0.0
    spawn_timer = 0.7
    hurt_timer = 0.0
    pending_choices = 0
    legendary_offers.clear()
    legendary_spent = false
    legendary_first_shown = false
    legendary_second_shown = false
    replace_card.clear()
    replace_options.clear()
    weapons = [{"id": hero["starter"], "level": 1, "rarity": "common", "timer": 0.0}]
    passives.clear()
    enemies.clear()
    player_shots.clear()
    weapon_areas.clear()
    weapon_activations.clear()
    chad_successful_activations = 0
    hostile_shots.clear()
    hazard_zones.clear()
    pickups.clear()
    safe_spot_charge = 0.0
    safe_spot_ready_at = 0.0
    safe_spot_uses = 0
    recovery_counts = {"snacks_spawned":0, "magnets_spawned":0, "snacks_collected":0, "magnets_collected":0}
    pickup_feedback.clear()
    passive_timers.clear()
    primary_hits = 0
    directional_hits = 0
    cook_stacks = 0
    cook_expires = 0.0
    aura_hits_bucket = -1
    aura_hits_in_bucket = 0
    primary_aura_times.clear()
    max_level_heal_at = 0.0
    sigma_target = {}
    rng.seed = 451 + 17 * index
    mode = "playing"
    _show_ui()
    _update_text()
    _update_camera(0.0, true)

func _process(delta: float) -> void:
    if mode == "playing":
        var remaining := clampf(delta, 0.0, 0.25)
        while remaining > 0.00000001 and mode == "playing":
            var dt := minf(remaining, 1.0 / 60.0)
            _advance(dt)
            remaining -= dt
    if mode == "won": finish_visual_age += clampf(delta,0.0,0.1)
    for defeated: Dictionary in defeated_visuals.duplicate():
        if run_time-float(defeated["defeated_at"])+finish_visual_age >= 0.85: defeated_visuals.erase(defeated)
    if mode == "lost": visual_defeat += clampf(delta,0.0,0.1)
    if mode == "playing":
        attack_flash = maxf(attack_flash - delta, 0.0)
        for effect: Dictionary in attack_visuals.duplicate():
            effect["life"] = float(effect["life"]) - delta
            if float(effect["life"]) <= 0.0:
                attack_visuals.erase(effect)
    _update_platform(delta)
    _update_camera(delta)
    if presentation != null: presentation.pump()
    status_timer -= delta
    if status_timer <= 0.0:
        status_timer = 0.10
        _update_text()
    queue_redraw()

func _update_camera(delta: float, snap: bool = false) -> void:
    var view := get_viewport_rect().size
    var zoom_value: float = CameraFramingScript.zoom_for(view, touch_device)
    camera.zoom = Vector2.ONE * zoom_value
    var target: Vector2 = CameraFramingScript.clamp_center(player_pos, view, zoom_value)
    var center: Vector2 = target if snap or bool(profile["settings"]["reducedMotion"]) else CameraFramingScript.follow(camera.position, target, delta)
    camera.position = CameraFramingScript.clamp_center(center, view, zoom_value)

func _advance(dt: float) -> void:
    if mode != "playing":
        return
    run_time += dt
    _tick_recovery(dt)
    _expire_weapon_shields()
    hurt_timer = maxf(0.0, hurt_timer - dt)
    flex_lock = maxf(0.0, flex_lock - dt)
    if flex_time > 0.0:
        flex_time = maxf(0.0, flex_time - dt)
        flex_age += dt
        _step_signature_flex()
    else:
        aura = minf(100.0, aura + 0.5 * dt)
    if mode != "playing": return
    _move_player(dt)
    if mode != "playing": return
    var new_wave := mini(5, 1 + int(run_time / SoloClock.WAVE_SECONDS))
    while wave < new_wave and not boss_spawned:
        wave += 1
        _gain_xp(float(40 * wave))
    _spawn_logic(dt)
    _check_legendary_window()
    if mode == "playing" and pending_choices > 0:
        _open_choice()
    if mode != "playing":
        return
    _tick_passives(dt)
    if mode != "playing": return
    _step_enemies(dt)
    if mode != "playing": return
    _step_hostile_shots(dt)
    if mode != "playing": return
    _step_hazards()
    if mode != "playing":
        return
    _fire_weapons(dt)
    if mode != "playing": return
    _step_player_shots(dt)
    if mode != "playing": return
    _step_weapon_areas()
    if mode != "playing": return
    _collect_drops()
    if mode != "playing":
        return
    _check_legendary_window()
    if mode == "playing" and pending_choices > 0:
        _open_choice()

func _tick_passives(dt: float) -> void:
    # All passive clocks advance only inside _advance while the run is playing.
    if _passive_level("w-wifi") > 0 and not enemies.is_empty() and run_time >= float(passive_timers.get("wifi_next", 12.0)):
        passive_timers["wifi_next"] = run_time + 12.0
        passive_timers["wifi_until"] = run_time + 4.0
        passive_timers["wifi_center"] = player_pos
    if _passive_level("big-chad") > 0 and not enemies.is_empty() and run_time >= float(passive_timers.get("big_chad_next", 10.0)):
        passive_timers["big_chad_next"] = run_time + 10.0
        var amount: float = max_hp * (0.05 + 0.02 * float(_passive_level("big-chad") - 1))
        _grant_weapon_shield("big-chad", amount, 4.0)
    if _passive_level("no-u") > 0 and not enemies.is_empty() and run_time >= float(passive_timers.get("no_u_next", 15.0)):
        passive_timers["no_u_next"] = run_time + 15.0
        _damage_nearby(200.0, 0.30 * _base_power())
        for e: Dictionary in enemies:
            if player_pos.distance_to(e["pos"]) <= 200.0:
                var is_boss: bool = bool(SoloEnemyRulesScript.DATA[e["kind"]]["boss"])
                e["weaken"] = 0.10 if is_boss else 0.20
                e["weaken_until"] = run_time + (2.0 if is_boss else 4.0)
    if int(passive_timers.get("so_back_remaining", 0)) > 0 and run_time >= float(passive_timers.get("so_back_next", 1e9)):
        passive_timers["so_back_remaining"] = int(passive_timers["so_back_remaining"]) - 1
        passive_timers["so_back_next"] = run_time + 1.0
        var heal_total: float = 0.10 + 0.05 * float(_passive_level("so-back") - 1)
        _heal_player(max_hp * heal_total * 0.20 * SoloPassiveRulesScript.support_scale(passives))

func _primary_activation(target: Vector2) -> void:
    primary_hits += 1
    for timestamp: float in primary_aura_times.duplicate():
        if run_time - timestamp >= 1.0: primary_aura_times.erase(timestamp)
    if flex_time <= 0.0 and primary_aura_times.size() < 2:
        aura = minf(100.0, aura + 1.0)
        primary_aura_times.append(run_time)
    if _passive_level("let-him-cook") > 0:
        cook_stacks = mini(5, (cook_stacks if run_time < cook_expires else 0) + 1)
        cook_expires = run_time + 3.0
    if _passive_level("homie-check") > 0 and run_time >= float(passive_timers.get("homie_ready", 0.0)):
        var homie_count: int = int(passive_timers.get("homie_count", 0)) + 1
        if homie_count >= 8:
            homie_count = 0
            passive_timers["homie_ready"] = run_time + 6.0
            var healed: float = max_hp * (0.02 + 0.01 * float(_passive_level("homie-check")))
            _heal_player(healed * SoloPassiveRulesScript.support_scale(passives))
        passive_timers["homie_count"] = homie_count
    if _passive_level("six-to-seven") > 0 and run_time >= float(passive_timers.get("six_ready", 0.0)):
        var sixth_count: int = int(passive_timers.get("six_counter", 0)) + 1
        if sixth_count >= 7:
            sixth_count = 0
            passive_timers["six_ready"] = run_time + 2.0
            var amount: float = _base_power() * (0.35 + 0.15 * float(_passive_level("six-to-seven") - 1))
            for e: Dictionary in enemies.duplicate():
                if Vector2(e["pos"]).distance_to(target) <= 90.0:
                    _hit_enemy(e, amount)
        passive_timers["six_counter"] = sixth_count

func _base_power() -> float:
    return float(hero["power"]) * (1.0 + 0.01 * float(level - 1))

func _nearest_target(reach: float = INF) -> Dictionary:
    var closest: Dictionary = {}
    var nearest := reach
    for enemy: Dictionary in enemies:
        var distance := player_pos.distance_to(enemy["pos"])
        if run_time < float(enemy.get("born", 0.0)) or float(enemy["hp"]) <= 0.0 or distance > nearest or not SoloWorldRulesScript.clear_line(player_pos, enemy["pos"]): continue
        if closest.is_empty() or distance < nearest or int(enemy["id"]) < int(closest["id"]):
            closest = enemy
            nearest = distance
    return closest

func _update_target_lock() -> void:
    var target := _nearest_target()
    if not target.is_empty():
        if int(hero_state["lock_id"]) != int(target["id"]):
            hero_state["lock_id"] = int(target["id"])
            hero_state["lock_since"] = run_time
        hero_state["lock_lost"] = run_time
    elif run_time - float(hero_state["lock_lost"]) > 1.0:
        hero_state["lock_id"] = -1
        hero_state["lock_since"] = run_time

func _update_movement_trait(moving: bool) -> void:
    if moving:
        hero_state["stopped_since"] = -1.0
        if float(hero_state["moving_since"]) < 0.0: hero_state["moving_since"] = run_time
    else:
        if float(hero_state["stopped_since"]) < 0.0: hero_state["stopped_since"] = run_time
        if run_time - float(hero_state["stopped_since"]) >= 1.0: hero_state["moving_since"] = -1.0

func _aim_direction(target: Dictionary) -> Vector2:
    var point: Vector2 = aim_point if manual_aim else target["pos"]
    var direction := (point - player_pos).normalized()
    return direction if direction.length_squared() > 0.0 else movement_direction

func _flex_facing() -> Vector2:
    if manual_aim and aim_point.distance_squared_to(player_pos) > 0.0:
        return (aim_point-player_pos).normalized()
    return movement_direction.normalized() if movement_direction.length_squared() > 0.0 else Vector2.from_angle(visual_facing)

func _signature_strike(radius: float, arc: float, power: float, limit: int = 2147483647, push: bool = false) -> bool:
    var facing := _flex_facing()
    var targets: Array[Dictionary] = []
    for enemy: Dictionary in enemies:
        var offset: Vector2 = enemy["pos"]-player_pos
        if run_time < float(enemy.get("born",0.0)) or float(enemy["hp"]) <= 0.0: continue
        if offset.length() > radius or absf(facing.angle_to(offset)) > deg_to_rad(arc*0.5): continue
        if not SoloWorldRulesScript.clear_line(player_pos,enemy["pos"]): continue
        targets.append(enemy)
    targets.sort_custom(func(a: Dictionary,b: Dictionary) -> bool:
        var da := player_pos.distance_squared_to(a["pos"])
        var db := player_pos.distance_squared_to(b["pos"])
        return int(a["id"]) < int(b["id"]) if is_equal_approx(da,db) else da < db)
    var hit := false
    for enemy: Dictionary in targets.slice(0,mini(limit,targets.size())):
        if mode != "playing": break
        var before: float = float(enemy["hp"])+float(enemy.get("shield",0.0))
        var previous_damage: float = run_metrics["damage"]
        _hit_enemy(enemy,power)
        run_metrics["flex_damage"] = float(run_metrics["flex_damage"])+float(run_metrics["damage"])-previous_damage
        hit = hit or float(enemy["hp"])+float(enemy.get("shield",0.0)) < before
        if push and enemies.has(enemy):
            if enemy["kind"] == "boss": _stagger_enemy(enemy,10.0)
            elif not bool(SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"]):
                enemy["pos"] = SoloWorldRulesScript.move(enemy["pos"],(Vector2(enemy["pos"])-player_pos).normalized()*40.0,float(enemy["radius"]))
    if mode != "playing": return hit
    hero_state["flex_outline"] = {"until":run_time+0.22,"origin":player_pos,"facing":facing,"radius":radius,"arc":arc}
    return hit

func _step_signature_flex() -> void:
    if hero["id"] == "cool-kid":
        var beats := [0.35,1.05,1.75,2.45,3.15,3.85]
        while mode == "playing" and int(hero_state.get("flex_beats",0)) < 6 and flex_age+0.000001 >= float(beats[int(hero_state.get("flex_beats",0))]):
            hero_state["flex_beats"] = int(hero_state.get("flex_beats",0))+1
            var successful := _signature_strike(115.0,110.0,0.20*_base_power(),5)
            if mode != "playing": return
            if successful:
                hero_state["flex_success"] = int(hero_state.get("flex_success",0))+1
        if mode != "playing": return
        if flex_age+0.000001 >= 4.50 and not bool(hero_state.get("flex_finisher",false)):
            hero_state["flex_finisher"] = true
            run_metrics["flex_finishers"] = int(run_metrics["flex_finishers"])+1
            _signature_strike(145.0,130.0,(0.45+0.10*mini(6,int(hero_state.get("flex_success",0))))*_base_power())
            if mode != "playing": return
            hero_state["flex_caption"] = "ENTER!"
            hero_state["flex_caption_until"] = run_time+0.5
    elif hero["id"] == "alpha":
        while mode == "playing" and int(hero_state.get("flex_slams",1)) < 3 and flex_age+0.000001 >= 2.0*float(hero_state.get("flex_slams",1)):
            hero_state["flex_slams"] = int(hero_state.get("flex_slams",1))+1
            _signature_strike(150.0,360.0,0.40*_base_power())
        if mode != "playing": return
        if flex_age+0.000001 >= 5.50 and not bool(hero_state.get("flex_finisher",false)):
            hero_state["flex_finisher"] = true
            run_metrics["flex_finishers"] = int(run_metrics["flex_finishers"])+1
            var scale := 0.50+minf(0.50,2.0*float(hero_state.get("flex_absorbed",0.0))/max_hp)
            _signature_strike(180.0,360.0,scale*_base_power(),2147483647,true)
            if mode != "playing": return
            hero_state["flex_caption"] = "GIGA!"
            hero_state["flex_caption_until"] = run_time+0.5

func _weapon_hit(enemy: Dictionary, damage: float, primary: bool, activation: Dictionary) -> void:
    # Each shared activation qualifies at most once, across projectiles/paired strikes.
    if primary and hero["id"] == "sigma" and flex_time > 0.0 and not enemies.has(sigma_target):
        sigma_target = _nearest_target(600.0)
    var qualifies: bool = primary and hero["id"] == "sigma" and flex_time > 0.0 and enemy == sigma_target and not bool(activation.get("verdict_counted",false)) and run_time >= float(enemy.get("born",0.0))
    _hit_enemy(enemy,damage,primary,true)
    if not qualifies or mode != "playing" or damage <= 0.0: return
    activation["verdict_counted"] = true
    hero_state["verdict_count"] = mini(3,int(hero_state.get("verdict_count",0))+1)
    if int(hero_state["verdict_count"]) == 3 and not bool(hero_state.get("flex_finisher",false)):
        hero_state["flex_finisher"] = true
        hero_state["flex_caption"] = "VERDICT!"
        hero_state["flex_caption_until"] = run_time+0.5
        run_metrics["flex_finishers"] = int(run_metrics["flex_finishers"])+1
        if enemies.has(enemy):
            var previous_damage: float = run_metrics["damage"]
            _hit_enemy(enemy,0.75*_base_power())
            run_metrics["flex_damage"] = float(run_metrics["flex_damage"])+float(run_metrics["damage"])-previous_damage

func flex_status() -> String:
    if flex_time <= 0.0:
        return "FLEX READY  [E]" if aura >= 100.0 and flex_lock <= 0.0 else "FLEX  %d%%" % int(aura)
    var progress := "%d/3" % int(hero_state.get("verdict_count",0)) if hero["id"] == "sigma" else ("%d/6" % int(hero_state.get("flex_beats",0)) if hero["id"] == "cool-kid" else "ABSORB %d" % ceili(float(hero_state.get("flex_absorbed",0.0))))
    return "%s  %.1fs" % [progress,flex_time]

func _move_player(dt: float) -> void:
    for key in blocked_movement.keys():
        if not Input.is_key_pressed(key): blocked_movement.erase(key)
    var direction := Vector2.ZERO
    for key in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
        if not Input.is_key_pressed(key) or blocked_movement.has(key): continue
        if key == KEY_W or key == KEY_UP: direction.y -= 1.0
        if key == KEY_S or key == KEY_DOWN: direction.y += 1.0
        if key == KEY_A or key == KEY_LEFT: direction.x -= 1.0
        if key == KEY_D or key == KEY_RIGHT: direction.x += 1.0
    direction = (direction + touch_direction).limit_length(1.0)
    if direction.length_squared() > 0.01:
        movement_direction = direction
    var speed: float = hero["speed"] * (1.25 if flex_time > 0.0 and hero["id"] == "cool-kid" else 1.0)
    speed *= 1.0 + 0.05 * float(_passive_level("caught-4k"))
    var previous := player_pos
    player_pos = SoloWorldRulesScript.move(player_pos, direction * speed * dt, 16.0)
    visual_moving = direction.length_squared() > 0.01
    visual_walk += player_pos.distance_to(previous)/float(hero["speed"])
    if visual_moving:
        var heading := roundf(direction.angle()/(PI/4))*(PI/4)
        if not visual_direction_known or absf(angle_difference(visual_heading,direction.angle())) > PI/8+0.105:
            visual_heading = heading
        visual_direction_known = true
    else: visual_direction_known = false
    _update_movement_trait(player_pos.distance_squared_to(previous) > 0.000001)
    _update_target_lock()

func _spawn_logic(dt: float) -> void:
    if not boss_spawned and event_index < SoloEnemyRulesScript.EVENT_SCHEDULE.size() and run_time >= float(SoloEnemyRulesScript.EVENT_SCHEDULE[event_index]["at"]):
        var event: Dictionary = SoloEnemyRulesScript.EVENT_SCHEDULE[event_index]
        _spawn_enemy(str(event["kind"]), {"telegraph": true})
        event_index += 1
    if not boss_spawned and run_time >= SoloClock.BOSS_AT:
        boss_spawned = true
        for drop: Dictionary in pickups:
            if drop["kind"] == "aura": _gain_xp(float(drop["xp"]))
        pickups.clear()
        enemies.clear()
        player_shots.clear()
        weapon_areas.clear()
        hostile_shots.clear()
        hazard_zones.clear()
        _spawn_enemy("boss", {"pos":Vector2(724.0, 445.0), "telegraph": true})
    spawn_timer -= dt
    if spawn_timer > 0.0 or enemies.size() >= 100:
        return
    var idx := wave - 1
    spawn_timer = 1.0 / (0.8 * float(WAVE_DENSITY[idx]) * (1.0 + 0.10 * fmod(run_time, SoloClock.WAVE_SECONDS) / SoloClock.WAVE_SECONDS))
    if boss_spawned:
        spawn_timer = 5.0
    else:
        var selected: String = SoloEnemyRulesScript.spawn_kind(wave, run_time, rng)
        var elites := 0
        for living: Dictionary in enemies:
            if bool(living.get("elite", false)): elites += 1
        var elite: bool = wave >= 3 and elites < 2 and rng.randf() < 0.07
        _spawn_enemy(selected, {"telegraph": true, "elite": elite})

func _spawn_enemy(kind: String, special: Dictionary = {}) -> void:
    if not SoloEnemyRulesScript.DATA.has(kind):
        push_error("Unknown GDD enemy ID: " + kind)
        return
    var stats: Dictionary = SoloEnemyRulesScript.DATA[kind]
    var pos: Vector2 = special.get("pos", Vector2.ZERO)
    if not special.has("pos"):
        var candidate = SoloWorldRulesScript.spawn_point(player_pos, rng)
        if candidate == null:
            return
        pos = candidate
    var boss_kind: bool = bool(stats["boss"])
    var elite: bool = bool(special.get("elite", false)) and not boss_kind and kind != "terminal"
    var hp_base: float = float(stats["hp"]) * (1.0 if boss_kind or kind == "terminal" else float(WAVE_HP[wave - 1])) * (2.5 if elite else 1.0)
    var damage: float = float(stats["damage"]) * (1.0 if boss_kind or kind == "terminal" else float(WAVE_DAMAGE[wave - 1])) * (1.3 if elite else 1.0)
    enemies.append({
        "id": next_enemy_id, "angle": (player_pos - pos).angle(), "elite": elite, "born": run_time + (0.8 if bool(special.get("telegraph", false)) else 0.0), "pos": pos, "hp": hp_base, "max": hp_base,
        "speed": float(stats["speed"]), "radius": float(stats["radius"]) * (1.2 if elite else 1.0),
        "damage": damage, "xp": 0 if bool(special.get("add", false)) else (60 if elite else int(stats["xp"])), "kind": kind,
        "add": bool(special.get("add", false)), "next_aux": run_time + (12.0 if kind == "reply-guy" else (10.0 if kind == "mod-supremo" else 7.0)),
        "stagger": 0.0, "stagger_added": 0.0, "stagger_window": -1,
        "stagger_until": 0.0, "stagger_locked": 0.0,
        "ring_phase": false, "beam_phase": false, "exposed_until": 0.0,
        "half_spawned": false, "terminals_spawned": false,
        "hit_cooldown": 0.0, "name": stats["name"], "phase": "",
        "next_attack": run_time + 2.0, "attack_at": 0.0,
        "locked_direction": Vector2.RIGHT, "charge_until": 0.0,
        "attack_slot": 0, "regen_stamp": int(run_time),
        "shield": hp_base * 0.20 if elite else 0.0, "shield_until": INF if elite else 0.0, "hurt_at": -100.0
    })
    next_enemy_id += 1

func _deal_damage_to_player(amount: float, source: Dictionary = {}, contact: bool = false, hazard: bool = false) -> void:
    if mode != "playing" or hp <= 0.0 or amount <= 0.0: return
    if contact and run_time - float(hero_state["last_contact"]) < 0.25: return
    var source_boss: bool = not source.is_empty() and bool(SoloEnemyRulesScript.DATA[source["kind"]]["boss"])
    if contact: hero_state["last_contact"] = run_time
    hurt_timer = 0.18
    var old_hp := hp
    var mitigation := minf(0.60, 1.0 - (1.0 - float(hero["resist"])) * (1.0 - 0.03 * float(_passive_level("thick-skin"))))
    var incoming := amount * (1.0 - mitigation)
    if run_time < float(source.get("weaken_until", 0.0)): incoming *= 1.0 - float(source.get("weaken", 0.0))
    if flex_time > 0.0 and contact and not source.is_empty() and not source_boss and not hazard:
        var before_flex := incoming
        if hero["id"] == "cool-kid": incoming *= 0.85
        elif hero["id"] == "alpha": incoming *= 0.80
        run_metrics["flex_prevented"] = float(run_metrics["flex_prevented"])+before_flex-incoming
    var absorbed := minf(shield, incoming)
    shield -= absorbed
    run_metrics["protection"] = float(run_metrics["protection"]) + absorbed
    var weapon_absorption := absorbed
    for shield_source: String in weapon_shields:
        var entry: Dictionary = weapon_shields[shield_source]
        var consumed := minf(float(entry["remaining"]), weapon_absorption)
        entry["remaining"] = float(entry["remaining"]) - consumed
        weapon_absorption -= consumed
        if shield_source == "giga-rampage" and flex_time > 0.0:
            hero_state["flex_absorbed"] = float(hero_state.get("flex_absorbed",0.0))+consumed
            run_metrics["flex_absorbed"] = float(run_metrics["flex_absorbed"])+consumed
    hp = maxf(0.0, hp - incoming + absorbed)
    if hero["id"] == "alpha" and not source.is_empty() and not hazard and run_time >= float(hero_state["certified_ready"]):
        hero_state["certified"] = true
        hero_state["certified_ready"] = run_time + 4.0
    if hp <= 0.0:
        _finish(false)
        return
    if old_hp >= max_hp * 0.30 and hp < max_hp * 0.30 and _passive_level("so-back") > 0 and run_time >= float(passive_timers.get("so_back_ready", 0.0)):
        passive_timers["so_back_ready"] = run_time + 45.0
        passive_timers["so_back_remaining"] = 5
        passive_timers["so_back_next"] = run_time + 1.0
        _grant_weapon_shield("so-back", max_hp * 0.10, 3.0)
    if old_hp >= max_hp * 0.25 and hp < max_hp * 0.25 and _passive_level("too-sigma") > 0 and run_time >= float(passive_timers.get("too_sigma_ready", 0.0)):
        passive_timers["too_sigma_ready"] = run_time + 60.0
        _grant_weapon_shield("too-sigma", max_hp * 0.25, 5.0)

func _spawn_hostile_shot(enemy: Dictionary) -> void:
    var dir: Vector2 = enemy["locked_direction"]
    hostile_shots.append({
        "pos":enemy["pos"], "dir":dir, "speed":450.0 if enemy["kind"] == "ping-sniper" else 180.0,
        "remaining":800.0, "damage":float(enemy["damage"]), "radius":7.0, "source": enemy
    })

func _step_hostile_shots(dt: float) -> void:
    for shot: Dictionary in hostile_shots.duplicate():
        var distance: float = float(shot["speed"]) * dt
        var start: Vector2 = shot["pos"]
        var ending: Vector2 = start + shot["dir"] * distance
        shot["pos"] = ending
        shot["remaining"] = float(shot["remaining"]) - distance
        if not SoloWorldRulesScript.clear_line(start, ending) or float(shot["remaining"]) <= 0.0 or not FIELD.has_point(ending):
            hostile_shots.erase(shot)
            continue
        if ending.distance_to(player_pos) < 16.0 + float(shot["radius"]):
            _deal_damage_to_player(float(shot["damage"]), shot.get("source", {}))
            hostile_shots.erase(shot)

func _cue_enemy_pose(enemy: Dictionary, impact: float, duration: float, heading: Vector2) -> void:
    if enemy.is_empty(): return
    var previous: Dictionary = enemy.get("attack_pose",{})
    if not previous.is_empty() and run_time < float(previous["impact"]): return
    enemy["attack_pose"] = {"start":run_time,"impact":impact,"end":impact+duration+0.22,"angle":heading.angle()}

func _schedule_hazard(point: Vector2, radius: float, delay: float, active_duration: float, damage: float, shape: String = "circle", heading: Vector2 = Vector2.RIGHT, source: Dictionary = {}) -> void:
    _cue_enemy_pose(source,run_time+delay,active_duration,heading)
    hazard_zones.append({
        "pos":point, "radius":radius, "at":run_time + delay, "end":run_time + delay + active_duration,
        "next_tick":run_time + delay, "damage":damage, "shape":shape, "dir":heading, "source": source, "hit": false
    })

func _hazard_contains(hazard: Dictionary, point: Vector2, radius: float = 16.0) -> bool:
    var offset: Vector2 = point - Vector2(hazard["pos"])
    var facing: Vector2 = hazard["dir"]
    if hazard["shape"] == "tether":
        return offset.length() <= float(hazard["radius"])
    if hazard["shape"] == "line":
        var along := facing.dot(offset)
        return along >= -radius and along <= float(hazard["radius"]) + radius and absf(facing.cross(offset)) <= 30.0 + radius
    if hazard["shape"] == "ring":
        var expansion := 80.0 + 200.0 * clampf((run_time - float(hazard["at"])) / 1.5, 0.0, 1.0)
        return absf(offset.length() - expansion) <= 12.5 + radius and absf(facing.angle_to(offset)) > deg_to_rad(35.0)
    if hazard["shape"] == "cone":
        return offset.length() <= float(hazard["radius"]) + radius and absf(facing.angle_to(offset)) <= PI / 3.0
    return offset.length() <= float(hazard["radius"]) + radius

func _step_hazards() -> void:
    for hazard: Dictionary in hazard_zones.duplicate():
        if mode != "playing":
            break
        if hazard["shape"] == "tether":
            var caster: Dictionary = hazard["source"]
            if not enemies.has(caster) or player_pos.distance_to(caster["pos"]) > 240.0:
                hazard_zones.erase(hazard)
                continue
            hazard["pos"] = caster["pos"]
        if run_time > float(hazard["end"]):
            hazard_zones.erase(hazard)
            continue
        if run_time < float(hazard["at"]) or run_time < float(hazard["next_tick"]) or bool(hazard.get("hit", false)):
            continue
        if _hazard_contains(hazard, player_pos) and SoloWorldRulesScript.clear_line(hazard["pos"], player_pos):
            var source: Dictionary = hazard.get("source", {})
            _deal_damage_to_player(float(hazard["damage"]), source, false, float(hazard["end"]) - float(hazard["at"]) > 1.6 and hazard["shape"] != "tether")
            hazard["hit"] = true
        # Persistent ground zones tick once per second. Expanding rings hit once.
        if float(hazard["end"]) - float(hazard["at"]) > 1.6 and hazard["shape"] != "ring":
            hazard["next_tick"] = run_time + 1.0
            hazard["hit"] = false

func _stagger_enemy(enemy: Dictionary, amount: float) -> void:
    if enemy["kind"] != "boss" or run_time < float(enemy.get("stagger_locked", 0.0)):
        return
    if int(enemy.get("stagger_window", -1)) != int(run_time):
        enemy["stagger_window"] = int(run_time)
        enemy["stagger_added"] = 0.0
    var applied := minf(amount, maxf(0.0, 20.0 - float(enemy["stagger_added"])))
    enemy["stagger_added"] = float(enemy["stagger_added"]) + applied
    enemy["stagger"] = float(enemy.get("stagger", 0.0)) + applied
    if float(enemy["stagger"]) >= 100.0:
        enemy["stagger"] = 0.0
        enemy["stagger_until"] = run_time + 3.0
        enemy["stagger_locked"] = run_time + 23.0
        for hazard: Dictionary in hazard_zones.duplicate():
            if hazard.get("source", {}) == enemy and float(hazard["at"]) > run_time:
                hazard_zones.erase(hazard)

func _enemy_auxiliary(enemy: Dictionary, facing: Vector2) -> void:
    var kind: String = enemy["kind"]
    if kind == "mod-supremo" and float(enemy["hp"]) < float(enemy["max"]) * 0.5 and not bool(enemy["half_spawned"]):
        enemy["half_spawned"] = true
        _spawn_enemy("hater", {"telegraph": true})
        _spawn_enemy("hater", {"telegraph": true})
    if run_time < float(enemy.get("next_aux", 1e9)):
        return
    if kind == "reply-guy":
        for i in range(4): _spawn_enemy("npc", {"telegraph": true})
        enemy["next_aux"] = run_time + 12.0
    elif kind == "mod-supremo":
        for angle in [-0.5, 0.5]:
            _schedule_hazard(enemy["pos"], 500.0, 1.0, 0.2, 15.0, "line", facing.rotated(angle), enemy)
        enemy["next_aux"] = run_time + 10.0
    elif kind == "doomscroll-prime" and run_time >= terminals_interrupt_until:
        _schedule_hazard(player_pos, 100.0, 1.0, 3.0, 12.0, "circle", facing, enemy)
        var second = SoloWorldRulesScript.spawn_point(player_pos, rng)
        if second != null:
            _schedule_hazard(second, 100.0, 1.0, 3.0, 12.0, "circle", facing, enemy)
        enemy["next_aux"] = run_time + 7.0

func _step_enemies(dt: float) -> void:
    for enemy: Dictionary in enemies.duplicate():
        if mode != "playing": return
        if not enemies.has(enemy) or run_time < float(enemy.get("born", 0.0)): continue
        for pending: Dictionary in hazard_zones:
            if pending.get("source", {}) == enemy and pending.get("tracking", false) and not pending.get("locked", false):
                pending["pos"] = enemy["pos"]
                pending["dir"] = (player_pos - Vector2(enemy["pos"])).normalized()
                if enemy.has("attack_pose"): enemy["attack_pose"]["angle"] = Vector2(pending["dir"]).angle()
                if run_time >= float(pending["lock_at"]): pending["locked"] = true
        enemy["anim_moving"] = false
        var kind: String = enemy["kind"]
        var pos: Vector2 = enemy["pos"]
        var to_player: Vector2 = player_pos - pos
        var distance: float = to_player.length()
        var direction: Vector2 = to_player.normalized() if distance > 0.01 else Vector2.RIGHT
        enemy["angle"] = rotate_toward(float(enemy.get("angle", 0.0)), direction.angle(), PI * 0.5 * dt)
        var speed: float = float(enemy["speed"])
        if kind == "terminal":
            continue
        if kind == "boss":
            if run_time < SoloClock.BERSERK_AT:
                enemy["regen_stamp"] = int(run_time)
            elif int(run_time) > int(enemy["regen_stamp"]):
                if run_time >= float(enemy["stagger_until"]):
                    enemy["hp"] = minf(float(enemy["max"]), float(enemy["hp"]) + float(enemy["max"]) * 0.001)
                enemy["regen_stamp"] = int(run_time)

        if run_time < float(enemy.get("stagger_until", 0.0)):
            continue
        _enemy_auxiliary(enemy, to_player.normalized())
        if kind == "boss":
            for hazard: Dictionary in hazard_zones:
                if hazard.get("source", {}) == enemy and float(hazard["at"]) > run_time:
                    speed = 0.0
                    break
        if kind == "hater" or kind == "ping-sniper":
            var preferred: float = 260.0 if kind == "hater" else 400.0
            if run_time < float(enemy.get("taunt_until", 0.0)): preferred = 0.0
            if distance < preferred - 20.0:
                direction = -direction
            elif absf(distance - preferred) < 20.0:
                speed = 0.0
        if enemy["phase"] == "charging":
            direction = enemy["locked_direction"]
            speed = 320.0
            if run_time >= float(enemy["charge_until"]):
                enemy["phase"] = ""
                speed = float(enemy["speed"])
        if float(enemy.get("slow_until", 0.0)) > run_time:
            speed *= 1.0 - minf(0.40, float(enemy.get("slow", 0.0))) * (0.5 if bool(SoloEnemyRulesScript.DATA[kind]["boss"]) else 1.0)
        if run_time >= float(enemy.get("recover_from", INF)) and run_time < float(enemy.get("recover_until", 0.0)):
            speed = 0.0
        if distance > float(enemy["radius"]) + 19.0:
            var destination: Vector2
            if enemy["phase"] == "charging":
                # Committed charges retain their locked direction; steering
                # must never turn a telegraphed charge around an obstacle.
                destination = SoloWorldRulesScript.move(pos,direction*speed*dt,float(enemy["radius"]))
            else:
                var goal := player_pos if direction.dot(to_player) >= 0.0 else pos+direction*120.0
                destination = EnemyNavigationScript.move(pos,goal,speed*dt,float(enemy["radius"]),enemy)
            enemy["pos"] = destination
            var travelled := destination.distance_to(pos)
            enemy["anim_moving"] = travelled > 0.001
            enemy["anim_walk"] = float(enemy.get("anim_walk",0.0))+travelled/maxf(5.0,float(enemy["speed"])/9.0)
        enemy["hit_cooldown"] = maxf(0.0, float(enemy["hit_cooldown"]) - dt)
        if distance <= float(enemy["radius"]) + 18.0 and float(enemy["hit_cooldown"]) == 0.0:
            enemy["hit_cooldown"] = 1.0 if kind == "boss" else 0.75
            var boss_mult := 1.0
            if kind == "boss" and run_time >= SoloClock.BERSERK_AT:
                boss_mult = minf(3.0, 2.0 * pow(1.1, floorf((run_time - SoloClock.BERSERK_AT) / 30.0)))
            var primary_active := false
            for hazard: Dictionary in hazard_zones:
                if hazard.get("source", {}) == enemy and absf(float(hazard["at"]) - run_time) < 0.05:
                    primary_active = true
                    break
            if not primary_active:
                if run_time >= float(enemy.get("attack_pose",{}).get("end",0.0)): _cue_enemy_pose(enemy,run_time,0.12,direction)
                _deal_damage_to_player(float(enemy["damage"]) * boss_mult, enemy, true)
        if mode != "playing":
            return
        if enemy["phase"] == "warning" and run_time >= float(enemy["attack_at"]):
            _spawn_hostile_shot(enemy)
            enemy["phase"] = ""
            enemy["next_attack"] = run_time + (6.0 if kind == "ping-sniper" else 3.0)
        elif (kind == "hater" or kind == "ping-sniper") and enemy["phase"] == "" and run_time >= float(enemy["next_attack"]):
            if kind == "hater" and not SoloWorldRulesScript.clear_line(pos, player_pos):
                enemy["next_attack"] = run_time + 0.1
                continue
            enemy["phase"] = "warning"
            enemy["attack_at"] = run_time + (1.2 if kind == "ping-sniper" else 0.6)
            enemy["locked_direction"] = to_player.normalized()
            _cue_enemy_pose(enemy,float(enemy["attack_at"]),0.16,to_player.normalized())

        if run_time < float(enemy["next_attack"]):
            continue
        if kind == "ratio-ram" or kind == "ohio-express":
            if enemy["phase"] == "":
                enemy["phase"] = "charge-warning"
                enemy["attack_at"] = run_time + (0.9 if kind == "ratio-ram" else 0.8)
                enemy["locked_direction"] = to_player.normalized()
                _cue_enemy_pose(enemy,float(enemy["attack_at"]),280.0/320.0,to_player.normalized())
            elif enemy["phase"] == "charge-warning" and run_time >= float(enemy["attack_at"]):
                enemy["phase"] = "charging"
                enemy["charge_until"] = run_time + 280.0 / 320.0
                var charge_count: int = int(enemy.get("charge_count", 0))
                enemy["charge_count"] = charge_count + 1
                enemy["next_attack"] = run_time + (5.0 if kind == "ratio-ram" else (1.7 if charge_count % 3 < 2 else 5.6))
                if kind == "ohio-express" and charge_count % 3 == 2:
                    enemy["recover_from"] = enemy["charge_until"]
                    enemy["recover_until"] = float(enemy["charge_until"]) + 2.0
        elif kind == "doomscroller":
            _schedule_hazard(player_pos, 70.0, 1.0, 3.0, float(enemy["damage"]), "circle", Vector2.RIGHT, enemy)
            enemy["next_attack"] = run_time + 6.0
        elif kind == "hype-bot":
            _cue_enemy_pose(enemy,run_time,0.2,direction)
            var count := 0
            for ally: Dictionary in enemies:
                if ally != enemy and not bool(SoloEnemyRulesScript.DATA[ally["kind"]]["boss"]) and Vector2(ally["pos"]).distance_to(pos) <= 160.0:
                    ally["shield"] = float(ally["max"]) * 0.15
                    ally["shield_until"] = run_time + 4.0
                    count += 1
                    if count == 3: break
            enemy["next_attack"] = run_time + 8.0
        elif kind == "comment-mod":
            _cue_enemy_pose(enemy,run_time,0.2,direction)
            var healed := 0
            for ally: Dictionary in enemies:
                if ally != enemy and ally["kind"] != "comment-mod" and not bool(SoloEnemyRulesScript.DATA[ally["kind"]]["boss"]) and Vector2(ally["pos"]).distance_to(pos) <= 180.0:
                    ally["hp"] = minf(float(ally["max"]), float(ally["hp"]) + 0.08 * float(ally["max"]))
                    healed += 1
                    if healed == 3: break
            enemy["next_attack"] = run_time + 8.0
        elif kind == "fanum-leech":
            if distance <= 200.0:
                _schedule_hazard(pos, 240.0, 0.8, 2.1, float(enemy["damage"]) * 0.5, "tether", to_player.normalized(), enemy)
            enemy["next_attack"] = run_time + 5.0
        elif kind == "reply-guy":
            _schedule_hazard(pos, 260.0, 0.8, 0.2, 18.0, "cone", to_player.normalized(), enemy)
            enemy["recover_from"] = run_time + 0.8
            enemy["recover_until"] = run_time + 2.3
            enemy["next_attack"] = run_time + 4.0
        elif kind == "mod-supremo":
            _schedule_hazard(pos, 130.0, 1.0, 0.2, 28.0, "circle", to_player.normalized(), enemy)
            enemy["next_attack"] = run_time + 6.0
        elif kind == "doomscroll-prime":
            _schedule_hazard(pos, 400.0, 0.6, 0.15, 18.0, "cone", to_player.normalized(), enemy)
            enemy["next_attack"] = run_time + 4.0
            if not bool(enemy["terminals_spawned"]):
                enemy["terminals_spawned"] = true
                _spawn_enemy("terminal", {"pos": Vector2(430, 520), "telegraph": true})
                _spawn_enemy("terminal", {"pos": Vector2(1050, 730), "telegraph": true})
        elif kind == "boss":
            var slot: int = int(enemy["attack_slot"]) % 4
            enemy["attack_slot"] = slot + 1
            var multi := 1.0 if run_time < SoloClock.BERSERK_AT else minf(3.0, 2.0 * pow(1.1, floorf((run_time - SoloClock.BERSERK_AT) / 30.0)))
            if slot == 0:
                _schedule_hazard(pos, 200.0, 1.0, 0.12, 35.0 * multi, "cone", to_player.normalized(), enemy)
                hazard_zones.back()["tracking"] = true
                hazard_zones.back()["lock_at"] = run_time + 0.7
                enemy["recover_from"] = run_time + 1.0
                enemy["recover_until"] = run_time + 2.2
            elif slot == 1:
                _schedule_hazard(pos, 600.0, 1.2, 0.1, 30.0 * multi, "line", to_player.normalized(), enemy)
                if bool(enemy["beam_phase"]):
                    _schedule_hazard(pos, 600.0, 1.3, 2.0, 8.0 * multi, "line", to_player.normalized(), enemy)
            elif slot == 2:
                _schedule_hazard(pos, 280.0, 1.0, 1.5, 25.0 * multi, "ring", to_player.normalized(), enemy)
                if bool(enemy["ring_phase"]):
                    _schedule_hazard(pos, 280.0, 1.8, 1.5, 25.0 * multi, "ring", to_player.normalized(), enemy)
            else:
                for add_kind in ["npc", "npc", "npc", "npc", "hype-bot"]:
                    var add_count := 0
                    for living: Dictionary in enemies:
                        if bool(living.get("add", false)): add_count += 1
                    if add_count < 8:
                        _spawn_enemy(add_kind, {"add": true, "telegraph": true})
            enemy["next_attack"] = run_time + (4.8 if run_time >= SoloClock.BERSERK_AT else 6.0)
        else:
            enemy["next_attack"] = run_time + 1.0

func _fire_weapons(dt: float) -> void:
    for weapon: Dictionary in weapons:
        weapon["timer"] = maxf(0.0, float(weapon["timer"]) - dt)
        if float(weapon["timer"]) > 0.0:
            continue
        var config: Dictionary = WEAPONS[weapon["id"]]
        var reach: float = float(config["range"])
        if hero["role"] == "ranged":
            reach *= SoloPassiveRulesScript.ranged_range_scale(passives)
        var closest := _nearest_target(reach)
        if closest.is_empty():
            weapon["timer"] = 0.10
            continue
        var weapon_id: String = weapon["id"]
        var count: int = int(weapon_activations.get(weapon_id, 0)) + 1
        weapon_activations[weapon_id] = count
        var legendary: bool = weapon["rarity"] == "legendary"
        var frequency: float = SoloPassiveRulesScript.weapon_frequency(passives, passive_timers, run_time, player_pos)
        weapon["timer"] = maxf(0.20, float(config["interval"]) * pow(0.95, int(weapon["level"]) - 1) / (1.0 + frequency))
        var power: float = float(hero["power"]) * float(config["power"])
        power *= float(RARITY_POWER[weapon["rarity"]]) * (1.0 + 0.15 * float(int(weapon["level"]) - 1))
        power *= SoloPassiveRulesScript.weapon_damage(passives, level, flex_time > 0.0, run_time, passive_timers, cook_stacks, cook_expires)
        if bool(hero_state.get("certified", false)):
            power *= 1.20
            hero_state["certified"] = false
        var secondary_power := power
        var shape: String = config["shape"]
        var streak := false
        if hero["role"] == "ranged":
            directional_hits += 1
            streak = _passive_level("no-cap-streak") > 0 and directional_hits % 5 == 0
        if streak:
            power *= 1.10
        if shape == "pulse" or shape == "blast" or shape == "cone":
            var center: Vector2 = player_pos if shape != "blast" else closest["pos"]
            var radius: float = (reach if shape != "blast" else 100.0) * SoloPassiveRulesScript.area_scale(passives)
            var facing: Vector2 = _aim_direction(closest)
            var arc := 360.0
            if shape == "cone":
                arc = 100.0
                if weapon["id"] == "ban-hammer": arc = 120.0
                if weapon["id"] == "touch-grass": arc = 180.0
                if weapon["id"] == "chad-hands": arc = 90.0
            var delay := 0.45 if shape == "blast" else (0.30 if weapon["id"] == "ban-hammer" else 0.0)
            var paired: bool = weapon["id"] == "keyboard-warrior" or weapon["id"] == "chad-hands"
            var activation := {"hit": false, "chad_counted": false, "slam": false, "id": weapon_id + ":" + str(count)}
            if legendary and weapon_id == "touch-grass" and count % 3 == 0:
                radius = 150.0 * SoloPassiveRulesScript.area_scale(passives)
                arc = 360.0
                power *= 1.25
            _queue_weapon_area(str(weapon["id"]), center, facing, radius, arc, power * (0.5 if paired else 1.0), delay, activation)
            var queued: Dictionary = weapon_areas.back()
            queued["legendary"] = legendary
            queued["weapon_power"] = float(RARITY_POWER[weapon["rarity"]]) * (1.0 + 0.15 * float(int(weapon["level"]) - 1))
            queued["shield_legend"] = legendary and weapon_id == "cope-shield" and count % 3 == 0
            queued["enhanced_grass"] = legendary and weapon_id == "touch-grass" and count % 3 == 0
            if paired:
                _queue_weapon_area(weapon_id, center, facing, radius, arc, power * 0.5, 0.12 if weapon_id == "keyboard-warrior" else 0.18, activation, {"second": true, "legendary": legendary})
            if legendary:
                if weapon_id == "brainrot-feed":
                    var shared_hits: Array = []
                    var sideways := Vector2(-facing.y, facing.x)
                    for offset in [-80.0, 0.0, 80.0]:
                        _queue_weapon_area(weapon_id, center + sideways * offset, facing, 65.0 * SoloPassiveRulesScript.area_scale(passives), 360.0, secondary_power * 0.15 / 0.65, 0.75, activation, {"primary": false, "hit_memory": shared_hits})
                elif weapon_id == "keyboard-warrior" and count % 3 == 0:
                    _queue_weapon_area(weapon_id, center, facing, 120.0 * SoloPassiveRulesScript.area_scale(passives), 100.0, secondary_power * 0.25 / 0.36, 0.24, activation, {"primary": false})
                elif weapon_id == "personal-space" and count % 2 == 0:
                    _grant_weapon_shield("my-aura", max_hp * 0.04, 3.0)
                elif weapon_id == "ban-hammer":
                    _queue_weapon_area(weapon_id, center, facing, 220.0, 360.0, secondary_power * 0.30 / 0.90, 0.80, activation, {"primary": false, "shape": "line"})
            attack_flash = 0.22
            attack_target = closest["pos"]
            visual_facing = (attack_target-player_pos).angle()
        else:
            var heading: Vector2 = _aim_direction(closest)
            var pierce: int = (4 if shape == "line" else 1) + (_passive_level("no-cap-streak") if streak else 0)
            if hero["id"] == "sigma" and flex_time > 0.0:
                pierce += 1
            _queue_player_shot(weapon_id, heading, power, reach, pierce)
            if legendary and weapon_id == "ratio-blaster" and count % 4 == 0:
                _queue_player_shot(weapon_id, heading, secondary_power * 0.10 / 0.20, reach, 1, false, 0.08)
                _queue_player_shot(weapon_id, heading, secondary_power * 0.10 / 0.20, reach, 1, false, 0.16)
            elif legendary and weapon_id == "no-cap":
                _queue_weapon_area(weapon_id, player_pos, heading, reach, 360.0, secondary_power * 0.25 / 0.50, 0.70, {"hit": false}, {"primary": false, "shape": "line"})
            attack_flash = 0.22
            attack_target = closest["pos"]
            visual_facing = (attack_target-player_pos).angle()
    _step_weapon_areas()

func _queue_player_shot(id: String, heading: Vector2, damage: float, reach: float, pierce: int, primary: bool = true, delay: float = 0.0) -> void:
    player_shots.append({
        "id": id, "pos": player_pos, "direction": heading,
        "speed": (750.0 if id == "no-cap" else 650.0) * reach / float(WEAPONS[id]["range"]),
        "remaining": reach, "radius": 16.0 if id == "no-cap" else 6.0,
        "damage": damage, "pierce": pierce, "hit": [], "activated": false,
        "primary": primary, "activation": {}, "at": run_time + delay
    })

func _queue_weapon_area(id: String, center: Vector2, facing: Vector2, radius: float, arc: float, damage: float, delay: float, activation: Dictionary, options: Dictionary = {}) -> void:
    var area: Dictionary = {
        "id": id, "center": center, "facing": facing, "radius": radius,
        "arc": arc, "damage": damage, "at": run_time + delay, "activation": activation,
        "primary": true, "shape": "sector", "hit_memory": [], "end": run_time + delay + 0.12, "impact_shown": false
    }
    area.merge(options, true)
    weapon_areas.append(area)

func _weapon_area_reaches(area: Dictionary, enemy: Dictionary) -> bool:
    if run_time < float(enemy.get("born",0.0)) or area["hit_memory"].has(int(enemy["id"])):
        return false
    var relative: Vector2 = Vector2(enemy["pos"]) - Vector2(area["center"])
    var facing: Vector2 = area["facing"]
    var radius: float = area["radius"]
    if area["shape"] == "line":
        var along := facing.dot(relative)
        if along < -float(enemy["radius"]) or along > radius + float(enemy["radius"]) or absf(facing.cross(relative)) > 15.0 + float(enemy["radius"]):
            return false
    elif relative.length() > radius + float(enemy["radius"]):
        return false
    return absf(facing.angle_to(relative)) <= deg_to_rad(float(area["arc"])*0.5) and SoloWorldRulesScript.clear_line(area["center"],enemy["pos"])

func _qualify_chad_activation(area: Dictionary) -> void:
    var activation: Dictionary = area["activation"]
    if not bool(area["primary"]) or area["id"] != "chad-hands" or bool(activation.get("chad_counted",false)):
        return
    # Resolve the successful activation before visiting damage recipients. The second
    # punch may be the first hit; its full slam cannot depend on enemy array order.
    var connects := false
    for candidate: Dictionary in enemies:
        if _weapon_area_reaches(area,candidate):
            connects = true
            break
    if not connects: return
    activation["chad_counted"] = true
    chad_successful_activations += 1
    if chad_successful_activations % 3 != 0: return
    activation["slam"] = true
    # Every pending area already exists in this array, including the current one.
    # Appending the current dictionary again would multiply its damage twice.
    for second: Dictionary in weapon_areas:
        if second["activation"] == activation and bool(second.get("second",false)):
            second["damage"] = float(second["damage"]) * (0.60 if bool(second.get("legendary",false)) else 0.40) / 0.22
            second["radius"] = (140.0 if bool(second.get("legendary",false)) else 110.0) * SoloPassiveRulesScript.area_scale(passives)
            second["arc"] = 360.0

func _step_weapon_areas() -> void:
    # Capture origin, direction and target at activation, as in Phaser weapons.ts.
    # Shared activation state limits primary passive/Aura procs across paired hits.
    for area: Dictionary in weapon_areas.duplicate():
        if mode != "playing":
            break
        if run_time > float(area["end"]):
            weapon_areas.erase(area)
            continue
        if run_time < float(area["at"]):
            continue
        _qualify_chad_activation(area)
        var center: Vector2 = area["center"]
        var facing: Vector2 = area["facing"]
        var radius: float = area["radius"]
        var shield_awarded := false
        for enemy: Dictionary in enemies.duplicate():
            if mode != "playing":
                break
            if not _weapon_area_reaches(area,enemy):
                continue
            var memory: Array = area["hit_memory"]
            var impact: Vector2 = enemy["pos"]
            var activation: Dictionary = area["activation"]
            var primary: bool = area["primary"]
            memory.append(int(enemy["id"]))
            _weapon_hit(enemy, float(area["damage"]), primary, activation)
            if primary and not bool(activation["hit"]) and mode == "playing":
                activation["hit"] = true
                _primary_activation(impact)
            if primary and enemies.has(enemy):
                if area["id"] == "touch-grass":
                    var enhanced: bool = area.get("enhanced_grass", false)
                    enemy["slow"] = maxf(float(enemy.get("slow", 0.0)) if float(enemy.get("slow_until", 0.0)) > run_time else 0.0, 0.25 if enhanced else 0.15)
                    enemy["slow_until"] = run_time + (2.0 if enhanced else 1.5)
                elif area["id"] == "personal-space" and not bool(SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"]):
                    if float(enemy.get("weaken_until", 0.0)) <= run_time or float(enemy.get("weaken", 0.0)) <= 0.08:
                        enemy["weaken"] = 0.08
                        enemy["weaken_until"] = run_time + 2.0
                elif area["id"] == "ban-hammer":
                    _stagger_enemy(enemy, 15.0)
                    if not bool(SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"]):
                        enemy["pos"] = SoloWorldRulesScript.move(enemy["pos"], (Vector2(enemy["pos"]) - player_pos).normalized() * 40.0, float(enemy["radius"]))
            if primary and area["id"] == "cope-shield" and not shield_awarded:
                shield_awarded = true
                _grant_weapon_shield("cope-shield", max_hp * 0.04 * float(area.get("weapon_power", 1.0)), 2.0)
                if bool(area.get("shield_legend", false)):
                    _grant_weapon_shield("unbothered", max_hp * 0.05, 3.0)
        if not bool(area["impact_shown"]):
            area["impact_shown"] = true
            if attack_visuals.size() >= 12:
                attack_visuals.pop_front()
            attack_visuals.append({"id": area["id"], "origin": center, "target": center + facing * radius if area["shape"] == "line" or float(area["arc"]) < 360.0 else center, "life": 0.18})

func _grant_weapon_shield(source: String, raw_amount: float, duration: float) -> void:
    # Weapon sources refresh themselves instead of stacking, and share the 40% cap.
    var previous: float = float(weapon_shields.get(source, {}).get("remaining", 0.0))
    var other := maxf(0.0, shield - previous)
    var amount := minf(maxf(0.0, max_hp * 0.40 - other), raw_amount * SoloPassiveRulesScript.support_scale(passives, true))
    weapon_shields[source] = {"remaining": amount, "until": run_time + duration}
    shield = other + amount

func _expire_weapon_shields() -> void:
    for source: String in weapon_shields.keys():
        var entry: Dictionary = weapon_shields[source]
        if run_time >= float(entry["until"]):
            shield = maxf(0.0, shield - float(entry["remaining"]))
            weapon_shields.erase(source)

func _step_player_shots(dt: float) -> void:
    # Phaser weapons.ts/Run.resolveShots: real travel, cover, range and hit memory.
    # Only the paused simulation clock calls this method; presentation consumes no RNG.
    for shot: Dictionary in player_shots.duplicate():
        if mode != "playing":
            break
        if run_time < float(shot.get("at", 0.0)):
            continue
        var previous: Vector2 = shot["pos"]
        var travel: float = float(shot["speed"]) * dt
        shot["pos"] = previous + Vector2(shot["direction"]) * travel
        shot["remaining"] = float(shot["remaining"]) - travel
        if float(shot["remaining"]) <= 0.0 or not SoloWorldRulesScript.clear_line(previous, shot["pos"]):
            player_shots.erase(shot)
            continue
        for enemy: Dictionary in enemies.duplicate():
            if mode != "playing":
                break
            if run_time < float(enemy.get("born", 0.0)): continue
            if shot["hit"].has(int(enemy["id"])):
                continue
            if Vector2(shot["pos"]).distance_to(enemy["pos"]) > float(enemy["radius"]) + float(shot["radius"]):
                continue
            shot["hit"].append(int(enemy["id"]))
            var impact: Vector2 = enemy["pos"]
            var primary: bool = shot.get("primary", true)
            _weapon_hit(enemy, float(shot["damage"]), primary, shot["activation"])
            if primary and not bool(shot["activated"]) and mode == "playing":
                shot["activated"] = true
                _primary_activation(impact)
            if shot["hit"].size() >= int(shot["pierce"]):
                player_shots.erase(shot)
                break

func _hit_enemy(enemy: Dictionary, amount: float, primary: bool = false, weapon: bool = false) -> void:
    if mode != "playing" or not enemies.has(enemy) or run_time < float(enemy.get("born", 0.0)) or amount <= 0.0:
        return
    amount *= SoloPassiveRulesScript.damage_to_target(passives, enemy, player_pos, primary or weapon)
    if primary or weapon:
        if hero["id"] == "sigma" and int(hero_state["lock_id"]) == int(enemy["id"]) and run_time - float(hero_state["lock_since"]) >= 2.0:
            amount *= 1.10
        if hero["id"] == "cool-kid" and float(hero_state["moving_since"]) >= 0.0 and run_time - float(hero_state["moving_since"]) >= 3.0:
            amount *= 1.10
    if primary:
        if hero["id"] == "sigma" and flex_time > 0.0 and enemy == sigma_target:
            amount *= 1.40
    if enemy["kind"] == "beta":
        var front := Vector2.from_angle(float(enemy["angle"]))
        if absf(front.angle_to(player_pos - Vector2(enemy["pos"]))) <= deg_to_rad(50.0): amount *= 0.60
    if enemy["kind"] == "boss":
        var exposed := 1.15 if run_time < float(enemy.get("stagger_until", 0.0)) else (1.10 if run_time < float(enemy.get("exposed_until", 0.0)) else 1.0)
        amount *= exposed
        if run_time >= SoloClock.BERSERK_AT:
            amount *= 0.65
    if float(enemy.get("shield_until", 0.0)) > run_time and float(enemy.get("shield", 0.0)) > 0.0:
        var blocked: float = minf(amount, float(enemy["shield"]))
        enemy["shield"] = float(enemy["shield"]) - blocked
        amount -= blocked
    run_metrics["damage"] = float(run_metrics["damage"]) + minf(maxf(0.0, float(enemy["hp"])), maxf(0.0, amount))
    enemy["hurt_at"] = run_time
    enemy["hp"] = float(enemy["hp"]) - amount
    if enemy["kind"] == "boss":
        if float(enemy["hp"]) <= float(enemy["max"]) * 0.70: enemy["ring_phase"] = true
        if float(enemy["hp"]) <= float(enemy["max"]) * 0.35: enemy["beam_phase"] = true
    if float(enemy["hp"]) <= 0.0:
        if enemy["kind"] == "copium-puffer":
            _schedule_hazard(Vector2(enemy["pos"]), 80.0, 1.0, 3.0, float(enemy["damage"]), "circle", Vector2.RIGHT, enemy)
        var visual: Dictionary = enemy.duplicate(true)
        visual["defeated_at"] = run_time
        defeated_visuals.append(visual)
        if defeated_visuals.size() > 64: defeated_visuals.pop_front()
        enemies.erase(enemy)
        kills += 1
        if enemy["kind"] == "boss":
            _finish(true)
            return
        if enemy["kind"] == "terminal":
            terminals_destroyed += 1
            if terminals_destroyed % 2 == 0:
                terminals_interrupt_until = run_time + 4.0
            return
        if bool(enemy.get("add", false)):
            if enemy["kind"] == "hype-bot":
                for boss: Dictionary in enemies:
                    if boss["kind"] == "boss": boss["exposed_until"] = run_time + 3.0
            return
        pickups.append({"pos": enemy["pos"], "xp": float(enemy["xp"]), "kind": "aura"})
        _spawn_special_drop(enemy)
        if SoloEnemyRulesScript.is_event(str(enemy["kind"])) and flex_time <= 0.0:
            aura = minf(100.0, aura + 10.0)

func _spawn_special_drop(enemy: Dictionary) -> void:
    var kind: String = RecoveryRulesScript.special_for(rng.randf(), bool(enemy.get("elite", false)))
    if kind.is_empty(): return
    var existing: Array[Dictionary] = []
    for drop: Dictionary in pickups:
        if drop["kind"] == kind: existing.append(drop)
    if existing.size() >= RecoveryRulesScript.SPECIAL_LIMIT: pickups.erase(existing[0])
    pickups.append({"pos":Vector2(enemy["pos"]) + Vector2(18,-12), "xp":0.0, "kind":kind})
    var key := "snacks_spawned" if kind == "snack" else "magnets_spawned"
    recovery_counts[key] = int(recovery_counts.get(key,0)) + 1

func _pickup_cue(kind: String, point: Vector2, text: String) -> void:
    if pickup_feedback.size() >= 24: pickup_feedback.pop_front()
    pickup_feedback.append({"kind":kind, "pos":point, "text":text, "until":run_time + 0.9})

func _tick_recovery(dt: float) -> void:
    for feedback: Dictionary in pickup_feedback.duplicate():
        if run_time >= float(feedback["until"]): pickup_feedback.erase(feedback)
    if player_pos.distance_to(RecoveryRulesScript.SAFE_SPOT) <= RecoveryRulesScript.SAFE_RADIUS and run_time >= safe_spot_ready_at and hp < max_hp:
        safe_spot_charge = minf(2.0, safe_spot_charge + dt)
        if safe_spot_charge >= 2.0 - 0.00000001:
            _heal_player(max_hp * 0.25 * SoloPassiveRulesScript.support_scale(passives))
            safe_spot_uses += 1
            safe_spot_ready_at = run_time + 90.0
            safe_spot_charge = 0.0
            _pickup_cue("snack", RecoveryRulesScript.SAFE_SPOT, "SAFE SPOT · HP RESTORED")
    else: safe_spot_charge = 0.0

func _collect_drops() -> void:
    for drop: Dictionary in pickups.duplicate():
        # A previous magnet can consume crystals still present in this snapshot.
        if player_pos.distance_to(drop["pos"]) >= RecoveryRulesScript.pickup_radius(drop["kind"]): continue
        if not pickups.has(drop): continue
        pickups.erase(drop)
        if drop["kind"] == "snack":
            recovery_counts["snacks_collected"] = int(recovery_counts.get("snacks_collected",0)) + 1
            _heal_player(0.18 * max_hp * SoloPassiveRulesScript.support_scale(passives))
            _pickup_cue("snack", drop["pos"], "STREET SNACK · HP RESTORED")
        elif drop["kind"] == "magnet":
            recovery_counts["magnets_collected"] = int(recovery_counts.get("magnets_collected",0)) + 1
            var collected := 0.0
            for item: Dictionary in pickups.duplicate():
                if item["kind"] == "aura":
                    collected += float(item["xp"])
                    pickups.erase(item)
            _gain_xp(collected)
            _pickup_cue("magnet", drop["pos"], "AURA MAGNET · ALL XP COLLECTED")
        else: _gain_xp(float(drop["xp"]))
        if mode != "playing": break

func _heal_player(amount: float) -> void:
    var effective := minf(maxf(0.0, amount), maxf(0.0, max_hp - hp))
    hp += effective
    run_metrics["healing"] = float(run_metrics["healing"]) + effective

func _recompute_max_hp() -> void:
    max_hp = (float(hero["hp"]) + 2.0 * float(level - 1)) * (1.0 + 0.08 * float(_passive_level("built-different")))
    hp = minf(hp, max_hp)

func _gain_xp(amount: float) -> void:
    if mode == "won" or mode == "lost" or not is_finite(amount) or amount <= 0.0:
        return
    total_xp += amount
    xp += amount
    while xp >= float(30 + 8 * level + level * level):
        xp -= float(30 + 8 * level + level * level)
        if level < 25:
            level += 1
            _recompute_max_hp()
            hp = minf(max_hp, hp + 2.0)
            pending_choices += 1
        elif run_time >= max_level_heal_at:
            _heal_player(max_hp * 0.05 * SoloPassiveRulesScript.support_scale(passives))
            max_level_heal_at = run_time + 20.0

func _passive_level(id: String) -> int:
    for passive: Dictionary in passives:
        if passive["id"] == id:
            return int(passive["level"])
    return 0

func _generate_legendary_offers() -> void:
    if not legendary_offers.is_empty():
        return
    var legendary_ids: Array[String] = []
    for id in SoloOfferRulesScript.PASSIVE_DATA.keys():
        if SoloOfferRulesScript.PASSIVE_DATA[id]["rarity"] == "legendary":
            legendary_ids.append(id)
    for i in range(legendary_ids.size() - 1, 0, -1):
        var swap_index: int = rng.randi_range(0, i)
        var saved: String = legendary_ids[i]
        legendary_ids[i] = legendary_ids[swap_index]
        legendary_ids[swap_index] = saved
    for i in range(3):
        var id: String = legendary_ids[i]
        var definition: Dictionary = SoloOfferRulesScript.PASSIVE_DATA[id]
        legendary_offers.append({"type":"passive", "id":id, "rarity":"legendary", "level":1, "label":str(definition["name"]) + " · LEGENDARY PASSIVE"})
    for id in WEAPONS.keys():
        if WEAPONS[id]["role"] != hero["role"]:
            continue
        var equipped := false
        for weapon in weapons:
            if weapon["id"] == id:
                equipped = true
                break
        legendary_offers.append({"type":"promote_weapon" if equipped else "weapon", "id":id, "rarity":"legendary", "level":1, "label":str(WEAPONS[id]["name"]) + " · LEGENDARY WEAPON"})

func _open_legendary() -> void:
    if mode != "playing" or legendary_spent or run_time < SoloClock.LEGENDARY_FIRST or run_time >= SoloClock.LEGENDARY_DEADLINE:
        return
    _generate_legendary_offers()
    if legendary_offers.size() != 6:
        push_error("Six legal GDD legendary choices are required")
        return
    if run_time >= SoloClock.LEGENDARY_REPRISE:
        legendary_second_shown = true
    else:
        legendary_first_shown = true
    mode = "legendary"
    selected_card_index = -1
    _clear_touch()
    _show_ui()

func _defer_legendary() -> void:
    if mode != "legendary":
        return
    mode = "playing"
    _show_ui()
    if pending_choices > 0:
        _open_choice()

func _check_legendary_window() -> void:
    if mode != "playing" or legendary_spent or run_time >= SoloClock.LEGENDARY_DEADLINE:
        return
    if run_time >= SoloClock.LEGENDARY_REPRISE and not legendary_second_shown:
        _open_legendary()
    elif run_time >= SoloClock.LEGENDARY_FIRST and not legendary_first_shown:
        _open_legendary()

func _open_choice() -> void:
    if pending_choices <= 0 or mode != "playing":
        return
    selection.clear()
    selection.append_array(SoloOfferRulesScript.choices(str(hero["role"]), wave, weapons, passives, WEAPONS, rng))
    mode = "choice"
    selected_card_index = -1
    _clear_touch()
    _show_ui()

func _replace_target(card: Dictionary) -> void:
    replace_card = card.duplicate(true)
    replace_options.clear()
    var inventory: Array[Dictionary] = weapons if card["type"] == "weapon" else passives
    for item: Dictionary in inventory:
        var name: String = str(WEAPONS[item["id"]]["name"]) if card["type"] == "weapon" else str(SoloOfferRulesScript.PASSIVE_DATA[item["id"]]["name"])
        replace_options.append({"id":item["id"], "label":name + " / " + str(item["rarity"]).to_upper() + " LV " + str(item["level"])})
    mode = "replace"
    selected_card_index = -1
    _clear_touch()
    _show_ui()

func _clear_removed_passive(id: String) -> void:
    var effects := {"w-wifi": ["wifi_until", "wifi_center"], "aura-viral": ["viral_until"], "w-squad": ["w_squad_until"]}
    for key in effects.get(id, []): passive_timers.erase(key)
    if id == "let-him-cook":
        cook_stacks = 0
        cook_expires = 0.0
    if id == "homie-check": passive_timers.erase("homie_count")
    if id == "six-to-seven": passive_timers.erase("six_counter")
    if id == "so-back": passive_timers.erase("so_back_remaining")
    if id == "no-cap-streak": directional_hits = 0
    if weapon_shields.has(id):
        shield = maxf(0.0, shield - float(weapon_shields[id]["remaining"]))
        weapon_shields.erase(id)

func _apply_card(card: Dictionary, replace_id: String = "") -> void:
    var kind: String = card.get("type", "")
    var rarity: String = card.get("rarity", "")
    var previous_ids: Array[String] = []
    for item: Dictionary in passives: previous_ids.append(str(item["id"]))
    var old_max := max_hp
    if kind == "heal":
        _heal_player(max_hp * 0.08 * SoloPassiveRulesScript.support_scale(passives))
    else:
        if not SoloOfferRulesScript.legal_item(str(card.get("id", "")), rarity, int(card.get("level", 0)), str(hero["role"]), WEAPONS) or (rarity == "legendary" and legendary_spent):
            return
        var is_weapon := kind == "weapon" or kind == "upgrade_weapon" or kind == "promote_weapon"
        if WEAPONS.has(card.get("id", "")) != is_weapon: return
        var inventory: Array[Dictionary] = weapons if is_weapon else passives
        var old_index := -1
        for i in range(inventory.size()):
            if inventory[i]["id"] == card["id"]: old_index = i
        if kind == "weapon" or kind == "passive":
            if old_index >= 0 or int(card["level"]) != 1: return
            if inventory.size() >= (3 if is_weapon else 5):
                if replace_id.is_empty():
                    _replace_target(card)
                    return
                var replacement := -1
                for i in range(inventory.size()):
                    if inventory[i]["id"] == replace_id: replacement = i
                if replacement < 0: return
                inventory.remove_at(replacement)
            var item := {"id": card["id"], "rarity": rarity, "level": int(card["level"])}
            if is_weapon: item["timer"] = 0.0
            inventory.append(item)
        elif kind == "upgrade_weapon" or kind == "upgrade_passive" or kind == "promote_weapon":
            if old_index < 0: return
            var old: Dictionary = inventory[old_index]
            if kind == "promote_weapon":
                var ranks := ["common", "rare", "epic", "legendary"]
                if ranks.find(rarity) <= ranks.find(old["rarity"]) or int(card["level"]) != mini(int(old["level"]), int(CAP_LEVELS[rarity])): return
            elif rarity != old["rarity"] or int(card["level"]) != int(old["level"]) + 1:
                return
            old["rarity"] = rarity
            old["level"] = int(card["level"])
        else:
            return
    for id: String in previous_ids:
        if _passive_level(id) == 0: _clear_removed_passive(id)
    _recompute_max_hp()
    hp = minf(max_hp, hp + maxf(0.0, max_hp - old_max))
    var periodic := {"w-wifi": ["wifi_next", 12.0], "big-chad": ["big_chad_next", 10.0], "no-u": ["no_u_next", 15.0]}
    for id in periodic:
        var data: Array = periodic[id]
        if _passive_level(id) > 0 and not passive_timers.has(data[0]): passive_timers[data[0]] = run_time + float(data[1])
    if rarity == "legendary": legendary_spent = true
    else: pending_choices = maxi(0, pending_choices - 1)
    replace_card.clear()
    replace_options.clear()
    mode = "playing"
    _show_ui()
    if pending_choices > 0: _open_choice()

func pick_upgrade(index: int) -> void:
    var count := selection.size() if mode == "choice" else (legendary_offers.size() if mode == "legendary" else (replace_options.size() if mode == "replace" else 0))
    if index < 0 or index >= count: return
    selected_card_index = index
    _show_ui()
    if index < offer_buttons.size() and offer_buttons[index].is_visible_in_tree(): offer_buttons[index].grab_focus()

func _confirm_selection() -> void:
    if mode == "confirm_exit":
        _return_to_menu()
        return
    if mode == "profile_export":
        _return_to_menu()
        return
    if mode == "profile_import":
        _import_profile_text(profile_text.text)
        return
    var index := selected_card_index
    selected_card_index = -1
    if mode == "replace" and index >= 0 and index < replace_options.size() and not replace_card.is_empty():
        _apply_card(replace_card, str(replace_options[index]["id"]))
    elif mode == "legendary" and index >= 0 and index < legendary_offers.size():
        _apply_card(legendary_offers[index])
    elif mode == "choice" and index >= 0 and index < selection.size():
        _apply_card(selection[index])

func _cancel_replacement() -> void:
    if mode != "replace": return
    mode = "legendary" if replace_card.get("rarity") == "legendary" else "choice"
    replace_card.clear()
    replace_options.clear()
    selected_card_index = -1
    _show_ui()
    _update_text()

func _request_return_to_menu() -> void:
    if mode == "replace":
        _cancel_replacement()
    elif mode == "profile_import" or mode == "profile_export":
        _return_to_menu()
    elif mode == "confirm_exit":
        mode = "paused"
    elif mode == "playing" or mode == "paused":
        mode = "confirm_exit"
        _clear_touch()
    else:
        _return_to_menu()
    _show_ui()
    _update_text()

func _apply_preferences() -> void:
    var volume := clampf(float(profile["settings"].get("masterVolume",1.0)),0.0,1.0)
    AudioServer.set_bus_mute(0, not bool(profile["settings"]["sound"]) or volume <= 0.0)
    AudioServer.set_bus_volume_db(0,linear_to_db(maxf(0.0001,volume)))

func _toggle_sound() -> void:
    profile["settings"]["sound"] = not bool(profile["settings"]["sound"])
    _apply_preferences()
    _save_profile()
    _show_ui()

func _toggle_motion() -> void:
    profile["settings"]["reducedMotion"] = not bool(profile["settings"]["reducedMotion"])
    _save_profile()
    _show_ui()

func _open_profile_import() -> void:
    if mode != "menu": return
    mode = "profile_import"
    profile_text.text = ""
    _show_ui()
    _update_text()

func _open_profile_export() -> void:
    if mode != "menu": return
    mode = "profile_export"
    profile_text.text = JSON.stringify(profile, "  ")
    _show_ui()
    _update_text()

func _import_profile_text(raw: String) -> bool:
    if mode != "profile_import" or raw.length() > 1048576: return false
    var value: Variant = ProfileStoreScript.parse_json(raw)
    if not value is Dictionary or (value.get("version") != 2 and value.get("schemaVersion") != 1):
        notice.text = "INVALID SAVE DATA — PROFILE UNCHANGED"
        if presentation != null: presentation.show_error(notice.text)
        return false
    var previous := profile.duplicate(true)
    var imported: Dictionary = ProfileStoreScript.read_data(value if value.get("version") == 2 else null, value if value.get("schemaVersion") == 1 else null)
    for id in previous["unlocked"]:
        if not imported["unlocked"].has(id): imported["unlocked"].append(id)
    var legacy: Dictionary = imported.get("legacy", {}) if imported.get("legacy", {}) is Dictionary else {"phaserSnapshot": imported["legacy"]}
    if not legacy.has("godotBeforeImport"):
        legacy["godotBeforeImport"] = previous
    imported["legacy"] = legacy
    profile = imported
    _save_profile()
    _apply_preferences()
    _return_to_menu()
    return true

func _damage_nearby(radius: float, amount: float) -> void:
    for e: Dictionary in enemies.duplicate():
        if player_pos.distance_to(e["pos"]) <= radius:
            _hit_enemy(e, amount)

func _use_flex() -> void:
    if mode != "playing" or aura < 100.0 or flex_lock > 0.0:
        return
    sigma_target = {}
    if hero["id"] == "sigma":
        sigma_target = _nearest_target(600.0)
        if sigma_target.is_empty():
            return
    aura = 0.0
    run_metrics["flexes"] = int(run_metrics["flexes"]) + 1
    flex_time = float(hero["duration"])
    flex_lock = 30.0
    flex_age = 0.0
    hero_state["flex_slams"] = 1
    hero_state["flex_beats"] = 0
    hero_state["flex_success"] = 0
    hero_state["flex_finisher"] = false
    hero_state["verdict_count"] = 0
    hero_state["flex_absorbed"] = 0.0
    if _passive_level("aura-viral") > 0:
        passive_timers["viral_until"] = run_time + 5.0
    if _passive_level("w-squad") > 0:
        passive_timers["w_squad_until"] = run_time + 6.0
    if hero["id"] == "alpha":
        _grant_weapon_shield("giga-rampage", max_hp * 0.25, 6.0)
        _signature_strike(150.0,360.0,0.40*_base_power())
        for enemy: Dictionary in enemies:
            if not bool(SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"]) and player_pos.distance_to(enemy["pos"]) <= 180.0:
                enemy["taunt_until"] = run_time + 2.0

func _toggle_pause() -> void:
    if mode == "playing":
        mode = "paused"
        _clear_touch()
    elif mode == "paused":
        mode = "playing"
        _clear_touch()
    _show_ui()

func _finish(won: bool) -> void:
    if mode != "playing":
        return
    flex_time = 0.0
    sigma_target = {}
    hero_state["flex_outline"] = {}
    hero_state["flex_caption_until"] = 0.0
    for key in ["flex_beats","flex_success","flex_slams","verdict_count","flex_absorbed","flex_finisher"]: hero_state.erase(key)
    mode = "won" if won else "lost"
    _clear_touch()
    var result := {
        "id": run_id, "hero": str(hero["id"]), "won": won,
        "time": run_time, "wave": wave, "level": level, "kills": kills,
        "xp": total_xp, "damage": run_metrics["damage"], "healing": run_metrics["healing"],
        "protection": run_metrics["protection"], "flexes": run_metrics["flexes"]
    }
    profile = ProfileStoreScript.record(profile, result, mode)
    _save_profile()
    _show_ui()

func _load_profile() -> void:
    profile = ProfileStoreScript.load_profile()
    for index in range(HEROES.size()):
        if HEROES[index]["id"] == profile["selected"]:
            hero_index = index

func _save_profile() -> void:
    storage_available = ProfileStoreScript.save_profile(profile)

func _return_to_menu() -> void:
    mode = "menu"
    _clear_touch()
    _show_ui()
    _update_text()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event.pressed or event.echo:
        return
    if event.keycode == KEY_M and mode == "playing":
        manual_aim = not manual_aim
        aim_point = get_global_mouse_position()
    elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
        if mode in ["menu","heroes"]: start_run(hero_index)
        else: _confirm_selection()
    elif event.keycode == KEY_ESCAPE and mode == "confirm_exit":
        mode = "paused"
        _show_ui()
        _update_text()
    elif event.keycode == KEY_ESCAPE and mode == "replace":
        _cancel_replacement()
    elif event.keycode == KEY_ESCAPE and mode in ["options","build"]:
        presentation.close_auxiliary()
    elif event.keycode == KEY_ESCAPE and mode == "heroes":
        _return_to_menu()
    elif event.keycode == KEY_P or event.keycode == KEY_ESCAPE or event.keycode == KEY_B:
        _toggle_pause()
    if event.keycode == KEY_SPACE or event.keycode == KEY_E:
        _use_flex()
    if event.keycode == KEY_L:
        _open_legendary()
    if mode in ["menu","heroes"] and event.keycode >= KEY_1 and event.keycode <= KEY_3:
        presentation.select_hero(event.keycode - KEY_1)
    elif (mode == "choice" or mode == "replace" or mode == "legendary") and event.keycode >= KEY_1 and event.keycode <= KEY_6:
        pick_upgrade(event.keycode - KEY_1)

func _clear_touch() -> void:
    for key in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
        if Input.is_key_pressed(key): blocked_movement[key] = true
    touch_active = false
    touch_index = -1
    touch_origin = Vector2.ZERO
    touch_direction = Vector2.ZERO
    if touch_joystick != null:
        touch_joystick.call("reset")

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        if mode == "playing": _toggle_pause()
        else: _clear_touch()

func _update_platform(delta: float) -> void:
    platform_poll -= delta
    if platform_poll > 0.0 or not OS.has_feature("web"): return
    platform_poll = 0.5
    var previous: String = JSON.stringify(web_metrics)
    web_metrics = WebPlatformScript.metrics()
    touch_device = touch_device or bool(web_metrics.get("touch",false))
    if JSON.stringify(web_metrics) != previous and presentation != null: presentation._window_changed(true)

func _touch_playfield() -> Rect2:
    var rect := Rect2(Vector2.ZERO,get_viewport_rect().size)
    if presentation != null: rect = Rect2(presentation.position,presentation.view)
    var top := 220.0 if rect.size.x < 700.0 else 100.0
    return Rect2(rect.position+Vector2(0,top),Vector2(rect.size.x*0.48,maxf(0.0,rect.size.y-top-92)))

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode in [KEY_ENTER,KEY_KP_ENTER] and mode in ["menu","heroes"]:
            var focused := get_viewport().gui_get_focus_owner()
            if focused is Button and focused.is_visible_in_tree() and not focused.disabled:
                return # Let the live focused destination/card handle ui_accept.
        if event.keycode in [KEY_ENTER,KEY_KP_ENTER] and mode in ["choice","replace","legendary"]:
            var focused_card := get_viewport().gui_get_focus_owner()
            var focused_index := offer_buttons.find(focused_card)
            if focused_index >= 0 and selected_card_index != focused_index:
                return # First ui_accept selects; a second explicit accept confirms.
        if (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and (mode in ["menu","heroes"] or mode in ["choice","replace","legendary"]):
            if mode in ["menu","heroes"]: start_run(hero_index)
            else: _confirm_selection()
            get_viewport().set_input_as_handled()
            return
        if mode == "playing" and (event.keycode == KEY_E or event.keycode == KEY_SPACE):
            _use_flex()
            get_viewport().set_input_as_handled()
            return
    if event is InputEventScreenTouch and event.pressed and not event.canceled:
        touch_device = true
    if event is InputEventKey and [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT].has(event.keycode):
        if not event.pressed: blocked_movement.erase(event.keycode)
        elif mode != "playing": blocked_movement[event.keycode] = true
    if event is InputEventMouseMotion and mode == "playing":
        aim_point = get_global_mouse_position()
    if event is InputEventScreenTouch:
        if event.index == touch_index and (not event.pressed or event.canceled):
            _clear_touch()
        elif event.pressed and not event.canceled and not touch_active and mode == "playing" and _touch_playfield().has_point(event.position):
            touch_active = true
            touch_index = event.index
            var field := _touch_playfield()
            touch_origin = Vector2(clampf(event.position.x,field.position.x+58,field.end.x-58),clampf(event.position.y,field.position.y+58,field.end.y-58))
            touch_direction = Vector2.ZERO
            touch_joystick.call("show_at", touch_origin, touch_direction)
    elif event is InputEventScreenDrag and touch_active and event.index == touch_index and mode == "playing":
        touch_direction = (event.position - touch_origin).limit_length(85.0) / 85.0
        touch_joystick.call("show_at", touch_origin, touch_direction)

## Option A visual motifs mirror the Phaser browser renderer; collision stays in _advance().
func _draw_contact_shadow(at: Vector2, radius: float) -> void:
    draw_set_transform(at + Vector2(3.0, 5.0), 0.0, Vector2(1.05, 0.30))
    draw_circle(Vector2.ZERO, radius, Color(0.14, 0.20, 0.29, 0.23))
    draw_set_transform(Vector2.ZERO)

func _draw_pickup(drop: Dictionary) -> void:
    var at: Vector2 = drop["pos"]
    var kind := str(drop["kind"])
    var ink := Color(0.14, 0.20, 0.29)
    var paper := Color(0.97, 0.93, 0.80)
    if kind == "aura":
        var pulse := 1.0 if profile["settings"]["reducedMotion"] else 1.0 + 0.08 * sin(run_time * 5.0 + at.x * 0.05)
        var diamond := PackedVector2Array([
            at + Vector2(0, -12) * pulse, at + Vector2(9, 0) * pulse,
            at + Vector2(0, 12) * pulse, at + Vector2(-9, 0) * pulse
        ])
        draw_colored_polygon(diamond, ink)
        draw_colored_polygon(PackedVector2Array([
            at + Vector2(0, -9) * pulse, at + Vector2(6, 0) * pulse,
            at + Vector2(0, 9) * pulse, at + Vector2(-6, 0) * pulse
        ]), Color(0.24, 0.90, 0.82))
        draw_line(at + Vector2(0, -8), at + Vector2(0, 6), paper, 1.5)
    elif kind == "snack":
        draw_circle(at, 16.0, ink)
        draw_rect(Rect2(at - Vector2(12, 12), Vector2(24, 24)), Color(0.44, 0.81, 0.61))
        draw_rect(Rect2(at - Vector2(3, 9), Vector2(6, 18)), paper)
        draw_rect(Rect2(at - Vector2(9, 3), Vector2(18, 6)), paper)
    elif kind == "magnet":
        draw_circle(at, 16.0, ink)
        draw_arc(at + Vector2(0, -2), 9.0, 0.0, PI, 16, paper, 8.0)
        draw_arc(at + Vector2(0, -2), 9.0, 0.0, PI, 16, Color(0.58, 0.46, 0.82), 5.0)
        draw_line(at + Vector2(-9, -4), at + Vector2(-9, -11), paper, 5.0)
        draw_line(at + Vector2(9, -4), at + Vector2(9, -11), paper, 5.0)

func _draw() -> void:
    if mode in ["menu","heroes"] or hero.is_empty():
        if not art.draw_backdrop(self, "ruin-alley", FIELD):
            draw_rect(FIELD, Color(0.12, 0.15, 0.22))
        draw_rect(FIELD, Color(0.025, 0.035, 0.06, 0.67))
        return
    var approved_map: bool = art.draw_backdrop(self, "ruin-alley", FIELD)
    if not approved_map:
        draw_rect(FIELD, Color(0.12, 0.15, 0.22))
    if not approved_map:
        for gx in range(0, 1449, 128):
            draw_line(Vector2(gx, 0), Vector2(gx, FIELD.size.y), Color(0.19, 0.24, 0.31), 2.0)
        for gy in range(0, 1087, 128):
            draw_line(Vector2(0, gy), Vector2(FIELD.size.x, gy), Color(0.19, 0.24, 0.31), 2.0)
    draw_rect(FIELD, Color(0.42, 0.49, 0.53), false, 10.0)
    _draw_recovery()
    for drop: Dictionary in pickups:
        _draw_pickup(drop)
    for zone: Dictionary in hazard_zones:
        var warning: bool = run_time < float(zone["at"])
        var tint := Color(1.0, 0.61, 0.22, 0.8) if warning else Color(0.98, 0.29, 0.31, 0.8)
        var center: Vector2 = zone["pos"]
        var facing: Vector2 = zone["dir"]
        if zone["shape"] == "ring":
            var radius := 80.0 if warning else 80.0 + 200.0 * clampf((run_time - float(zone["at"])) / 1.5, 0.0, 1.0)
            draw_arc(center, radius, facing.angle() + deg_to_rad(35.0), facing.angle() + TAU - deg_to_rad(35.0), 48, tint, 4.0 if warning else 6.0)
        elif zone["shape"] == "tether":
            draw_line(center, player_pos, tint, 3.0)
        elif zone["shape"] == "line":
            draw_line(center, center + facing * float(zone["radius"]), Color(tint, 0.18), 60.0)
            draw_line(center, center + facing * float(zone["radius"]), tint, 3.0)
        elif zone["shape"] == "cone":
            draw_arc(center, float(zone["radius"]), facing.angle() - PI / 3.0, facing.angle() + PI / 3.0, 32, tint, 4.0)
        else:
            draw_arc(center, float(zone["radius"]), 0.0, TAU, 48, tint, 4.0 if warning else 6.0)
    for shot: Dictionary in hostile_shots:
        var shot_pos: Vector2 = shot["pos"]
        var shot_dir: Vector2 = shot["dir"]
        draw_line(shot_pos - shot_dir * 16.0, shot_pos, Color(0.89, 0.45, 0.38), 6.0)
        draw_circle(shot_pos, 5.0, Color(1.0, 0.45, 0.49))
    for area: Dictionary in weapon_areas:
        if area.get("shape", "sector") == "line":
            draw_line(area["center"], Vector2(area["center"]) + Vector2(area["facing"]) * float(area["radius"]), Color(0.97, 0.77, 0.37, 0.65), 3.0)
        elif area["id"] == "brainrot-feed":
            draw_arc(area["center"], float(area["radius"]), 0.0, TAU, 40, Color(0.97, 0.77, 0.37, 0.75), 3.0)
        elif area["id"] == "ban-hammer":
            var heading: float = Vector2(area["facing"]).angle()
            var half_arc: float = deg_to_rad(float(area["arc"]) * 0.5)
            draw_arc(area["center"], float(area["radius"]), heading - half_arc, heading + half_arc, 24, Color(0.97, 0.77, 0.37, 0.65), 3.0)
    for shot: Dictionary in player_shots:
        if run_time < float(shot.get("at", 0.0)):
            continue
        WeaponVisualsScript.draw_attack(self, {
            "id": shot["id"], "origin": Vector2(shot["pos"]) - Vector2(shot["direction"]) * 24.0,
            "target": shot["pos"], "life": 0.18
        })
    for effect: Dictionary in attack_visuals:
        WeaponVisualsScript.draw_attack(self, effect)
    if flex_time > 0.0:
        draw_arc(player_pos, 26.0, 0.0, TAU, 36, Color(1.0, 0.89, 0.36), 5.0)
    var outline: Dictionary = hero_state.get("flex_outline",{})
    if not outline.is_empty() and run_time < float(outline.get("until",0.0)):
        var angle: float = Vector2(outline["facing"]).angle()
        var half: float = deg_to_rad(float(outline["arc"])*0.5)
        var origin: Vector2 = outline["origin"]
        var radius: float = outline["radius"]
        var color := Color("6eaab0") if hero["id"] == "cool-kid" else Color("f8c45f")
        draw_arc(origin,radius,angle-half,angle+half,32,color,2.0)
        if float(outline["arc"]) < 360.0:
            draw_line(origin,origin+Vector2.from_angle(angle-half)*radius,color,2.0)
            draw_line(origin,origin+Vector2.from_angle(angle+half)*radius,color,2.0)
    if flex_time > 0.0 and hero["id"] == "sigma" and enemies.has(sigma_target):
        draw_line(player_pos,sigma_target["pos"],Color("6eaab0"),1.0)
        draw_rect(Rect2(Vector2(sigma_target["pos"])-Vector2(24,28),Vector2(48,56)),Color("f8c45f"),false,2.0)
    _draw_depth_actors()
    if run_time < float(hero_state.get("flex_caption_until",0.0)):
        draw_string(ThemeDB.fallback_font,player_pos+Vector2(-40,-48),str(hero_state.get("flex_caption","")),HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("253449"))

func _draw_depth_actors() -> void:
    var actors: Array[Dictionary] = [{"kind":"hero", "pos":player_pos}]
    for cover: Vector2 in COVERS: actors.append({"kind":"cover", "pos":cover})
    for enemy: Dictionary in enemies: actors.append({"kind":"enemy", "pos":enemy["pos"], "enemy":enemy})
    for defeated: Dictionary in defeated_visuals: actors.append({"kind":"defeated","pos":defeated["pos"],"enemy":defeated})
    actors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return Vector2(a["pos"]).y < Vector2(b["pos"]).y)
    for actor: Dictionary in actors:
        if actor["kind"] == "hero": _draw_hero_actor()
        elif actor["kind"] == "cover": art.draw_cover(self, actor["pos"])
        elif actor["kind"] == "defeated": art.draw_enemy(self,actor["enemy"],run_time,run_time-float(actor["enemy"]["defeated_at"])+finish_visual_age)
        else: _draw_enemy_actor(actor["enemy"])

func _draw_enemy_actor(e: Dictionary) -> void:
    if run_time < float(e.get("born", 0.0)):
        draw_arc(e["pos"], float(e["radius"]) + 8.0, 0.0, TAU, 32, Color(0.97, 0.77, 0.37, 0.75), 3.0)
        return
    var radius: float = float(e["radius"])
    var color := Color(0.89, 0.33, 0.40)
    if e["kind"] == "hater" or e["kind"] == "ping-sniper":
        color = Color(0.92, 0.49, 0.64)
    elif SoloEnemyRulesScript.is_event(str(e["kind"])):
        color = Color(0.79, 0.38, 0.98)
    elif e["kind"] == "boss":
        color = Color(0.99, 0.30, 0.25)
    if e["phase"] == "warning" or e["phase"] == "charge-warning":
        var locked: Vector2 = e["locked_direction"]
        draw_line(Vector2(e["pos"]), Vector2(e["pos"]) + locked * 420.0, Color(1.0, 0.58, 0.24, 0.70), 3.0)
    if float(e.get("shield", 0.0)) > 0.0 and run_time < float(e.get("shield_until", 0.0)):
        draw_arc(e["pos"], radius + 6.0, 0.0, TAU, 32, Color(0.50, 0.81, 0.98), 3.0)
    _draw_contact_shadow(e["pos"], radius)
    if not art.draw_enemy(self, e, run_time):
        draw_circle(e["pos"], radius, color)
    var sprite_height := maxf(52.0, radius * (2.6 if bool(SoloEnemyRulesScript.DATA[e["kind"]]["boss"]) else 3.1))
    var bar_pos: Vector2 = e["pos"] + Vector2(-radius, -sprite_height - 10.0)
    draw_rect(Rect2(bar_pos, Vector2(radius * 2.0, 5.0)), Color(0.13, 0.11, 0.13))
    draw_rect(Rect2(bar_pos, Vector2(radius * 2.0 * maxf(0.0, float(e["hp"]) / float(e["max"])), 5.0)), Color(0.63, 0.92, 0.44))

func hero_pose() -> Dictionary:
    return HeroAnimationScript.pose(str(hero["id"]), {"time":run_time,"walk":visual_walk,"defeat":visual_defeat,"lost":mode == "lost","hurt":hurt_timer,"flex":flex_time,"flex_age":flex_age,"attack":attack_flash,"heading":visual_heading,"moving":visual_moving,"facing":visual_facing})

func _draw_hero_actor() -> void:
    _draw_contact_shadow(player_pos, 19.0)
    if not art.draw_hero_pose(self, player_pos, str(hero["id"]), hero_pose()):
        draw_circle(player_pos, 16.0, hero["color"])
        draw_arc(player_pos, 18.0, 0.0, TAU, 32, Color(0.06, 0.09, 0.15), 3.0)
        draw_circle(player_pos + Vector2(-5, -4), 2.1, Color(0.08, 0.08, 0.10))
        draw_circle(player_pos + Vector2(5, -4), 2.1, Color(0.08, 0.08, 0.10))
    # Hero art uses a foot pivot: keep the health bar above the head.
    draw_rect(Rect2(player_pos + Vector2(-23, -79), Vector2(46, 5)), Color(0.16, 0.13, 0.14))
    draw_rect(Rect2(player_pos + Vector2(-23, -79), Vector2(46.0 * hp / max_hp, 5)), Color(0.27, 0.94, 0.50))

func _draw_recovery() -> void:
    var point: Vector2 = RecoveryRulesScript.SAFE_SPOT
    var cooldown := maxf(0.0, safe_spot_ready_at - run_time)
    var tint := Color("5cf0b4") if cooldown <= 0.0 else Color("8394aa")
    draw_circle(point, 68.0, Color(tint, 0.19))
    draw_arc(point, 68.0, 0.0, TAU, 48, tint, 4.0)
    draw_rect(Rect2(point-Vector2(43,26),Vector2(86,52)),Color("24364a"))
    draw_rect(Rect2(point-Vector2(43,26),Vector2(86,52)),tint,false,3.0)
    draw_rect(Rect2(point-Vector2(5,16),Vector2(10,32)),tint)
    draw_rect(Rect2(point-Vector2(16,5),Vector2(32,10)),tint)
    var progress := safe_spot_charge / 2.0 if cooldown <= 0.0 else 1.0-cooldown/90.0
    if progress > 0.0: draw_arc(point,52.0,-PI/2.0,-PI/2.0+TAU*progress,48,Color("ffd06e"),5.0)
    draw_string(ThemeDB.fallback_font,point+Vector2(-41,90),"SAFE SPOT" if cooldown <= 0.0 else "%ds" % ceili(cooldown),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("fff7da"))
    for feedback: Dictionary in pickup_feedback:
        var age := 0.9 - (float(feedback["until"]) - run_time)
        var offset := Vector2(0,-35.0-(0.0 if profile["settings"]["reducedMotion"] else age*20.0))
        var at: Vector2 = Vector2(feedback["pos"]) + offset
        draw_string_outline(ThemeDB.fallback_font,at,feedback["text"],HORIZONTAL_ALIGNMENT_LEFT,-1,17,5,Color("253449"))
        draw_string(ThemeDB.fallback_font,at,feedback["text"],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("f7edcd"))
