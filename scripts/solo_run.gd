extends Node2D

const ApprovedVisualsScript = preload("res://scripts/approved_visuals.gd")
const SoloOfferRulesScript = preload("res://scripts/solo_offer_rules.gd")
const SoloEnemyRulesScript = preload("res://scripts/solo_enemy_rules.gd")
const SoloPassiveRulesScript = preload("res://scripts/solo_passive_rules.gd")
## Initial GDD-grounded playable solo slice.
## Procedural debug visuals and simplified enemy patterns are NOT final approved art or combat parity.

const HEROES := [
    {"id": "sigma", "name": "THE SIGMA", "role": "ranged", "hp": 100.0, "speed": 180.0, "power": 100.0, "resist": 0.0, "starter": "no-cap", "flex": "Sigma Stare", "duration": 6.0, "color": Color(0.95, 0.71, 0.28)},
    {"id": "cool-kid", "name": "COOL KID", "role": "melee", "hp": 110.0, "speed": 190.0, "power": 95.0, "resist": 0.05, "starter": "keyboard-warrior", "flex": "Giga Chad Rampage", "duration": 5.0, "color": Color(0.37, 0.69, 0.96)},
    {"id": "alpha", "name": "ALPHA CHAD", "role": "tank", "hp": 140.0, "speed": 160.0, "power": 90.0, "resist": 0.15, "starter": "cope-shield", "flex": "Alpha Hold", "duration": 6.0, "color": Color(0.82, 0.45, 0.69)}
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
const EVENTS := [
    {"at": 195.0, "name": "Reply Guy", "hp": 1400.0},
    {"at": 375.0, "name": "Mod Supremo", "hp": 3200.0},
    {"at": 555.0, "name": "Ohio Express", "hp": 2800.0},
    {"at": 735.0, "name": "Doomscroll Prime", "hp": 5200.0}
]

var art = ApprovedVisualsScript.new()
var movement_direction := Vector2.DOWN
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
var spawn_timer := 0.7
var hurt_timer := 0.0
var attack_flash := 0.0
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
var sigma_target: Dictionary = {}
var rng := RandomNumberGenerator.new()
var hero_index := 0
var profile: Dictionary = {"runs": 0, "wins": 0, "best_wave": 1, "total_kills": 0}
var touch_active := false
var touch_origin := Vector2.ZERO
var touch_direction := Vector2.ZERO
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

func _ready() -> void:
    rng.seed = 451
    _load_profile()
    camera = Camera2D.new()
    camera.enabled = true
    camera.zoom = Vector2(0.94, 0.94)
    add_child(camera)
    layer = CanvasLayer.new()
    add_child(layer)
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
    restart_button.pressed.connect(_return_to_menu)
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
    hud_top.visible = mode != "menu"
    hud_bottom.visible = mode == "playing" or mode == "paused"
    modal_dim.visible = mode == "choice" or mode == "replace" or mode == "legendary" or mode == "paused" or mode == "lost" or mode == "won"
    for i in range(3):
        hero_portraits[i].visible = mode == "menu"
        menu_buttons[i].visible = mode == "menu"
        menu_buttons[i].text = "%d   %s   ·   %s" % [i + 1, HEROES[i]["name"], HEROES[i]["flex"]]
    for i in range(offer_buttons.size()):
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
    legendary_button.visible = mode == "playing" and run_time >= 540.0 and run_time < 895.0 and not legendary_spent and not legendary_offers.is_empty()
    defer_button.visible = mode == "legendary"
    flex_button.visible = mode == "playing"
    pause_button.visible = mode == "playing" or mode == "paused"
    pause_button.text = "RESUME [P]" if mode == "paused" else "PAUSE [P]"
    restart_button.visible = mode == "lost" or mode == "won" or mode == "paused"

func _update_text() -> void:
    if mode == "menu":
        headline.text = "AURA FARMER"
        headline.position = Vector2(82, 40)
        headline.add_theme_font_size_override("font_size", 54)
        metrics.text = "RUIN ALLEY  ·  FIVE WAVES  ·  ONE BIG HATER  ·  STARTER SOLO DEMO"
        metrics.position = Vector2(86, 120)
        notice.text = "CHOOSE YOUR ENERGY"
        notice.position = Vector2(448, 204)
        return
    headline.position = Vector2(25, 16)
    headline.add_theme_font_size_override("font_size", 26)
    metrics.position = Vector2(25, 55)
    notice.position = Vector2(345, 184)
    headline.text = "%s   /   %s   /   %02d:%02d" % [hero["name"], "BIG HATER" if boss_spawned else WAVE_NAMES[wave - 1], int(run_time) / 60, int(run_time) % 60]
    var flex_label = "READY" if aura >= 100.0 and flex_lock <= 0.0 else "%.0f / 100" % aura
    metrics.text = "HP %.0f/%.0f   Shield %.0f   LV %d   XP %.0f/%.0f   Aura %s   Kills %d   Weapons %d/3   Passives %d/5" % [hp, max_hp, shield, level, xp, float(30 + 8 * level + level * level), flex_label, kills, weapons.size(), passives.size()]
    flex_button.disabled = aura < 100.0 or flex_lock > 0.0
    if mode == "choice":
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
        notice.text = ""

func start_run(index: int) -> void:
    if index < 0 or index >= HEROES.size():
        return
    hero_index = index
    hero = HEROES[index].duplicate(true)
    player_pos = Vector2(724, 540)
    movement_direction = Vector2.DOWN
    hp = hero["hp"]
    max_hp = hp
    shield = 0.0
    aura = 0.0
    flex_time = 0.0
    flex_lock = 0.0
    run_time = 0.0
    level = 1
    xp = 0.0
    total_xp = 0.0
    kills = 0
    wave = 1
    event_index = 0
    boss_spawned = false
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
    hostile_shots.clear()
    hazard_zones.clear()
    pickups.clear()
    passive_timers.clear()
    primary_hits = 0
    directional_hits = 0
    cook_stacks = 0
    cook_expires = 0.0
    aura_hits_bucket = -1
    aura_hits_in_bucket = 0
    sigma_target.clear()
    rng.seed = 451 + 17 * index
    mode = "playing"
    _show_ui()
    _update_text()
    camera.position = player_pos

func _process(delta: float) -> void:
    if mode == "playing":
        var dt := minf(delta, 0.05)
        _advance(dt)
    attack_flash = maxf(attack_flash - delta, 0.0)
    camera.position = camera.position.lerp(player_pos, minf(1.0, delta * 8.0))
    status_timer -= delta
    if status_timer <= 0.0:
        status_timer = 0.10
        _update_text()
    queue_redraw()

func _advance(dt: float) -> void:
    run_time += dt
    hurt_timer = maxf(0.0, hurt_timer - dt)
    flex_lock = maxf(0.0, flex_lock - dt)
    if flex_time > 0.0:
        flex_time = maxf(0.0, flex_time - dt)
        flex_age += dt
        if hero["id"] == "alpha" and (absf(flex_age - 2.0) < dt or absf(flex_age - 4.0) < dt):
            _damage_nearby(150.0, 0.40 * hero["power"])
    else:
        aura = minf(100.0, aura + 0.5 * dt)
    _move_player(dt)
    _tick_passives(dt)
    var new_wave := mini(5, 1 + int(run_time / 180.0))
    if new_wave != wave and not boss_spawned:
        wave = new_wave
        _gain_xp(float(40 * wave))
    _spawn_logic(dt)
    _step_enemies(dt)
    _step_hostile_shots(dt)
    _step_hazards()
    if mode != "playing":
        return
    _fire_weapons(dt)
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
        shield = minf(max_hp * 0.40, shield + amount * SoloPassiveRulesScript.support_scale(passives, hero["role"] == "tank"))
    if _passive_level("no-u") > 0 and not enemies.is_empty() and run_time >= float(passive_timers.get("no_u_next", 15.0)):
        passive_timers["no_u_next"] = run_time + 15.0
        _damage_nearby(200.0, 0.30 * float(hero["power"]))
        for e: Dictionary in enemies:
            if player_pos.distance_to(e["pos"]) <= 200.0:
                var is_boss: bool = bool(SoloEnemyRulesScript.DATA[e["kind"]]["boss"])
                e["weaken"] = 0.10 if is_boss else 0.20
                e["weaken_until"] = run_time + (2.0 if is_boss else 4.0)
    if int(passive_timers.get("so_back_remaining", 0)) > 0 and run_time >= float(passive_timers.get("so_back_next", 1e9)):
        passive_timers["so_back_remaining"] = int(passive_timers["so_back_remaining"]) - 1
        passive_timers["so_back_next"] = run_time + 1.0
        var heal_total: float = 0.10 + 0.05 * float(_passive_level("so-back") - 1)
        hp = minf(max_hp, hp + max_hp * heal_total * 0.20 * SoloPassiveRulesScript.support_scale(passives))

func _primary_activation(target: Vector2) -> void:
    primary_hits += 1
    if aura_hits_bucket != int(run_time):
        aura_hits_bucket = int(run_time)
        aura_hits_in_bucket = 0
    if flex_time <= 0.0 and aura_hits_in_bucket < 2:
        aura = minf(100.0, aura + 1.0)
        aura_hits_in_bucket += 1
    if _passive_level("let-him-cook") > 0:
        cook_stacks = mini(5, cook_stacks + 1)
        cook_expires = run_time + 3.0
    if _passive_level("homie-check") > 0 and run_time >= float(passive_timers.get("homie_ready", 0.0)):
        var homie_count: int = int(passive_timers.get("homie_count", 0)) + 1
        if homie_count >= 8:
            homie_count = 0
            passive_timers["homie_ready"] = run_time + 6.0
            var healed: float = max_hp * (0.02 + 0.01 * float(_passive_level("homie-check")))
            hp = minf(max_hp, hp + healed * SoloPassiveRulesScript.support_scale(passives))
        passive_timers["homie_count"] = homie_count
    if _passive_level("six-to-seven") > 0 and run_time >= float(passive_timers.get("six_ready", 0.0)):
        var sixth_count: int = int(passive_timers.get("six_counter", 0)) + 1
        if sixth_count >= 7:
            sixth_count = 0
            passive_timers["six_ready"] = run_time + 2.0
            var amount: float = float(hero["power"]) * (0.35 + 0.15 * float(_passive_level("six-to-seven") - 1))
            for e: Dictionary in enemies.duplicate():
                if Vector2(e["pos"]).distance_to(target) <= 90.0:
                    _hit_enemy(e, amount)
        passive_timers["six_counter"] = sixth_count

func _move_player(dt: float) -> void:
    var axis = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var wasd := Vector2(float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)), float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W)))
    var direction: Vector2 = (axis + wasd + touch_direction).limit_length(1.0)
    if direction.length_squared() > 0.01:
        movement_direction = direction
    var speed: float = hero["speed"] * (1.25 if flex_time > 0.0 and hero["id"] == "cool-kid" else 1.0)
    speed *= 1.0 + 0.05 * float(_passive_level("caught-4k"))
    var desired := player_pos + direction * speed * dt
    desired.x = clampf(desired.x, 50.0, FIELD.size.x - 50.0)
    desired.y = clampf(desired.y, 50.0, FIELD.size.y - 50.0)
    for obstacle: Vector2 in COVERS:
        if desired.distance_to(obstacle) < 46.0:
            var away := (desired - obstacle).normalized()
            desired = obstacle + away * 46.0
    player_pos = desired

