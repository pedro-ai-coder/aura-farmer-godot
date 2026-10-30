extends Control
## Original state-driven circular Flex dial: a visual invitation, never auto-use.
## Only game.aura and existing _use_flex control authorize ability activation.
const BODY=preload("res://assets/ui-hud-candidates/v2/flex-body.svg")
var progress: float=0.0
var visual_state: String="charging"
var emphasized: bool=false
var highlighted: bool=false
var reduced_motion: bool=false
var ready_phase: float=0.0
var ready_introduction: float=0.0
var push_target: float=0.0
var push_current: float=0.0
var hero_id: String="sigma"
var body_alpha: float=1.0

func set_occluded(covered: bool) -> void:
    var alpha: float=0.18 if covered else 1.0
    if is_equal_approx(alpha,body_alpha):return
    body_alpha=alpha;queue_redraw()

func set_identity(id: String) -> void:
    if hero_id==id:return
    hero_id=id;queue_redraw()

func _ready() -> void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(false)

func show_state(aura_fraction: float, next_state: String, button_emphasized: bool=false, low_motion: bool=false) -> void:
    var value: float=clampf(aura_fraction,0.0,1.0)
    var entering_ready: bool=next_state=="ready" and visual_state!="ready"
    var changed: bool=not is_equal_approx(value,progress) or visual_state!=next_state or emphasized!=button_emphasized or reduced_motion!=low_motion
    progress=value
    visual_state=next_state
    emphasized=button_emphasized
    reduced_motion=low_motion
    if entering_ready:
        ready_phase=0.0
        ready_introduction=1.0
    if reduced_motion:
        ready_introduction=0.0
        push_current=push_target
    set_process((visual_state=="ready" and not reduced_motion and is_visible_in_tree()) or absf(push_target-push_current)>0.001 or ready_introduction>0.0)
    if changed:
        queue_redraw()

func set_pressed(pressed: bool) -> void:
    push_target=1.0 if pressed else 0.0
    if reduced_motion:
        push_current=push_target
    set_process(not reduced_motion or absf(push_target-push_current)>0.001)
    queue_redraw()

func _process(delta: float) -> void:
    if visual_state=="ready" and not reduced_motion and is_visible_in_tree():
        ready_phase+=delta
    if ready_introduction>0.0:
        ready_introduction=maxf(0.0,ready_introduction-delta*3.0)
    push_current=lerpf(push_current,push_target,clampf(delta*18.0,0.0,1.0))
    if absf(push_target-push_current)<0.003:
        push_current=push_target
    queue_redraw()
    if (visual_state!="ready" or reduced_motion or not is_visible_in_tree()) and ready_introduction<=0.0 and push_current==push_target:
        set_process(false)

func _draw() -> void:
    if size.x<=0.0 or size.y<=0.0:
        return
    var center: Vector2=size*0.5
    var squash: float=1.0-0.065*push_current
    var radius: float=(minf(size.x,size.y)*0.5-10.0)*squash
    var ink:=Color("13233a")
    var blue:=Color("20d9ff")
    var gold:=Color("ffce30")
    var teal:=Color("6eaab0")
    var paper:=Color("f7edcd")
    var accent: Color=teal if visual_state=="active" else gold if visual_state=="ready" else blue
    var complete: bool=visual_state=="ready"
    var body_radius: float=(radius+7.0)
    draw_texture_rect(BODY,Rect2(center-Vector2.ONE*body_radius,Vector2.ONE*body_radius*2.0),false,Color(0.72,0.78,0.85,body_alpha) if visual_state in ["recovery","disabled"] else Color(1,1,1,body_alpha))
    draw_arc(center,radius-1.0,-PI*0.5,PI*1.5,72,Color("45617a"),7.0,true)
    draw_arc(center,radius-1.0,-PI*0.5,-PI*0.5+TAU*progress,72,accent,8.0,true)
    if complete:
        # Slow two-second visual breathing makes READY discoverable without
        # flashing or automatically pressing the player action.
        var breathe: float=0.0 if reduced_motion else (0.5+0.5*sin(ready_phase*PI))
        var expansion: float=0.0 if reduced_motion else 3.0*breathe+2.0*ready_introduction
        draw_arc(center,radius+5.0+expansion,0.0,TAU,72,gold,3.0+2.0*breathe,true)
        for i in range(8):
            var theta: float=TAU*float(i)/8.0
            var direction: Vector2=Vector2.RIGHT.rotated(theta)
            draw_line(center+direction*(radius+7.0+expansion),center+direction*(radius+10.0+expansion),gold,2.5,true)
    elif visual_state=="active":
        draw_arc(center,radius+5.0,0.0,TAU,72,teal,3.0,true)
    # Original lightweight UI motifs; all hero artwork stays byte-identical.
    var mark:=Vector2(center.x,size.y*0.26)
    var unit: float=size.x/184.0
    if hero_id=="sigma":
        draw_polyline(PackedVector2Array([mark+Vector2(-16,0)*unit,mark+Vector2(-7,-7)*unit,mark+Vector2(7,-7)*unit,mark+Vector2(16,0)*unit,mark+Vector2(7,7)*unit,mark+Vector2(-7,7)*unit,mark+Vector2(-16,0)*unit]),paper,2*unit,true)
        draw_circle(mark,4*unit,accent)
    elif hero_id=="cool-kid":
        draw_rect(Rect2(mark-Vector2(17,10)*unit,Vector2(34,20)*unit),paper,false,2*unit)
        draw_polyline(PackedVector2Array([mark+Vector2(8,-5)*unit,mark+Vector2(8,3)*unit,mark+Vector2(-8,3)*unit,mark+Vector2(-3,-2)*unit,mark+Vector2(-8,3)*unit,mark+Vector2(-3,8)*unit]),accent,2*unit,true)
    else:
        draw_polyline(PackedVector2Array([mark+Vector2(0,-11)*unit,mark+Vector2(13,-6)*unit,mark+Vector2(11,6)*unit,mark+Vector2(0,13)*unit,mark+Vector2(-11,6)*unit,mark+Vector2(-13,-6)*unit,mark+Vector2(0,-11)*unit]),paper,2*unit,true)
        draw_line(mark+Vector2(0,-5)*unit,mark+Vector2(0,6)*unit,accent,3*unit,true)
    if emphasized or push_current>0.01:
        draw_arc(center,radius+4.0,0.0,TAU,72,paper,2.0,true)
