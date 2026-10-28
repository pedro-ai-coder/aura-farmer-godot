extends Control
## Full-face, tactile Godot button animation for Hero Clash.
##
## The original Button remains exactly where it is: same rect, focus owner,
## pressed signals, keyboard navigation and touch ownership. This mouse-
## ignoring child exclusively draws the button artwork and displaced label.
## The face travels inside the fixed hitbox; no fake scale of the entire Button.
const INK := Color("13233a")
const PAPER := Color("fff9e9")
const SKY := Color("4ea3ff")
const GOLD := Color("f8c45f")
const FACE_RISE := 6.0
const PUSH_DOWN_RATE := 21.0
const POP_UP_RATE := 11.0

var action: Button
var game
var family: String=""
var selected: bool=false
var held: bool=false
var hovered: bool=false
var focused: bool=false
var press_depth: float=0.0
var hover_glow: float=0.0
var release_flash: float=0.0
var selection_flash: float=0.0
var reveal_remaining: float=0.0
var reveal_delay: float=0.0
var low_motion: bool=false
var full_face: bool=false
var face_normal: StyleBox
var face_hover: StyleBox
var face_down: StyleBox
var face_disabled: StyleBox
var face_selected: StyleBox

func install(target: Button, owner_game) -> void:
    action=target
    game=owner_game
    name="ClashButtonFeedback"
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    action.button_down.connect(_button_down)
    action.button_up.connect(_button_up)
    action.pressed.connect(_activated)
    action.mouse_entered.connect(_mouse_entered)
    action.mouse_exited.connect(_mouse_exited)
    action.focus_entered.connect(_focus_entered)
    action.focus_exited.connect(_focus_exited)
    action.visibility_changed.connect(_visibility_changed)
    set_process(false)

func configure(new_family: String, new_selected: bool=false) -> void:
    var previous_family: String=family
    var newly_selected: bool=new_selected and not selected and previous_family==new_family
    family=new_family
    selected=new_selected
    full_face=family.begins_with("menu/")
    low_motion=_reduced_motion()
    if newly_selected and not low_motion:
        selection_flash=1.0
    if full_face:
        # StyleBoxTexture states are the immutable approved source artwork.
        # Draw these on the movable CHILD; native button's background/text
        # must not remain fixed behind the moving face.
        face_normal=action.get_theme_stylebox("normal")
        face_hover=action.get_theme_stylebox("hover")
        face_down=action.get_theme_stylebox("pressed")
        face_disabled=action.get_theme_stylebox("disabled")
        face_selected=face_hover
        action.flat=true
        for name_key in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color"]:
            action.add_theme_color_override(name_key,Color.TRANSPARENT)
    else:
        action.flat=false
        # The native art stays authoritative for cards and other complicated
        # components; only corner selection effects belong to the child.
    queue_redraw()
    _update_processing()

func _reduced_motion() -> bool:
    return game==null or bool(game.profile.get("settings",{}).get("reducedMotion",false))

func reveal(stagger: float=0.0) -> void:
    if _reduced_motion():
        reveal_remaining=0.0
        reveal_delay=0.0
        return
    reveal_remaining=1.0
    reveal_delay=maxf(0.0,stagger)
    _update_processing()

func _button_down() -> void:
    if action.disabled:
        return
    held=true
    _update_processing()

func _button_up() -> void:
    held=false
    _update_processing()

func _activated() -> void:
    # The actual button already emitted its pressed signal. Do not emit again.
    if not _reduced_motion():
        release_flash=1.0
    _update_processing()

func _mouse_entered() -> void:
    hovered=true
    _update_processing()

func _mouse_exited() -> void:
    hovered=false
    if not action.button_pressed:
        held=false
    _update_processing()

func _focus_entered() -> void:
    focused=true
    _update_processing()

func _focus_exited() -> void:
    focused=false
    _update_processing()

func _visibility_changed() -> void:
    if is_visible_in_tree():
        _update_processing()
        return
    held=false
    hovered=false
    focused=false
    press_depth=0.0
    hover_glow=0.0
    release_flash=0.0
    selection_flash=0.0
    reveal_remaining=0.0
    reveal_delay=0.0
    set_process(false)
    queue_redraw()

func _update_processing() -> void:
    low_motion=_reduced_motion()
    if low_motion:
        press_depth=1.0 if held else 0.0
        hover_glow=1.0 if (hovered or focused) else 0.0
        release_flash=0.0
        selection_flash=0.0
        reveal_remaining=0.0
        reveal_delay=0.0
        set_process(false)
        queue_redraw()
        return
    var target_glow: float=1.0 if (hovered or focused) else 0.0
    var target_depth: float=1.0 if held else 0.0
    var needs_tick: bool=absf(press_depth-target_depth)>0.001 or absf(hover_glow-target_glow)>0.001
    needs_tick=needs_tick or release_flash>0.001 or selection_flash>0.001 or reveal_remaining>0.001 or reveal_delay>0.001
    set_process(needs_tick and is_visible_in_tree())
    queue_redraw()