func _spawn_logic(dt: float) -> void:
    if not boss_spawned and event_index < SoloEnemyRulesScript.EVENT_SCHEDULE.size() and run_time >= float(SoloEnemyRulesScript.EVENT_SCHEDULE[event_index]["at"]):
        var event: Dictionary = SoloEnemyRulesScript.EVENT_SCHEDULE[event_index]
        _spawn_enemy(str(event["kind"]))
        event_index += 1
    if not boss_spawned and run_time >= 900.0:
        boss_spawned = true
        enemies.clear()
        hostile_shots.clear()
        hazard_zones.clear()
        _spawn_enemy("boss", {"pos":Vector2(724.0, 445.0)})
    spawn_timer -= dt
    if spawn_timer > 0.0 or enemies.size() >= 100:
        return
    var idx := wave - 1
    spawn_timer = 1.0 / (0.8 * float(WAVE_DENSITY[idx]))
    if boss_spawned:
        spawn_timer = 5.0
    else:
        var selected: String = SoloEnemyRulesScript.spawn_kind(wave, run_time, rng)
        _spawn_enemy(selected)

func _spawn_enemy(kind: String, special: Dictionary = {}) -> void:
    if not SoloEnemyRulesScript.DATA.has(kind):
        push_error("Unknown GDD enemy ID: " + kind)
        return
    var stats: Dictionary = SoloEnemyRulesScript.DATA[kind]
    var pos: Vector2 = special.get("pos", Vector2.ZERO)
    if not special.has("pos"):
        var found := false
        for attempt in range(35):
            pos = Vector2(rng.randf_range(60.0, 1388.0), rng.randf_range(60.0, 1026.0))
            if pos.distance_to(player_pos) >= 260.0:
                found = true
                break
        if not found:
            pos = Vector2(80.0, 80.0)
    var boss_kind: bool = bool(stats["boss"])
    var hp_base: float = float(stats["hp"]) * (1.0 if boss_kind else float(WAVE_HP[wave - 1]))
    var damage: float = float(stats["damage"]) * (1.0 if boss_kind else float(WAVE_DAMAGE[wave - 1]))
    enemies.append({
        "pos": pos, "hp": hp_base, "max": hp_base,
        "speed": float(stats["speed"]), "radius": float(stats["radius"]),
        "damage": damage, "xp": int(stats["xp"]), "kind": kind,
        "hit_cooldown": 0.0, "name": stats["name"], "phase": "",
        "next_attack": run_time + 2.0, "attack_at": 0.0,
        "locked_direction": Vector2.RIGHT, "charge_until": 0.0,
        "attack_slot": 0, "regen_stamp": int(run_time),
        "shield": 0.0, "shield_until": 0.0, "hurt_at": -100.0
    })

