extends "res://scripts/vfx/six_to_seven.gd"
## PROPOSED. Active-time presentation values only. The burst payload owns the radius and hits.
const RELEASE := 0.13
const FADE := 0.32
const CONTACT := 0.19
const VOID := Color("#170e29")
const WINE := Color("#73204d")
const NEON := Color("#ff66c8")
const PEACH := Color("#ffac83")
const WHITE_HOT := Color("#fff6dc")
const STATIC_EDGE := Color("#f8b0de")
const SEGMENTS := 32
const CONTACT_CAPACITY := 128
const CRESTS := [0.97, 1.0, 0.85, 0.92, 0.96, 0.95, 0.86, 0.93,
    0.98, 0.96, 0.94, 0.85, 0.93, 0.98, 0.88, 0.96,
    0.99, 0.96, 0.90, 0.95, 1.0, 0.93, 0.90, 0.87,
    0.95, 0.98, 0.96, 0.86, 0.95, 1.0, 0.97, 0.89]
const SPARKS := [1, 4, 9, 15, 19, 25, 28]

var front := PackedVector2Array()
var extent := PackedVector2Array()
var core := PackedVector2Array()
var pressure_fans: Array[PackedVector2Array] = []
var streak := PackedVector2Array([Vector2(-0.26, 0), Vector2(0.12, -0.036),
    Vector2(0.22, 0), Vector2(0.05, 0.018)])
var contact := PackedVector2Array([Vector2(-23, -11), Vector2(-12, -6),
    Vector2(-8, -10), Vector2(-12, 4), Vector2(-23, 10), Vector2(-17, 0)])

func _init() -> void:
    super()
    for slot in slots:
        slot.positions.resize(CONTACT_CAPACITY)
    for index in SEGMENTS:
        var direction := Vector2.from_angle(TAU * float(index) / SEGMENTS)
        var tooth := float(CRESTS[index])
        front.append(direction * tooth)
        extent.append(direction)
    front.append(front[0])
    extent.append(extent[0])
    # Each fan follows a different part of the front and tapers into the wake.
    for start: int in [2, 13, 22]:
        var fan := PackedVector2Array()
        for index in range(start, start + 7):
            fan.append(front[index])
        fan.append(front[start + 5] * 0.88)
        fan.append(front[start + 4] * 0.74)
        fan.append(front[start + 2] * 0.85)
        fan.append(front[start + 1] * 0.91)
        pressure_fans.append(fan)
    var points := [0.94, 0.37, 0.59, 0.29, 1.0, 0.44, 0.85, 0.28,
        0.68, 0.35, 0.97, 0.32, 0.71, 0.36, 0.61, 0.40]
    for index in points.size():
        var angle := TAU * float(index) / points.size() + 0.15
        core.append(Vector2.from_angle(angle) * float(points[index]))

func burst(center: Vector2, radius: float, at: float, contacts: Array[Dictionary]) -> void:
    var slot := slots[cursor]
    cursor = (cursor + 1) % MAX_BURSTS
    slot.at = at
    slot.center = center
    slot.radius = radius
    slot.count = 0
    for hit in contacts:
        if float(hit.hp_lost) <= 0.0:
            continue
        if slot.count == CONTACT_CAPACITY:
            break
        slot.positions[slot.count] = hit.position
        slot.count += 1

