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

# These are presentation asset keys, never new gameplay/profile hero IDs.
const FEMALE_ASSETS := {"sigma":"pixel-vixen", "cool-kid":"byte-baddie", "alpha":"block-queen"}

static func asset_slug(hero_id: String) -> String:
    return str(FEMALE_ASSETS.get(hero_id, ""))

static func asset_path(hero_id: String, usage: String) -> String:
    var slug := asset_slug(hero_id)
    var suffix: String = {"selection":"portrait", "hud":"hud", "atlas":"atlas"}.get(usage, "")
    if slug.is_empty() or suffix.is_empty(): return ""
    return "res://assets/art-candidates/%s/v2/%s-%s-v2.png" % [slug,slug,suffix]

static func manifest_path(hero_id: String) -> String:
    var slug := asset_slug(hero_id)
    return "" if slug.is_empty() else "res://assets/art-candidates/%s/v2/manifest.json" % slug

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
    if appearance != FEMALE or not FEMALE_ASSETS.has(hero_id): return false
    if not FileAccess.file_exists(manifest_path(hero_id)): return false
    if hero_id != "sigma" and not FileAccess.file_exists(manifest_path(hero_id).get_base_dir()+"/frames.json"): return false
    for usage in ["atlas", "selection", "hud"]:
        if not ResourceLoader.exists(asset_path(hero_id,usage)): return false
    return true
