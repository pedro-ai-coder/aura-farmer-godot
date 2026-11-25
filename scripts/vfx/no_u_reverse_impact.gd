extends "res://scripts/vfx/no_u_counter_pulse.gd"
## EXPERIMENTAL V2. Presentation uses resolved snapshots; no RNG or combat writes.
const MAGENTA := Color("#ff4bba")
const CYAN := Color("#57f4ee")
const HOT := Color("#fff4fb")
const DARK := Color("#190e29")
const LIFE := 0.58
var _incoming := Vector2.ZERO

func incoming(source: Vector2, center: Vector2, _hazard: bool) -> void:
    _incoming = center.direction_to(source)

func draw_ground(canvas: CanvasItem, now: float, reduced: bool) -> void:
    var age := now - _at
    if age < 0.0 or age >= LIFE:
        return
    var alpha := 1.0 - smoothstep(0.28, LIFE, age)
    var travel := 1.0 if reduced else 1.0 - pow(1.0 - clampf((age - 0.035) / 0.23, 0.0, 1.0), 2.0)
    var front := lerpf(31.0, _radius, travel)
    var marks := PackedVector2Array()
    for sector in 12:
        var angle := TAU * sector / 12.0
        var axis := Vector2.from_angle(angle)
        var cross := axis.orthogonal()
        # The fixed fine edge is the exact gameplay extent, never an oversized glow.
        canvas.draw_arc(_origin, _radius, angle + 0.035, angle + 0.42, 8, Color(DARK, alpha), 5.0, true)
        canvas.draw_arc(_origin, _radius, angle + 0.035, angle + 0.42, 8, Color(CYAN, alpha * 0.85), 1.4, true)
        # Paired reversal chevrons; open center preserves player and enemy silhouettes.
        for trailing in 2:
            var point := _origin + axis * (front - trailing * 14.0)
            marks.append(point - axis * 13.0 + cross * 9.0)
            marks.append(point)
            marks.append(point)
            marks.append(point - axis * 13.0 - cross * 9.0)
    canvas.draw_multiline(marks, Color(DARK, alpha), 7.0, true)
    canvas.draw_multiline(marks, Color(MAGENTA, alpha), 3.5, true)
    canvas.draw_multiline(marks, Color(HOT, alpha * 0.8), 1.1, true)
    if not reduced and age < 0.24:
        canvas.draw_arc(_origin, maxf(22.0, front - 30.0), 0, TAU, 48, Color(MAGENTA, 0.18 * alpha), 3.0, true)

func draw_contacts(canvas: CanvasItem, now: float, reduced: bool) -> void:
    var age := now - _at
    if age < 0.0 or age > 0.32:
        return
    var alpha := 1.0 - smoothstep(0.08, 0.32, age)
    var marks := PackedVector2Array()
    for point in _contacts:
        var at := point + Vector2(0, 10)
        var spread := 0.0 if reduced else age * 14.0
        for side: float in [-1.0, 1.0]:
            marks.append(at + Vector2(-11 - spread, -6 * side))
            marks.append(at + Vector2(11 + spread, 6 * side))
    if not marks.is_empty():
        canvas.draw_multiline(marks, Color(DARK, alpha), 8.0, true)
        canvas.draw_multiline(marks, Color(MAGENTA, alpha), 4.3, true)
        canvas.draw_multiline(marks, Color(HOT, alpha), 1.8, true)
    # Compact source-facing inbound wedge. Unknown/environmental origins use a neutral diamond.
    if age < 0.18:
        var hit_alpha := 1.0 - smoothstep(0.06, 0.18, age)
        if _incoming == Vector2.ZERO:
            var diamond := PackedVector2Array([_origin + Vector2(0,-29), _origin + Vector2(7,-22),
                _origin + Vector2(0,-15), _origin + Vector2(-7,-22), _origin + Vector2(0,-29)])
            canvas.draw_polyline(diamond, Color(HOT, hit_alpha), 2.2, true)
        else:
            var impact := _origin + _incoming * 27.0
            var cross := _incoming.orthogonal() * 12.0
            var wedge := PackedVector2Array([impact + cross + _incoming * 8.0, impact,
                impact - cross + _incoming * 8.0])
            canvas.draw_polyline(wedge, Color(DARK, hit_alpha), 7.0, true)
            canvas.draw_polyline(wedge, Color(HOT, hit_alpha), 3.0, true)

func draw_weakened(canvas: CanvasItem, enemies: Array[Dictionary], now: float) -> void:
    if now > _latest_weaken_until + 0.25:
        return
    var marks := PackedVector2Array()
    var expires := PackedVector2Array()
    for enemy in enemies:
        var application = _weakened.get(enemy["id"])
        if application == null or now < float(enemy["born"]):
            continue
        var point: Vector2 = enemy["pos"] + Vector2(float(enemy["radius"]) + 8.0, -17.0)
        if not has_weaken_marker(enemy, now):
            if now >= float(application[1]) and now < float(application[1]) + 0.25:
                expires.append(point + Vector2(-4, 7))
                expires.append(point + Vector2(4, 7))
            continue
        # Broken attack shaft + down arrow. Separate from the bright damage X at the feet.
        var fade := clampf((float(application[1]) - now) / 0.25, 0.0, 1.0)
        canvas.draw_rect(Rect2(point + Vector2(-9, -6), Vector2(19, 24)), Color(DARK, 0.8 * fade))
        marks.append(point + Vector2(-4,-4)); marks.append(point + Vector2(-4,1))
        marks.append(point + Vector2(-8,0)); marks.append(point + Vector2(-1,0))
        marks.append(point + Vector2(-2,4)); marks.append(point + Vector2(1,7))
        marks.append(point + Vector2(-4,8)); marks.append(point + Vector2(2,14))
        marks.append(point + Vector2(2,14)); marks.append(point + Vector2(8,8))
        # Brief local interference on application; stationary opacity only under Reduced Motion too.
        if now - _at < 0.18:
            canvas.draw_line(point + Vector2(-9,3), point + Vector2(9,3), Color(CYAN, 0.65), 1.0)
    if not marks.is_empty():
        canvas.draw_multiline(marks, Color(DARK, 0.95), 4.5, true)
        canvas.draw_multiline(marks, Color(CYAN, 0.92), 1.8, true)
    if not expires.is_empty():
        canvas.draw_multiline(expires, Color(CYAN, 0.35), 1.0, true)
