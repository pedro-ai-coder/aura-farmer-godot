class_name CleanCutTypography
extends RefCounted

## Shared runtime typography rules. Reuses the repository's existing licensed font assets.
const Style = preload("res://scripts/arcade_theme.gd")
const ROLES = {
    "display": {"font": "display", "size": 38},
    "section": {"font": "black", "size": 26},
    "card_title": {"font": "black", "size": 26},
    "button": {"font": "black", "size": 20},
    "hud_value": {"font": "numbers", "size": 18},
    "hud_label": {"font": "black", "size": 15},
    "body": {"font": "body", "size": 18},
    "caption": {"font": "body", "size": 15},
    "micro": {"font": "numbers", "size": 13}
}

static func size_for(role: String, compact: bool = false) -> int:
    var entry: Dictionary = ROLES.get(role, ROLES["body"])
    var pixels: int = int(entry["size"])
    return maxi(12, pixels - (6 if role == "display" and compact else 3 if compact else 0))

static func apply(label: Label, role: String, compact: bool = false) -> void:
    var entry: Dictionary = ROLES.get(role, ROLES["body"])
    label.add_theme_font_override("font", Style.font(str(entry["font"])))
    label.add_theme_font_size_override("font_size", size_for(role, compact))
    label.add_theme_constant_override("outline_size", 0)
    label.add_theme_constant_override("shadow_offset_x", 0)
    label.add_theme_constant_override("shadow_offset_y", 0)
    label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)

static func button(button: Button, compact: bool = false) -> void:
    button.add_theme_font_override("font", Style.font("black"))
    button.add_theme_font_size_override("font_size", size_for("button", compact))
    button.clip_text = true
    button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
