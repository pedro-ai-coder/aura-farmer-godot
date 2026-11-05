extends RefCounted
## Level Zero EXPERIMENTAL visual-space collision adapter, candidate only.
## Print factory artwork original: 1672x941 cropped with cover into 1448x1086.
## Bounds hand-fitted to the visible walkable ground. Do not reuse as GDD V3 canon.
## Keep Ruin Alley cover behavior, enemy sampling rectangle and seed semantics.
const Base = preload("res://scripts/solo_world_rules.gd")
const PLAYER_SPAWN := Vector2(724.0, 670.0)
const IMITATION_SPAWN := Vector2(820.0, 730.0)
const FLOOR := [
    # Feet need extra visual clearance: hero sprites extend above their collider.
    # Previous polygon allowed the upper body into painted press/poster stacks.
    Vector2(170,530), Vector2(330,500), Vector2(470,520),
    Vector2(580,565), Vector2(810,570), Vector2(970,535),
    Vector2(1220,505), Vector2(1370,535), Vector2(1370,760),
    Vector2(1240,910), Vector2(1050,1035), Vector2(410,1035),
    Vector2(235,900), Vector2(115,760), Vector2(115,560)
]
static var polygon: PackedVector2Array = PackedVector2Array(FLOOR)

static func in_floor(point: Vector2, radius: float = 16.0) -> bool:
    if not Geometry2D.is_point_in_polygon(point, polygon):
        return false
    # A clearance margin prevents actor feet crossing painted machinery/fences.
    for i in range(FLOOR.size()):
        var a: Vector2 = FLOOR[i]
        var b: Vector2 = FLOOR[(i + 1) % FLOOR.size()]
        var segment := b - a
        var closest := a + segment * clampf((point - a).dot(segment) / segment.length_squared(), 0.0, 1.0)
        if point.distance_to(closest) < radius:
            return false
    return true

static func walkable(point: Vector2, radius: float = 16.0) -> bool:
    if not in_floor(point, radius):
        return false
    for cover: Dictionary in Base.COVERS:
        if point.distance_to(cover["pos"]) <= float(cover["radius"]) + radius:
            return false
    return true

static func move(point: Vector2, delta: Vector2, radius: float = 16.0) -> Vector2:
    # Keep canonical axis-separated sliding; only swap the floor polygon.
    # Sweep in small steps so one fast movement cannot jump across a cover
    # or narrow non-walkable region. No additional RNG is consumed.
    var steps := maxi(1, ceili(delta.length() / 12.0))
    var per_step := delta / float(steps)
    var current := point
    for step in range(steps):
        var horizontal := current + Vector2(per_step.x, 0.0)
        if per_step.x != 0.0 and walkable(horizontal, radius):
            current = horizontal
        var vertical := current + Vector2(0.0, per_step.y)
        if per_step.y != 0.0 and walkable(vertical, radius):
            current = vertical
    return current

static func clear_line(start: Vector2, ending: Vector2) -> bool:
    # Preserve V3 cover line-of-sight while this optional floor remains in review.
    return Base.clear_line(start, ending)

static func spawn_point(player: Vector2, rng_source, radius: float = 24.0):
    # Same 80-attempt bound, rectangle and distance as the shared rules.
    # Reject candidate positions outside the print-factory floor, deterministically.
    for attempt in range(80):
        var position := Vector2(180.0 + rng_source.randf() * 1100.0, 300.0 + rng_source.randf() * 650.0)
        if walkable(position, maxf(24.0, radius)) and position.distance_to(player) >= 260.0:
            return position
    return null
