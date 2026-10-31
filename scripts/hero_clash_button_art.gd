extends RefCounted
## Original candidate artwork; NOT an approved-art registry. Loaded once, shared by live buttons.
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
    # Match source-pixel density vertically before nine-slicing horizontally.
    # This keeps authored cap proportions at 64px, 72px and compact control sizes.
    var scale_factor: float=rect.size.y/192.0 if family!="selection" else 0.5
    canvas.draw_set_transform(rect.position,0,Vector2.ONE*scale_factor)
    canvas.draw_style_box(style(family,state),Rect2(Vector2.ZERO,rect.size/scale_factor))
    canvas.draw_set_transform(Vector2.ZERO)
