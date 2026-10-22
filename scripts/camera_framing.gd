class_name CameraFraming
extends RefCounted

## Phaser camera-follow.ts landscape targets; clamped to the approved map image.
const WORLD := Vector2(1448,1086)

static func zoom_for(view: Vector2, touch: bool = false) -> float:
    if view.x <= 0.0 or view.y <= 0.0: return 1.0
    var desired := Vector2(1120,510) if touch else Vector2(1040,585)
    return maxf(maxf(view.x / WORLD.x, view.y / WORLD.y), minf(view.x / desired.x, view.y / desired.y))

static func clamp_center(point: Vector2, view: Vector2, zoom: float) -> Vector2:
    var half := view / maxf(zoom, 0.001) * 0.5
    return Vector2(clampf(point.x, half.x, WORLD.x - half.x), clampf(point.y, half.y, WORLD.y - half.y))

static func follow(previous: Vector2, target: Vector2, delta: float) -> Vector2:
    if not is_finite(delta) or delta <= 0.0: return previous
    return previous.lerp(target, 1.0 - exp(-10.0 * minf(delta, 0.1)))
