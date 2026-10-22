extends RefCounted

## Pure playback of the approved Phaser hero poses. No simulation or RNG changes.
static func pose(id: String, state: Dictionary) -> Dictionary:
    var cool := id == "cool-kid"
    var alpha := id == "alpha"
    var frame := 0
    var sheet := "atlas"
    var label := "idle"
    var flip := cos(float(state.get("facing", 0.0))) < 0.0
    var moving: bool = state.get("moving", false)
    var heading: float = state.get("heading", 0.0)
    var age: float = state.get("flex_age", 0.0)
    var remaining: float = state.get("flex", 0.0)
    var walk: float = state.get("walk", 0.0)
    if state.get("lost", false):
        frame = [29,30,31,32][mini(3,int(float(state.get("defeat",0.0))*8))] if cool else [37,38,39,40][mini(3,int(float(state.get("defeat",0.0))*8))]
        label = "defeat"
    elif float(state.get("hurt",0.0)) > 0.0:
        label = "hurt"
        if cool and remaining > 0:
            frame = 6
            sheet = "flex-v2"
            flip = cos(heading) < 0
        else: frame = (29 if cool else 37) + (1 if 0.18-float(state["hurt"]) >= 0.09 else 0)
    elif remaining > 0:
        label = "flex-loop"
        if cool:
            sheet = "flex-v2"
            flip = cos(heading if moving else float(state.get("facing",0.0))) < 0
            if age < 0.25:
                frame = int(age*8)
                label = "flex-in"
            elif remaining <= 0.25:
                frame = 6 if remaining > 0.125 else 7
                label = "flex-out"
            else: frame = 2+int(walk*11.25)%4 if moving else 1
        elif alpha:
            var phase := fmod(age,2.0)
            frame = 44 if phase < 0.125 else 45 if phase < 0.25 else 46 if phase < 0.4 else 43 if age < 4 and phase > 1.875 else 41 if age < 4 and phase > 1.75 else 42
            if age < 0.4: label = "flex-in"
            if remaining <= 0.25:
                frame = 46 if remaining > 0.125 else 47
                label = "flex-out"
        elif age < 0.25:
            frame = 41+int(age*8)
            label = "flex-in"
        elif remaining <= 0.25:
            frame = 46 if remaining > 0.125 else 47
            label = "flex-out"
        else: frame = 43+int((age-0.25)*8)%4
    elif float(state.get("attack",0.0)) > 0:
        frame = (26 if cool else 34)+mini(2,int(maxf(0,0.22-float(state["attack"]))/ (0.22/3)))
        label = "attack"
    elif moving:
        label = "run"
        var direction := posmod(int(round(heading/(PI/4))),8)
        var step := int(walk*9)%4
        if alpha and direction >= 5:
            sheet = "rear-v2"
            frame = int([8,4,0][direction-5])+step
            flip = false
        elif cool and direction == 6:
            sheet = "rear-v2"
            frame = step
            flip = false
        else:
            var groups: Array = [0,4,8,12,16,20,24,28]
            if cool: groups = [0,4,8,12,0,16,0,20]
            elif alpha: groups = [0,8,16,24,0,0,0,0]
            frame = int(groups[direction])+step
            flip = direction == 4 if cool or alpha else direction == 5
    else: frame = (24 if cool else 32)+int(float(state.get("time",0.0))*2)%2
    var scale := 84.0/377 if sheet == "flex-v2" else (64.0/328 if alpha else 64.0/648) if sheet == "rear-v2" else 64.0/(208 if cool else 171 if alpha else 176)
    return {"frame":frame,"sheet":sheet,"state":label,"flip":flip,"scale":scale}
