extends RefCounted
## Neon Punk Arcade v1: candidate numeric tokens, isolated to frontend screens.
## Original OFL Archivo faces and approved brand/hero pixels are reused unchanged.
const Base=preload("res://scripts/cpk_design_system.gd")
const LIME=Color("d6ff36")
const MAGENTA=Color("ff37c8")
const PURPLE=Color("994bff")
const WHITE=Color("f7f8ef")
const INK=Color("0c0c14")
const PANEL=Color("16141f")
const MUTED=Color("c4bfd4")
const FAST=0.12
const ENTER=0.24
const SPACE=8.0
const TOUCH_MIN=48.0
static var cached_theme: Theme

static func box(fill: Color, rim: Color, width: int=1) -> StyleBoxFlat:
    var style:=Base.box(fill,rim,width,0)
    style.skew=Vector2(-0.08,0)
    style.content_margin_left=24;style.content_margin_right=24
    style.content_margin_top=10;style.content_margin_bottom=10
    return style

static func theme() -> Theme:
    if cached_theme!=null:return cached_theme
    cached_theme=Base.theme().duplicate(true)
    for variation in ["CpkPrimary","CpkSecondary"]:
        var primary: bool=variation=="CpkPrimary"
        for state in ["normal","hover","pressed","disabled","focus"]:
            var fill: Color=LIME if primary else PANEL
            var rim: Color=LIME if primary else Color("777083")
            if state=="hover":fill=WHITE if primary else Color("32243d");rim=MAGENTA
            if state=="pressed":fill=MAGENTA;rim=WHITE
            if state=="disabled":fill=Color("292632");rim=Color("514b5e")
            var style:=box(fill,rim,2)
            if state=="focus":
                style=box(Color.TRANSPARENT,WHITE,3)
                style.expand_margin_left=5;style.expand_margin_right=5
                style.expand_margin_top=5;style.expand_margin_bottom=5
            cached_theme.set_stylebox(state,variation,style)
        for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
            cached_theme.set_color(state,variation,INK if primary or state=="font_pressed_color" else WHITE)
        cached_theme.set_color("font_disabled_color",variation,Color("aaa3b5"))
        cached_theme.set_font("font",variation,Base.DISPLAY)
        cached_theme.set_font_size("font_size",variation,22)
    return cached_theme

static func button(control: Button,primary: bool=false) -> void:
    Base.button(control,primary);control.theme=theme()
    control.alignment=HORIZONTAL_ALIGNMENT_LEFT

static func label(control: Label,role: String="body") -> void:
    Base.label(control,role);control.add_theme_color_override("font_color",WHITE)
    if role in ["small","micro"]:control.add_theme_color_override("font_color",MUTED)

static func panel(control: PanelContainer) -> void:
    control.theme=theme()
    control.add_theme_stylebox_override("panel",box(Color(PANEL,.94),MAGENTA,1))

static func card(control: Button,selected: bool=false) -> void:
    button(control)
    control.add_theme_stylebox_override("normal",box(PANEL,LIME if selected else Color("777083"),3 if selected else 1))
    control.set_meta("cpk_selected",selected)
