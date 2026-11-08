extends RefCounted

## Proposed cosmetic motion only. No new frames, RNG, collision, hit geometry,
## combat deadlines, game-state fields, or save data.
const HEAVY := ["beta", "ratio-ram", "copium-puffer", "reply-guy",
    "mod-supremo", "ohio-express", "doomscroll-prime", "boss"]
const LIGHT := ["reply-goblin", "fanum-leech"]

static func neutral() -> Dictionary:
    return {"offset": Vector2.ZERO, "scale": Vector2.ONE, "rotation": 0.0}

static func hero_motion(id: String, pose: Dictionary, clock: float, travel: float, reduced: bool, transitions: Dictionary = {}) -> Dictionary:
    if reduced: return neutral()
    # Pilot: distinctive motion for both authored appearances of the ranged kit.
    # Other hero kits retain V1 until separately reviewed.
    if id == "sigma":
        return _ranged_motion(pose,clock,travel,transitions)
    var phase: String = str(pose.get("state", "idle"))
    var weight: float = 0.72 if id == "alpha" else 1.12 if id == "cool-kid" else 1.0
    var offset := Vector2.ZERO
    var stretch := Vector2.ONE
    var tilt := 0.0
    if phase == "run":
        # Travel-driven, not wall-time-driven: a blocked hero does not walk in place.
        var cycle: float = travel * TAU * 2.25
        var step: float = absf(sin(cycle))
        offset.y = -1.4 * weight * step
        stretch = Vector2(1.0 + 0.019 * weight * step, 1.0 - 0.025 * weight * step)
        tilt = sin(cycle) * 0.020 * weight
    elif phase == "idle":
        var breathe: float = sin(clock * (2.1 if id == "alpha" else 2.65))
        stretch = Vector2(1.0 - 0.012 * weight * breathe, 1.0 + 0.014 * weight * breathe)
        offset.y = -0.35 * weight * (1.0 + breathe)
    elif phase == "attack":
        # Original authored attack frames remain responsible for each strike.
        stretch = Vector2(1.0 + 0.030 * weight, 1.0 - 0.028 * weight)
        tilt = (-1.0 if bool(pose.get("flip",false)) else 1.0) * 0.017 * weight
    elif phase.begins_with("flex"):
        var pulse: float = 0.5 + 0.5 * sin(clock * 7.0)
        stretch = Vector2(1.0 + 0.013 * weight * pulse, 1.0 - 0.011 * weight * pulse)
        offset.y = -0.6 * weight * pulse
    elif phase == "hurt":
        stretch = Vector2(1.0 + 0.038 * weight, 1.0 - 0.036 * weight)
        offset.x = 0.9 if bool(pose.get("flip",false)) else -0.9
    elif phase == "defeat":
        stretch = Vector2(1.0 + 0.025 * weight, 1.0 - 0.040 * weight)
        offset.y = 1.0 * weight
    return {"offset":offset, "scale":stretch, "rotation":tilt}


