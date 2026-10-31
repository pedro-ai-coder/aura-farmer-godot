class_name HeroAppearance
extends RefCounted

## Presentation-only identity mapping. Canonical hero IDs and combat kits never change.
## Female artwork is not yet available; this foundation must not use male poses
## to misrepresent an unfinished variant as playable.
const ORIGINAL := "original"
const FEMALE := "female"

const FEMALE_NAMES := {
    "sigma": "PIXEL VIXEN",
    "cool-kid": "BYTE BADDIE",
    "alpha": "BLOCK QUEEN"
}

static func is_valid(value: Variant) -> bool:
    return value is String and value in [ORIGINAL, FEMALE]

static func normalize(value: Variant) -> String:
    return value if is_valid(value) else ORIGINAL

static func display_name(hero_id: String, appearance: String, original_name: String) -> String:
    if appearance == FEMALE:
        return str(FEMALE_NAMES.get(hero_id, original_name))
    return original_name

static func can_start(appearance: String, hero_id: String = "sigma") -> bool:
    if appearance == ORIGINAL:
        return true
    # Pixel Vixen only: a reviewable art candidate with its own actual atlas.
    # Other female variants must not fall back to original/male gameplay art.
    return appearance == FEMALE and hero_id == "sigma" and ResourceLoader.exists("res://assets/art-candidates/pixel-vixen/v1/atlas.png")
