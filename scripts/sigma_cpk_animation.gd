extends RefCounted

## Presentation only: use the unchanged Sigma state precedence and deadlines.
const Canonical = preload("res://scripts/hero_animation.gd")
const SHEET := "sigma-cpk"
const CELL := 144
const ORIGIN := Vector2(72,120)
const DISPLAY_SCALE := 0.72

static func pose(state: Dictionary) -> Dictionary:
    var original := Canonical.pose("sigma",state)
    var phase: String = original["state"]
    var frame := posmod(int(float(state.get("time",0.0))*7.0),7)
    var flip: bool = original["flip"]
    if phase == "run":
        frame = 7+posmod(int(float(state.get("walk",0.0))*9.0*7.0/4.0),7)
        flip = cos(float(state.get("heading",0.0))) < 0.0
    elif phase == "attack":
        frame = 21+clampi(int((0.22-float(state.get("attack",0.0)))*7.0/0.22),0,6)
    elif phase == "hurt":
        frame = 28+clampi(int((0.18-float(state.get("hurt",0.0)))*7.0/0.18),0,6)
    elif phase == "flex-in":
        frame = 35+clampi(int(float(state.get("flex_age",0.0))*3.0/0.25),0,2)
    elif phase == "flex-loop":
        frame = 37+posmod(int(float(state.get("flex_age",0.0))*4.0),3)
    elif phase == "flex-out":
        frame = 40 if float(state.get("flex",0.0)) > 0.125 else 41
    elif phase == "defeat":
        frame = 42+clampi(int(float(state.get("defeat",0.0))*6.0/0.375),0,6)
    return {"sheet":SHEET,"state":phase,"frame":frame,"flip":flip,"scale":DISPLAY_SCALE}

static func source_rect(frame: int) -> Rect2:
    return Rect2(posmod(frame,7)*CELL,int(frame/7)*CELL,CELL,CELL)