func _process(delta: float) -> void:
    if _reduced_motion():
        _update_processing()
        return
    press_depth=move_toward(press_depth,1.0 if held else 0.0,delta*(PUSH_DOWN_RATE if held else POP_UP_RATE))
    hover_glow=move_toward(hover_glow,1.0 if hovered or focused else 0.0,delta*9.0)
    release_flash=move_toward(release_flash,0.0,delta*5.0)
    selection_flash=move_toward(selection_flash,0.0,delta*3.5)
    if reveal_delay>0.0:
        reveal_delay=maxf(0.0,reveal_delay-delta)
    elif reveal_remaining>0.0:
        reveal_remaining=maxf(0.0,reveal_remaining-delta*4.0)
    queue_redraw()
    _update_processing()

func _draw() -> void:
    if action==null or not action.visible or size.x<32.0 or size.y<28.0:
        return
    if full_face:
        _draw_movable_face()
    else:
        _draw_card_accents()

func _draw_movable_face() -> void:
    var w: float=size.x
    var h: float=size.y
    var edge: float=clampf(h*0.10,4.0,8.0)
    var depressed: float=press_depth
    var movement: float=FACE_RISE*depressed
    var accent: Color=GOLD if family=="menu/primary" else SKY
    # Solid extruded base follows the actual button silhouette, not just a
    # skinny horizontal stroke. A deep "raised" position is recognizable.
    var underlay:=PackedVector2Array([
        Vector2(edge+2,6),Vector2(w-edge-26,6),
        Vector2(w-edge+1,24),Vector2(w-edge+1,h-3),
        Vector2(edge+4,h-3),Vector2(edge-1,h-13)
    ])
    draw_colored_polygon(underlay,INK)
    draw_line(Vector2(edge+9,h-4),Vector2(w-edge-12,h-4),Color(accent,0.58),2.5,true)
    # Move the entire approved face image down; it and its label share one
    # translation. The face never exits the original control rectangle.
    var rect:=Rect2(0.0,movement,w,h-FACE_RISE)
    var current: StyleBox=face_normal
    if action.disabled:
        current=face_disabled if face_disabled!=null else face_normal
    elif depressed>0.03:
        current=face_down if face_down!=null else face_normal
    elif hovered or focused:
        current=face_hover if face_hover!=null else face_normal
    if current!=null:
        draw_style_box(current,rect)
    # Top edge of the raised slab changes to an inset shadow when held.
    if depressed>0.02:
        draw_line(Vector2(edge+12,movement+5),Vector2(w-edge-39,movement+5),Color(INK,0.46*depressed),2.5,true)
    elif hovered or focused:
        draw_line(Vector2(edge+12,4),Vector2(w-edge-39,4),Color(accent,0.65*hover_glow),2.5,true)
    # Use the live original Button text for accessibility and all localization.
    # Its own rendered text is transparent but still owned by the real Button.
    _draw_moving_label(rect,accent)
    if release_flash>0.01:
        var alpha: float=release_flash
        draw_line(Vector2(edge+12,movement+3),Vector2(w-edge-40,movement+3),Color(PAPER,0.85*alpha),3.0,true)
    if reveal_remaining>0.01 and reveal_delay<=0.0:
        var x: float=lerpf(edge+8.0,w-edge-45.0,1.0-reveal_remaining)
        draw_line(Vector2(x,movement+3),Vector2(minf(x+31,w-edge-9),movement+3),Color(PAPER,0.58*reveal_remaining),3.0,true)

func _draw_moving_label(rect: Rect2, accent: Color) -> void:
    if action.text.is_empty():
        return
    var font: Font=action.get_theme_font("font")
    if font==null:
        return
    var requested: int=action.get_theme_font_size("font_size")
    var available: float=maxf(32.0,rect.size.x-30.0)
    var size_px: int=requested
    while size_px>12 and font.get_string_size(action.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px).x>available:
        size_px-=1
    var baseline: float=rect.position.y+(rect.size.y-font.get_height(size_px))*0.5+font.get_ascent(size_px)
    var ink_color: Color=Color("253449")
    var alpha: float=0.50 if action.disabled else 1.0
    var x: float=(rect.size.x-available)*0.5
    draw_string(font,Vector2(x,baseline+2),action.text,HORIZONTAL_ALIGNMENT_CENTER,available,size_px,Color(INK,0.30*alpha))
    draw_string(font,Vector2(x,baseline),action.text,HORIZONTAL_ALIGNMENT_CENTER,available,size_px,Color(ink_color,alpha))

func _draw_card_accents() -> void:
    var w: float=size.x
    var h: float=size.y
    var accent: Color=GOLD if selected else SKY
    var active: float=maxf(hover_glow,selection_flash)
    if active>0.02:
        draw_line(Vector2(12,10),Vector2(w-12,10),Color(accent,0.24+0.42*active),3.0,true)
    if selected:
        # Do not cover the real rarity art or card text. Corner keys only.
        for top in [true,false]:
            var yy: float=10.0 if top else h-10.0
            var direction: float=1.0 if top else -1.0
            draw_line(Vector2(10,yy),Vector2(44,yy),accent,4.0,true)
            draw_line(Vector2(10,yy),Vector2(10,yy+direction*27),accent,4.0,true)
            draw_line(Vector2(w-10,yy),Vector2(w-44,yy),accent,4.0,true)
            draw_line(Vector2(w-10,yy),Vector2(w-10,yy+direction*27),accent,4.0,true)
