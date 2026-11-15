extends RefCounted
## Static ground-only candidate treatment; exact approved geometry is read-only.
const World=preload("res://scripts/solo_world_rules.gd")
const CPK=preload("res://scripts/cpk_design_system.gd")
const EMBLEM=preload("res://assets/production/cpk-brand-2026-11-13-v1/cpk-emblem-color-96.png")
static var floor_polygon:=PackedVector2Array(World.FLOOR)
const WALL_MARKS=[Vector2(132,570),Vector2(1334,714)]
static func draw_ground(canvas: CanvasItem) -> void:
    canvas.draw_rect(Rect2(Vector2.ZERO,World.SIZE),Color(CPK.INK,.065))
    canvas.draw_colored_polygon(floor_polygon,Color(CPK.PAPER,.035))
    for i in range(World.FLOOR.size()):
        canvas.draw_line(World.FLOOR[i],World.FLOOR[(i+1)%World.FLOOR.size()],Color(CPK.INK,.08),7,true)
    for cover in World.COVERS:
        canvas.draw_set_transform(cover["pos"]+Vector2(0,3),0,Vector2(1,.6))
        canvas.draw_circle(Vector2.ZERO,float(cover["radius"]),Color(CPK.INK,.23),true,-1,true)
    canvas.draw_set_transform(Vector2.ZERO)
    for point in WALL_MARKS:
        # Exact logo paint is outside the traversable floor, never a fake collider.
        if not World.walkable(point,0):canvas.draw_texture_rect(EMBLEM,Rect2(point-Vector2(19,19),Vector2(38,38)),false,Color(1,1,1,.55))