func _deal_damage_to_player(amount: float) -> void:
    if mode != "playing" or hurt_timer > 0.0:
        return
    hurt_timer = 0.25
    var old_hp := hp
    var incoming: float = amount * (1.0 - float(hero["resist"]))
    incoming *= 1.0 - minf(0.45, 0.03 * float(_passive_level("thick-skin")))
    if hero["id"] == "cool-kid" and flex_time > 0.0:
        incoming *= 0.5
    var absorbed := minf(shield, incoming)
    shield -= absorbed
    hp = maxf(0.0, hp - incoming + absorbed)
    if hp <= 0.0:
        _finish(false)
        return
    if old_hp >= max_hp * 0.30 and hp < max_hp * 0.30 and _passive_level("so-back") > 0 and run_time >= float(passive_timers.get("so_back_ready", 0.0)):
        passive_timers["so_back_ready"] = run_time + 45.0
        passive_timers["so_back_remaining"] = 5
        passive_timers["so_back_next"] = run_time + 1.0
        shield = minf(max_hp * 0.40, shield + max_hp * 0.10 * SoloPassiveRulesScript.support_scale(passives))
    if old_hp >= max_hp * 0.25 and hp < max_hp * 0.25 and _passive_level("too-sigma") > 0 and run_time >= float(passive_timers.get("too_sigma_ready", 0.0)):
        passive_timers["too_sigma_ready"] = run_time + 60.0
        shield = minf(max_hp * 0.40, shield + max_hp * 0.25 * SoloPassiveRulesScript.support_scale(passives))

