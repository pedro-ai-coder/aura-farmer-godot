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

# The approved polygon is immutable. Dense navigation checks it thousands of
# times per frame; cache edge geometry instead of reconstructing it per actor.
static var _floor_polygon := PackedVector2Array(FLOOR)
static var _floor_edges: Array[Vector2] = _make_floor_edges()
static var _floor_lengths: PackedFloat64Array = _make_floor_lengths()
# A conservative spatial certificate, not an approximate collider. The distance
# to any boundary is 1-Lipschitz: a point nearer to a certified cell center than
# (clearance - actor radius) cannot cross that boundary. Uncertain points still
# execute the exact original test. No covers or actor radii are baked into it.
const _CELL_SIZE := 32.0
const _GRID_WIDTH := 46
const _GRID_HEIGHT := 34
static var _floor_clearance: PackedFloat64Array = _make_floor_clearance()

static func _make_floor_edges() -> Array[Vector2]:
    var result: Array[Vector2] = []
    for i in range(FLOOR.size()):result.append(FLOOR[(i + 1) % FLOOR.size()] - FLOOR[i])
    return result

static func _make_floor_lengths() -> PackedFloat64Array:
    var result := PackedFloat64Array()
    for edge in _floor_edges:result.append(edge.length_squared())
    return result

static func _make_floor_clearance() -> PackedFloat64Array:
    var result := PackedFloat64Array()
    result.resize(_GRID_WIDTH * _GRID_HEIGHT)
    for y in range(_GRID_HEIGHT):
        for x in range(_GRID_WIDTH):
            var center := Vector2(x + 0.5, y + 0.5) * _CELL_SIZE
            if not Geometry2D.is_point_in_polygon(center, _floor_polygon):continue
            var clearance := INF
            for i in range(FLOOR.size()):
                var a: Vector2 = FLOOR[i]
                var edge: Vector2 = _floor_edges[i]
                var fraction := clampf((center-a).dot(edge)/_floor_lengths[i],0.0,1.0)
                clearance=minf(clearance,center.distance_to(a+edge*fraction))
            # Conservative allowance exceeds Vector2 float roundoff at this
            # world's extent. It only selects the exact fallback more often.
            result[y*_GRID_WIDTH+x]=maxf(0.0,clearance-0.01)
    return result

static func in_floor(point: Vector2, radius: float = 16.0) -> bool:
    if radius >= 1.0:
        var cell_x := floori(point.x/_CELL_SIZE)
        var cell_y := floori(point.y/_CELL_SIZE)
        if cell_x>=0 and cell_x<_GRID_WIDTH and cell_y>=0 and cell_y<_GRID_HEIGHT:
            var center := Vector2(cell_x+0.5,cell_y+0.5)*_CELL_SIZE
            if _floor_clearance[cell_y*_GRID_WIDTH+cell_x]>radius+point.distance_to(center):return true
    var inside := false
    for i in range(FLOOR.size()):
        var a: Vector2 = FLOOR[i]
        var b: Vector2 = FLOOR[(i + 1) % FLOOR.size()]
        var edge: Vector2 = _floor_edges[i]
        var nearest_fraction := clampf((point - a).dot(edge) / _floor_lengths[i], 0.0, 1.0)
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
    var after_x := horizontal if delta.x != 0.0 and walkable(horizontal, radius) else point
    var vertical := after_x + Vector2(0.0, delta.y)
    return vertical if delta.y != 0.0 and walkable(vertical, radius) else after_x

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
