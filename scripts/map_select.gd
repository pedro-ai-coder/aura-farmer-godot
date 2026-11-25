extends Control

const Maps = preload("res://scripts/solo_maps.gd")
const Neon = preload("res://scripts/neon_arcade.gd")
const World = preload("res://scripts/solo_world_rules.gd")

var game
var selected: StringName
var heading: Label
var choices: Dictionary[StringName, Button]
var previews: Dictionary[StringName, Rect2]
var back: Button
var start: Button
var qa: Button
var visual: Button
var no_u_density := 0
var no_u_case := 0
var contract_button: Button
const NO_U_CASES := ["LIVE COMBAT", "HP HIT", "SHIELD ONLY", "SIMULTANEOUS", "RECHARGE", "FATAL", "ENVIRONMENT"]
var no_u_treatment := 2
const NO_U_TREATMENTS := ["A / BASELINE", "B / COUNTER-PULSE V1", "C / REVERSE IMPACT V3"]
const NO_U_SCENARIOS := ["NO U QA OFF", "NO U QA NORMAL", "NO U QA DENSE"]

func install(owner_game) -> void:
    game = owner_game
    mouse_filter = Control.MOUSE_FILTER_STOP
    heading = Label.new()
    heading.text = "CHOOSE MAP"
    Neon.label(heading, "title")
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(heading)
    for id: StringName in Maps.NAMES:
        choices[id] = _button(Maps.NAMES[id], _select.bind(id))
        choices[id].toggle_mode = true
    back = _button("BACK", game.close_map_select)
    start = _button("START RUN", _start_run, true)
    if OS.has_feature("six_to_seven_review"):
        qa = _button("QA: SIX → SEVEN OFF", func(): pass)
        qa.toggle_mode = true
        qa.toggled.connect(func(enabled: bool):
            qa.text = "QA: SIX → SEVEN ON" if enabled else "QA: SIX → SEVEN OFF")
        visual = _button("VFX: V2 BASELINE", func(): pass)
        visual.toggle_mode = true
        visual.toggled.connect(func(neon: bool):
            visual.text = "VFX: V3 NEON IMPACT" if neon else "VFX: V2 BASELINE")
    elif OS.has_feature("no_u_review"):
        qa = _button(NO_U_SCENARIOS[0], _cycle_no_u)
        qa.tooltip_text = "EXPERIMENTAL / NOT FOR PRODUCTION. Choose Normal or Dense, then A/B/C. V3 retaliates only after surviving HP loss; V1 is periodic."
        visual = _button(NO_U_TREATMENTS[no_u_treatment], func():
            no_u_treatment = (no_u_treatment + 1) % NO_U_TREATMENTS.size()
            visual.text = NO_U_TREATMENTS[no_u_treatment])
        visual.tooltip_text = "A: unchanged baseline. B: preserved periodic V1. C: reactive Reverse Impact V3, 200 U, 15s recharge after activation."
        contract_button = _button("INPUT / " + NO_U_CASES[0], func():
            no_u_case = (no_u_case + 1) % NO_U_CASES.size()
            contract_button.text = "INPUT / " + NO_U_CASES[no_u_case])
    clear_selection()

func _cycle_no_u() -> void:
    no_u_density = (no_u_density + 1) % NO_U_SCENARIOS.size()
    qa.text = NO_U_SCENARIOS[no_u_density]
    visual.disabled = no_u_density == 0
    _update_focus_order()

func _start_run() -> void:
    game.start_selected_map(selected, qa != null and qa.button_pressed,
        visual != null and (no_u_treatment > 0 if OS.has_feature("no_u_review") else visual.button_pressed), no_u_density, no_u_treatment, no_u_case)

func _button(caption: String, action: Callable, primary: bool = false) -> Button:
    var button := Button.new()
    button.text = caption
    Neon.button(button, primary)
    button.alignment = HORIZONTAL_ALIGNMENT_CENTER
    button.pressed.connect(action)
    add_child(button)
    return button

