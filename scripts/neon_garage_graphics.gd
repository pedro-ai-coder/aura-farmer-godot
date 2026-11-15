extends Control
## Lightweight graphic framing; reuses the existing candidate garage underneath.
const Design=preload("res://scripts/neon_arcade.gd")
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
    var w:=size.x;var h:=size.y
    # The asymmetric ink scrim keeps navigation legible without obscuring the garage.
    if w>=700:
        draw_colored_polygon(PackedVector2Array([Vector2.ZERO,Vector2(w*.47,0),Vector2(w*.57,h),Vector2(0,h)]),Color(Design.INK,.90))
        draw_line(Vector2(w*.47,0),Vector2(w*.57,h),Color(Design.MAGENTA,.48),2,true)
        for i in range(5):
            var x:=w*.50+i*12
            draw_line(Vector2(x,h-24),Vector2(x+15,h-47),Design.LIME,3,true)
    else:draw_rect(Rect2(Vector2.ZERO,size),Color(Design.INK,.38))
    draw_rect(Rect2(0,0,w,5),Design.LIME)
    draw_rect(Rect2(0,h-5,w*.36,5),Design.MAGENTA)
    draw_rect(Rect2(w*.83,h-5,w*.17,5),Design.LIME)
