extends RefCounted
## Proposed, code-drawn scenery for the six original Feedverse layouts.
## All drawing is cosmetic. maps.json remains the sole geometry source.

const INK := Color("#13233a")
const CREAM := Color("#f3e9db")
const ORANGE := Color("#ff6a00")
const VIOLET := Color("#9b00ff")
const GOLD := Color("#f8c45f")
const TEAL := Color("#6eaab0")
const FactoryPlate = preload("res://assets/art-candidates/feedverse/msg-factory-v2/arena-plate-proposed.png")
const PressHousing = preload("res://assets/art-candidates/feedverse/msg-factory-v2/press-housing-proposed.png")

static func draw_map(canvas: Node2D, data: Dictionary, floor: PackedVector2Array, world: Vector2) -> void:
    var kind := int(data.style)
    if kind == 0:
        # Illustrated MSG Factory V2. The plate has no cover objects; each
        # machine sprite is placed from the original collision data below.
        canvas.draw_texture_rect(FactoryPlate,
            Rect2(Vector2(-43, -18), Vector2(1535, 1173)), false)
        for cover in data.covers:
            var center := Vector2(cover[0], cover[1])
            var radius := float(cover[2])
            var half := radius * 1.30
            canvas.draw_texture_rect(PressHousing,
                Rect2(center - Vector2(half, half), Vector2(half * 2.0, half * 2.0)),
                false)
        return
    var accent := Color(data.accent)
    _backdrop(canvas, kind, world, accent)
    _floor(canvas, kind, floor, world, accent)
    _architecture(canvas, kind, accent)
    for cover in data.covers:
        _cover(canvas, kind, Vector2(cover[0], cover[1]), float(cover[2]), accent)
    _edge(canvas, floor, accent)


static func _backdrop(c: Node2D, kind: int, world: Vector2, accent: Color) -> void:
    var dark: Color = [Color("#2d3035"), Color("#384047"), Color("#263a49"),
        Color("#293843"), Color("#211d32"), Color("#211d31")][kind]
    c.draw_rect(Rect2(Vector2.ZERO, world), dark)
    # Sparse city silhouettes carry region identity without adding hitboxes.
    for i in range(13):
        var x := float(i * 118 - 22)
        var height := float(74 + ((i * 41 + kind * 29) % 115))
        var top := 175.0 - height
        c.draw_rect(Rect2(x, top, 102, height), dark.lightened(0.08))
        c.draw_rect(Rect2(x, top, 102, 7), INK)
        for row in range(2):
            for col in range(3):
                c.draw_rect(Rect2(x + 16 + col * 27, top + 20 + row * 27, 11, 7),
                    Color(accent, 0.24))
    c.draw_rect(Rect2(0, 0, world.x, 34), INK)
    c.draw_rect(Rect2(0, world.y - 42, world.x, 42), INK)
    for i in range(19):
        var x := float(i * 80)
        c.draw_line(Vector2(x, 0), Vector2(x - 30, 34), Color(accent, 0.25), 3.0)
    # A quiet outer network motif shared by the six environments.
    for y in [52.0, 1040.0]:
        c.draw_line(Vector2(0, y), Vector2(world.x, y), Color(accent, 0.26), 3.0)
        for x in range(30, 1448, 120):
            c.draw_circle(Vector2(x, y), 5.0, accent.darkened(0.25))


