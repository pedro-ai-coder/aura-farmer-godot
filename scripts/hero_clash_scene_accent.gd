extends Control
## Non-interactive, short Hero Clash scene-title accent reveal.
## Does not dim combat, scale controls or block pointer/keyboard focus.
var age: float=0.0
var duration: float=0.36
var current_mode: String=""
var canvas: Vector2=Vector2.ZERO

func _ready() -> void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    visible=false
    set_process(false)

func play(mode: String, viewport: Vector2, reduced_motion: bool=false) -> void:
    current_mode=mode
    canvas=viewport
    if reduced_motion or mode=="playing":
        visible=false
        set_process(false)
        return
    age=0.0
    visible=true
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    age+=delta
    if age>=duration:
        age=duration
        visible=false
        set_process(false)
    queue_redraw()

func _draw() -> void:
    if not visible or canvas.x<100.0 or canvas.y<100.0:
        return
    var t: float=clampf(age/duration,0.0,1.0)
    var eased: float=1.0-pow(1.0-t,3.0)
    var fade: float=1.0-t
    var x: float=40.0 if current_mode=="menu" else 30.0
    var y: float=215.0 if current_mode=="menu" else 94.0
    var end_x: float=x+minf(canvas.x*0.20,178.0)*eased
    var gold:=Color("f8c45f")
    var sky:=Color("4ea3ff")
    draw_line(Vector2(x,y),Vector2(end_x,y),Color(gold,0.80*fade),4.0,true)
    if end_x-x>22.0:
        draw_line(Vector2(end_x-20.0,y+5.0),Vector2(end_x,y+5.0),Color(sky,0.66*fade),2.0,true)
        draw_colored_polygon(PackedVector2Array([
            Vector2(end_x,y-6.0),Vector2(end_x+7.0,y),
            Vector2(end_x,y+6.0),Vector2(end_x-7.0,y)
        ]),Color("fff9e9",0.70*fade))
