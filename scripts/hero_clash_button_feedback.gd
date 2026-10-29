extends Control
## Full-face, tactile Godot button animation for Hero Clash.
##
## The original Button remains exactly where it is: same rect, focus owner,
## pressed signals, keyboard navigation and touch ownership. This mouse-
## ignoring child exclusively draws the button artwork and displaced label.
## The face travels inside the fixed hitbox; no fake scale of the entire Button.
const Artwork = preload("hero_clash_button_art.gd")
var art_family := "secondary"

const INK := Color("13233a")
const PAPER := Color("fff9e9")
const SKY := Color("4ea3ff")
const GOLD := Color("f8c45f")
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
var native_empty := StyleBoxEmpty.new()

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
    art_family=Artwork.family_for(action,game,family)
    low_motion=_reduced_motion()
    if newly_selected and not low_motion:
        selection_flash=1.0
    if full_face:
        # Candidate face/text are drawn by this mouse-ignoring child. Native
        # focus/hover backgrounds must not leave the old art visible underneath.
        action.flat=true
        for state_name in ["normal","hover","pressed","disabled","focus"]:
            action.add_theme_stylebox_override(state_name,native_empty)
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

func artwork_state() -> String:
    if action.disabled: return "disabled"
    if held or press_depth>0.03: return "pressed"
    if selected: return "selected"
    if focused: return "focus"
    if hovered: return "hover"
    return "normal"

func _draw_movable_face() -> void:
    # The authored shell already supplies its material, depth and edge treatment.
    # Only the existing short press travel remains; no extra bevels, shadows or glows.
    var movement: float=3.0*press_depth
    var rect:=Rect2(0,movement,size.x,size.y-movement)
    Artwork.draw(self,art_family,artwork_state(),rect)
    _draw_moving_label(Rect2(0,movement,size.x,size.y-6.0),GOLD)

func _draw_moving_label(rect: Rect2, _accent: Color) -> void:
    if action.text.is_empty(): return
    var font: Font=action.get_theme_font("font")
    if font==null: return
    var size_px: int=action.get_theme_font_size("font_size")
    var available: float=maxf(32.0,rect.size.x-32.0)
    while size_px>14 and font.get_string_size(action.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px).x>available:
        size_px-=1
    var baseline: float=rect.position.y+(rect.size.y-font.get_height(size_px))*0.5+font.get_ascent(size_px)
    var color:=Color("253449") if action.disabled else INK
    draw_string(font,Vector2((rect.size.x-available)*0.5,baseline),action.text,HORIZONTAL_ALIGNMENT_CENTER,available,size_px,color)

func _draw_card_accents() -> void:
    # Transparent center preserves approved hero/icon/card art. No second clickable control.
    var visual: String=artwork_state()
    if visual=="normal": return
    if selected and not action.disabled: visual="selected"
    Artwork.draw(self,"selection",visual,Rect2(Vector2(2,2),size-Vector2(4,4)))
