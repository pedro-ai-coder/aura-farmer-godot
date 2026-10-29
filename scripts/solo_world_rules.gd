class_name SoloWorldRules
extends RefCounted

## Ruin Alley foot-level geometry copied exactly from Phaser
## src/game/simulation/world.ts at the approved pinned art revision.
## Gameplay geometry is independent of sprite alpha, scaling and animation.
const SIZE := Vector2(1448.0, 1086.0)
const FLOOR := [
    Vector2(234, 448), Vector2(440, 334), Vector2(825, 287),
    Vector2(1047, 408), Vector2(1255, 550), Vector2(1310, 713),
    Vector2(1182, 843), Vector2(831, 979), Vector2(666, 880),
    Vector2(445, 786), Vector2(250, 772), Vector2(169, 642)
]
const COVERS := [
    {"pos": Vector2(600, 550), "radius": 30.0},
    {"pos": Vector2(940, 680), "radius": 30.0}
]

static func in_floor(point: Vector2, radius: float = 16.0) -> bool:
    var inside := false
    for i in range(FLOOR.size()):
        var a: Vector2 = FLOOR[i]
        var b: Vector2 = FLOOR[(i + 1) % FLOOR.size()]
        var edge := b - a
        var nearest_fraction := clampf((point - a).dot(edge) / edge.length_squared(), 0.0, 1.0)
        if point.distance_to(a + edge * nearest_fraction) < radius:
            return false
        if (a.y > point.y) != (b.y > point.y):
            if point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x:
                inside = not inside
    return inside

static func walkable(point: Vector2, radius: float = 16.0) -> bool:
    if not in_floor(point, radius):
        return false
    for cover: Dictionary in COVERS:
        if point.distance_to(cover["pos"]) <= float(cover["radius"]) + radius:
            return false
    return true

static func move(point: Vector2, delta: Vector2, radius: float = 16.0) -> Vector2:
    # Phaser separates axes, allowing sliding along walls instead of snapping
    # actors through the collider when both movement axes are requested.
    var horizontal := point + Vector2(delta.x, 0.0)
    var after_x := horizontal if walkable(horizontal, radius) else point
    var vertical := after_x + Vector2(0.0, delta.y)
    return vertical if walkable(vertical, radius) else after_x

static func clear_line(start: Vector2, ending: Vector2) -> bool:
    var delta := ending - start
    var squared := delta.length_squared()
    for cover: Dictionary in COVERS:
        var center: Vector2 = cover["pos"]
        var fraction := clampf((center - start).dot(delta) / squared, 0.0, 1.0) if squared > 0.0 else 0.0
        if center.distance_to(start + delta * fraction) <= float(cover["radius"]):
            return false
    return true

static func spawn_point(player: Vector2, rng, collision_radius: float = 24.0):
    # Preserve the sample rectangle, 80-attempt bound and 260 U arrival distance.
    # Large enemies need their actual collider clearance at birth; 24 U was
    # insufficient for elites/events/Big Hater and could create embedded actors.
    # RandomNumberGenerator is an input: geometry itself never consumes RNG.
    for attempt in range(80):
        var position := Vector2(180.0 + rng.randf() * 1100.0, 300.0 + rng.randf() * 650.0)
        if walkable(position, maxf(24.0,collision_radius)) and position.distance_to(player) >= 260.0:
            return position
    return null
