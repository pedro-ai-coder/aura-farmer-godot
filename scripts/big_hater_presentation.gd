extends Node2D
## Screen-space encounter beats and world-space accents. Reads the active clock.
const Type = preload("res://scripts/clean_cut_typography.gd")
const CORAL := Color("ff665f")
const LIME := Color("d9fa64")
const INK := Color("17111f")
const PAPER := Color("fff9e9")
const ENTRANCE_LENGTH := 1.65
const RESULTS_AT := 1.48
const REDUCED_RESULTS_AT := 1.05
const FADE_OUT := 0.26

var game
var entrance_at := -INF
var defeated_at := Vector2.ZERO
var celebrating := false
var screen_active := false

func install(owner_game) -> void:
    game = owner_game
    var screen := CanvasLayer.new()
    screen.layer = game.layer.layer + 1
    game.add_child(screen)
    screen.add_child(self)

func reset() -> void:
    entrance_at = -INF
    celebrating = false
    game.layer.show()
    queue_redraw()

func depart(point: Vector2) -> void:
    defeated_at = point
    celebrating = true
    game.layer.hide()

func update() -> void:
    if celebrating and not game.layer.visible and game.finish_visual_age >= results_at():
        game.layer.show()
    var entrance_age: float = game.run_time - entrance_at
    var active: bool = (game.mode == "playing" and entrance_age < ENTRANCE_LENGTH) or (
        celebrating and game.mode == "won" and game.finish_visual_age < results_at() + FADE_OUT)
    if active or screen_active:
        queue_redraw()
    screen_active = active

func results_at() -> float:
    return REDUCED_RESULTS_AT if game.profile.settings.reducedMotion else RESULTS_AT

func draw_arrival(canvas: CanvasItem, point: Vector2, age: float, reduced: bool) -> void:
    if reduced or age < 0.0 or age >= ENTRANCE_LENGTH:
        return
    var opacity := 0.8 * (1.0 - smoothstep(0.42, ENTRANCE_LENGTH, age))
    var width := lerpf(92.0, 62.0, smoothstep(0.0, 0.62, age))
    for side in [-1.0, 1.0]:
        var base := point + Vector2(side * width, -7.0)
        var corner := base + Vector2(0.0, -84.0)
        canvas.draw_polyline(PackedVector2Array([base, corner, corner + Vector2(-side * 20.0, 0.0)]),
            Color(CORAL, opacity), 3.0, true)

func draw_departure(canvas: CanvasItem, hero_position: Vector2, reduced: bool) -> void:
    if not celebrating or reduced:
        return
    var age: float = game.finish_visual_age
    if age < 0.76:
        var travel := smoothstep(0.0, 0.76, age)
        for i in range(9):
            var direction := Vector2.from_angle(-PI + PI * float(i) / 8.0)
            var p := defeated_at + Vector2(0, -30) + direction * lerpf(25.0, 120.0, travel)
            var length := lerpf(24.0, 4.0, travel)
            canvas.draw_line(p, p + direction * length, Color(CORAL, 0.92 * (1.0 - travel)), 4.0, true)
    if age >= 0.35 and age < 1.25:
        var travel := smoothstep(0.35, 1.25, age)
        for i in range(5):
            var p := hero_position + Vector2(float(i - 2) * 23.0, -20.0 - travel * (66.0 + float(i % 2) * 30.0))
            var size := lerpf(4.0, 1.0, travel)
            canvas.draw_colored_polygon(PackedVector2Array([p + Vector2.UP * size, p + Vector2.RIGHT * size,
                p + Vector2.DOWN * size, p + Vector2.LEFT * size]), Color(LIME, 1.0 - travel))

func _draw() -> void:
    var reduced: bool = game.profile.settings.reducedMotion
    var view := get_viewport_rect().size
    if game.mode == "playing":
        var age: float = game.run_time - entrance_at
        if age >= 0.0 and age < ENTRANCE_LENGTH:
            var opacity := 1.0 if reduced else 1.0 - smoothstep(1.31, ENTRANCE_LENGTH, age)
            var slide := 0.0 if reduced else 14.0 * (1.0 - smoothstep(0.0, 0.24, age))
            _title(view, maxf(108.0, view.y * 0.24) - slide, "BIG HATER", CORAL, opacity)
    elif game.mode == "won" and celebrating:
        var age: float = game.finish_visual_age
        var reveal := results_at()
        if age < reveal:
            var opacity := 1.0 if reduced else smoothstep(0.15, 0.40, age)
            _title(view, view.y * 0.24, "VICTORY", LIME, opacity)
        if not reduced and age >= reveal - FADE_OUT and age < reveal + FADE_OUT:
            var dark := 1.0 - smoothstep(0.0, FADE_OUT, absf(age - reveal))
            draw_rect(Rect2(Vector2.ZERO, view), Color(INK, dark))

func _title(view: Vector2, y: float, title: String, accent: Color, opacity: float) -> void:
    var width := minf(430.0, view.x - 20.0)
    var height := 62.0 if view.y < 500.0 else 76.0
    var rect := Rect2((view.x - width) * 0.5, y, width, height)
    var panel := PackedVector2Array([rect.position + Vector2(16, 0), Vector2(rect.end.x, rect.position.y),
        rect.end - Vector2(16, 0), Vector2(rect.position.x, rect.end.y)])
    draw_colored_polygon(panel, Color(INK, 0.97 * opacity))
    draw_polyline(PackedVector2Array([panel[0], panel[1], panel[2]]), Color(accent, opacity), 2.0, true)
    draw_polyline(PackedVector2Array([panel[2], panel[3], panel[0]]), Color(accent, opacity), 2.0, true)
    var font: Font = Type.DISPLAY
    var font_size := clampi(floori(width * 0.11), 22, 43)
    var text_width := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
    var baseline := y + (height + font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
    draw_string(font, Vector2((view.x - text_width) * 0.5, baseline), title,
        HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(PAPER, opacity))
