extends Control
## Original review-only vector lockups using real licensed fonts.
## A and B remain unchanged; C is the creator-directed typography/graphic hybrid.
var typography

func treatment() -> String:
    if typography == null:
        return "unassigned"
    match typography.candidate:
        "a": return "clash_bold"
        "b": return "clash_circuit"
        "c": return "clash_hybrid"
    return "unknown"

func _draw() -> void:
    if typography == null or size.x < 1.0 or size.y < 1.0:
        return
    var face: Font = typography.font("brand_logo")
    var factor: float = minf(size.x/440.0,size.y/140.0)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE*factor)
    var ink := Color("142638")
    var gold := Color("ffd55c")
    var paper := Color("fff9e9")
    if typography.candidate == "a":
        draw_colored_polygon(PackedVector2Array([Vector2(0,14),Vector2(400,14),Vector2(426,128),Vector2(18,140)]),ink)
        draw_rect(Rect2(18,111,388,9),gold)
        draw_string(face,Vector2(24,75),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,72,Color("36506b"))
        draw_string(face,Vector2(20,70),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,72,paper)
        draw_string(face,Vector2(24,109),"FARMER",HORIZONTAL_ALIGNMENT_LEFT,-1,39,gold)
    elif typography.candidate == "b":
        draw_colored_polygon(PackedVector2Array([Vector2(0,70),Vector2(27,25),Vector2(49,70),Vector2(27,113)]),gold)
        draw_line(Vector2(55,122),Vector2(418,122),gold,4)
        draw_string(face,Vector2(58,75),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,76,paper)
        draw_string(face,Vector2(62,113),"FARMER",HORIZONTAL_ALIGNMENT_LEFT,-1,38,gold)
        draw_line(Vector2(405,28),Vector2(428,51),paper,5)
    elif typography.candidate == "c":
        _draw_hybrid(face,ink,gold,paper)
    draw_set_transform(Vector2.ZERO)

func _draw_hybrid(face: Font, ink: Color, gold: Color, paper: Color) -> void:
    # Layered, flat angular frame: broad Archivo Black lettering (A), stronger
    # circuit-like silhouette and color blocking (B), no artificial skew or glow.
    var blue := Color("087cc6")
    var deep := Color("0e2234")
    # Ink silhouette and energetic sky-blue title plate.
    draw_colored_polygon(PackedVector2Array([
        Vector2(2,34),Vector2(374,15),Vector2(427,39),
        Vector2(411,115),Vector2(49,140),Vector2(10,125)
    ]),ink)
    draw_colored_polygon(PackedVector2Array([
        Vector2(16,40),Vector2(367,27),Vector2(409,46),
        Vector2(397,93),Vector2(23,107)
    ]),blue)
    # The second navy fascia keeps FARMER prominent instead of tiny subtitle.
    draw_colored_polygon(PackedVector2Array([
        Vector2(24,108),Vector2(396,95),Vector2(405,119),
        Vector2(48,132)
    ]),deep)
    draw_line(Vector2(47,135),Vector2(399,122),gold,3.0,true)
    # A restrained crown detail connects to Aura Farmer without borrowing
    # third-party logos or adding an unreadable decorative texture.
    draw_colored_polygon(PackedVector2Array([
        Vector2(322,21),Vector2(328,9),Vector2(340,18),
        Vector2(351,4),Vector2(361,17),Vector2(371,7),
        Vector2(374,23)
    ]),gold)
    draw_line(Vector2(320,26),Vector2(375,25),ink,3.0,true)
    # AURA is the primary word; shadow is a 2 px graphic keyline only.
    draw_string(face,Vector2(33,90),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,75,deep)
    draw_string(face,Vector2(31,87),"AURA",HORIZONTAL_ALIGNMENT_LEFT,-1,75,paper)
    # FARMER must remain readable and carry meaningful brand weight.
    draw_string(face,Vector2(48,126),"FARMER",HORIZONTAL_ALIGNMENT_LEFT,-1,38,gold)
    # Original angular edge accents echo B without the futuristic font.
    draw_line(Vector2(386,49),Vector2(376,75),paper,4.0,true)
    draw_line(Vector2(401,53),Vector2(391,79),gold,4.0,true)