func clear_selection() -> void:
    if qa != null:
        qa.button_pressed = false
        visual.button_pressed = false
        if OS.has_feature("no_u_review"):
            no_u_case = 0
            contract_button.text = "INPUT / " + NO_U_CASES[0]
            no_u_treatment = 2
            visual.text = NO_U_TREATMENTS[no_u_treatment]
            no_u_density = 0
            qa.text = NO_U_SCENARIOS[0]
            visual.disabled = true
    _select(&"")

func _select(id: StringName) -> void:
    selected = id
    for map_id: StringName in choices:
        var button := choices[map_id]
        var active := selected == map_id
        button.set_pressed_no_signal(active)
        button.text = ("%s  ✓" if active else "%s") % Maps.NAMES[map_id]
        button.add_theme_stylebox_override("pressed", Neon.box(Neon.LIME, Neon.LIME, 2))
    start.disabled = selected.is_empty()
    _update_focus_order()
    queue_redraw()

func _update_focus_order() -> void:
    var buttons: Array[Button] = [choices[Maps.RUIN_ALLEY], choices[Maps.MSG_FACTORY]]
    if qa != null:
        buttons.append(qa)
        if not visual.disabled:
            buttons.append(visual)
    if contract_button != null:
        buttons.append(contract_button)
    buttons.append(back)
    if not start.disabled:
        buttons.append(start)
    for i in range(buttons.size()):
        buttons[i].focus_next = buttons[(i + 1) % buttons.size()].get_path()
        buttons[i].focus_previous = buttons[posmod(i - 1, buttons.size())].get_path()

func refresh(offset: Vector2, extent: Vector2) -> void:
    var entering: bool = not visible and game.mode == "maps"
    visible = game.mode == "maps"
    if not visible:
        return
    position = offset
    size = extent
    var card_width := minf(440, (size.x - 64) / 2)
    var qa_height := (112 if contract_button != null else 60) if qa != null else 0
    var preview_height := clampf(size.y - 250 - qa_height, 0, card_width * 0.75)
    var center := size * 0.5
    var top := center.y - (preview_height + 190 + qa_height) * 0.5
    heading.position = Vector2(0, top)
    heading.size = Vector2(size.x, 48)
    heading.add_theme_font_size_override("font_size", 38)
    var left := center.x - card_width - 10
    var right := center.x + 10
    previews[Maps.RUIN_ALLEY] = Rect2(left, top + 65, card_width, preview_height)
    previews[Maps.MSG_FACTORY] = Rect2(right, top + 65, card_width, preview_height)
    var bottom := top + 65 + preview_height
    for id: StringName in choices:
        var button := choices[id]
        button.position = Vector2(previews[id].position.x, bottom)
        button.size = Vector2(card_width, 54)
    back.position = Vector2(left, bottom + 75)
    back.size = Vector2(card_width, 52)
    start.position = Vector2(right, bottom + 75)
    start.size = Vector2(card_width, 52)
    if qa != null:
        qa.position = Vector2(left, bottom + 135)
        qa.size = Vector2(card_width, 48)
        visual.position = Vector2(right, bottom + 135)
        visual.size = Vector2(card_width, 48)
    if contract_button != null:
        contract_button.position = Vector2(left, bottom + 187)
        contract_button.size = Vector2(card_width * 2 + 20, 44)
    if entering:
        choices[Maps.RUIN_ALLEY].grab_focus()
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Neon.INK)
    for id: StringName in previews:
        var rect := previews[id]
        var factory := id == Maps.MSG_FACTORY
        draw_texture_rect(Maps.FACTORY_ARENA if factory else Maps.ALLEY_ARENA, rect, false)
        if factory:
            var scale := rect.size / World.SIZE
            for cover: Dictionary in Maps.FactoryGeometry.COVERS:
                var sprite: Texture2D = cover.sprite
                draw_texture_rect(sprite, Rect2(rect.position + (cover.pos - Maps.COVER_TEXTURE_ORIGIN) * scale, sprite.get_size() * scale), false)
        draw_rect(rect, Neon.LIME if id == selected else Neon.MUTED.darkened(0.5), false, 2)
