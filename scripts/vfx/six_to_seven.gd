extends RefCounted
## Proposed impact renderer. Inputs are positions, confirmed contacts, and active time.
const LIFE := 0.48
const HIT_LIFE := 0.25
const MAX_BURSTS := 3
const MAX_MARKS := 16
const INK := Color("#211a32")
const EDGE := Color("#ff9a54")
const HOT := Color("#fff2cd")
const CHROME := Color("#7546ad")
const LOBES := 9
const SIDES := [-1.0, 1.0]

class Burst:
    var at := -INF
    var center := Vector2.ZERO
    var radius := 0.0
    var count := 0
    var positions := PackedVector2Array()

    func _init() -> void:
        positions.resize(MAX_MARKS)

var slots: Array[Burst] = []
var cursor := 0
var wedges: Array[PackedVector2Array] = []
var rays := PackedVector2Array()

func _init() -> void:
    for index in MAX_BURSTS:
        slots.append(Burst.new())
    for index in LOBES:
        var angle := TAU * float(index) / LOBES
        rays.append(Vector2.from_angle(angle))
        wedges.append(PackedVector2Array([
            Vector2.from_angle(angle - 0.30),
            Vector2.from_angle(angle + 0.08),
            Vector2.from_angle(angle + 0.27) * 0.80,
            Vector2.from_angle(angle - 0.08) * 0.91,
            Vector2.from_angle(angle - 0.34) * 0.85,
        ]))

func clear() -> void:
    cursor = 0
    for slot in slots:
        slot.at = -INF

func burst(center: Vector2, radius: float, at: float, contacts: Array[Dictionary]) -> void:
    var slot := slots[cursor]
    cursor = (cursor + 1) % MAX_BURSTS
    slot.at = at
    slot.center = center
    slot.radius = radius
    slot.count = mini(MAX_MARKS, contacts.size())
    for index in slot.count:
        slot.positions[index] = contacts[index].position

func draw_armed(canvas: Node2D, feet: Vector2) -> void:
    for side: float in SIDES:
        var base := feet + Vector2(29.0 * side, 9.0)
        var bend := base + Vector2(0, 9)
        var tip := bend - Vector2(14.0 * side, 0.0)
        canvas.draw_line(base, bend, INK, 6.0, true)
        canvas.draw_line(bend, tip, INK, 6.0, true)
        canvas.draw_line(base, bend, EDGE, 2.5, true)
        canvas.draw_line(bend, tip, HOT, 2.5, true)

func draw_ground(canvas: Node2D, now: float, reduced: bool) -> void:
    for slot in slots:
        var age := now - slot.at
        if age < 0.0 or age >= LIFE:
            continue
        var phase := age / LIFE
        var opacity := 1.0 - smoothstep(0.14, 1.0, phase)
        # The segmented perimeter always marks the actual radius.
        for index in LOBES:
            var angle := rays[index].angle()
            canvas.draw_arc(slot.center, slot.radius, angle - 0.23, angle + 0.23, 5, Color(INK, opacity * 0.8), 5.0, true)
            canvas.draw_arc(slot.center, slot.radius, angle - 0.23, angle + 0.23, 5, Color(EDGE, opacity * 0.80), 2.0, true)
        if reduced:
            continue
        var expansion := lerpf(0.32, 1.0, 1.0 - pow(1.0 - phase, 4.0)) * slot.radius
        canvas.draw_set_transform(slot.center, phase * 0.15, Vector2.ONE * expansion)
        for index in LOBES:
            canvas.draw_colored_polygon(wedges[index], Color(CHROME.lerp(INK, phase), opacity * 0.93))
            canvas.draw_line(wedges[index][0], wedges[index][1], Color(HOT, opacity), 0.032, true)
            canvas.draw_line(rays[index] * 0.39, rays[index] * 0.69, Color(CHROME, opacity), 0.028, true)
        canvas.draw_set_transform(Vector2.ZERO)

func draw_contacts(canvas: Node2D, now: float, reduced: bool) -> void:
    for slot in slots:
        var age := now - slot.at
        if age < 0.0 or age >= HIT_LIFE:
            continue
        var visibility := 1.0 - smoothstep(0.09, HIT_LIFE, age)
        # A compact source flash is separate from the contact marks.
        var onset := 1.0 - smoothstep(0.025, 0.15, age)
        if onset > 0.0 and not reduced:
            for ray in rays:
                canvas.draw_line(slot.center + ray * 5.0, slot.center + ray * 31.0, Color(CHROME, onset), 7.0, true)
                canvas.draw_line(slot.center + ray * 5.0, slot.center + ray * 33.0, Color(HOT, onset), 3.0, true)
        for index in slot.count:
            var point := slot.positions[index]
            var spread := 13.0 if reduced else 13.0 + age * 28.0
            for side: float in SIDES:
                var corner := point + Vector2(side * spread, 1)
                var shoulder := corner + Vector2(side * 5, -8)
                var heel := corner + Vector2(side * 5, 8)
                canvas.draw_line(shoulder, corner, Color(INK, visibility), 5.5, true)
                canvas.draw_line(corner, heel, Color(INK, visibility), 5.5, true)
                canvas.draw_line(shoulder, corner, Color(HOT, visibility), 2.5, true)
                canvas.draw_line(corner, heel, Color(EDGE, visibility), 2.5, true)
