class_name ArcadeTheme
extends RefCounted

## Canonical Option A palette. Original Phaser catalog symbols remain the UI icons.
const INK := Color("253449")
const PAPER := Color("f7edcd")
const CARD := Color("fff9e9")
const GOLD := Color("f8c45f")
const TEAL := Color("6eaab0")
const CORAL := Color("e57461")
const RARITY := {"common":Color("c9c5b5"),"rare":Color("448d9d"),"epic":Color("9167a4"),"legendary":Color("bc8328")}

static func box(fill: Color, border: Color = INK, radius: int = 12, shadow: int = 4) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.set_border_width_all(3)
    style.set_corner_radius_all(radius)
    style.shadow_color = Color(INK,0.55)
    style.shadow_size = shadow
    style.shadow_offset = Vector2(0,4)
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    return style

static func button(control: Button, selected: bool = false, accent: Color = INK) -> void:
    control.add_theme_stylebox_override("normal",box(GOLD if selected else PAPER,accent))
    control.add_theme_stylebox_override("hover",box(Color("fff1c6"),INK))
    control.add_theme_stylebox_override("pressed",box(TEAL,INK,12,0))
    control.add_theme_stylebox_override("disabled",box(Color("cecbbd"),Color("7c827d"),12,0))
    var focus := box(Color.TRANSPARENT,GOLD,14,0)
    focus.set_border_width_all(3)
    focus.expand_margin_left = 4
    focus.expand_margin_right = 4
    focus.expand_margin_top = 4
    focus.expand_margin_bottom = 4
    control.add_theme_stylebox_override("focus",focus)
    for state in ["font_color","font_hover_color","font_pressed_color"]: control.add_theme_color_override(state,INK)
    control.add_theme_color_override("font_disabled_color",Color("5a6268"))
    control.add_theme_font_size_override("font_size",22)
    control.clip_text = true
    control.focus_mode = Control.FOCUS_ALL
