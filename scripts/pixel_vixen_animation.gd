extends RefCounted

## Candidate cosmetic pose sampling for sigma's Pixel Vixen appearance.
## The actual No Cap / Deadpan Verdict combat logic remains unchanged.
## Atlas: 7x3, 52x58 cells. 0-6 idle/direction, 7-12 run,
## 13-15 attack, 16-17 Flex, 18-19 defeat.
static func pose(state: Dictionary) -> Dictionary:
    var frame := 0
    var label := "idle"
    var heading: float = float(state.get("heading",0.0))
    var facing: float = float(state.get("facing",0.0))
    var flip := cos(heading if state.get("moving",false) else facing) < 0.0
    if state.get("lost",false):
        label = "defeat"
        frame = 18 + mini(1,int(float(state.get("defeat",0.0))*6.0))
    elif float(state.get("hurt",0.0)) > 0.0:
        label = "hurt"
        frame = 2
    elif float(state.get("flex",0.0)) > 0.0:
        label = "flex-loop"
        frame = 16 + int(float(state.get("flex_age",0.0))*6.0)%2
        if float(state.get("flex_age",0.0)) < 0.25: label = "flex-in"
        if float(state.get("flex",0.0)) <= 0.25: label = "flex-out"
    elif float(state.get("attack",0.0)) > 0.0:
        label = "attack"
        frame = 13 + mini(2,int(maxf(0,0.22-float(state["attack"]))/(0.22/3.0)))
    elif state.get("moving",false):
        label = "run"
        frame = 7 + int(float(state.get("walk",0.0))*9.0)%6
    else:
        frame = posmod(int(round(facing/(PI/4.0))),7)
    return {"sheet":"pixel-vixen","frame":frame,"state":label,"flip":flip,"scale":1.12}
