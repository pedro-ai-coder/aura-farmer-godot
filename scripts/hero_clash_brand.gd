extends Control
## Review-only candidate brand art. Original approved wordmark stays hash-pinned
## and loadable. Do not promote the brand before owner approval.
const Type = preload("res://scripts/clean_cut_typography.gd")

func _draw() -> void:
    if size.x < 20.0 or size.y < 20.0:
        return
    var factor: float = minf(size.x / 460.0,size.y / 154.0)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE * factor)
    var deep:=Color("13233a")
    var navy:=Color("253449")
    var blue:=Color("087cc6")
    var paper:=Color("fff9e9")
    var gold:=Color("f8c45f")
    draw_colored_polygon(PackedVector2Array([
        Vector2(4,35),Vector2(405,22),Vector2(455,45),
        Vector2(442,126),Vector2(54,148),Vector2(10,132)
    ]),deep)
    draw_colored_polygon(PackedVector2Array([
        Vector2(17,42),Vector2(405,32),Vector2(436,49),
        Vector2(422,102),Vector2(23,116)
    ]),blue)
    draw_colored_polygon(PackedVector2Array([
        Vector2(28,115),Vector2(422,103),Vector2(432,132),
        Vector2(51,143)
    ]),navy)
    draw_line(Vector2(45,147),Vector2(428,136),gold,4.0,true)
    # One restrained crown: recognisable original brand accent, not a borrowed logo.
    draw_colored_polygon(PackedVector2Array([
        Vector2(342,28),Vector2(345,11),Vector2(361,22),Vector2(372,5),
        Vector2(385,21),Vector2(401,10),Vector2(403,29)
    ]),gold)
    draw_line(Vector2(340,31),Vector2(405,31),deep,3.0,true)
    # The logo uses genuinely filled Archivo Black, not outline-only lettering.
    draw_string(Type.DISPLAY,Vector2(35,96),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,83,deep)
    draw_string(Type.DISPLAY,Vector2(32,92),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,83,paper)
    draw_string(Type.DISPLAY,Vector2(57,136),"FARMER",HORIZONTAL_ALIGNMENT_LEFT,-1,40,gold)
    draw_line(Vector2(413,53),Vector2(402,83),paper,4.0,true)
    draw_set_transform(Vector2.ZERO)