static func _floor(c: Node2D, kind: int, floor: PackedVector2Array, world: Vector2, accent: Color) -> void:
    var ground: Color = [
        Color("#756b60"), Color("#686869"), Color("#737d82"),
        Color("#676f71"), Color("#4b4659"), Color("#645b64")
    ][kind]
    c.draw_colored_polygon(floor, INK)
    c.draw_colored_polygon(floor, ground)
    # All small markings are placed well inside the original polygon.
    for y in range(190, 920, 84):
        for x in range(165, 1350, 94):
            var p := Vector2(x, y)
            if not _clear_floor(p, floor, 30.0):
                continue
            var variant := (x / 94 + y / 84 + kind) % 9
            if variant == 0:
                c.draw_rect(Rect2(p - Vector2(21, 1), Vector2(42, 2)), Color(INK, 0.16))
            elif variant == 2:
                c.draw_circle(p, 3.0, Color(INK, 0.16))
            elif variant == 4:
                c.draw_line(p + Vector2(-8, 0), p + Vector2(9, -4), Color(CREAM, 0.13), 2.0)
    _floor_details(c, kind, floor, accent)
    # An uninterrupted, low-contrast combat court around the original spawn.
    var spawn := Vector2(720, 540)
    c.draw_arc(spawn, 178.0, 0.0, TAU, 80, Color(accent, 0.13), 2.0)
    c.draw_arc(spawn, 204.0, 0.0, TAU, 80, Color(INK, 0.10), 2.0)


static func _floor_details(c: Node2D, kind: int, floor: PackedVector2Array, accent: Color) -> void:
    match kind:
        0:
            for y in range(185, 915, 110):
                for x in range(205, 1310, 150):
                    var p := Vector2(x, y)
                    if _clear_floor(p, floor, 62.0):
                        c.draw_rect(Rect2(p - Vector2(55, 38), Vector2(110, 76)),
                            Color(INK, 0.095), false, 2.0)
                        for bolt in [-42.0, 42.0]:
                            c.draw_circle(p + Vector2(bolt, -25), 2.0, Color(CREAM, 0.25))
            for x in [330.0, 1090.0]:
                c.draw_line(Vector2(x, 280), Vector2(x, 785), Color(INK, 0.20), 24.0)
                c.draw_line(Vector2(x, 280), Vector2(x, 785), Color(accent, 0.25), 3.0)
        1:
            for y in range(210, 900, 112):
                for x in range(200, 1280, 154):
                    var p := Vector2(x + (y % 2) * 32, y)
                    if _clear_floor(p, floor, 76.0):
                        c.draw_line(p + Vector2(-64, -45), p + Vector2(64, -45),
                            Color(INK, 0.25), 2.0)
                        c.draw_line(p + Vector2(-64, -45), p + Vector2(-64, 45),
                            Color(INK, 0.20), 2.0)
                        if (x + y) % 3 == 0:
                            c.draw_line(p + Vector2(20, -44), p + Vector2(10, -10),
                                Color(INK, 0.28), 2.0)
                            c.draw_line(p + Vector2(10, -10), p + Vector2(28, 9),
                                Color(INK, 0.28), 2.0)
        2:
            for y in range(190, 880, 100):
                for x in range(220, 1280, 100):
                    var p := Vector2(x, y)
                    if _clear_floor(p, floor, 65.0):
                        c.draw_rect(Rect2(p - Vector2(43, 43), Vector2(86, 86)),
                            Color(INK, 0.11), false, 2.0)
                        if (x / 100 + y / 100) % 4 == 0:
                            c.draw_rect(Rect2(p - Vector2(32, 32), Vector2(64, 6)),
                                Color(accent, 0.19))
        3:
            for y in [245.0, 875.0]:
                c.draw_line(Vector2(280, y), Vector2(1160, y), Color(INK, 0.32), 14.0)
                c.draw_line(Vector2(280, y), Vector2(1160, y), Color(CREAM, 0.37), 4.0)
                for x in range(310, 1140, 92):
                    c.draw_rect(Rect2(x, y - 6, 50, 11), Color(accent, 0.36))
            for x in range(275, 1180, 120):
                var p := Vector2(x, 565)
                if _clear_floor(p, floor, 65.0):
                    c.draw_line(p + Vector2(-16, -28), p + Vector2(16, 0),
                        Color(INK, 0.17), 3.0)
                    c.draw_line(p + Vector2(16, 0), p + Vector2(-16, 28),
                        Color(INK, 0.17), 3.0)
        4:
            for x in range(235, 1245, 126):
                for y in range(205, 890, 118):
                    var p := Vector2(x, y)
                    if _clear_floor(p, floor, 64.0):
                        c.draw_line(p + Vector2(-34, 0), p + Vector2(34, 0),
                            Color(accent, 0.14), 3.0)
                        c.draw_circle(p + Vector2(-34, 0), 4.0, Color(accent, 0.18))
                        c.draw_circle(p + Vector2(34, 0), 4.0, Color(accent, 0.18))
                        c.draw_rect(Rect2(p - Vector2(17, 24), Vector2(34, 48)),
                            Color(INK, 0.12), false, 2.0)
        5:
            for radius in [235.0, 290.0]:
                c.draw_arc(Vector2(720, 540), radius, 0.0, TAU, 96,
                    Color(INK, 0.16), 3.0)
            for i in range(24):
                var direction := Vector2.from_angle(TAU * float(i) / 24.0)
                var start := Vector2(720, 540) + direction * 240.0
                var finish := Vector2(720, 540) + direction * 285.0
                c.draw_line(start, finish, Color(accent, 0.20), 3.0)


