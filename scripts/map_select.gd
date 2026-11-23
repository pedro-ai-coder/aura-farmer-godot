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
    start = _button("START RUN", func(): game.start_selected_map(selected), true)
    clear_selection()

func _button(caption: String, action: Callable, primary: bool = false) -> Button:
    var button := Button.new()
    button.text = caption
    Neon.button(button, primary)
    button.alignment = HORIZONTAL_ALIGNMENT_CENTER
    button.pressed.connect(action)
    add_child(button)
    return button

func clear_selection() -> void:
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
    var buttons: Array[Button] = [choices[Maps.RUIN_ALLEY], choices[Maps.MSG_FACTORY], back]
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
    var preview_height := clampf(size.y - 250, 0, card_width * 0.75)
    var center := size * 0.5
    var top := center.y - (preview_height + 190) * 0.5
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
