extends RefCounted

## Presentation only. Canonical state precedence and deadlines remain unchanged.
const Canonical = preload("res://scripts/hero_animation.gd")
const SHEET := "cool-kid-cpk"
const CELL := 144
const ORIGIN := Vector2(72,120)
const DISPLAY_SCALE := 0.75 # 168 source pixels -> 84 atlas pixels -> 63 game pixels.

static func pose(state: Dictionary) -> Dictionary:
    var original := Canonical.pose("cool-kid",state)
    var phase: String = original["state"]
    var frame := int(fmod(float(state.get("time",0.0)),1.0)*7.0)
    var flip: bool = original["flip"]
    if phase == "run":
        # The approved board has side-running only, not rear/front artwork.
        # Preserve the existing 4/9-second gait cycle while using all seven poses.
        frame = 7+posmod(int(float(state.get("walk",0.0))*9.0*7.0/4.0),7)
        flip = cos(float(state.get("heading",0.0))) < 0.0
    elif phase == "attack":
        var remaining := float(state.get("attack",0.0))
        # decorate_pose holds 0.22 during the real windup and starts impact at
        # 0.145. Never show the bat's execution before the actual combat event.
        frame = 16 if remaining > 0.18 else 17 if remaining > 0.145 else 18 if remaining > 0.09 else 19 if remaining > 0.04 else 20
    elif phase == "hurt":
        frame = 22+clampi(int((0.18-float(state.get("hurt",0.0)))*6.0/0.18),0,5)
    elif phase == "flex-in":
        frame = 28+clampi(int(float(state.get("flex_age",0.0))*3.0/0.25),0,2)
    elif phase == "flex-out":
        frame = 33 if float(state.get("flex",0.0)) > 0.125 else 34
    elif phase == "flex-loop":
        frame = 31+posmod(int(float(state.get("flex_age",0.0))*2.0),2)
    elif phase == "defeat":
        # Same 0.375-second deadline as the old four poses at 8 fps.
        frame = 35+clampi(int(float(state.get("defeat",0.0))*6.0/0.375),0,6)
    return {"sheet":SHEET,"state":phase,"frame":frame,"flip":flip,"scale":DISPLAY_SCALE}

static func source_rect(frame: int) -> Rect2:
    return Rect2(posmod(frame,7)*CELL,int(frame/7)*CELL,CELL,CELL)
