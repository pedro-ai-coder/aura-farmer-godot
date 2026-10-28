extends Control
## Hero Clash raised-button treatment. All animation is cosmetic on this child:
## the parent Button and its touch/focus rectangle never move or scale.
## Only the real Godot BaseButton emits gameplay/navigation actions.

const PRESS_IN: float = 18.0
const RELEASE_OUT: float = 12.0
const FLASH_DECAY: float = 4.2

var action: Button
var game
var family: String = ""
var selected: bool = false
var held: bool = false
var hovered: bool = false
var focused: bool = false
var press_depth: float = 0.0
var hover_glow: float = 0.0
var release_flash: float = 0.0
var selection_flash: float = 0.0
var pulse_clock: float = 0.0
var reveal_remaining: float = 0.0
var reveal_delay: float = 0.0
var low_motion: bool = false

func install(target: Button, owner_game) -> void:
    action=target
    game=owner_game
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
    queue_redraw()

func configure(new_family: String, new_selected: bool=false) -> void:
    # The skin refreshes on many game-state updates. A repeated style application
    # must not restart an animation or allocate another visual overlay.
    var changed: bool=family!=new_family or selected!=new_selected
    var became_selected: bool=new_selected and not selected and family==new_family
    family=new_family
    selected=new_selected
    low_motion=_reduced_motion()
    if became_selected and not low_motion:
        selection_flash=1.0
    if changed:
        queue_redraw()
    _update_processing()

func reveal(stagger: float = 0.0) -> void:
    if _reduced_motion():
        reveal_remaining=0.0
        reveal_delay=0.0
        return
    reveal_remaining=1.0
    reveal_delay=maxf(0.0,stagger)
    set_process(true)

func _reduced_motion() -> bool:
    return game==null or bool(game.profile.get("settings",{}).get("reducedMotion",false))

func _button_down() -> void:
    if action.disabled:
        return
    held=true
    _update_processing()
    queue_redraw()

func _button_up() -> void:
    held=false
    _update_processing()
    queue_redraw()

func _activated() -> void:
    if not _reduced_motion():
        release_flash=1.0
    _update_processing()
    queue_redraw()

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
        hover_glow=1.0 if hovered or focused else 0.0
        release_flash=0.0
        selection_flash=0.0
        reveal_remaining=0.0
        reveal_delay=0.0
        set_process(false)
        queue_redraw()
        return
    var active: bool=held or (hovered or focused) != (hover_glow>0.999)
    active=active or press_depth>0.003 or release_flash>0.003 or selection_flash>0.003 or reveal_remaining>0.003 or reveal_delay>0.003
    set_process(active and is_visible_in_tree())

func _process(delta: float) -> void:
    low_motion=_reduced_motion()
    if low_motion:
        _update_processing()
        return
    var target_press: float=1.0 if held else 0.0
    var target_glow: float=1.0 if (hovered or focused) else 0.0
    press_depth=move_toward(press_depth,target_press,delta*(PRESS_IN if held else RELEASE_OUT))
    hover_glow=move_toward(hover_glow,target_glow,delta*7.0)
    release_flash=move_toward(release_flash,0.0,delta*FLASH_DECAY)
    selection_flash=move_toward(selection_flash,0.0,delta*3.6)
    if reveal_delay>0.0:
        reveal_delay=maxf(0.0,reveal_delay-delta)
    elif reveal_remaining>0.0:
        reveal_remaining=maxf(0.0,reveal_remaining-delta*3.7)
    pulse_clock+=delta
    queue_redraw()
    # No per-frame UI work after the brief interaction ends.
    if not held and is_zero_approx(press_depth) and is_equal_approx(hover_glow,target_glow) and is_zero_approx(release_flash) and is_zero_approx(selection_flash) and is_zero_approx(reveal_remaining) and is_zero_approx(reveal_delay):
        set_process(false)