static func _clear_floor(p: Vector2, floor: PackedVector2Array, margin: float) -> bool:
    if not Geometry2D.is_point_in_polygon(p, floor):
        return false
    for i in range(floor.size()):
        if p.distance_to(Geometry2D.get_closest_point_to_segment(
                p, floor[i], floor[(i + 1) % floor.size()])) < margin:
            return false
    return true


static func _edge(c: Node2D, floor: PackedVector2Array, accent: Color) -> void:
    for i in range(floor.size()):
        var a: Vector2 = floor[i]
        var b: Vector2 = floor[(i + 1) % floor.size()]
        c.draw_line(a + Vector2(6, 9), b + Vector2(6, 9), Color(INK, 0.65), 19.0)
        c.draw_line(a, b, INK, 14.0)
        c.draw_line(a, b, Color(accent, 0.74), 3.0)
        var length := a.distance_to(b)
        for j in range(1, int(length / 72.0)):
            var p := a.lerp(b, float(j) * 72.0 / length)
            c.draw_line(p, p + Vector2(0, 7), CREAM.darkened(0.2), 2.0)


static func _architecture(c: Node2D, kind: int, accent: Color) -> void:
    match kind:
        0: _factory(c, accent)
        1: _valley(c, accent)
        2: _moderation(c, accent)
        3: _rails(c, accent)
        4: _depths(c, accent)
        5: _heart(c, accent)


static func _panel(c: Node2D, rect: Rect2, body: Color, accent: Color) -> void:
    c.draw_rect(Rect2(rect.position + Vector2(6, 9), rect.size), Color(INK, 0.35))
    c.draw_rect(rect, INK)
    c.draw_rect(Rect2(rect.position + Vector2(5, 5), rect.size - Vector2(10, 10)), body)
    c.draw_line(rect.position + Vector2(7, 7), rect.position + Vector2(rect.size.x - 7, 7),
        Color(accent, 0.65), 3.0)
    for x in [rect.position.x + 12.0, rect.end.x - 12.0]:
        c.draw_circle(Vector2(x, rect.end.y - 12), 2.5, CREAM.darkened(0.4))


static func _factory(c: Node2D, accent: Color) -> void:
    # Presses, print rollers and dispatch chutes are scenery outside the court.
    for side in [0, 1]:
        var x := 35.0 if side == 0 else 1278.0
        _panel(c, Rect2(x, 215, 130, 625), Color("#45474b"), accent)
        for y in range(255, 800, 88):
            c.draw_rect(Rect2(x + 18, y, 94, 43), INK)
            c.draw_rect(Rect2(x + 27, y + 9, 76, 24), CREAM.darkened(0.08))
            c.draw_line(Vector2(x + 35, y + 16), Vector2(x + 95, y + 16), accent, 3.0)
        c.draw_line(Vector2(x + 65, 110), Vector2(x + 65, 215), INK, 25.0)
    for x in [270.0, 1135.0]:
        c.draw_line(Vector2(x, 155), Vector2(x, 850), Color(INK, 0.18), 23.0)
        for y in range(265, 815, 105):
            c.draw_rect(Rect2(x - 18, y, 36, 25), Color(accent, 0.26))
    _panel(c, Rect2(525, 38, 400, 78), Color("#4e4b49"), accent)
    for i in range(5):
        c.draw_rect(Rect2(556 + i * 72, 71, 45, 15), CREAM.darkened(0.13))


