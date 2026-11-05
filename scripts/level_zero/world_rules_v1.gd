extends RefCounted
## Level Zero EXPERIMENTAL visual-space collision adapter, candidate only.
## Print factory artwork original: 1672x941 cropped with cover into 1448x1086.
## Foot clearance traced in original source-pixel coordinates, then projected by the same cover crop as the backdrop. NOT canonical GDD V3 geometry.
## Keep Ruin Alley cover behavior, enemy sampling rectangle and seed semantics.
const Base = preload("res://scripts/solo_world_rules.gd")
const VisualAssets = preload("res://scripts/level_zero/visual_assets_v1.gd")
const PLAYER_SPAWN := Vector2(724.0, 670.0)
const IMITATION_SPAWN := Vector2(820.0, 730.0)
const SOURCE_SIZE := Vector2(1672.0, 941.0)
# Trace image-space foot clearance instead of approximating it in world space.
# Source is the byte-verified candidate PNG; this is not a canonical collision map.
const SOURCE_FLOOR := [
    Vector2(218,500), Vector2(245,430), Vector2(300,385),
    Vector2(390,371), Vector2(460,380), Vector2(540,385),
    Vector2(620,418), Vector2(827,420), Vector2(900,370),
    Vector2(1020,366), Vector2(1190,367), Vector2(1248,381),
    Vector2(1340,425), Vector2(1452,480), Vector2(1453,775),
    Vector2(1380,895), Vector2(1245,916), Vector2(450,916),
    Vector2(280,895), Vector2(209,780)
]

static func source_crop() -> Rect2:
    # Share the exact center-cover projection used by the drawn factory texture.
    return VisualAssets.cover_rect(SOURCE_SIZE, Rect2(Vector2.ZERO, Base.SIZE))

static func source_to_world(source: Vector2) -> Vector2:
    var crop := source_crop()
    return Vector2(
        (source.x - crop.position.x) * Base.SIZE.x / crop.size.x,
        (source.y - crop.position.y) * Base.SIZE.y / crop.size.y
    )

static func _make_world_floor() -> Array[Vector2]:
    var result: Array[Vector2] = []
    for point: Vector2 in SOURCE_FLOOR:
        result.append(source_to_world(point))
    return result

static var FLOOR: Array[Vector2] = _make_world_floor()
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
