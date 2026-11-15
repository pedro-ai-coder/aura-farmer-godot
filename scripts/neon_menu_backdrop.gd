extends Control
## Code-drawn menu shell. No art, input, simulation or random-number ownership.
const Design=preload("res://scripts/neon_arcade.gd")
const MODES=["paused","build","options","confirm_exit","profile_import","profile_export","won","lost","choice","replace","legendary"]
var game
var mode: String=""
var age: float=Design.ENTER

func install(owner_game) -> void:
    game=owner_game
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_process(false)

func refresh(extent: Vector2) -> void:
    var changed: bool=mode!=game.mode
    mode=game.mode;size=extent;visible=mode in MODES
    if changed:age=0.0
    if game.profile["settings"]["reducedMotion"]:age=Design.ENTER
    set_process(visible and age<Design.ENTER)
    queue_redraw()

func _process(delta: float) -> void:
    age=Design.ENTER if game.profile["settings"]["reducedMotion"] else minf(Design.ENTER,age+delta)
    set_process(age<Design.ENTER and visible)
    queue_redraw()

func _draw() -> void:
    if mode!="paused":
        draw_rect(Rect2(Vector2.ZERO,size),Design.INK)
        draw_colored_polygon(PackedVector2Array([Vector2(size.x*.76,0),Vector2(size.x,0),size,Vector2(size.x*.57,size.y)]),Color("21162c"))
        draw_line(Vector2(size.x*.76,0),Vector2(size.x*.57,size.y),Color(Design.MAGENTA,.28),2,true)
    var reveal: float=1.0-pow(1.0-age/Design.ENTER,3.0)
    draw_rect(Rect2(0,0,size.x*reveal,3),Design.LIME)
    draw_rect(Rect2(size.x*(1.0-reveal),size.y-3,size.x*reveal,3),Design.MAGENTA)
    for i in range(5):
        var x: float=size.x-32-i*9
        draw_line(Vector2(x,size.y-18),Vector2(x+6,size.y-28),Design.LIME,2,true)
