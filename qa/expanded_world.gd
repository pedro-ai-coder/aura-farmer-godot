extends RefCounted
## EXPERIMENTAL: Wave 5-only QA world. Approved Ruin Alley art and cover
## positions stay unchanged. The floor polygon is widened about its center.
const Canonical=preload("res://scripts/solo_world_rules.gd")
const CENTER:=Vector2(724.0,543.0)
const SCALE:=1.118033988749895 # sqrt(1.25): +25% polygon area.
const ID:="wave5-expanded-floor-v1"

static func canonical_point(position: Vector2) -> Vector2:
    return CENTER+(position-CENTER)/SCALE

static func expanded_point(position: Vector2) -> Vector2:
    return CENTER+(position-CENTER)*SCALE

static func in_floor(position: Vector2, radius: float=16.0) -> bool:
    # Exact canonical polygon edge clearance, scaled back into its own space.
    return Canonical.in_floor(canonical_point(position),radius/SCALE)

static func walkable(position: Vector2, radius: float=16.0) -> bool:
    if not in_floor(position,radius):return false
    # Physical cover art stays at exactly the original location/radius.
    for cover: Dictionary in Canonical.COVERS:
        if position.distance_to(cover["pos"])<=float(cover["radius"])+radius:return false
    return true

static func move(position: Vector2, movement: Vector2, radius: float=16.0) -> Vector2:
    var horizontal:=position+Vector2(movement.x,0)
    var after_x:=horizontal if movement.x!=0.0 and walkable(horizontal,radius) else position
    var vertical:=after_x+Vector2(0,movement.y)
    return vertical if movement.y!=0.0 and walkable(vertical,radius) else after_x

static func clear_line(start: Vector2, ending: Vector2) -> bool:
    # Cover obstruction is unchanged; only the outer walkable boundary differs.
    return Canonical.clear_line(start,ending)

static func spawn_point(player: Vector2, rng, collision_radius: float=24.0):
    # Preserve the RNG call count and 80-attempt limit. Samples are expanded
    # along with the floor, not teleported through cover or spawned too close.
    for attempt in range(80):
        var original:=Vector2(180.0+rng.randf()*1100.0,300.0+rng.randf()*650.0)
        var candidate:=expanded_point(original)
        if walkable(candidate,maxf(24.0,collision_radius)) and candidate.distance_to(player)>=260.0:
            return candidate
    return null

static func floor_outline() -> PackedVector2Array:
    var points:=PackedVector2Array()
    for point: Vector2 in Canonical.FLOOR:points.append(expanded_point(point))
    return points
