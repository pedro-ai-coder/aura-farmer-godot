class_name FloatingJoystick
extends Control

## GDD C.1: visual-only, thumb-origin joystick. Input is owned by SoloRun.
## Screen-space overlay, never a world-space collision or gameplay RNG source.
const INK := Color("#253449")
const PAPER := Color("#f7edcd")
const AURA := Color("#f8c45f")

var center := Vector2.ZERO
var axis := Vector2.ZERO
var active := false

func show_at(position: Vector2, movement: Vector2) -> void:
    center = position
    axis = movement.limit_length(1.0)
    active = true
    visible = true
    queue_redraw()

func reset() -> void:
    active = false
    axis = Vector2.ZERO
    visible = false
    queue_redraw()

func _draw() -> void:
    if not active:
        return
    # The transparent visual always follows the first finger contact.
    draw_circle(center, 57.0, Color(INK, 0.52))
    draw_circle(center, 50.0, Color(PAPER, 0.12))
    draw_arc(center, 54.0, 0.0, TAU, 44, Color(PAPER, 0.62), 3.0)
    var thumb := center + axis * 44.0
    draw_circle(thumb, 25.0, Color(INK, 0.92))
    draw_circle(thumb, 20.0, Color(AURA, 0.95))
    draw_arc(thumb, 20.0, 0.0, TAU, 24, Color(PAPER, 0.8), 2.0)
