extends Control
## Accent motion inside a fixed native Button hitbox; never emits activation.
const Design=preload("res://scripts/neon_arcade.gd")
var action: Button
var owner_game
var accent:=0.0
var transition: Tween
func install(button: Button,game) -> void:
    action=button;owner_game=game;mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    button.mouse_entered.connect(_highlight)
    button.focus_entered.connect(_highlight)
    button.mouse_exited.connect(_settle)
    button.focus_exited.connect(_settle)
    button.pressed.connect(_confirm)
    button.visibility_changed.connect(_visibility_changed)
    set_process(false)
func _reduced() -> bool:return bool(owner_game.profile["settings"]["reducedMotion"])
func _animate(value: float) -> void:
    if transition!=null:transition.kill()
    if _reduced():accent=value;queue_redraw();return
    transition=create_tween()
    transition.tween_method(_set_accent,accent,value,Design.FAST)
func _set_accent(value: float) -> void:accent=value;queue_redraw()
func _highlight() -> void:_animate(1.0)
func _settle() -> void:_animate(1.0 if action.has_focus() or action.is_hovered() else 0.0)
func _confirm() -> void:
    _set_accent(1.0);_settle()
func _visibility_changed() -> void:
    if not is_visible_in_tree():
        if transition!=null:transition.kill()
        accent=0.0;queue_redraw()
func _draw() -> void:
    if accent<=0 or action.disabled:return
    var color:=Color(Design.MAGENTA,accent*.9)
    draw_line(Vector2(10,10),Vector2(10,size.y-10),color,3,true)
    draw_line(Vector2(10,size.y-10),Vector2(10+(size.x-30)*accent,size.y-10),color,2,true)