static func _valley(c: Node2D, accent: Color) -> void:
    for start in [Vector2(0, 180), Vector2(965, 5)]:
        c.draw_line(start, start + Vector2(480, 195), Color(INK, 0.47), 66.0)
        c.draw_line(start, start + Vector2(480, 195), Color("#aba49b"), 45.0)
        for i in range(7):
            var p: Vector2 = start + Vector2(i * 70, i * 28)
            c.draw_line(p, p + Vector2(0, 30), INK, 5.0)
    for x in [34.0, 1220.0]:
        _panel(c, Rect2(x, 270, 185, 85), Color("#5e6466"), accent)
        c.draw_line(Vector2(x + 17, 336), Vector2(x + 160, 289), CREAM, 5.0)
    for i in range(10):
        var x := float(85 + i * 130)
        c.draw_line(Vector2(x, 945), Vector2(x + 40, 984), Color(INK, 0.35), 3.0)


static func _moderation(c: Node2D, accent: Color) -> void:
    for x in [35.0, 1248.0]:
        _panel(c, Rect2(x, 178, 165, 705), Color("#526470"), accent)
        for y in range(215, 850, 103):
            c.draw_rect(Rect2(x + 24, y, 114, 43), INK)
            c.draw_rect(Rect2(x + 32, y + 9, 98, 24), Color("#9db1b9"))
            c.draw_line(Vector2(x + 40, y + 21), Vector2(x + 120, y + 21), accent, 3.0)
    for x in [310.0, 1135.0]:
        c.draw_line(Vector2(x, 175), Vector2(x, 885), Color(INK, 0.25), 6.0)
        for y in range(265, 855, 148):
            c.draw_rect(Rect2(x - 13, y, 26, 39), Color(accent, 0.24))
    _panel(c, Rect2(485, 35, 480, 78), Color("#435564"), accent)
    for i in range(7):
        c.draw_rect(Rect2(522 + i * 58, 66, 35, 15), CREAM.darkened(0.08))


static func _rails(c: Node2D, accent: Color) -> void:
    for y in [90.0, 1025.0]:
        c.draw_line(Vector2(0, y), Vector2(1448, y), INK, 31.0)
        for shift in [-10.0, 10.0]:
            c.draw_line(Vector2(0, y + shift), Vector2(1448, y + shift),
                Color(accent, 0.65), 4.0)
        for x in range(0, 1448, 60):
            c.draw_line(Vector2(x, y - 18), Vector2(x + 23, y + 18),
                Color("#a79b8b"), 6.0)
    for x in [90.0, 1215.0]:
        _panel(c, Rect2(x, 260, 140, 520), Color("#4b565d"), accent)
        for y in range(290, 750, 90):
            c.draw_rect(Rect2(x + 16, y, 108, 30), INK)
            c.draw_rect(Rect2(x + 23, y + 7, 94, 16), Color("#a2b7b6"))
    for y in [310.0, 830.0]:
        c.draw_line(Vector2(245, y), Vector2(1203, y), Color(accent, 0.17), 9.0)


static func _depths(c: Node2D, accent: Color) -> void:
    for x in [35.0, 1285.0]:
        _panel(c, Rect2(x, 145, 130, 770), Color("#35344b"), accent)
        for y in range(170, 900, 64):
            c.draw_rect(Rect2(x + 16, y, 98, 49), INK)
            c.draw_rect(Rect2(x + 23, y + 7, 84, 34), Color("#56536b"))
            for i in range(4):
                c.draw_circle(Vector2(x + 34 + i * 20, y + 25), 3.0, accent)
    for i in range(6):
        var x := float(295 + i * 165)
        c.draw_line(Vector2(x, 0), Vector2(x + 60, 180), Color(INK, 0.70), 13.0)
        c.draw_line(Vector2(x + 24, 0), Vector2(x + 80, 175), Color(accent, 0.45), 3.0)
    c.draw_arc(Vector2(720, 540), 310, 0.0, TAU, 96, Color(accent, 0.19), 8.0)


