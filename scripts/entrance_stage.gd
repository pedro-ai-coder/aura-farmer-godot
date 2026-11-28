extends Node2D

const Maps = preload("res://scripts/solo_maps.gd")
const Cast = preload("res://scripts/entrance_cast.gd")
const Factory = preload("res://scripts/msg_factory_presentation.gd")
const FIELD := Rect2(0, 0, 1448, 1086)
const ARENAS := {
    Maps.RUIN_ALLEY: {"lane": Vector2(66, 198), "accent": Color("76f1ed"), "trim": Color("e449a6")},
    Maps.MSG_FACTORY: {"lane": Vector2(-57, 200), "accent": Color("ffb865"), "trim": Color("d9fa64")},
}

var game
var arena: StringName
var hero_id: String
var appearance: String
var age := 0.0
var reduced := false
var frame: Dictionary
var entrance_mix := 1.0

func _draw() -> void:
    if frame.is_empty():
        return
    var factory := arena == Maps.MSG_FACTORY
    draw_texture_rect(Maps.FACTORY_ARENA if factory else Maps.ALLEY_V3_ARENA, FIELD, false)
    var anchor: Vector2 = frame.feet
    var accent: Color = ARENAS[arena].accent
    if entrance_mix > 0.0:
        draw_rect(FIELD, Color(0.026, 0.021, 0.057, entrance_mix * 0.32))
        # Light falls across the existing floor; distinct directions describe
        # the open alley and machine-side factory doors.
        var direction := -1.0 if factory else 1.0
        var beam := PackedVector2Array([anchor + Vector2(direction * 160, -370),
            anchor + Vector2(direction * 200, -370), anchor + Vector2(105, 96), anchor + Vector2(-95, 96)])
        draw_colored_polygon(beam, Color(accent, entrance_mix * 0.14))
    if factory:
        for cover: Dictionary in Maps.FactoryGeometry.COVERS:
            if cover.pos.y <= anchor.y: _factory_cover(cover)
    else:
        for point: Vector2 in game.COVERS:
            if point.y <= anchor.y: _alley_cover(point)
    draw_texture_rect(Factory.contact_shadow, Rect2(anchor - Vector2(23, 12), Vector2(46, 24)), false)
    Cast.draw(game.art.hero_sheets, self, anchor, (-Vector2(ARENAS[arena].lane)).angle(),
        hero_id, appearance, frame.shot, age, reduced)
    if factory:
        for cover: Dictionary in Maps.FactoryGeometry.COVERS:
            if cover.pos.y > anchor.y: _factory_cover(cover)
    else:
        for point: Vector2 in game.COVERS:
            if point.y > anchor.y: _alley_cover(point)

func _factory_cover(cover: Dictionary) -> void:
    draw_texture(cover.sprite, cover.sprite_anchor - Maps.COVER_TEXTURE_ORIGIN)
    Factory.draw_machine_detail(self, cover.detail, 0.0 if reduced else fposmod(age, Factory.PERIOD))

func _alley_cover(point: Vector2) -> void:
    var rect := Maps.ALLEY_COVER_RECT
    rect.position += point
    draw_texture_rect(Maps.ALLEY_V3_COVER, rect, false)
