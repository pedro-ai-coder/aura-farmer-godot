extends "res://scripts/vfx/no_u_reverse_impact_v3.gd"
## EXPERIMENTAL / PROPOSED. Painted atlas choreography; V3 resolved state/status contract.
## No nodes, particles, gameplay RNG, camera shake or wall-clock animation.
const ART := preload("res://assets/experimental/no-u-v4/reversal-atlas.png")
const CELLS := [Rect2(0, 0, 627, 627), Rect2(627, 0, 627, 627),
    Rect2(0, 627, 627, 627), Rect2(627, 627, 627, 627)]

func _paint(canvas: CanvasItem, cell: int, center: Vector2, extent: Vector2, alpha: float, angle: float = 0.0) -> void:
    if alpha <= 0.0:
        return
    canvas.draw_set_transform(center, angle)
    canvas.draw_texture_rect_region(ART, Rect2(-extent * 0.5, extent), CELLS[cell], Color(1, 1, 1, alpha), false, true)
    canvas.draw_set_transform(Vector2.ZERO)

func draw_ground(canvas: CanvasItem, now: float, reduced: bool) -> void:
    var age := now - _at
    if age < 0.0 or age >= 0.82:
        return
    var release := clampf((age - 0.035) / 0.19, 0.0, 1.0)
    var travel := 1.0 - pow(1.0 - release, 4.0)
    var fade := 1.0 - smoothstep(0.20, 0.65, age)
    var diameter := _radius * 2.0 * (0.98 if reduced else lerpf(0.20, 0.98, travel))
    # One painted, torn pressure front: the hollow center preserves player readability.
    _paint(canvas, 0, _origin, Vector2.ONE * diameter, fade * (0.62 if reduced else 0.91))
    if not reduced:
        var debris := smoothstep(0.07, 0.19, age) * (1.0 - smoothstep(0.25, 0.82, age))
        var drift := 1.0 - pow(1.0 - clampf(age / 0.82, 0.0, 1.0), 3.0)
        _paint(canvas, 3, _origin + Vector2(-68, 52) * drift, Vector2(188, 97), debris * 0.8)
        _paint(canvas, 3, _origin + Vector2(81, 34) * drift, Vector2(152, 78), debris * 0.65, -2.6)
    # Opposed returning brush hooks form the reversal signature; not a radial particle system.
    var return_alpha := 1.0 - smoothstep(0.10, 0.32, age)
    var heading := _incoming.angle() if _incoming != Vector2.ZERO else -0.4
    var recoil := 0.0 if reduced else 14.0 * (1.0 - travel)
    for side: float in [-1.0, 1.0]:
        var axis := Vector2.from_angle(heading)
        var center := _origin + axis * side * (41.0 + recoil) + axis.orthogonal() * side * 15.0
        _paint(canvas, 2, center, Vector2(107, 62), return_alpha * 0.9, heading + (PI if side > 0 else 0.0))

func draw_contacts(canvas: CanvasItem, now: float, reduced: bool) -> void:
    var age := now - _at
    if age < 0.0 or age >= 0.44:
        return
    # Concentrated ignition, localized to the incoming contact, never a screen flash.
    var ignition := 1.0 - smoothstep(0.035, 0.16, age)
    _paint(canvas, 1, _origin + _incoming * 22.0, Vector2.ONE * (68.0 if reduced else 88.0), ignition * 0.95)
    var alpha := 1.0 - smoothstep(0.08, 0.42, age)
    var spread := 0.0 if reduced else 7.0 * smoothstep(0.0, 0.42, age)
    var lethal_positions := _lethal.values()
    for point in _contacts:
        var axis := _origin.direction_to(point)
        var lethal: bool = point in lethal_positions
        # Only actual HP recipients get hot damage confirmation; shield-only targets do not.
        _paint(canvas, 1 if lethal else 2, point + Vector2(0, -13) + axis * spread,
            Vector2(58, 58) if lethal else Vector2(57, 34), alpha, axis.angle() - (0.35 if lethal else 0.0))
