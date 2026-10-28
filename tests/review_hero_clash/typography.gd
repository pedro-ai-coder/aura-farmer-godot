extends RefCounted
## Review-only typography. All sizes are logical pixels before the existing UI scale.
const FACES = {
    "a": [preload("fonts/archivoblack/ArchivoBlack.ttf"), preload("fonts/archivo/Archivo.ttf")],
    "b": [preload("fonts/oxanium/Oxanium.ttf"), preload("fonts/rubik/Rubik.ttf")],
}
const SYMBOLS = preload("res://assets/fonts/Inter-Body.ttf")
# family, weight, desktop size, compact size, extra line spacing, capitalization.
# Archivo Black is a static black design: its registered weight is Regular, not synthetic bold.
const TOKENS = {
    "brand_logo": [0,800,64,48,0,"upper"],
    "display_xl": [0,800,54,38,0,"upper"],
    "display_large": [0,800,44,32,0,"upper"],
    "screen_heading": [0,800,42,30,0,"upper"],
    "section_heading": [0,700,26,23,2,"upper"],
    "hero_name": [0,700,30,26,2,"identity"],
    "upgrade_card_title": [0,700,29,26,2,"identity"],
    "rarity_label": [1,700,16,16,1,"upper"],
    "hud_primary_stat": [1,700,24,22,0,"identity"],
    "hud_secondary_stat": [1,600,17,17,1,"identity"],
    "numeric_emphasis": [1,700,28,26,0,"identity"],
    "ability_status": [1,700,17,16,1,"upper"],
    "button_label": [1,700,22,20,0,"upper"],
    "body_text": [1,500,19,18,3,"identity"],
    "micro_label": [1,600,16,16,1,"upper"],
}
const LEGACY = {"display_l":"screen_heading", "section_header":"section_heading", "card_title":"upgrade_card_title", "hud_stat":"hud_primary_stat", "hud_secondary":"hud_secondary_stat", "body_m":"body_text", "body_s":"body_text", "equipment_label":"hud_secondary_stat"}
var candidate := "a"
var cache: Dictionary = {}

func font(role: String) -> FontVariation:
    if cache.has(role): return cache[role]
    var token: Array = TOKENS[role]
    var base: FontFile = FACES[candidate][token[0]]
    base.allow_system_fallback = false
    var face := FontVariation.new()
    face.base_font = base
    face.fallbacks = [SYMBOLS]
    var ts := TextServerManager.get_primary_interface()
    face.variation_opentype = {ts.name_to_tag("wght"):token[1],ts.name_to_tag("wdth"):100}
    face.spacing_glyph = 0
    if role in ["numeric_emphasis","hud_primary_stat","hud_secondary_stat"]:
        face.opentype_features = {TextServerManager.get_primary_interface().name_to_tag("tnum"):1}
    cache[role] = face
    return face

func apply(node: Control, role: String, compact: bool) -> void:
    role = LEGACY.get(role,role)
    if not TOKENS.has(role): role = "body_text"
    var token: Array = TOKENS[role]
    node.set_meta("review_typography_role",role)
    node.add_theme_font_override("font",font(role))
    node.add_theme_font_size_override("font_size",token[3] if compact else token[2])
    node.add_theme_constant_override("line_spacing",token[4])
    # Preserve established semantic colors. Only text directly over the world needs a keyline.
    var world: bool = node.get_theme_constant("outline_size") >= 3
    node.add_theme_constant_override("outline_size",1 if world else 0)
    node.add_theme_color_override("font_shadow_color",Color(0.04,0.08,0.14,0.45) if world else Color.TRANSPARENT)
    node.add_theme_constant_override("shadow_offset_x",0)
    node.add_theme_constant_override("shadow_offset_y",1 if world else 0)
    if node is Label: node.uppercase = token[5] == "upper"
