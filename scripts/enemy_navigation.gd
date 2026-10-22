extends RefCounted

## Deterministic steering around the two approved static covers.
## Movement still uses the original foot-level collision solver. No RNG/timers.
const World = preload("res://scripts/solo_world_rules.gd")
const ARC_STEP := PI/8.0

static func _blocked_cover(position: Vector2, target: Vector2, radius: float) -> int:
    var chosen := -1
    var nearest := INF
    for index in range(World.COVERS.size()):
        var cover: Dictionary = World.COVERS[index]
        var center: Vector2 = cover["pos"]
        var clearance := float(cover["radius"])+radius+0.5
        var closest := Geometry2D.get_closest_point_to_segment(center,position,target)
        if center.distance_squared_to(closest) >= clearance*clearance: continue
        var distance := position.distance_squared_to(closest)
        if distance < nearest:
            chosen = index
            nearest = distance
    return chosen

static func move(position: Vector2, target: Vector2, distance: float, radius: float, state: Dictionary) -> Vector2:
    if distance <= 0.0: return position
    var heading := target-position
    if heading.length_squared() < 0.000001: return position
    var blocked := _blocked_cover(position,target,radius)
    var waypoint := target
    if blocked >= 0:
        var center: Vector2 = World.COVERS[blocked]["pos"]
        # Margin and a short arc keep the chord outside the expanded collider,
        # including the initial approach from just outside its actual boundary.
        var ring := (float(World.COVERS[blocked]["radius"])+radius+1.0)/cos(ARC_STEP)+0.5
        var angle := (position-center).angle()
        if int(state.get("navigation_cover",-1)) != blocked:
            var clockwise := center+Vector2.from_angle(angle+ARC_STEP)*ring
            var counter := center+Vector2.from_angle(angle-ARC_STEP)*ring
            state["navigation_side"] = 1.0 if clockwise.distance_squared_to(target) <= counter.distance_squared_to(target) else -1.0
            state["navigation_cover"] = blocked
            state.erase("navigation_waypoint")
        if not state.has("navigation_waypoint") or position.distance_to(state["navigation_waypoint"]) < 0.05:
            state["navigation_waypoint"] = center+Vector2.from_angle(angle+ARC_STEP*float(state["navigation_side"]))*ring
        waypoint = state["navigation_waypoint"]
    else:
        state.erase("navigation_cover")
        state.erase("navigation_waypoint")
    var desired := waypoint-position
    var step := desired.normalized()*minf(distance,desired.length())
    var result := World.move(position,step,radius)
    if result.distance_to(position) >= distance*0.2: return result
    # At floor edges try both sides. Commit the better side for ties rather
    # than repeating a known blocked perpendicular step forever.
    var side: float = state.get("navigation_edge_side",1.0)
    var perpendicular := Vector2(-heading.y,heading.x).normalized()*distance
    var first := World.move(position,perpendicular*side,radius)
    var second := World.move(position,-perpendicular*side,radius)
    var first_travel := first.distance_to(position)
    var second_travel := second.distance_to(position)
    if second_travel > first_travel+0.01:
        state["navigation_edge_side"] = -side
        return second
    return first if first_travel > result.distance_to(position) else result
