extends RefCounted

## Cosmetic playback only. Canonical state precedence/flip/Flex phase remains
## owned by hero_animation.gd. No combat definitions, events, input or RNG here.
const Canonical = preload("res://scripts/hero_animation.gd")
const Vixen = preload("res://scripts/pixel_vixen_animation.gd")
const Appearance = preload("res://scripts/hero_appearance.gd")

static func pose(hero_id: String, state: Dictionary) -> Dictionary:
    if hero_id == "sigma": return Vixen.pose(state)
    var original := Canonical.pose(hero_id,state)
    var phase: String = original["state"]
    var row := 0
    var step := posmod(int(float(state.get("time",0.0))*2.0),4)
    if phase == "run":
        row=1;step=posmod(int(float(state.get("walk",0.0))*9.0),4)
    elif phase == "attack":
        row=2;step=clampi(int((0.22-float(state.get("attack",0.0)))*4.0/0.22),0,3)
    elif phase == "hurt":
        row=3;step=clampi(int((0.18-float(state.get("hurt",0.0)))*4.0/0.18),0,3)
    elif phase.begins_with("flex"):
        row=4
        # Follow the original hero's authored beat/slam presentation, rather
        # than showing extra slams unrelated to canonical Flex events.
        if hero_id == "alpha": step=int({41:1,42:0,43:1,44:1,45:2,46:3,47:0}.get(int(original["frame"]),0))
        else: step=clampi(int(original["frame"])-26,0,2)
        if phase == "flex-out": step=3
    elif phase == "defeat":
        row=5;step=mini(3,int(float(state.get("defeat",0.0))*8.0))
    return {"sheet":Appearance.asset_slug(hero_id),"state":phase,
        "frame":row*4+step,"flip":bool(original["flip"])}