func _spawn_hostile_shot(enemy: Dictionary) -> void:
    var dir: Vector2 = enemy["locked_direction"]
    hostile_shots.append({
        "pos":enemy["pos"], "dir":dir, "speed":450.0 if enemy["kind"] == "ping-sniper" else 180.0,
        "remaining":800.0, "damage":float(enemy["damage"]), "radius":7.0
    })

func _step_hostile_shots(dt: float) -> void:
    for shot: Dictionary in hostile_shots.duplicate():
        var distance: float = float(shot["speed"]) * dt
        var start: Vector2 = shot["pos"]
        var ending: Vector2 = start + shot["dir"] * distance
        shot["pos"] = ending
        shot["remaining"] = float(shot["remaining"]) - distance
        var blocked := false
        for cover: Vector2 in COVERS:
            if ending.distance_to(cover) < 36.0:
                blocked = true
                break
        if blocked or float(shot["remaining"]) <= 0.0 or not FIELD.has_point(ending):
            hostile_shots.erase(shot)
            continue
        if ending.distance_to(player_pos) < 16.0 + float(shot["radius"]):
            _deal_damage_to_player(float(shot["damage"]))
            hostile_shots.erase(shot)

func _schedule_hazard(point: Vector2, radius: float, delay: float, active_duration: float, damage: float, shape: String = "circle", heading: Vector2 = Vector2.RIGHT) -> void:
    hazard_zones.append({
        "pos":point, "radius":radius, "at":run_time + delay, "end":run_time + delay + active_duration,
        "next_tick":run_time + delay, "damage":damage, "shape":shape, "dir":heading
    })

func _step_hazards() -> void:
    for hazard: Dictionary in hazard_zones.duplicate():
        if run_time > float(hazard["end"]):
            hazard_zones.erase(hazard)
            continue
        if run_time < float(hazard["at"]) or run_time < float(hazard["next_tick"]):
            continue
        hazard["next_tick"] = run_time + 1.0
        var offset: Vector2 = player_pos - Vector2(hazard["pos"])
        var danger := false
        if hazard["shape"] == "line":
            var aim: Vector2 = hazard["dir"]
            danger = offset.length() <= float(hazard["radius"]) and absf(aim.cross(offset)) <= 30.0 and aim.dot(offset) >= 0.0
        elif hazard["shape"] == "ring":
            danger = absf(offset.length() - float(hazard["radius"])) <= 32.0
        elif hazard["shape"] == "cone":
            danger = offset.length() <= float(hazard["radius"]) and hazard["dir"].dot(offset.normalized()) >= 0.5
        else:
            danger = offset.length() <= float(hazard["radius"])
        if danger:
            _deal_damage_to_player(float(hazard["damage"]))