func _draw() -> void:
    if action==null or size.x<28.0 or size.y<26.0 or not action.visible:
        return
    var w: float=size.x
    var h: float=size.y
    var is_card: bool=family.begins_with("cards/") or family.begins_with("hero-select/")
    var is_primary: bool=family=="menu/primary"
    var accent: Color=Color("f8c45f") if is_primary or selected else Color("4ea3ff")
    var ink:=Color("13233a")
    var paper:=Color("fff9e9")
    var depth: float=press_depth
    var edge: float=clampf(minf(w,h)*0.085,3.0,7.0)
    if is_card:
        # Card artwork must remain the dominant surface. Only the selected
        # metal corners and focus affordance are animated.
        var card_alpha: float=0.18+0.60*selection_flash if selected else 0.18*hover_glow
        if card_alpha>0.005:
            draw_line(Vector2(edge,edge),Vector2(w-edge,edge),Color(accent,card_alpha),3.0,true)
            draw_line(Vector2(edge,h-edge),Vector2(w-edge,h-edge),Color(accent,card_alpha*0.7),2.0,true)
        if selected:
            draw_line(Vector2(8,8),Vector2(42,8),accent,4.0,true)
            draw_line(Vector2(8,8),Vector2(8,32),accent,4.0,true)
            draw_line(Vector2(w-8,h-8),Vector2(w-42,h-8),accent,4.0,true)
            draw_line(Vector2(w-8,h-8),Vector2(w-8,h-32),accent,4.0,true)
        return
    # Three-layer original pseudo-3D finish for the approved flat button art.
    # Draw *inside* the button bounds: real hit target never changes.
    # Thick bottom inset forms a visible lifted edge at rest, compressed on
    # press. It is painted INSIDE the real approved click rectangle.
    var bevel_y: float=h-(4.0+7.0*(1.0-depth))
    var base_tint: Color=Color(ink,0.78-0.36*depth)
    draw_colored_polygon(PackedVector2Array([
        Vector2(edge+3.0,bevel_y),Vector2(w-edge-3.0,bevel_y),
        Vector2(w-edge-6.0,h-edge+1.0),Vector2(edge+1.0,h-edge+1.0)
    ]),Color(ink,0.34*(1.0-depth)+0.22))
    draw_line(Vector2(edge+6,bevel_y),Vector2(w-edge-7,bevel_y),base_tint,3.0-1.0*depth,true)
    var upper: Color=Color(paper,(0.44+hover_glow*0.35)*(1.0-depth*0.80))
    draw_line(Vector2(edge+7,edge),Vector2(w-edge-7,edge),upper,2.4,true)
    draw_line(Vector2(edge+4,edge+3),Vector2(edge+4,h-edge-7),Color(paper,0.23*(1.0-depth)),1.6,true)
    # An asymmetric small circuit-like accent; no floating highlight over text.
    draw_colored_polygon(PackedVector2Array([
        Vector2(w-edge-29,edge+4),Vector2(w-edge-12,edge+4),
        Vector2(w-edge-20,edge+12),Vector2(w-edge-37,edge+12)
    ]),Color(accent,0.60+0.30*hover_glow))
    if is_primary:
        draw_line(Vector2(edge+10,h-edge-3),Vector2(w-edge-10,h-edge-3),Color("ffc83d",0.53*(1.0-depth)),2.3,true)
    if hover_glow>0.01 or focused:
        var glow: float=maxf(hover_glow,1.0 if focused else 0.0)
        draw_line(Vector2(edge+14,edge+1),Vector2(w-edge-42,edge+1),Color(accent,0.72*glow),3.0,true)
        draw_line(Vector2(edge+9,h-edge-1),Vector2(w-edge-9,h-edge-1),Color(accent,0.27*glow),2.0,true)
    if depth>0.01:
        # Clear inset shading and top/bottom edge inversion at full press:
        # no scaling of the actual Control or hit-testing rectangle.
        draw_rect(Rect2(edge+5,edge+7,maxf(1.0,w-edge*2.0-10.0),maxf(1.0,h-edge*2.0-17.0)),Color(ink,0.11*depth),true)
        draw_line(Vector2(edge+10,edge+5),Vector2(w-edge-10,edge+5),Color(ink,0.48*depth),3.0,true)
        draw_line(Vector2(edge+9,h-edge-2),Vector2(w-edge-9,h-edge-2),Color(paper,0.30*depth),3.0,true)
    if release_flash>0.01:
        draw_line(Vector2(edge+10,edge+1),Vector2(w-edge-10,edge+1),Color(paper,0.72*release_flash),3.0,true)
        draw_line(Vector2(edge+12,h-edge-1),Vector2(w-edge-12,h-edge-1),Color(accent,0.65*release_flash),2.0,true)
    if reveal_remaining>0.01 and reveal_delay<=0.0:
        # Short traveling metal sheen on screen entry (edge only, no text cover).
        var traveled: float=1.0-reveal_remaining
        var sheen_x: float=lerpf(edge+12.0,w-edge-32.0,traveled)
        draw_line(Vector2(sheen_x,edge+1),Vector2(minf(w-edge-7,sheen_x+26),edge+1),Color(paper,0.66*reveal_remaining),3.0,true)
