extends "res://scripts/vfx/no_u_counter_pulse.gd"
## EXPERIMENTAL / PROPOSED. Read-only resolved presentation, active combat time, no RNG.
## Ink-cut reversal ribbons, opposed cyan/magenta edges and broken attack stamps.
const PINK := Color("#ff35a9")
const ICE := Color("#65fff0")
const WHITE := Color("#fff9ee")
const VOID := Color("#160d25")
const LIFE := 0.72
const CHARGE := 0.05
const RELEASE := 0.20
const TEETH := [1.0, 0.91, 0.97, 0.85, 0.98, 0.94, 0.88, 1.0, 0.93, 0.86, 0.98, 0.90]
var _incoming := Vector2.ZERO
var _lethal: Dictionary = {}

func incoming(source: Vector2, center: Vector2, _hazard: bool) -> void:
    _incoming = center.direction_to(source)

func classify(hits: Array[Dictionary], survivors: Array[Dictionary]) -> void:
    _lethal.clear()
    var live := {}
    for enemy in survivors:
        live[enemy.id] = true
    for index in mini(hits.size(), MAX_CONTACTS):
        var hit: Dictionary = hits[index]
        if not live.has(hit.id):
            _lethal[hit.id] = hit.pos

func clear() -> void:
    super.clear()
    _lethal.clear()
    _incoming = Vector2.ZERO

func _stroke(canvas: CanvasItem, points: PackedVector2Array, color: Color, alpha: float, width: float) -> void:
    canvas.draw_polyline(points, Color(VOID, alpha), width + 5.0, true)
    canvas.draw_polyline(points, Color(color, alpha), width, true)
    canvas.draw_polyline(points, Color(WHITE, alpha * 0.92), maxf(1.0, width * 0.22), true)

func draw_ground(canvas: CanvasItem, now: float, reduced: bool) -> void:
    var age := now - _at
    if age < 0.0 or age >= LIFE:
        return
    var fade := 1.0 - smoothstep(0.29, LIFE, age)
    # Exact 200 U extent is separate from the irregular silhouette; all glow stays inside it.
    for sector in 8:
        var angle := TAU * sector / 8.0
        canvas.draw_arc(_origin, _radius - 2.0, angle + 0.03, angle + 0.64, 12, Color(VOID, fade * 0.9), 4.0, true)
        canvas.draw_arc(_origin, _radius - 1.0, angle + 0.03, angle + 0.64, 12, Color(ICE, fade * 0.76), 2.0, true)
    if age < CHARGE and not reduced:
        var squeeze := smoothstep(0.0, CHARGE, age)
        for side in 4:
            var axis := Vector2.from_angle(side * PI * 0.5 + 0.3)
            var tangent := axis.orthogonal()
            var tip := _origin + axis * lerpf(49.0, 26.0, squeeze)
            _stroke(canvas, PackedVector2Array([tip + tangent * 11.0 + axis * 8.0, tip, tip - tangent * 11.0 + axis * 8.0]), ICE, 1.0, 3.0)
        return
    var phase := clampf((age - CHARGE) / (RELEASE - CHARGE), 0.0, 1.0)
    var ease := 1.0 - pow(1.0 - phase, 4.0)
    var front := _radius * (0.91 if reduced else lerpf(0.18, 0.94, ease))
    var pressure := 1.0 - smoothstep(0.16, 0.46, age)
    # Unequal scissor-cut ribbons, asymmetric lengths and dogleg crests: never a technical ring.
    for sector in 8:
        var ribbon := PackedVector2Array()
        var wake := PackedVector2Array()
        var heading := TAU * sector / 8.0 + 0.07
        for step in 7:
            var angle := heading + float(step) * (0.082 if sector % 3 else 0.092)
            var axis := Vector2.from_angle(angle)
            var tooth: float = TEETH[(sector * 3 + step) % TEETH.size()]
            ribbon.append(_origin + axis * front * tooth)
            wake.append(_origin + axis * maxf(20.0, front * tooth - (11.0 if reduced else 22.0 * pressure + 8.0)))
        var thickness := (6.0 if reduced else lerpf(15.0, 6.0, ease)) * (0.85 if sector % 3 == 0 else 1.0)
        var pigment := PINK if sector % 2 == 0 else ICE
        _stroke(canvas, wake, pigment, fade * 0.28, thickness * 0.58)
        _stroke(canvas, ribbon, pigment, fade, thickness)
    # Reversed double hooks make the center signature compact; no player-covering fill or flash.
    if age < 0.28:
        var accent := 1.0 - smoothstep(0.12, 0.28, age)
        for side: float in [-1.0, 1.0]:
            var at := _origin + Vector2(side * 36.0, -3.0)
            var hook := PackedVector2Array([at + Vector2(side * 13, 13), at + Vector2(side * 13, -8), at + Vector2(-side * 6, -8), at + Vector2(side * 2, -16)])
            _stroke(canvas, hook, PINK if side < 0 else ICE, accent, 4.0)
    if reduced:
        return
    # Delayed, decelerating ink chips stay within the actual radius, with independent decay.
    var tail := smoothstep(0.12, 0.21, age) * (1.0 - smoothstep(0.25, LIFE, age))
    var drift := 1.0 - pow(1.0 - clampf((age - 0.12) / 0.6, 0.0, 1.0), 3.0)
    for shard in 16:
        var axis := Vector2.from_angle(TAU * shard / 16.0 + 0.16)
        var tangent := axis.orthogonal()
        var tip := _origin + axis * _radius * lerpf(0.71, 0.96, drift)
        var size := lerpf(13.0, 3.0, drift) * (1.0 if shard % 3 else 1.5)
        var chip := PackedVector2Array([tip, tip - axis * size + tangent * 3.0, tip - axis * size * 0.6 - tangent * 2.0])
        canvas.draw_colored_polygon(chip, Color(ICE if shard % 2 else PINK, tail * 0.85))