func _step_enemies(dt: float) -> void:
    for enemy: Dictionary in enemies.duplicate():
        if mode != "playing" or not enemies.has(enemy):
            return
        var kind: String = enemy["kind"]
        var pos: Vector2 = enemy["pos"]
        var to_player: Vector2 = player_pos - pos
        var distance: float = to_player.length()
        var direction: Vector2 = to_player.normalized() if distance > 0.01 else Vector2.RIGHT
        var speed: float = float(enemy["speed"])
        if kind == "terminal":
            continue
        if kind == "boss":
            if run_time < 1080.0:
                enemy["regen_stamp"] = int(run_time)
            elif int(run_time) > int(enemy["regen_stamp"]):
                enemy["hp"] = minf(float(enemy["max"]), float(enemy["hp"]) + float(enemy["max"]) * 0.001)
                enemy["regen_stamp"] = int(run_time)

        if kind == "hater" or kind == "ping-sniper":
            var preferred: float = 260.0 if kind == "hater" else 400.0
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
        if distance > float(enemy["radius"]) + 19.0:
            var destination: Vector2 = pos + direction * speed * dt
            destination.x = clampf(destination.x, 20.0, FIELD.size.x - 20.0)
            destination.y = clampf(destination.y, 20.0, FIELD.size.y - 20.0)
            enemy["pos"] = destination
        enemy["hit_cooldown"] = maxf(0.0, float(enemy["hit_cooldown"]) - dt)
        if distance <= float(enemy["radius"]) + 18.0 and float(enemy["hit_cooldown"]) == 0.0:
            enemy["hit_cooldown"] = 0.75
            if hero["id"] == "cool-kid" and flex_time > 0.0 and not bool(SoloEnemyRulesScript.DATA[kind]["boss"]):
                _hit_enemy(enemy, 0.35 * float(hero["power"]))
            else:
                var boss_mult := 1.0
                if kind == "boss" and run_time >= 1080.0:
                    boss_mult = minf(3.0, 2.0 * pow(1.1, floorf((run_time - 1080.0) / 30.0)))
                var weaken: float = float(enemy.get("weaken", 0.0)) if run_time < float(enemy.get("weaken_until", -1.0)) else 0.0
                _deal_damage_to_player(float(enemy["damage"]) * boss_mult * (1.0 - weaken))

        if enemy["phase"] == "warning" and run_time >= float(enemy["attack_at"]):
            _spawn_hostile_shot(enemy)
            enemy["phase"] = ""
            enemy["next_attack"] = run_time + (6.0 if kind == "ping-sniper" else 3.0)
        elif (kind == "hater" or kind == "ping-sniper") and enemy["phase"] == "" and run_time >= float(enemy["next_attack"]):
            enemy["phase"] = "warning"
            enemy["attack_at"] = run_time + (1.2 if kind == "ping-sniper" else 0.6)
            enemy["locked_direction"] = direction if speed >= 0.0 else -direction

        if run_time < float(enemy["next_attack"]):
            continue
        if kind == "ratio-ram" or kind == "ohio-express":
            if enemy["phase"] == "":
                enemy["phase"] = "charge-warning"
                enemy["attack_at"] = run_time + 0.9
                enemy["locked_direction"] = to_player.normalized()
            elif enemy["phase"] == "charge-warning" and run_time >= float(enemy["attack_at"]):
                enemy["phase"] = "charging"
                enemy["charge_until"] = run_time + 280.0 / 320.0
                enemy["next_attack"] = run_time + 5.0
        elif kind == "doomscroller":
            _schedule_hazard(player_pos, 70.0, 1.0, 3.0, float(enemy["damage"]))
            enemy["next_attack"] = run_time + 6.0
        elif kind == "hype-bot":
            var count := 0
            for ally: Dictionary in enemies:
                if ally != enemy and not bool(SoloEnemyRulesScript.DATA[ally["kind"]]["boss"]) and Vector2(ally["pos"]).distance_to(pos) <= 160.0:
                    ally["shield"] = float(ally["max"]) * 0.15
                    ally["shield_until"] = run_time + 4.0
                    count += 1
                    if count == 3: break
            enemy["next_attack"] = run_time + 8.0
        elif kind == "comment-mod":
            var healed := 0
            for ally: Dictionary in enemies:
                if ally != enemy and ally["kind"] != "comment-mod" and not bool(SoloEnemyRulesScript.DATA[ally["kind"]]["boss"]) and Vector2(ally["pos"]).distance_to(pos) <= 180.0:
                    ally["hp"] = minf(float(ally["max"]), float(ally["hp"]) + 0.08 * float(ally["max"]))
                    healed += 1
                    if healed == 3: break
            enemy["next_attack"] = run_time + 8.0
        elif kind == "fanum-leech":
            if distance <= 200.0:
                _schedule_hazard(pos, 240.0, 0.8, 2.4, 5.0, "line", to_player.normalized())
            enemy["next_attack"] = run_time + 5.0
        elif kind == "reply-guy":
            _schedule_hazard(pos, 260.0, 0.8, 0.2, 18.0, "cone", to_player.normalized())
            for i in range(4): _spawn_enemy("npc")
            enemy["next_attack"] = run_time + 12.0
        elif kind == "mod-supremo":
            _schedule_hazard(pos, 500.0, 1.0, 0.2, 15.0, "line", to_player.normalized())
            enemy["next_attack"] = run_time + 10.0
        elif kind == "doomscroll-prime":
            _schedule_hazard(player_pos, 100.0, 1.0, 3.0, 12.0)
            enemy["next_attack"] = run_time + 7.0
        elif kind == "boss":
            var slot: int = int(enemy["attack_slot"]) % 4
            enemy["attack_slot"] = slot + 1
            var multi := 1.0 if run_time < 1080.0 else minf(3.0, 2.0 * pow(1.1, floorf((run_time - 1080.0) / 30.0)))
            if slot == 0:
                _schedule_hazard(pos, 200.0, 1.0, 0.15, 35.0 * multi, "cone", to_player.normalized())
            elif slot == 1:
                _schedule_hazard(pos, 600.0, 1.2, 0.2, 30.0 * multi, "line", to_player.normalized())
            elif slot == 2:
                _schedule_hazard(pos, 280.0, 1.0, 1.5, 25.0 * multi, "ring")
            else:
                for i in range(4): _spawn_enemy("npc")
                _spawn_enemy("hype-bot")
            enemy["next_attack"] = run_time + (4.8 if run_time >= 1080.0 else 6.0)
        else:
            enemy["next_attack"] = run_time + 1.0

