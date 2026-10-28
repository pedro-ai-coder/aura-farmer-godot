extends Control
## Non-interactive embossed/pressed feedback for original live Godot Buttons.
## This only changes visual transforms. It never emits pressed or consumes input.
var action: Button
var game
var active_tween: Tween
var held: bool = false

func install(target: Button, owner_game) -> void:
    action=target
    game=owner_game
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    target.button_down.connect(_down)
    target.button_up.connect(_up)
    target.visibility_changed.connect(_visibility_changed)
    target.mouse_exited.connect(_mouseleave)
    queue_redraw()

func _motion_is_reduced() -> bool:
    return game == null or bool(game.profile.get("settings",{}).get("reducedMotion",false))

func _set_press(press: bool) -> void:
    if action == null or not is_instance_valid(action):
        return
    held=press and not action.disabled
    if active_tween!=null and active_tween.is_running():
        active_tween.kill()
    action.pivot_offset=action.size*0.5
    var destination: Vector2=Vector2(0.975,0.955) if held else Vector2.ONE
    var tint: Color=Color(0.92,0.92,0.92) if held else Color.WHITE
    if _motion_is_reduced():
        action.scale=destination
        action.self_modulate=tint
    else:
        active_tween=action.create_tween()
        active_tween.set_parallel(true)
        active_tween.tween_property(action,"scale",destination,0.075 if held else 0.15).set_trans(Tween.TRANS_BACK if not held else Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
        active_tween.tween_property(action,"self_modulate",tint,0.075 if held else 0.15)
    queue_redraw()

func _down() -> void:
    _set_press(true)

func _up() -> void:
    _set_press(false)

func _mouseleave() -> void:
    if action!=null and not action.button_pressed:
        _set_press(false)

func _visibility_changed() -> void:
    if action==null or not is_instance_valid(action) or action.visible:
        return
    if active_tween!=null and active_tween.is_running():
        active_tween.kill()
    held=false
    action.scale=Vector2.ONE
    action.self_modulate=Color.WHITE

func _draw() -> void:
    if size.x<28.0 or size.y<26.0:
        return
    var edge: float=4.0
    var shadow: Color=Color(0.03,0.07,0.14,0.56 if not held else 0.20)
    var shine: Color=Color(1.0,0.99,0.92,0.44 if not held else 0.13)
    draw_line(Vector2(edge+4.0,size.y-6.0),Vector2(size.x-edge-4.0,size.y-6.0),shadow,3.0 if not held else 1.0,true)
    draw_line(Vector2(edge+7.0,5.0),Vector2(size.x-edge-7.0,5.0),shine,2.0,true)
