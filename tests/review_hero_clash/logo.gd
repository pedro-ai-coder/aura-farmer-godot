extends Control
## Original review-only vector lockups, using real font outlines. No approved asset edits.
var typography
func _draw() -> void:
    if typography == null or size.x < 1: return
    var face: Font = typography.font("brand_logo")
    var factor: float = minf(size.x/440.0,size.y/140.0)
    draw_set_transform(Vector2.ZERO,0,Vector2.ONE*factor)
    var ink := Color("142638")
    var gold := Color("ffd55c")
    var paper := Color("fff9e9")
    if typography.candidate == "a":
        draw_colored_polygon(PackedVector2Array([Vector2(0,14),Vector2(400,14),Vector2(426,128),Vector2(18,140)]),ink)
        draw_rect(Rect2(18,111,388,9),gold)
        draw_string(face,Vector2(24,75),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,72,Color("36506b"))
        draw_string(face,Vector2(20,70),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,72,paper)
        draw_string(face,Vector2(24,109),"FARMER",HORIZONTAL_ALIGNMENT_LEFT,-1,39,gold)
    else:
        draw_colored_polygon(PackedVector2Array([Vector2(0,70),Vector2(27,25),Vector2(49,70),Vector2(27,113)]),gold)
        draw_line(Vector2(55,122),Vector2(418,122),gold,4)
        draw_string(face,Vector2(58,75),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,76,paper)
        draw_string(face,Vector2(62,113),"FARMER",HORIZONTAL_ALIGNMENT_LEFT,-1,38,gold)
        draw_line(Vector2(405,28),Vector2(428,51),paper,5)
    draw_set_transform(Vector2.ZERO)