func _fire_weapons(dt: float) -> void:
    for weapon: Dictionary in weapons:
        weapon["timer"] = maxf(0.0, float(weapon["timer"]) - dt)
        if float(weapon["timer"]) > 0.0:
            continue
        var config: Dictionary = WEAPONS[weapon["id"]]
        var closest: Dictionary = {}
        var closest_dist := 100000.0
        for enemy: Dictionary in enemies:
            var distance := player_pos.distance_to(enemy["pos"])
            if distance <= float(config["range"]) and distance < closest_dist:
                closest = enemy
                closest_dist = distance
        if closest.is_empty():
            weapon["timer"] = 0.10
            continue
        var frequency := minf(1.0, 0.05 * float(_passive_level("terminally-online")))
        weapon["timer"] = maxf(0.20, float(config["interval"]) * pow(0.95, int(weapon["level"]) - 1) / (1.0 + frequency))
        var power := float(hero["power"]) * float(config["power"])
        power *= float(RARITY_POWER[weapon["rarity"]]) * (1.0 + 0.15 * (int(weapon["level"]) - 1))
        power *= 1.0 + 0.01 * (level - 1) + 0.06 * float(_passive_level("main-character"))
        if hero["id"] == "sigma" and flex_time > 0.0:
            power *= 1.4
        var shape: String = config["shape"]
        var hits := 0
        if shape == "pulse" or shape == "blast" or shape == "cone":
            var center: Vector2 = player_pos if shape != "blast" else closest["pos"]
            var radius: float = float(config["range"]) if shape != "blast" else 100.0
            for e: Dictionary in enemies.duplicate():
                if center.distance_to(e["pos"]) <= radius:
                    _hit_enemy(e, power)
                    hits += 1
        elif shape == "line":
            var heading: Vector2 = (closest["pos"] - player_pos).normalized()
            for e: Dictionary in enemies.duplicate():
                var offset: Vector2 = e["pos"] - player_pos
                if offset.length() <= 600.0 and absf(heading.cross(offset)) <= 36.0 and heading.dot(offset) > 0.0:
                    _hit_enemy(e, power)
                    hits += 1
                    if hits == 4:
                        break
        else:
            _hit_enemy(closest, power)
            hits = 1
        if hits > 0:
            if flex_time <= 0.0:
                aura = minf(100.0, aura + 1.0)
            attack_flash = 0.12
            attack_target = closest["pos"]
            if weapon["id"] == "cope-shield":
                shield = minf(max_hp * 0.40, shield + max_hp * 0.04)

func _hit_enemy(enemy: Dictionary, amount: float) -> void:
    if not enemies.has(enemy):
        return
    if float(enemy.get("shield_until", 0.0)) > run_time and float(enemy.get("shield", 0.0)) > 0.0:
        var blocked: float = minf(amount, float(enemy["shield"]))
        enemy["shield"] = float(enemy["shield"]) - blocked
        amount -= blocked
    enemy["hp"] = float(enemy["hp"]) - amount
    if float(enemy["hp"]) <= 0.0:
        if enemy["kind"] == "copium-puffer":
            _schedule_hazard(Vector2(enemy["pos"]), 80.0, 1.0, 3.0, 12.0)
        enemies.erase(enemy)
        kills += 1
        if enemy["kind"] == "boss":
            _finish(true)
            return
        pickups.append({"pos": enemy["pos"], "xp": float(enemy["xp"]), "kind": "aura"})
        var chance := rng.randf()
        if chance < 0.020:
            pickups.append({"pos": enemy["pos"] + Vector2(19, 0), "xp": 0.0, "kind": "snack"})
        elif chance < 0.030:
            pickups.append({"pos": enemy["pos"] + Vector2(19, 0), "xp": 0.0, "kind": "magnet"})
        if SoloEnemyRulesScript.is_event(str(enemy["kind"])) and flex_time <= 0.0:
            aura = minf(100.0, aura + 10.0)

func _collect_drops() -> void:
    for drop: Dictionary in pickups.duplicate():
        if player_pos.distance_to(drop["pos"]) > 45.0:
            continue
        pickups.erase(drop)
        if drop["kind"] == "snack":
            hp = minf(max_hp, hp + 0.15 * max_hp)
        elif drop["kind"] == "magnet":
            for item: Dictionary in pickups.duplicate():
                if item["kind"] == "aura":
                    _gain_xp(float(item["xp"]))
                    pickups.erase(item)
        else:
            _gain_xp(float(drop["xp"]))

func _gain_xp(amount: float) -> void:
    total_xp += amount
    xp += amount
    while level < 25 and xp >= float(30 + 8 * level + level * level):
        xp -= float(30 + 8 * level + level * level)
        level += 1
        max_hp += 2.0
        hp = minf(max_hp, hp + 2.0)
        pending_choices += 1

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
        var swap_index := rng.randi_range(0, i)
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
    if mode != "playing" or legendary_spent or run_time < 540.0 or run_time >= 895.0:
        return
    _generate_legendary_offers()
    if legendary_offers.size() != 6:
        push_error("Six legal GDD legendary choices are required")
        return
    if run_time >= 720.0:
        legendary_second_shown = true
    else:
        legendary_first_shown = true
    mode = "legendary"
    _show_ui()

func _defer_legendary() -> void:
    if mode != "legendary":
        return
    mode = "playing"
    _show_ui()
    if pending_choices > 0:
        _open_choice()

func _check_legendary_window() -> void:
    if mode != "playing" or legendary_spent or run_time >= 895.0:
        return
    if run_time >= 720.0 and not legendary_second_shown:
        _open_legendary()
    elif run_time >= 540.0 and not legendary_first_shown:
        _open_legendary()

func _open_choice() -> void:
    if pending_choices <= 0 or mode != "playing":
        return
    selection.clear()
    selection.append_array(SoloOfferRulesScript.choices(str(hero["role"]), wave, weapons, passives, WEAPONS, rng))
    mode = "choice"
    _show_ui()

