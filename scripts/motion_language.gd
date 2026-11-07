extends RefCounted

## Proposed cosmetic motion only. No new frames, RNG, collision, hit geometry,
## combat deadlines, game-state fields, or save data.
const HEAVY := ["beta", "ratio-ram", "copium-puffer", "reply-guy",
    "mod-supremo", "ohio-express", "doomscroll-prime", "boss"]
const LIGHT := ["reply-goblin", "fanum-leech"]

static func neutral() -> Dictionary:
    return {"offset": Vector2.ZERO, "scale": Vector2.ONE, "rotation": 0.0}

static func hero_motion(id: String, pose: Dictionary, clock: float, travel: float, reduced: bool) -> Dictionary:
    if reduced: return neutral()
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
