extends Control
## Separate presentation layers over the candidate environment-only backdrop.
## Native light, hero contact shadow, platform and foreground; no gameplay RNG.
const Design=preload("res://scripts/cpk_design_system.gd")
var hero_feet:=Vector2.ZERO
var reduced_motion:=false
var age:=0.0
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
    if not is_visible_in_tree() or reduced_motion:return
    age=fmod(age+delta,TAU*10.0);queue_redraw()
func _draw() -> void:
    var glow:=0.045 if reduced_motion else 0.045+sin(age*0.45)*0.008
    # A restrained local pool; no flicker, camera shake, screen tint or input effect.
    draw_colored_polygon(PackedVector2Array([Vector2(size.x*.42,size.y*.07),Vector2(size.x*.58,size.y*.07),Vector2(size.x*.76,size.y),Vector2(size.x*.24,size.y)]),Color(Design.ORANGE,glow))
    var radius:=minf(size.x*.17,155.0)
    draw_set_transform(hero_feet,0,Vector2(1,.25))
    draw_circle(Vector2.ZERO,radius,Color(Design.INK,.62),true,-1,true)
    draw_arc(Vector2.ZERO,radius-5,0,TAU,64,Color(Design.ORANGE,.7),3,true)
    draw_set_transform(Vector2.ZERO)
    # Independent foreground edge, leaving the actual buttons and center unobstructed.
    draw_rect(Rect2(0,size.y-6,size.x,6),Design.INK)
    draw_line(Vector2(0,size.y-8),Vector2(size.x*.15,size.y-8),Design.ORANGE,2)
    draw_line(Vector2(size.x*.85,size.y-8),Vector2(size.x,size.y-8),Design.VIOLET,2)
