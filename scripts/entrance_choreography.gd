extends RefCounted

const Camera = preload("res://scripts/camera_framing.gd")
const REVEAL := 2.45
const SIGNATURE := 4.45
const HANDOFF := 6.05
const COUNTDOWN := 7.25
const END := 10.25

static func sample(age: float, view: Vector2, spawn: Vector2, lane: Vector2, touch: bool, reduced: bool) -> Dictionary:
    var normal := Camera.zoom_for(view, touch)
    var close := maxf(normal * 1.35, minf(view.x / 225.0, view.y / 155.0))
    var wide := maxf(normal * 1.08, minf(view.x / 840.0, view.y / 460.0))
    var travel := smoothstep(0.0, REVEAL + 0.65, age)
    var feet := spawn + lane * (1.0 - travel)
    var center := feet - Vector2(0, 41)
    var zoom := close
    var shot := 0
    if age >= REVEAL:
        shot = 1
        var sweep := smoothstep(REVEAL, SIGNATURE, age)
        center = spawn + Vector2(lane.x * (0.3 - sweep), lerpf(16.0, -132.0, sweep))
        zoom = lerpf(close * 0.60, wide, sweep)
    if age >= SIGNATURE:
        shot = 2
        var push := smoothstep(SIGNATURE, HANDOFF, age)
        center = spawn - Vector2(0, 33)
        zoom = close * lerpf(0.80, 0.88, push)
    if age >= HANDOFF:
        shot = 3
        var settle := smoothstep(HANDOFF, COUNTDOWN, age)
        center = center.lerp(spawn, settle)
        zoom = lerpf(close * 0.88, normal, settle)
    if reduced:
        feet = spawn + lane * 0.44 if shot == 0 else spawn
        center = feet - Vector2(0, 36) if shot in [0, 2] else spawn
        zoom = [close, wide, close * 0.86, normal][shot]
    zoom = maxf(normal, zoom)
    return {"shot": shot, "feet": feet, "center": Camera.clamp_center(center, view, zoom), "zoom": zoom}
