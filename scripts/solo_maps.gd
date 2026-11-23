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
    # Foot-level ellipses follow the broad, shallow bases. Sprite anchors keep
    # the V4 cutouts registered to the original plate.
    const COVERS := [
        {"pos": Vector2(438, 411), "axes": Vector2(118, 38), "sprite_anchor": Vector2(444, 410), "detail": &"vent", "sprite": preload("res://assets/first_playable/msg_factory/ink-pump.png")},
        {"pos": Vector2(1007, 421), "axes": Vector2(113, 40), "sprite_anchor": Vector2(1010, 424), "detail": &"indicator", "sprite": preload("res://assets/first_playable/msg_factory/roller.png")},
        {"pos": Vector2(350, 712), "axes": Vector2(110, 43), "sprite_anchor": Vector2(352, 702), "sprite": preload("res://assets/first_playable/msg_factory/ink-tanks.png")},
        {"pos": Vector2(1023, 723), "axes": Vector2(126, 44), "sprite_anchor": Vector2(1028, 718), "sprite": preload("res://assets/first_playable/msg_factory/dispatch-rack.png")},
    ]
    # Trace the V4 floor where it meets the walls and fixed machinery.
    static var floor := PackedVector2Array([
        Vector2(130, 310), Vector2(298, 236), Vector2(570, 218),
        Vector2(782, 290), Vector2(1100, 280), Vector2(1218, 388),
        Vector2(1382, 576), Vector2(1398, 808), Vector2(1218, 986),
        Vector2(1000, 1040), Vector2(410, 1040), Vector2(200, 956),
        Vector2(59, 885), Vector2(59, 540), Vector2(93, 510),
        Vector2(163, 478), Vector2(166, 435), Vector2(138, 376),
    ])

    static func in_floor(point: Vector2, radius: float) -> bool:
        if not Geometry2D.is_point_in_polygon(point, floor):
            return false
        for i in range(floor.size()):
            var edge := Geometry2D.get_closest_point_to_segment(point, floor[i], floor[(i + 1) % floor.size()])
            if point.distance_to(edge) < radius:
                return false
        return true
