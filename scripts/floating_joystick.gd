class_name FloatingJoystick
extends Control

## GDD Annex C.1. Circular procedural fallback; candidate decorative art stays isolated.
const INK := Color("#253449")
const PAPER := Color("#f7edcd")
const AURA := Color("#f8c45f")
const OUTER_RADIUS := 80.0
const THUMB_RADIUS := 35.0
const SATURATION_TRAVEL := 119.0
const THUMB_OFFSET := 61.6
# Movement is digital at normal GDD speed after a short touch dead zone.
# The visual thumb still follows analog travel through the approved 119-unit range.
const MOVEMENT_DEADZONE := 18.0
const FOOTPRINT := THUMB_RADIUS + THUMB_OFFSET
var center := Vector2.ZERO
var axis := Vector2.ZERO
var active := false
var geometry_scale := 1.0

func configure(bounds: Rect2) -> void:
    geometry_scale = clampf(minf(bounds.size.x,bounds.size.y)/(2.0*FOOTPRINT),0.0,1.0)

func clamp_center(at: Vector2, bounds: Rect2) -> Vector2:
    var edge := FOOTPRINT*geometry_scale
    return Vector2(clampf(at.x,bounds.position.x+edge,bounds.end.x-edge),clampf(at.y,bounds.position.y+edge,bounds.end.y-edge))

func saturation() -> float:
    return maxf(1.0,SATURATION_TRAVEL*geometry_scale)

## Independent axes: full-speed gameplay direction versus proportional visual travel.
## This is an input responsiveness correction, not a movement-speed/balance change.
func direction_from_offset(offset: Vector2) -> Vector2:
    if offset.length_squared() <= pow(MOVEMENT_DEADZONE * geometry_scale, 2.0):
        return Vector2.ZERO
    return offset.normalized()

func visual_from_offset(offset: Vector2) -> Vector2:
    if offset.length_squared() <= pow(MOVEMENT_DEADZONE * geometry_scale, 2.0):
        return Vector2.ZERO
    return offset.limit_length(saturation()) / saturation()

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
    if not active: return
    var r := OUTER_RADIUS*geometry_scale
    draw_circle(center,r,Color(INK,0.52))
    draw_circle(center,r*0.88,Color(PAPER,0.12))
    draw_arc(center,r*0.95,0.0,TAU,64,Color(PAPER,0.62),3.0*geometry_scale)
    var thumb := center+axis*THUMB_OFFSET*geometry_scale
    draw_circle(thumb,THUMB_RADIUS*geometry_scale,Color(INK,0.92))
    draw_circle(thumb,THUMB_RADIUS*0.8*geometry_scale,Color(AURA,0.95))
    draw_arc(thumb,THUMB_RADIUS*0.8*geometry_scale,0.0,TAU,48,Color(PAPER,0.8),2.0*geometry_scale)
