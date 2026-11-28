extends RefCounted

const Atlases = preload("res://scripts/full_hero_atlases.gd")
const Choreography = preload("res://scripts/entrance_choreography.gd")
# Candidate lines and presentation-only pose timing. The frames belong to the
# selected approved atlas, and do not execute an attack or Flex.
const SIGNATURES := {
    "the-sigma": ["Keep watching.", 0.15, 0.28],
    "pixel-vixen": ["Stay in my frame.", 0.02, 0.25],
    "cool-kid": ["Try to keep up.", 0.02, 0.51],
    "byte-baddie": ["I set the tempo.", 0.08, 0.48],
    "alpha-chad": ["Make some room.", 0.13, 0.36],
    "block-queen": ["I hold this ground.", 0.18, 0.36],
}

static func signature(hero_id: String, appearance: String) -> Array:
    return SIGNATURES[Atlases.slug(hero_id, appearance)]

static func draw(atlases, canvas: CanvasItem, feet: Vector2, direction: float, hero_id: String, appearance: String, shot: int, age: float, reduced: bool) -> void:
    var phase := "idle"
    var pose_age := 0.0
    if shot == 0 or (shot == 1 and age < 3.10):
        phase = "idle" if reduced else "run"
    elif shot == 2:
        phase = "flex-in"
        var style := signature(hero_id, appearance)
        pose_age = float(style[2]) if reduced else clampf(age - Choreography.SIGNATURE - float(style[1]), 0.0, float(style[2]))
    var heading := direction if shot < 2 else PI * 0.5
    atlases.draw(canvas, feet, hero_id, appearance, {"state": phase}, {
        "heading": heading, "facing": heading, "walk": age * 0.78, "time": age,
        "flex_age": pose_age, "reduced_motion": reduced,
    })