func _replace_target(card: Dictionary) -> void:
    replace_card = card.duplicate(true)
    replace_options.clear()
    var inventory: Array[Dictionary] = weapons if card["type"] == "weapon" else passives
    for item: Dictionary in inventory:
        var name: String = str(WEAPONS[item["id"]]["name"]) if card["type"] == "weapon" else str(SoloOfferRulesScript.PASSIVE_DATA[item["id"]]["name"])
        replace_options.append({"id":item["id"], "label":name + " / " + str(item["rarity"]).to_upper() + " LV " + str(item["level"])})
    mode = "replace"
    _show_ui()

func _apply_card(card: Dictionary, replace_id: String = "") -> void:
    if card["type"] == "heal":
        hp = minf(max_hp, hp + max_hp * 0.08)
    else:
        if not SoloOfferRulesScript.legal_item(str(card["id"]), str(card["rarity"]), int(card["level"]), str(hero["role"]), WEAPONS):
            push_error("Refusing an illegal GDD item offer")
            return
        var kind: String = card["type"]
        if kind == "weapon" and weapons.size() >= 3 and replace_id == "":
            _replace_target(card)
            return
        if kind == "passive" and passives.size() >= 5 and replace_id == "":
            _replace_target(card)
            return
        if kind == "weapon":
            if replace_id != "":
                for i in range(weapons.size()):
                    if weapons[i]["id"] == replace_id:
                        weapons.remove_at(i)
                        break
            weapons.append({"id": card["id"], "level":int(card["level"]), "rarity":card["rarity"], "timer":0.0})
        elif kind == "passive":
            if replace_id != "":
                for i in range(passives.size()):
                    if passives[i]["id"] == replace_id:
                        passives.remove_at(i)
                        break
            passives.append({"id":card["id"], "level":int(card["level"]), "rarity":card["rarity"]})
            if card["id"] == "built-different":
                var additional_hp := max_hp * 0.08
                max_hp += additional_hp
                hp = minf(max_hp, hp + additional_hp)
        elif kind == "upgrade_weapon" or kind == "promote_weapon":
            for weapon: Dictionary in weapons:
                if weapon["id"] == card["id"]:
                    weapon["rarity"] = card["rarity"]
                    weapon["level"] = int(card["level"])
                    break
        elif kind == "upgrade_passive":
            for passive: Dictionary in passives:
                if passive["id"] == card["id"]:
                    passive["level"] = int(card["level"])
                    if card["id"] == "built-different":
                        var additional_hp := max_hp * 0.08
                        max_hp += additional_hp
                        hp = minf(max_hp, hp + additional_hp)
                    break
    if card.get("rarity", "") == "legendary":
        legendary_spent = true
    else:
        pending_choices -= 1
    replace_card.clear()
    replace_options.clear()
    mode = "playing"
    _show_ui()
    if pending_choices > 0:
        _open_choice()

func pick_upgrade(index: int) -> void:
    if mode == "replace":
        if index >= 0 and index < replace_options.size() and not replace_card.is_empty():
            _apply_card(replace_card, str(replace_options[index]["id"]))
        return
    if mode == "legendary":
        if index >= 0 and index < legendary_offers.size():
            _apply_card(legendary_offers[index])
        return
    if mode != "choice" or index < 0 or index >= selection.size():
        return
    _apply_card(selection[index])

func _damage_nearby(radius: float, amount: float) -> void:
    for e: Dictionary in enemies.duplicate():
        if player_pos.distance_to(e["pos"]) <= radius:
            _hit_enemy(e, amount)

func _use_flex() -> void:
    if mode != "playing" or aura < 100.0 or flex_lock > 0.0:
        return
    sigma_target.clear()
    if hero["id"] == "sigma":
        var nearest := 1000000.0
        for e: Dictionary in enemies:
            var dist: float = player_pos.distance_to(e["pos"])
            if dist < nearest and dist <= 600.0:
                nearest = dist
                sigma_target = e
        if sigma_target.is_empty():
            return
    aura = 0.0
    flex_time = float(hero["duration"])
    flex_lock = 30.0
    flex_age = 0.0
    if _passive_level("aura-viral") > 0:
        passive_timers["viral_until"] = run_time + 5.0
    if _passive_level("w-squad") > 0:
        passive_timers["w_squad_until"] = run_time + 6.0
    if hero["id"] == "alpha":
        shield = minf(max_hp * 0.40, shield + max_hp * 0.25 * SoloPassiveRulesScript.support_scale(passives, true))
        _damage_nearby(150.0, 0.40 * float(hero["power"]))

func _toggle_pause() -> void:
    if mode == "playing":
        mode = "paused"
    elif mode == "paused":
        mode = "playing"
    _show_ui()

func _finish(won: bool) -> void:
    if mode != "playing":
        return
    mode = "won" if won else "lost"
    profile["runs"] = int(profile.get("runs", 0)) + 1
    if won:
        profile["wins"] = int(profile.get("wins", 0)) + 1
    profile["best_wave"] = maxi(int(profile.get("best_wave", 1)), wave)
    profile["total_kills"] = int(profile.get("total_kills", 0)) + kills
    _save_profile()
    _show_ui()

