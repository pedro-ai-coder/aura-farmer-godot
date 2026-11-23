extends RefCounted

const RUIN_ALLEY := &"ruin-alley"
const MSG_FACTORY := &"msg-factory"
const NAMES := {RUIN_ALLEY: "Ruin Alley", MSG_FACTORY: "MSG Factory"}
const ALLEY_ARENA = preload("res://assets/approved/ruin-alley.png")
const FACTORY_ARENA = preload("res://assets/first_playable/msg_factory/arena.webp")
const COVER_TEXTURE_ORIGIN := Vector2(160, 188)

class FactoryGeometry:
    const SPAWN := Vector2(724, 543)
    const EAST_TERMINAL := Vector2(1170, 700)
    const COVERS := [
        {"pos": Vector2(444, 410), "radius": 55.0, "sprite": preload("res://assets/first_playable/msg_factory/ink-pump.png")},
        {"pos": Vector2(1010, 424), "radius": 62.0, "sprite": preload("res://assets/first_playable/msg_factory/roller.png")},
        {"pos": Vector2(352, 702), "radius": 52.0, "sprite": preload("res://assets/first_playable/msg_factory/ink-tanks.png")},
        {"pos": Vector2(1028, 718), "radius": 65.0, "sprite": preload("res://assets/first_playable/msg_factory/dispatch-rack.png")},
    ]
    # Trace the V4 floor where it meets the walls and fixed machinery.
    static var floor := PackedVector2Array([
        Vector2(130, 310), Vector2(298, 236), Vector2(570, 218),
        Vector2(782, 290), Vector2(1100, 280), Vector2(1218, 388),
        Vector2(1382, 576), Vector2(1398, 808), Vector2(1218, 986),
        Vector2(1000, 1040), Vector2(410, 1040), Vector2(200, 956),
        Vector2(59, 885), Vector2(59, 560),
    ])

    static func in_floor(point: Vector2, radius: float) -> bool:
        if not Geometry2D.is_point_in_polygon(point, floor):
            return false
        for i in range(floor.size()):
            var edge := Geometry2D.get_closest_point_to_segment(point, floor[i], floor[(i + 1) % floor.size()])
            if point.distance_to(edge) < radius:
                return false
        return true
