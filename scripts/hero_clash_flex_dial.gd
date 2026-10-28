extends Control
## Original vector Flex dial for the Hero Clash M0 interface candidate.
## Presentation-only: actual action/button, Aura, timing and ownership live in SoloRun.
var progress: float = 0.0
var visual_state: String = "charging"
var emphasized: bool = false
var highlighted: bool = false

func show_state(aura_fraction: float, next_state: String, button_emphasized: bool = false) -> void:
    var value: float = clampf(aura_fraction,0.0,1.0)
    if is_equal_approx(value,progress) and visual_state == next_state and emphasized == button_emphasized:
        return
    progress = value
    visual_state = next_state
    emphasized = button_emphasized
    queue_redraw()

func _draw() -> void:
    if size.x <= 0.0 or size.y <= 0.0:
        return
    var center: Vector2 = size * 0.5
    var radius: float = minf(size.x,size.y) * 0.5 - 10.0
    var ink := Color("13233a")
    var blue := Color("4ea3ff")
    var gold := Color("f8c45f")
    var teal := Color("6eaab0")
    var paper := Color("f7edcd")
    var color: Color = teal if visual_state == "active" else gold if visual_state == "ready" else blue
    var complete: bool = visual_state == "ready"
    # Restrained depth and concentric rims: readable over the detailed Ruin Alley.
    draw_circle(center + Vector2(0,3),radius+7.0,Color(0.02,0.05,0.09,0.38))
    draw_circle(center,radius+3.0,ink)
    draw_circle(center,radius-6.0,Color("1f3e63"))
    draw_circle(center,radius-13.0,ink)
    draw_arc(center,radius-1.0,-PI*0.5,PI*1.5,72,Color("45617a"),7.0,true)
    draw_arc(center,radius-1.0,-PI*0.5,-PI*0.5+TAU*progress,72,color,8.0,true)
    if complete:
        # A stable gold READY halo; no flashing, constant animation or gameplay RNG.
        draw_arc(center,radius+5.0,0.0,TAU,72,gold,4.0,true)
        for i in range(8):
            var theta: float=TAU*float(i)/8.0
            var start: Vector2=center+Vector2.RIGHT.rotated(theta)*(radius+7.0)
            var stop: Vector2=center+Vector2.RIGHT.rotated(theta)*(radius+11.0)
            draw_line(start,stop,gold,2.5,true)
    elif visual_state == "active":
        draw_arc(center,radius+5.0,0.0,TAU,72,teal,3.0,true)
    if emphasized:
        draw_arc(center,radius+5.0,0.0,TAU,72,paper,2.0,true)