func draw_contacts(canvas: CanvasItem, now: float, reduced: bool) -> void:
    var age := now - _at
    if age < 0.0 or age >= 0.48:
        return
    # Hit-confirm stays immediate, even though the visual recoil compresses for 50 ms.
    if age < 0.17:
        var axis := _incoming if _incoming != Vector2.ZERO else Vector2.UP
        var cross := axis.orthogonal()
        var tip := _origin + axis * 27.0
        var hit := PackedVector2Array([tip + axis * 12.0 + cross * 12.0, tip, tip + axis * 12.0 - cross * 12.0])
        _stroke(canvas, hit, WHITE, 1.0 - smoothstep(0.045, 0.17, age), 4.5)
    var alpha := 1.0 - smoothstep(0.11, 0.42, age)
    var spread := 0.0 if reduced else 9.0 * (1.0 - pow(1.0 - clampf(age / 0.35, 0.0, 1.0), 3.0))
    var damage_marks := PackedVector2Array()
    var lethal_marks := PackedVector2Array()
    var lethal_positions := _lethal.values()
    for point in _contacts:
        if point in lethal_positions:
            continue
        var axis := _origin.direction_to(point)
        if axis == Vector2.ZERO:
            axis = Vector2.RIGHT
        var cross := axis.orthogonal()
        var at := point + Vector2(0, -9)
        # One forceful tapered slash per HP recipient; lethal outcomes get their own finisher.
        var root := at + axis * spread
        damage_marks.append(root - axis * 16.0 - cross * 9.0)
        damage_marks.append(root + axis * 12.0 + cross * 5.0)
    # Lethal recipients retain a split four-point finisher after their actor has been removed.
    for point: Vector2 in _lethal.values():
        for quadrant in 4:
            var axis := Vector2.from_angle(PI * 0.25 + quadrant * PI * 0.5)
            var at := point + axis * (12.0 + spread)
            lethal_marks.append(at)
            lethal_marks.append(at + axis * 9.0 + axis.orthogonal() * 4.0)
    _batch(canvas, damage_marks, PINK, alpha, 3.5)
    _batch(canvas, lethal_marks, WHITE, alpha, 3.0)

func _batch(canvas: CanvasItem, points: PackedVector2Array, color: Color, alpha: float, width: float) -> void:
    if points.is_empty():
        return
    canvas.draw_multiline(points, Color(VOID, alpha), width + 4.0, false)
    canvas.draw_multiline(points, Color(color, alpha), width, false)
    canvas.draw_multiline(points, Color(WHITE, alpha * 0.85), maxf(1.0, width * 0.22), true)

func draw_weakened(canvas: CanvasItem, enemies: Array[Dictionary], now: float) -> void:
    if now > _latest_weaken_until + 0.28:
        return
    # At most two fade groups (normal / boss), independent of crowd size.
    var groups: Array[PackedVector2Array] = [PackedVector2Array(), PackedVector2Array()]
    var backs: Array[PackedVector2Array] = [PackedVector2Array(), PackedVector2Array()]
    var alphas := [1.0, 1.0]
    var expires := PackedVector2Array()
    var expire_alpha := 0.0
    for enemy in enemies:
        var applied = _weakened.get(enemy.id)
        if applied == null or now < float(enemy.born):
            continue
        if enemy.get("weaken_until") != applied[1] or enemy.get("weaken") != applied[0]:
            continue
        var remaining := float(applied[1]) - now
        var at: Vector2 = enemy.pos + Vector2(float(enemy.radius) + 10.0, -22.0)
        if remaining <= 0.0:
            if remaining > -0.28:
                expire_alpha = maxf(expire_alpha, 1.0 - smoothstep(0.0, 0.28, -remaining))
                expires.append(at + Vector2(-6,10)); expires.append(at + Vector2(-2,10))
                expires.append(at + Vector2(2,10)); expires.append(at + Vector2(6,10))
            continue
        var group := 1 if float(applied[0]) < 0.15 else 0
        alphas[group] = lerpf(0.35, 1.0, smoothstep(0.0, 0.25, remaining))
        backs[group].append(at + Vector2(0,-7)); backs[group].append(at + Vector2(0,23))
        # Broken sword, displaced tip, downward chevrons. Never a vulnerability/up marker.
        groups[group].append(at + Vector2(-3,-4)); groups[group].append(at + Vector2(-3,1))
        groups[group].append(at + Vector2(-7,1)); groups[group].append(at + Vector2(1,1))
        groups[group].append(at + Vector2(0,4)); groups[group].append(at + Vector2(3,7))
        for row in 2:
            var y := 8.0 + row * 6.0
            groups[group].append(at + Vector2(-6,y)); groups[group].append(at + Vector2(0,y+5))
            groups[group].append(at + Vector2(0,y+5)); groups[group].append(at + Vector2(6,y))
        var duration := 2.0 if group == 1 else 4.0
        groups[group].append(at + Vector2(-7,22))
        groups[group].append(at + Vector2(-7 + 14 * clampf(remaining / duration, 0, 1),22))
    for group in 2:
        if backs[group].is_empty():
            continue
        canvas.draw_multiline(backs[group], Color(VOID, 0.88 * alphas[group]), 21.0)
        canvas.draw_multiline(groups[group], Color(VOID, alphas[group]), 4.0, true)
        canvas.draw_multiline(groups[group], Color(ICE, alphas[group]), 1.8, true)
    if not expires.is_empty():
        canvas.draw_multiline(expires, Color(ICE, expire_alpha * 0.65), 2.0, true)