func draw_ground(canvas: Node2D, now: float, reduced: bool) -> void:
    for slot in slots:
        var age := now - slot.at
        if age < 0.0 or age >= FADE:
            continue
        var alpha := 1.0 - smoothstep(RELEASE, FADE, age)
        if reduced:
            _draw_extent(canvas, slot, alpha)
            continue
        var sweep := clampf(age / RELEASE, 0.0, 1.0)
        var travel := 1.0 - (1.0 - sweep) * (1.0 - sweep) * (1.0 - sweep)
        var reach := lerpf(0.24, 1.0, travel)
        var pressure := alpha * (1.0 - smoothstep(RELEASE, 0.26, age))
        var width := lerpf(0.145, 0.044, travel)
        canvas.draw_set_transform(slot.center, 0, Vector2.ONE * slot.radius * reach)
        var wake := pressure * (1.0 - smoothstep(0.055, RELEASE, age))
        if wake > 0.0:
            for fan in pressure_fans:
                canvas.draw_colored_polygon(fan, Color(WINE, wake * 0.76))
        canvas.draw_polyline(front, Color(VOID, pressure * 0.96), width, true)
        canvas.draw_polyline(front, Color(NEON, pressure * 0.91), width * 0.53, true)
        canvas.draw_polyline(front, Color(WHITE_HOT, pressure * 0.95), width * 0.16, true)
        var tail := lerpf(0.68, 0.94, travel)
        canvas.draw_set_transform(slot.center, 0, Vector2.ONE * slot.radius * reach * tail)
        canvas.draw_polyline(front, Color(WINE, pressure * 0.62), width * 0.40, true)
        var spark_alpha := 1.0 - smoothstep(0.085, 0.22, age)
        if spark_alpha > 0.0:
            for index: int in SPARKS:
                var axis := extent[index]
                var position := slot.center + axis * slot.radius * lerpf(0.30, 0.77, travel)
                canvas.draw_set_transform(position, TAU * float(index) / SEGMENTS,
                    Vector2.ONE * slot.radius * lerpf(1.0, 0.56, sweep))
                canvas.draw_colored_polygon(streak, Color(PEACH if index % 2 == 0 else NEON, spark_alpha))
        canvas.draw_set_transform(Vector2.ZERO)
        var rim := smoothstep(0.068, RELEASE, age) * alpha * 0.62
        if rim > 0.0:
            _draw_extent(canvas, slot, rim)

func _draw_extent(canvas: Node2D, slot: Burst, alpha: float) -> void:
    canvas.draw_set_transform(slot.center, 0, Vector2.ONE * slot.radius)
    canvas.draw_polyline(extent, Color(VOID, alpha * 0.93), 0.056, true)
    canvas.draw_polyline(extent, Color(STATIC_EDGE, alpha * 0.88), 0.024, true)
    canvas.draw_set_transform(Vector2.ZERO)

func draw_contacts(canvas: Node2D, now: float, reduced: bool) -> void:
    for slot in slots:
        var age := now - slot.at
        if age < 0.0 or age >= FADE:
            continue
        if reduced:
            var alpha := 1.0 - smoothstep(RELEASE, FADE, age)
            canvas.draw_circle(slot.center, 7.0, Color(VOID, alpha), true, -1.0, true)
            canvas.draw_circle(slot.center, 4.0, Color(STATIC_EDGE, alpha), true, -1.0, true)
        elif age < 0.11:
            var heat := 1.0 - smoothstep(0.018, 0.11, age)
            var size := lerpf(31.0, 19.0, age / 0.11)
            canvas.draw_set_transform(slot.center, 0, Vector2.ONE * size)
            canvas.draw_colored_polygon(core, Color(VOID, heat))
            canvas.draw_set_transform(slot.center, 0, Vector2.ONE * size * 0.80)
            canvas.draw_colored_polygon(core, Color(NEON, heat))
            canvas.draw_set_transform(slot.center, 0, Vector2.ONE * size * 0.53)
            canvas.draw_colored_polygon(core, Color(WHITE_HOT, heat))
        if age < CONTACT:
            var alpha := 1.0 - smoothstep(0.07, CONTACT, age)
            for index in slot.count:
                var point := slot.positions[index]
                _draw_contact(canvas, point, 0, alpha, reduced)
                _draw_contact(canvas, point, PI, alpha, reduced)
        canvas.draw_set_transform(Vector2.ZERO)

func _draw_contact(canvas: Node2D, point: Vector2, angle: float, alpha: float, reduced: bool) -> void:
    canvas.draw_set_transform(point, angle)
    canvas.draw_colored_polygon(contact, Color(VOID, alpha))
    canvas.draw_set_transform(point + Vector2.from_angle(angle) * -2.8, angle, Vector2.ONE * 0.84)
    canvas.draw_colored_polygon(contact, Color(STATIC_EDGE if reduced else WHITE_HOT, alpha))
