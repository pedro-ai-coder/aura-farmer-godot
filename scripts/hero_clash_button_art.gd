extends RefCounted
## Historical candidate PNG inspection and live shared native CPK Theme rendering.
## Neither implementation nor original candidate inventory confers artistic approval.
const TEXTURES = {
    "primary-normal":preload("res://assets/ui-button-candidates/v1/primary-normal.png"),
    "primary-hover":preload("res://assets/ui-button-candidates/v1/primary-hover.png"),
    "primary-focus":preload("res://assets/ui-button-candidates/v1/primary-focus.png"),
    "primary-pressed":preload("res://assets/ui-button-candidates/v1/primary-pressed.png"),
    "primary-selected":preload("res://assets/ui-button-candidates/v1/primary-selected.png"),
    "primary-disabled":preload("res://assets/ui-button-candidates/v1/primary-disabled.png"),
    "secondary-normal":preload("res://assets/ui-button-candidates/v1/secondary-normal.png"),
    "secondary-hover":preload("res://assets/ui-button-candidates/v1/secondary-hover.png"),
    "secondary-focus":preload("res://assets/ui-button-candidates/v1/secondary-focus.png"),
    "secondary-pressed":preload("res://assets/ui-button-candidates/v1/secondary-pressed.png"),
    "secondary-selected":preload("res://assets/ui-button-candidates/v1/secondary-selected.png"),
    "secondary-disabled":preload("res://assets/ui-button-candidates/v1/secondary-disabled.png"),
    "destructive-normal":preload("res://assets/ui-button-candidates/v1/destructive-normal.png"),
    "destructive-hover":preload("res://assets/ui-button-candidates/v1/destructive-hover.png"),
    "destructive-focus":preload("res://assets/ui-button-candidates/v1/destructive-focus.png"),
    "destructive-pressed":preload("res://assets/ui-button-candidates/v1/destructive-pressed.png"),
    "destructive-selected":preload("res://assets/ui-button-candidates/v1/destructive-selected.png"),
    "destructive-disabled":preload("res://assets/ui-button-candidates/v1/destructive-disabled.png"),
    "selection-normal":preload("res://assets/ui-button-candidates/v1/selection-normal.png"),
    "selection-hover":preload("res://assets/ui-button-candidates/v1/selection-hover.png"),
    "selection-focus":preload("res://assets/ui-button-candidates/v1/selection-focus.png"),
    "selection-pressed":preload("res://assets/ui-button-candidates/v1/selection-pressed.png"),
    "selection-selected":preload("res://assets/ui-button-candidates/v1/selection-selected.png"),
    "selection-disabled":preload("res://assets/ui-button-candidates/v1/selection-disabled.png"),
}
static var styles: Dictionary = {}
const CPK=preload("res://scripts/cpk_design_system.gd")
static var live_styles: Dictionary={}

static func live_style(family: String,state: String) -> StyleBox:
    var key:=family+"-"+state
    if live_styles.has(key):return live_styles[key]
    var result: StyleBox
    if family=="selection":
        var rim: Color=CPK.ORANGE if state=="selected" else CPK.MUTED if state=="disabled" else CPK.PAPER
        result=CPK.box(Color.TRANSPARENT,rim,0 if state=="normal" else 3)
    elif family=="destructive":
        result=CPK.box(CPK.PANEL,CPK.DANGER if state!="disabled" else CPK.BORDER,3 if state in ["focus","hover"] else 1)
    else:
        var variant: String="CpkPrimary" if family=="primary" else "Button"
        var native_state: String="normal" if state=="selected" else state
        if native_state=="focus":
            result=CPK.theme().get_stylebox("normal",variant).duplicate()
            result.border_color=CPK.PAPER;result.set_border_width_all(3)
        else:
            result=CPK.theme().get_stylebox(native_state,variant if CPK.theme().has_stylebox(native_state,variant) else "Button")
    live_styles[key]=result
    return result
static func style(family: String, state: String) -> StyleBoxTexture:
    var key := family+"-"+state
    if styles.has(key): return styles[key]
    var box := StyleBoxTexture.new()
    box.texture = TEXTURES[key]
    if family == "selection":
        for edge in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: box.set_texture_margin(edge,112)
        box.draw_center = false
    else:
        box.set_texture_margin(SIDE_LEFT,64)
        box.set_texture_margin(SIDE_RIGHT,64)
        box.set_texture_margin(SIDE_TOP,16)
        box.set_texture_margin(SIDE_BOTTOM,24)
    styles[key] = box
    return box

static func family_for(action: Button, game, legacy: String) -> String:
    if not legacy.begins_with("menu/"): return "selection"
    if game != null:
        if (action == game.confirm_button and game.mode == "confirm_exit") or action == game.presentation.secondary.quit_run:
            return "destructive"
    return "primary" if legacy == "menu/primary" else "secondary"

static func draw(canvas: CanvasItem, family: String, state: String, rect: Rect2) -> void:
    # The shared native Theme owns live controls. Old PNG/style() stays inspectable
    # for immutable historical provenance; no original source pixels are repainted.
    canvas.draw_style_box(live_style(family,state),rect)
