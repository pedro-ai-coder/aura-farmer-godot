extends RefCounted

const SigmaAnimation = preload("res://scripts/hero_animation.gd")

## Pixel Vixen uses Sigma's canonical attack and Flex state machine.
## Only the sprite index changes; all gameplay timing and RNG stay untouched.
## V2: seven columns x seven rows (idle, run A, run B, attack,
## hurt, Flex, defeat). All indices are zero-based and deterministic.
static func pose(state: Dictionary) -> Dictionary:
    var sigma_pose: Dictionary = SigmaAnimation.pose("sigma",state)
    var phase: String = str(sigma_pose["state"])
    var frame: int = 0
    var legacy: int = 0

    match phase:
        "defeat":
            var step: int = mini(6,int(float(state.get("defeat",0.0))*9.0))
            frame = 42 + step
            legacy = 18 + mini(1,int(float(state.get("defeat",0.0))*6.0))
        "hurt":
            var hurt_step: int = 3 if float(state.get("hurt",0.0)) < 0.09 else 0
            frame = 28 + hurt_step
            legacy = 2
        "flex-in", "flex-loop", "flex-out":
            var flex_step: int = posmod(int(float(state.get("flex_age",0.0))*8.0),7)
            if phase == "flex-in":
                flex_step = mini(2,flex_step)
            elif phase == "flex-out":
                flex_step = 5 + mini(1,flex_step%2)
            frame = 35 + flex_step
            legacy = 16 + flex_step%2
        "attack":
            var elapsed: float = maxf(0.0,0.22-float(state.get("attack",0.0)))
            var attack_step: int = clampi(int(elapsed*7.0/0.22),0,6)
            frame = 21 + attack_step
            legacy = 13 + mini(2,int(elapsed*3.0/0.22))
        "run":
            var run_step: int = posmod(int(float(state.get("walk",0.0))*9.0),7)
            var heading: float = float(state.get("heading",0.0))
            frame = (14 if cos(heading) < 0.0 else 7) + run_step
            legacy = 7 + run_step%6
        _:
            frame = posmod(int(float(state.get("time",0.0))*2.0),7)
            legacy = frame

    return {
        "sheet":"pixel-vixen",
        "state":phase,
        "frame":frame,
        "legacy_frame":legacy,
        "flip":bool(sigma_pose["flip"]),
        "scale":64.0/96.0,
        "legacy_scale":1.60
    }
