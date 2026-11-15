extends Control
## Bounded native ambient layers. No particles, shaders or gameplay RNG.
const Design=preload("res://scripts/neon_arcade.gd")
var hero_feet:=Vector2.ZERO
var reduced_motion:=false
var age:=0.0
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
    if not is_visible_in_tree() or reduced_motion:return
    age=fmod(age+delta,120.0);queue_redraw()
func _draw() -> void:
    var drift:=0.0 if reduced_motion else sin(age*.73)*.012
    draw_colored_polygon(PackedVector2Array([Vector2(size.x*.65,0),Vector2(size.x*.79,0),Vector2(size.x*.97,size.y),Vector2(size.x*.47,size.y)]),Color(Design.PURPLE,.045+drift))
    var radius:=minf(size.x*.17,155.0)
    draw_set_transform(hero_feet,0,Vector2(1,.25))
    draw_circle(Vector2.ZERO,radius,Color(Design.INK,.72),true,-1,true)
    draw_arc(Vector2.ZERO,radius-5,0,TAU,64,Color(Design.MAGENTA,.65),2,true)
    var start:=0.4 if reduced_motion else age*.55
    draw_arc(Vector2.ZERO,radius+2,start,start+1.1,12,Design.LIME,3,true)
    draw_set_transform(Vector2.ZERO)
    # Two asynchronous industrial signal rails; no full-screen flash.
    if size.x>=700:
        var level:=.20 if reduced_motion else .20+.05*sin(age*1.37)
        draw_line(Vector2(size.x*.82,size.y*.22),Vector2(size.x*.94,size.y*.22),Color(Design.MAGENTA,level),4,true)
        draw_line(Vector2(size.x*.83,size.y*.24),Vector2(size.x*.89,size.y*.24),Color(Design.LIME,.22+drift),2,true)
