extends RefCounted
## Hand positions relative to the foot pivot, measured against immutable masters.
## Idle / anticipation / execution / recovery. Positive X faces right; transform
## X once using the approved pose flip. No font/text sprite is ever reflected.
const GRIPS := {
    "sigma:original":[Vector2(12,-24),Vector2(-14,-26),Vector2(27,-27),Vector2(16,-26)],
    "sigma:female":[Vector2(16,-26),Vector2(22,-20),Vector2(23,-26),Vector2(17,-26)],
    "cool-kid:original":[Vector2(9,-23),Vector2(-7,-49),Vector2(24,-25),Vector2(8,-14)],
    "cool-kid:female":[Vector2(12,-24),Vector2(-5,-46),Vector2(25,-29),Vector2(22,-24)],
    "alpha:original":[Vector2(18,-27),Vector2(16,-28),Vector2(23,-26),Vector2(24,-28)],
    "alpha:female":[Vector2(18,-29),Vector2(15,-30),Vector2(26,-28),Vector2(23,-29)]
}
static func grip(hero_id: String, appearance: String, stage: int, flip: bool) -> Vector2:
    var point: Vector2=GRIPS[hero_id+":"+appearance][clampi(stage,0,3)]
    return Vector2(-point.x,point.y) if flip else point

static func embedded(id: String, hero_id: String, appearance: String) -> bool:
    # Preserve existing authored keyboards, shields and gauntlets. Do not paint
    # a second unrelated weapon over those character-defining illustrations.
    return id in ["keyboard-warrior","cope-shield","chad-hands"] or (id=="ratio-blaster" and hero_id=="sigma" and appearance=="female")