static func _heart(c: Node2D, accent: Color) -> void:
    # A centered distant broadcast citadel, separated from playable space.
    var center := 724.0
    c.draw_colored_polygon(PackedVector2Array([
        Vector2(center - 195, 164), Vector2(center - 115, 74),
        Vector2(center + 115, 74), Vector2(center + 195, 164)]), INK)
    _panel(c, Rect2(center - 120, 8, 240, 105), Color("#4b3d50"), accent)
    c.draw_line(Vector2(center, 7), Vector2(center, -52), INK, 15.0)
    c.draw_circle(Vector2(center, 7), 17.0, ORANGE)
    for x in [80.0, 1250.0]:
        _panel(c, Rect2(x, 305, 115, 485), Color("#4a3e52"), accent)
        for y in range(345, 765, 80):
            c.draw_rect(Rect2(x + 25, y, 65, 36), INK)
            c.draw_rect(Rect2(x + 33, y + 9, 49, 18), Color(VIOLET, 0.62))
    for radius in [345.0, 395.0]:
        c.draw_arc(Vector2(720, 540), radius, 0.0, TAU, 96,
            Color(accent, 0.22), 4.0)


static func _cover(c: Node2D, kind: int, p: Vector2, radius: float, accent: Color) -> void:
    # Every visible cover fits within its original collision circle.
    c.draw_circle(p + Vector2(4, 7), radius, Color(INK, 0.43))
    c.draw_circle(p, radius - 2.0, INK)
    var body: Color = [
        Color("#51565b"), Color("#706b66"), Color("#526570"),
        Color("#596269"), Color("#45445d"), Color("#574a5b")
    ][kind]
    c.draw_circle(p, radius - 8.0, body)
    c.draw_arc(p, radius - 8.0, PI * 1.05, TAU * 0.97, 28, CREAM.darkened(0.15), 3.0)
    match kind:
        0:
            c.draw_rect(Rect2(p - Vector2(radius * 0.58, 17), Vector2(radius * 1.16, 33)), INK)
            c.draw_rect(Rect2(p - Vector2(radius * 0.50, 11), Vector2(radius, 20)), CREAM)
            for i in range(3):
                c.draw_line(p + Vector2(-radius * 0.38, -5 + i * 6),
                    p + Vector2(radius * 0.38, -5 + i * 6), accent, 2.0)
        1:
            for i in range(3):
                var shift := float(i - 1) * 13.0
                c.draw_line(p + Vector2(-radius * 0.5, shift - 6),
                    p + Vector2(radius * 0.47, shift + 7), INK, 6.0)
            c.draw_circle(p + Vector2(9, -7), 6.0, accent)
        2:
            c.draw_rect(Rect2(p - Vector2(radius * 0.46, radius * 0.35),
                Vector2(radius * 0.92, radius * 0.70)), INK)
            c.draw_rect(Rect2(p - Vector2(radius * 0.36, radius * 0.25),
                Vector2(radius * 0.72, radius * 0.50)), Color("#8da3ad"))
            c.draw_line(p + Vector2(-18, 0), p + Vector2(18, 0), accent, 4.0)
        3:
            for shift in [-15.0, 0.0, 15.0]:
                c.draw_line(p + Vector2(-radius * 0.5, shift),
                    p + Vector2(radius * 0.5, shift), accent, 5.0)
            c.draw_rect(Rect2(p - Vector2(18, 8), Vector2(36, 15)), INK)
        4:
            for i in range(3):
                c.draw_rect(Rect2(p + Vector2(-radius * 0.42, -26 + i * 16),
                    Vector2(radius * 0.84, 12)), INK)
                c.draw_circle(p + Vector2(radius * 0.27, -20 + i * 16), 3.0, accent)
        5:
            c.draw_arc(p, radius * 0.55, 0.0, TAU, 48, accent, 8.0)
            c.draw_circle(p, radius * 0.25, INK)
            c.draw_circle(p, radius * 0.15, CREAM)
