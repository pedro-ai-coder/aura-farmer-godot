class_name CpkDesignSystem
extends RefCounted
## Presentation tokens. Canon a1e670f, CPK-BRAND-2026-11-13-01.
## Component layouts are review candidates; no gameplay or save ownership.
const PAPER=Color("f3e9db")
const ORANGE=Color("ff6a00")
const VIOLET=Color("9b00ff")
const INK=Color("18171d")
const PANEL=Color("24212b")
const MUTED=Color("bab2c3")
const BORDER=Color("625a70")
const DANGER=Color("ff8b83")
const SUCCESS=Color("8bdfb1")
const SPACE=8.0
const TOUCH_MIN=48.0
const DISPLAY=preload("res://assets/fonts/hero-clash/ArchivoBlack.ttf")
const BODY=preload("res://assets/fonts/hero-clash/Archivo.ttf")
const NATIVE_THEME=preload("res://assets/ui/cpk/theme.tres")
static var card_styles: Dictionary={}

static func theme() -> Theme:
    return NATIVE_THEME

static func box(fill: Color=PANEL, rim: Color=BORDER, width: int=1, radius: int=8) -> StyleBoxFlat:
    var result:=StyleBoxFlat.new()
    result.bg_color=fill;result.border_color=rim
    result.set_border_width_all(width);result.set_corner_radius_all(radius)
    result.content_margin_left=16;result.content_margin_right=16
    result.content_margin_top=10;result.content_margin_bottom=10
    return result

static func button(control: Button, primary: bool=false) -> void:
    control.theme=NATIVE_THEME
    control.theme_type_variation="CpkPrimary" if primary else "CpkSecondary"
    control.focus_mode=Control.FOCUS_ALL
    control.custom_minimum_size.y=TOUCH_MIN
    control.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
    control.clip_text=false

static func card(control: Button, selected: bool=false, accent: Color=BORDER) -> void:
    button(control)
    var key:=str([selected,accent])
    if not card_styles.has(key):
        card_styles[key]=box(PANEL,ORANGE if selected else accent,3 if selected else 1)
    control.add_theme_stylebox_override("normal",card_styles[key])
    control.set_meta("cpk_selected",selected)

static func label(control: Label, role: String="body", compact: bool=false) -> void:
    control.theme=NATIVE_THEME
    var sizes: Dictionary={"display":[40,30],"title":[28,23],"body":[19,18],"small":[16,15],"micro":[14,14]}
    var values: Array=sizes.get(role,sizes["body"])
    control.add_theme_font_size_override("font_size",values[1 if compact else 0])
    control.add_theme_font_override("font",DISPLAY if role in ["display","title"] else BODY)
    control.mouse_filter=Control.MOUSE_FILTER_IGNORE

static func panel(control: PanelContainer, elevated: bool=false) -> void:
    control.theme=NATIVE_THEME
    control.add_theme_stylebox_override("panel",box(PANEL.lightened(0.04) if elevated else PANEL))

static func contrast(a: Color,b: Color) -> float:
    var x:=a.srgb_to_linear();var y:=b.srgb_to_linear()
    var la:=0.2126*x.r+0.7152*x.g+0.0722*x.b
    var lb:=0.2126*y.r+0.7152*y.g+0.0722*y.b
    return (maxf(la,lb)+0.05)/(minf(la,lb)+0.05)
