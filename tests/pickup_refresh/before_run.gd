extends "res://tests/pickup_refresh/review_run.gd"
## Exact procedural pickup renderer from production 47f5f55331a4.
func _draw_pickup(drop: Dictionary) -> void:
    var at: Vector2 = drop["pos"]
    var kind := str(drop["kind"])
    var ink := Color(0.14, 0.20, 0.29)
    var paper := Color(0.97, 0.93, 0.80)
    if kind == "aura":
        if drop.has("phase"):
            draw_arc(at, 19.0, 0, TAU, 24, Color("f8c45f"), 3.0)
        var pulse := 1.0 if profile["settings"]["reducedMotion"] else 1.0 + 0.08 * sin(run_time * 5.0 + at.x * 0.05)
        var diamond := PackedVector2Array([
            at + Vector2(0, -12) * pulse, at + Vector2(9, 0) * pulse,
            at + Vector2(0, 12) * pulse, at + Vector2(-9, 0) * pulse
        ])
        draw_colored_polygon(diamond, ink)
        draw_colored_polygon(PackedVector2Array([
            at + Vector2(0, -9) * pulse, at + Vector2(6, 0) * pulse,
            at + Vector2(0, 9) * pulse, at + Vector2(-6, 0) * pulse
        ]), Color(0.24, 0.90, 0.82))
        draw_line(at + Vector2(0, -8), at + Vector2(0, 6), paper, 1.5)
    elif kind == "snack":
        draw_circle(at, 16.0, ink)
        draw_rect(Rect2(at - Vector2(12, 12), Vector2(24, 24)), Color(0.44, 0.81, 0.61))
        draw_rect(Rect2(at - Vector2(3, 9), Vector2(6, 18)), paper)
        draw_rect(Rect2(at - Vector2(9, 3), Vector2(18, 6)), paper)
    elif kind == "magnet":
        draw_circle(at, 16.0, ink)
        draw_arc(at + Vector2(0, -2), 9.0, 0.0, PI, 16, paper, 8.0)
        draw_arc(at + Vector2(0, -2), 9.0, 0.0, PI, 16, Color(0.58, 0.46, 0.82), 5.0)
        draw_line(at + Vector2(-9, -4), at + Vector2(-9, -11), paper, 5.0)
        draw_line(at + Vector2(9, -4), at + Vector2(9, -11), paper, 5.0)