## Ranged motion pilot: deliberately more readable than the V1 micro-bounce.
## Coordinates are local presentation offsets around the existing foot pivot.
## `transitions` comes exclusively from visual-only clocks, not simulated stats.
static func _ranged_motion(pose: Dictionary, clock: float, travel: float, context: Dictionary) -> Dictionary:
    var phase: String = str(pose.get("state","idle"))
    var heading: float = float(context.get("heading",0.0))
    var start_age: float = float(context.get("start_age",1000.0))
    var stop_age: float = float(context.get("stop_age",1000.0))
    var turn_age: float = float(context.get("turn_age",1000.0))
    var turn_sign: float = float(context.get("turn_sign",0.0))
    var female: bool = str(context.get("appearance","original")) == "female"
    var weight: float = 0.88 if female else 1.0
    var offset := Vector2.ZERO
    var scale := Vector2.ONE
    var rotation := 0.0
    if phase == "run":
        # Keep the leg cycle tied to distance actually travelled, not wall time.
        var cycle: float = travel * TAU * 2.7
        var stride: float = sin(cycle)
        var plant: float = absf(stride)
        var launch: float = 1.0-smoothstep(0.0,0.14,start_age)
        var turn: float = 1.0-smoothstep(0.0,0.18,turn_age)
        var horizontal: float = cos(heading)
        offset = Vector2(-3.1*horizontal*launch, -3.4*plant + 2.2*launch) * weight
        scale = Vector2(1.0 + weight*(0.047*plant - 0.060*launch),
            1.0 + weight*(-0.049*plant + 0.065*launch))
        rotation = weight*(0.065*horizontal + 0.026*stride + 0.055*turn_sign*turn)
    elif phase == "idle":
        # Visible plant-and-settle after releasing movement, then restrained idle.
        var settle: float = 1.0-smoothstep(0.0,0.22,stop_age)
        var breathe: float = sin(clock*(2.35 if female else 2.65))
        var sway: float = sin(clock*1.45)
        offset = Vector2(0.80*sway,-0.65*(1.0+breathe)+2.3*settle)*weight
        scale = Vector2(1.0+weight*(0.012*breathe+0.080*settle),
            1.0+weight*(-0.018*breathe-0.064*settle))
        rotation = weight*(0.012*sway-0.055*cos(heading)*settle)
    elif phase == "attack":
        # The canonical 0.22s attack poses and actual hits still own timing.
        var side: float = -1.0 if bool(pose.get("flip",false)) else 1.0
        offset = Vector2(-2.4*side,1.5)*weight
        scale = Vector2(1.0+0.062*weight,1.0-0.055*weight)
        rotation = side*0.052*weight
    elif phase.begins_with("flex"):
        var pulse: float = 0.5+0.5*sin(clock*8.0)
        offset.y = -1.7*weight*pulse
        scale = Vector2(1.0+0.030*weight*pulse,1.0-0.024*weight*pulse)
    elif phase == "hurt":
        offset.x = (2.5 if bool(pose.get("flip",false)) else -2.5)*weight
        scale = Vector2(1.0+0.052*weight,1.0-0.055*weight)
    elif phase == "defeat":
        scale = Vector2(1.0+0.025*weight,1.0-0.042*weight)
        offset.y = 1.0*weight
    return {"offset":offset,"scale":scale,"rotation":rotation}

static func enemy_motion(enemy: Dictionary, clock: float, death_age: float, reduced: bool) -> Dictionary:
    if reduced or death_age >= 0.0: return neutral()
    var kind: String = str(enemy.get("kind","npc"))
    var phase: String = str(enemy.get("phase",""))
    if kind == "terminal" or phase in ["warning","charge-warning","charging"]:
        # Hostile attack danger cues stay aligned to real collision/hit frames.
        return neutral()
    var weight: float = 0.58 if kind in HEAVY else 1.22 if kind in LIGHT else 1.0
    var offset := Vector2.ZERO
    var stretch := Vector2.ONE
    var tilt := 0.0
    var attack: Dictionary = enemy.get("attack_pose",{})
    if not attack.is_empty() and clock >= float(attack.get("start",INF)) and clock < float(attack.get("end",-INF)):
        var impact: float = float(attack.get("impact",clock))
        if clock < impact:
            var lead: float = clampf((clock-float(attack["start"]))/maxf(0.01,impact-float(attack["start"])),0.0,1.0)
            stretch = Vector2(1.0 - 0.022 * weight * lead,1.0 + 0.018 * weight * lead)
            tilt = (1.0 if cos(float(attack.get("angle",0.0))) >= 0.0 else -1.0) * 0.012 * weight * lead
        else:
            var recover: float = 1.0-clampf((clock-impact)/maxf(0.01,float(attack["end"])-impact),0.0,1.0)
            stretch = Vector2(1.0 + 0.025 * weight * recover,1.0 - 0.020 * weight * recover)
    elif clock < float(enemy.get("stagger_until",-INF)) or clock-float(enemy.get("hurt_at",-INF)) < 0.16:
        stretch = Vector2(1.0 + 0.026 * weight,1.0 - 0.025 * weight)
    elif bool(enemy.get("anim_moving",false)):
        var cycle: float = float(enemy.get("anim_walk",0.0)) * PI * 0.5
        var step: float = absf(sin(cycle))
        offset.y = -1.25 * weight * step
        stretch = Vector2(1.0 + 0.015 * weight * step,1.0 - 0.021 * weight * step)
        tilt = sin(cycle) * 0.018 * weight
    else:
        # Stable actor ID dephases the crowd without using gameplay RNG.
        var id_phase: float = float(posmod(int(enemy.get("id",0)),7)) * 0.58
        var breathe: float = sin(clock * (2.0 if weight < 0.7 else 2.6) + id_phase)
        stretch = Vector2(1.0 - 0.007 * weight * breathe,1.0 + 0.010 * weight * breathe)
        offset.y = -0.30 * weight * (1.0+breathe)
    return {"offset":offset,"scale":stretch,"rotation":tilt}
