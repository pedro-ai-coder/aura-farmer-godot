extends RefCounted
## Fixed world-space pulse, resolved hit accents, and live No U state markers.

const TRAVEL := 0.24
const PULSE_LIFE := 0.46
const CONTACT_LIFE := 0.23
const MAX_CONTACTS := 48
const EDGE := Color("#61eafa")
const CORE := Color("#dbfbff")
const INK := Color("#122535")
const STATUS := Color("#8ec4dc")

var _origin := Vector2.ZERO
var _radius := 0.0
var _at := -INF
var _contacts := PackedVector2Array()
var _weakened: Dictionary = {}
var _latest_weaken_until := -INF


func clear() -> void:
    _at = -INF
    _contacts.clear()
    _weakened = {}
    _latest_weaken_until = -INF


func pulse(center: Vector2, radius: float, at: float, hits: Array[Dictionary], weakened: Dictionary) -> void:
    _origin = center
    _radius = radius
    _at = at
    _contacts.clear()
    for index in mini(hits.size(), MAX_CONTACTS):
        _contacts.append(hits[index]["pos"])
    _weakened = weakened
    _latest_weaken_until = -INF
    for status: Array in weakened.values():
        _latest_weaken_until = maxf(_latest_weaken_until, float(status[1]))


func draw_ground(canvas: CanvasItem, now: float, reduced: bool) -> void:
    var age := now - _at
    if age < 0.0 or age >= PULSE_LIFE:
        return
    var travel := clampf(age / TRAVEL, 0.0, 1.0)
    var fade := 1.0 - smoothstep(TRAVEL, PULSE_LIFE, age)
    var front := _radius if reduced else lerpf(37.0, _radius, 1.0 - pow(1.0 - travel, 1.65))
    # A broken, unfilled edge keeps the ground and hostile telegraphs visible.
    for sector in 8:
        var heading := sector * TAU / 8.0 + TAU / 32.0
        var end := heading + 0.68
        canvas.draw_arc(_origin, front, heading, end, 18, Color(INK, 0.85 * fade), 7.0, true)
        canvas.draw_arc(_origin, front, heading, end, 18, Color(EDGE, 0.90 * fade), 3.4, true)
        canvas.draw_arc(_origin, front, heading + 0.08, end - 0.20, 12, Color(CORE, 0.86 * fade), 1.25, true)
        var radial := Vector2.from_angle(heading)
        var cap := _origin + radial * front
        canvas.draw_line(cap - radial * 10.0 - radial.orthogonal() * 5.0, cap, Color(CORE, fade), 2.1, true)
        if not reduced and age < TRAVEL:
            var wake := lerpf(8.0, 34.0, travel)
            var inner := maxf(12.0, front - wake)
            canvas.draw_arc(_origin, inner, heading + 0.15, end - 0.09, 12, Color(EDGE, 0.32 * (1.0 - travel)), 2.4, true)
    var ignition := 1.0 - smoothstep(0.04, 0.20, age)
    if ignition <= 0.0:
        return
    for quadrant in 4:
        var radial := Vector2.from_angle(PI * 0.25 + quadrant * PI * 0.5)
        var tangent := radial.orthogonal()
        var tip := _origin + radial * 43.0
        canvas.draw_polyline(PackedVector2Array([tip - radial * 13.0 - tangent * 8.0, tip, tip - radial * 13.0 + tangent * 8.0]),
            Color(INK, ignition), 7.0, true)
        canvas.draw_polyline(PackedVector2Array([tip - radial * 13.0 - tangent * 8.0, tip, tip - radial * 13.0 + tangent * 8.0]),
            Color(CORE, ignition), 2.8, true)


func draw_contacts(canvas: CanvasItem, now: float, reduced: bool) -> void:
    var age := now - _at
    if age < 0.0 or age >= CONTACT_LIFE:
        return
    var alpha := 1.0 - smoothstep(0.04, CONTACT_LIFE, age)
    var spread := 2.0 if reduced else 2.0 + 9.0 * age / CONTACT_LIFE
    for point in _contacts:
        var axis := (_origin.direction_to(point) + Vector2(0.01, 0.0)).normalized()
        var cross := axis.orthogonal()
        var strike := point + Vector2(0, -18)
        for side: float in [-1.0, 1.0]:
            var root := strike + cross * spread * side
            var tip := root + axis * 13.0 + cross * 8.0 * side
            canvas.draw_line(root, tip, Color(INK, alpha), 5.0, true)
            canvas.draw_line(root, tip, Color(CORE, alpha), 2.2, true)


func has_weaken_marker(enemy: Dictionary, now: float) -> bool:
    var applied = _weakened.get(enemy["id"])
    return applied != null and now >= float(enemy["born"]) and now < float(enemy.get("weaken_until", 0.0)) \
        and enemy.get("weaken_until") == applied[1] and enemy.get("weaken") == applied[0]


func draw_weakened(canvas: CanvasItem, enemies: Array[Dictionary], now: float) -> void:
    if now >= _latest_weaken_until:
        return
    for enemy in enemies:
        if not has_weaken_marker(enemy, now):
            continue
        var point: Vector2 = enemy["pos"] + Vector2(float(enemy["radius"]) * 0.78 + 8.0, -12.0)
        var chevrons := PackedVector2Array([
            point + Vector2(-5, -5), point, point + Vector2(5, -5),
            point + Vector2(-5, 1), point + Vector2(0, 6), point + Vector2(5, 1)])
        canvas.draw_multiline(PackedVector2Array([
            chevrons[0], chevrons[1], chevrons[1], chevrons[2],
            chevrons[3], chevrons[4], chevrons[4], chevrons[5]]), Color(INK, 0.94), 5.0, true)
        canvas.draw_polyline(chevrons.slice(0, 3), Color(STATUS, 0.90), 1.8, true)
        canvas.draw_polyline(chevrons.slice(3), Color(STATUS, 0.90), 1.8, true)
