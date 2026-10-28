class_name CleanCutTypography
extends RefCounted
## Proposed Hero Clash UI treatment: original A typography, B-inspired graphic framing.
## Packaged SIL OFL files copied byte-identically from the reviewed PR #78 fonts.
## Existing approved Barlow resources remain intact for possible rollback.
const DISPLAY = preload("res://assets/fonts/hero-clash/ArchivoBlack.ttf")
const BODY = preload("res://assets/fonts/hero-clash/Archivo.ttf")
const SEMIBOLD = preload("res://assets/fonts/hero-clash/Archivo.ttf")
const BOLD = preload("res://assets/fonts/hero-clash/ArchivoBlack.ttf")
const SYMBOLS = preload("res://assets/fonts/Inter-Body.ttf")
const INK = Color("253449")
const PAPER = Color("fff9e9")
# family, desktop px, compact px, tracking px, extra line spacing, capitalization.
const TOKENS = {
    "display_xl":["display",54,40,0,0,"upper"],
    "display_l":["display",46,32,0,0,"upper"],
    "section_header":["display",28,23,0,1,"upper"],
    "card_title":["display",29,25,0,1,"identity"],
    "button_label":["semibold",22,19,0,0,"upper"],
    "hud_stat":["semibold",23,19,0,0,"identity"],
    "hud_secondary":["semibold",17,15,0,1,"identity"],
    "body_m":["body",19,18,0,3,"sentence"],
    "body_s":["body",17,16,0,2,"sentence"],
    "micro_label":["semibold",15,14,0,0,"upper"],
    "equipment_label":["semibold",15,14,0,1,"identity"],
    "numeric_emphasis":["semibold",27,23,0,0,"identity"],
}
static var fonts: Dictionary = {}
static var shared_theme: Theme

static func _static_init() -> void:
    var symbols: FontFile = SYMBOLS
    symbols.allow_system_fallback = false
    for face: FontFile in [DISPLAY,BODY,SEMIBOLD,BOLD]:
        face.allow_system_fallback = false
        face.fallbacks = [SYMBOLS]

static func font(role: String) -> Font:
    if fonts.has(role): return fonts[role]
    var token: Array = TOKENS[role]
    var variation := FontVariation.new()
    variation.base_font = {"display":DISPLAY,"body":BODY,"semibold":SEMIBOLD,"bold":BOLD}[token[0]]
    if token[0] != "display" and token[0] != "bold":
        # Archivo is a licensed variable font; real axis weights, no fake strokes.
        var weight: int = 700 if token[0] == "semibold" else 500
        variation.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"):weight}
    variation.spacing_glyph = token[3]
    if role in ["hud_stat","numeric_emphasis","hud_secondary"]:
        variation.opentype_features = {"tnum":1}
    fonts[role] = variation
    return variation

static func apply(control: Control, role: String, compact: bool=false, color: Color=INK, on_world: bool=false) -> void:
    var token: Array = TOKENS[role]
    control.set_meta("typography_role",role)
    control.add_theme_font_override("font",font(role))
    control.add_theme_font_size_override("font_size",token[2] if compact else token[1])
    control.add_theme_color_override("font_color",color)
    var strong: bool=role in ["display_xl","display_l","section_header","card_title"]
    control.add_theme_color_override("font_outline_color",Color("13233a") if on_world or color!=INK else INK)
    control.add_theme_constant_override("outline_size",3 if on_world else 1 if strong else 0)
    control.add_theme_color_override("font_shadow_color",Color(0,0,0,0.20) if on_world else Color.TRANSPARENT)
    control.add_theme_constant_override("shadow_offset_x",0)
    control.add_theme_constant_override("shadow_offset_y",1 if on_world else 0)
    control.add_theme_constant_override("line_spacing",token[4])
    if control is Label: control.uppercase = token[5] == "upper"

static func theme() -> Theme:
    if shared_theme != null: return shared_theme
    shared_theme = Theme.new()
    shared_theme.default_font = BODY
    shared_theme.default_font_size = 19
    for kind in ["Label","Button","TextEdit","LineEdit","TooltipLabel"]:
        shared_theme.set_font("font",kind,BODY)
        shared_theme.set_font_size("font_size",kind,17 if kind == "TooltipLabel" else 19)
    return shared_theme

static func equipment_name(id: String, full_name: String) -> String:
    if font("equipment_label").get_string_size(full_name,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x <= 72: return full_name
    # Stable, recognizable aliases; full identity remains in tooltip/build inspection.
    var aliases: Dictionary={"terminally-online":"Term.\nOnline", "main-character":"Main\nCharacter", "caught-4k":"Caught\nin 4K",
        "big-meme":"Big Meme\nEnergy", "timeline":"Across\nTimeline",
        "hands-on-sight":"Hands On\nSight", "no-cap-streak":"No Cap\nStreak",
        "let-him-cook":"Let Him\nCook", "big-chad":"Big Chad\nEnergy",
        "its-over":"It's So\nOver", "aura-viral":"Aura Goes\nViral",
        "so-back":"We Are\nSo Back", "six-to-seven":"Six →\nSeven",
        "too-sigma":"Too\nSigma"}
    var alias: String=str(aliases.get(id,full_name.replace(" ","\n")))
    # Source names stay complete in the Build screen; legacy 72px aliases must
    # remain stable under the larger Archivo text metrics if drawn in a tooltip.
    var lines: PackedStringArray=alias.split("\n")
    var adjusted: PackedStringArray=PackedStringArray()
    for raw_line in lines:
        var fragment: String=raw_line
        while fragment.length()>1 and font("equipment_label").get_string_size(fragment,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x>72.0:
            fragment=fragment.substr(0,fragment.length()-1)
        adjusted.append(fragment)
    return "\n".join(adjusted)
