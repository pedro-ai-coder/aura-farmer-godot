extends RefCounted
## Geometry adapter for the original six maps. No gameplay rule or RNG changes.

var COVERS: Array[Dictionary] = []
var floor_polygon := PackedVector2Array()


func _init(map_data: Dictionary) -> void:
    for point in map_data.floor:
        floor_polygon.append(Vector2(point[0], point[1]))
    for cover in map_data.covers:
        COVERS.append({"pos": Vector2(cover[0], cover[1]), "radius": float(cover[2])})


func in_floor(point: Vector2, radius: float = 16.0) -> bool:
    if not Geometry2D.is_point_in_polygon(point, floor_polygon):
        return false
    for i in range(floor_polygon.size()):
        var nearest := Geometry2D.get_closest_point_to_segment(
            point, floor_polygon[i], floor_polygon[(i + 1) % floor_polygon.size()])
        if point.distance_to(nearest) < radius:
            return false
    return true


func walkable(point: Vector2, radius: float = 16.0) -> bool:
    if not in_floor(point, radius):
        return false
    for cover in COVERS:
        if point.distance_to(cover.pos) <= float(cover.radius) + radius:
            return false
    return true


func move(point: Vector2, delta: Vector2, radius: float = 16.0) -> Vector2:
    var horizontal := point + Vector2(delta.x, 0.0)
    var after_x := horizontal if delta.x != 0.0 and walkable(horizontal, radius) else point
    var vertical := after_x + Vector2(0.0, delta.y)
    return vertical if delta.y != 0.0 and walkable(vertical, radius) else after_x


func clear_line(start: Vector2, ending: Vector2) -> bool:
    var delta := ending - start
    var squared := delta.length_squared()
    for cover in COVERS:
        var center: Vector2 = cover.pos
        var fraction := clampf((center - start).dot(delta) / squared, 0.0, 1.0) if squared > 0.0 else 0.0
        if center.distance_to(start + delta * fraction) <= float(cover.radius):
            return false
    return true


func spawn_point(player: Vector2, rng, collision_radius: float = 24.0):
    # Keep the production sample rectangle, attempt cap and arrival distance.
    for attempt in range(80):
        var position := Vector2(180.0 + rng.randf() * 1100.0, 300.0 + rng.randf() * 650.0)
        if walkable(position, maxf(24.0, collision_radius)) and position.distance_to(player) >= 260.0:
            return position
    return null