func _load_profile() -> void:
    if not FileAccess.file_exists("user://godot_slice_profile_v1.json"):
        return
    var file := FileAccess.open("user://godot_slice_profile_v1.json", FileAccess.READ)
    if file == null:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary and int(parsed.get("version", 0)) == 1:
        profile = parsed

func _save_profile() -> void:
    var file := FileAccess.open("user://godot_slice_profile_v1.json", FileAccess.WRITE)
    if file != null:
        profile["version"] = 1
        file.store_string(JSON.stringify(profile))

func _return_to_menu() -> void:
    mode = "menu"
    touch_active = false
    touch_direction = Vector2.ZERO
    _show_ui()
    _update_text()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event.pressed or event.echo:
        return
    if event.keycode == KEY_P or event.keycode == KEY_ESCAPE:
        _toggle_pause()
    if event.keycode == KEY_SPACE or event.keycode == KEY_E:
        _use_flex()
    if event.keycode == KEY_L:
        _open_legendary()
    if mode == "menu" and event.keycode >= KEY_1 and event.keycode <= KEY_3:
        start_run(event.keycode - KEY_1)
    elif (mode == "choice" or mode == "replace" or mode == "legendary") and event.keycode >= KEY_1 and event.keycode <= KEY_6:
        pick_upgrade(event.keycode - KEY_1)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and event.position.x < 475.0 and event.position.y > 185.0 and mode == "playing":
            touch_active = true
            touch_origin = event.position
            touch_direction = Vector2.ZERO
        elif not event.pressed:
            touch_active = false
            touch_direction = Vector2.ZERO
    if event is InputEventScreenDrag and touch_active:
        touch_direction = (event.position - touch_origin).limit_length(85.0) / 85.0

func _draw() -> void:
    if mode == "menu":
        if not art.draw_backdrop(self, "main-menu", FIELD):
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
    for cover: Vector2 in COVERS:
        draw_circle(cover, 31.0, Color(0.28, 0.30, 0.34))
        draw_arc(cover, 32.0, 0.0, TAU, 24, Color(0.70, 0.62, 0.46), 4.0)
    for drop: Dictionary in pickups:
        var color := Color(0.31, 0.93, 0.86)
        if drop["kind"] == "snack":
            color = Color(0.35, 0.95, 0.42)
        elif drop["kind"] == "magnet":
            color = Color(0.93, 0.52, 0.96)
        draw_circle(drop["pos"], 7.0 if drop["kind"] == "aura" else 12.0, color)
    for zone: Dictionary in hazard_zones:
        if run_time < float(zone["at"]):
            draw_arc(Vector2(zone["pos"]), float(zone["radius"]), 0.0, TAU, 48, Color(1.0, 0.61, 0.22, 0.8), 4.0)
        else:
            draw_arc(Vector2(zone["pos"]), float(zone["radius"]), 0.0, TAU, 48, Color(0.98, 0.29, 0.31, 0.8), 6.0)
    for shot: Dictionary in hostile_shots:
        draw_circle(shot["pos"], float(shot["radius"]), Color(1.0, 0.37, 0.47))
    for e: Dictionary in enemies:
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
        if not art.draw_enemy(self, e):
            draw_circle(e["pos"], radius, color)
        draw_circle(e["pos"] + Vector2(-5, -4), 2.0, Color(0.15, 0.12, 0.18))
        draw_circle(e["pos"] + Vector2(5, -4), 2.0, Color(0.15, 0.12, 0.18))
        draw_rect(Rect2(e["pos"] + Vector2(-radius, -radius - 13), Vector2(radius * 2.0, 5.0)), Color(0.13, 0.11, 0.13))
        draw_rect(Rect2(e["pos"] + Vector2(-radius, -radius - 13), Vector2(radius * 2.0 * maxf(0.0, float(e["hp"]) / float(e["max"])), 5.0)), Color(0.63, 0.92, 0.44))
    if attack_flash > 0.0:
        draw_line(player_pos, attack_target, Color(0.99, 0.87, 0.42, 0.6), 5.0)
    if flex_time > 0.0:
        draw_arc(player_pos, 26.0, 0.0, TAU, 36, Color(1.0, 0.89, 0.36), 5.0)
    if not art.draw_hero(self, player_pos, str(hero["id"]), run_time, movement_direction, flex_time > 0.0, attack_flash > 0.0):
        draw_circle(player_pos, 16.0, hero["color"])
        draw_arc(player_pos, 18.0, 0.0, TAU, 32, Color(0.06, 0.09, 0.15), 3.0)
        draw_circle(player_pos + Vector2(-5, -4), 2.1, Color(0.08, 0.08, 0.10))
        draw_circle(player_pos + Vector2(5, -4), 2.1, Color(0.08, 0.08, 0.10))
    draw_rect(Rect2(player_pos + Vector2(-23, -31), Vector2(46, 5)), Color(0.16, 0.13, 0.14))
    draw_rect(Rect2(player_pos + Vector2(-23, -31), Vector2(46.0 * hp / max_hp, 5)), Color(0.27, 0.94, 0.50))
