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
        # Keep a small clearance outside the axis-separated collision solver.
        # A mathematically tangent diagonal can lose an axis and re-enter the
        # blocked branch on the following frame, oscillating indefinitely.
        var clearance := float(cover["radius"])+radius+2.0
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
        if int(state.get("navigation_cover",-1)) != blocked or Vector2(state.get("navigation_target",target)).distance_to(target)>64.0:
            var clockwise := center+Vector2.from_angle(angle+ARC_STEP)*ring
            var counter := center+Vector2.from_angle(angle-ARC_STEP)*ring
            state["navigation_side"] = 1.0 if clockwise.distance_squared_to(target) <= counter.distance_squared_to(target) else -1.0
            state["navigation_cover"] = blocked
            state["navigation_target"] = target
            state.erase("navigation_waypoint")
        # Arrival tolerance must exceed a frame's integration error. Requiring
        # 0.05 U left actors alternating beside an almost-reached arc waypoint.
        if not state.has("navigation_waypoint") or position.distance_to(state["navigation_waypoint"]) <= maxf(2.0,distance*1.5):
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

# Opt-in development diagnostics. No allocations or RNG work when disabled.
# Movement time is accumulated only while navigation requests displacement;
# stationary attack/range/stagger intervals never count as blocked pursuit.
static var diagnostics_enabled := false
static var diagnostic_events: Array[Dictionary] = []
static func observe(enemy: Dictionary, target: Vector2, before: Vector2, intended: Vector2, dt: float, time: float, wave: int) -> void:
    if not diagnostics_enabled: return
    var trace: Dictionary=enemy.get("navigation_trace",{})
    if trace.is_empty() or time-float(trace["last"])>dt*2.1:
        trace={"anchor":before,"elapsed":0.0,"requested":0.0,"last":time}
        enemy["navigation_trace"]=trace
    trace["last"]=time
    trace["elapsed"]+=dt
    trace["requested"]+=intended.length()
    if float(trace["elapsed"])<1.5: return
    var actual: Vector2=enemy["pos"]-before
    var progress: float=Vector2(enemy["pos"]).distance_to(trace["anchor"])
    if progress<maxf(2.0,float(trace["requested"])*0.15):
        if diagnostic_events.size()==128:diagnostic_events.pop_front()
        diagnostic_events.append({"id":enemy["id"],"kind":enemy["kind"],"position":enemy["pos"],"target":target,
            "waypoint":enemy.get("navigation_waypoint",target),"cover":enemy.get("navigation_cover",-1),
            "intended":intended,"speed":intended.length()/maxf(dt,0.000001),"actual":actual,
            "phase":enemy["phase"],"without_progress":trace["elapsed"],"net_progress":progress,
            "collision_rejected":actual.length()<intended.length()*0.2,"wave":wave,"time":time})
    trace["anchor"]=enemy["pos"];trace["elapsed"]=0.0;trace["requested"]=0.0
