class_name ArcadeTheme
extends RefCounted

## Hero Spotlight V5 semantic treatment. Isolated illustration exports remain gated.
const INK := Color("253449")
const DEEP := Color("13233a")
const BLUE := Color("1f3e63")
const SKY := Color("4ea3ff")
const PAPER := Color("f7edcd")
const CARD := Color("fff9e9")
const GOLD := Color("f8c45f")
const TEAL := Color("6eaab0")
const CORAL := Color("e57461")
const RARITY := {"common":Color("c9c5b5"),"rare":SKY,"epic":Color("a66bff"),"legendary":GOLD}
const BODY = preload("res://assets/fonts/Inter-Body.ttf")
const NUMBERS = preload("res://assets/fonts/Inter-Numbers.ttf")
const BLACK = preload("res://assets/fonts/Inter-Black.ttf")
const DISPLAY = preload("res://assets/fonts/Inter-Display.ttf")

static func font(role: String = "body") -> Font:
    var chosen: Font = {"body":BODY,"numbers":NUMBERS,"black":BLACK,"display":DISPLAY}.get(role,BODY)
    if chosen.fallbacks.is_empty(): chosen.fallbacks = [ThemeDB.fallback_font]
    return chosen

static func box(fill: Color, border: Color = INK, radius: int = 12, shadow: int = 4) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.set_border_width_all(3)
    style.set_corner_radius_all(radius)
    style.shadow_color = Color(DEEP,0.7)
    style.shadow_size = shadow
    style.shadow_offset = Vector2(0,4)
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 8
    style.content_margin_bottom = 8
    return style

static func _focus(control: Button) -> void:
    var outline := box(Color.TRANSPARENT,SKY,14,0)
    outline.set_border_width_all(4)
    for side in ["left","right","top","bottom"]: outline.set("expand_margin_"+side,4.0)
    control.add_theme_stylebox_override("focus",outline)
    control.add_theme_font_override("font",BLACK)
    control.add_theme_font_size_override("font_size",22)
    control.clip_text = false
    control.focus_mode = Control.FOCUS_ALL

static func button(control: Button, primary: bool = false, _accent: Color = INK) -> void:
    var fill := GOLD if primary else BLUE
    var rim := INK if primary else Color("86b6d6")
    control.add_theme_stylebox_override("normal",box(fill,rim,12,6))
    control.add_theme_stylebox_override("hover",box(fill.lightened(0.12),SKY,12,6))
    control.add_theme_stylebox_override("pressed",box(fill.darkened(0.10),INK,12,0))
    control.add_theme_stylebox_override("disabled",box(Color("556170"),Color("718096"),12,0))
    for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: control.add_theme_color_override(state,INK if primary else CARD)
    control.add_theme_color_override("font_disabled_color",Color("d1d8df"))
    _focus(control)

static func card(control: Button, selected: bool, rarity: Color = INK) -> void:
    var normal := box(PAPER,SKY if selected else rarity,19,5)
    normal.set_border_width_all(5 if selected else 4)
    control.add_theme_stylebox_override("normal",normal)
    control.add_theme_stylebox_override("hover",box(CARD,SKY,19,5))
    control.add_theme_stylebox_override("pressed",box(PAPER.darkened(0.04),SKY,19,0))
    for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: control.add_theme_color_override(state,INK)
    _focus(control)
