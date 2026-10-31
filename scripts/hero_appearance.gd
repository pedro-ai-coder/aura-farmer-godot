class_name HeroAppearance
extends RefCounted

## Presentation-only identity mapping. Canonical hero IDs and combat kits never change.
## A female appearance is playable only when its real V2 visual assets exist.
## Never present original male artwork as a substitute.
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
    # Female Sigma is playable only when every V2 runtime asset is really included
    # in the exported build. The older 36x40 V1 preview is never a fallback.
    const VIXEN_DIR := "res://assets/art-candidates/pixel-vixen/v2/"
    return (
        appearance == FEMALE
        and hero_id == "sigma"
        and ResourceLoader.exists(VIXEN_DIR + "pixel-vixen-atlas-v2.png")
        and ResourceLoader.exists(VIXEN_DIR + "pixel-vixen-portrait-v2.png")
        and ResourceLoader.exists(VIXEN_DIR + "pixel-vixen-hud-v2.png")
    )
