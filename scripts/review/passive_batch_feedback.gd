extends "res://scripts/passive_feedback.gd"
## EXPERIMENTAL presentation adapter. Existing authoritative callbacks only.
const IDS := ["big-chad", "too-sigma", "so-back", "w-squad", "absolute-cinema"]
const TIMING := {"big-chad": [0.09,0.64], "too-sigma": [0.16,0.88],
    "so-back": [0.20,0.80], "w-squad": [0.12,0.72], "absolute-cinema": [0.055,0.56]}
const PROFILES := [[0.16,220.0,70.0,0.24], [0.22,110.0,390.0,0.12],
    [0.11,660.0,1320.0,0.02], [0.17,440.0,880.0,0.05], [0.19,190.0,760.0,0.20]]
var textures: Dictionary = {}
var bursts: Array[Dictionary] = []
var shields: Dictionary = {}
var recorder: RefCounted
var event_count := 0

func install(game, observer: RefCounted) -> void:
    recorder = observer
    suppress_six_to_seven_ring = true
    for i in IDS.size():
        textures[IDS[i]] = load("res://assets/experimental/passive-batch-01/%s.png" % IDS[i])
        if game.combat_audio != null and game.combat_audio.playback_enabled:
            var key: String = "batch_" + IDS[i]
            if not game.combat_audio.clips.has(key):
                game.combat_audio.clips[key] = game.combat_audio.make_clip(PROFILES[i])

func reset() -> void:
    super.reset()
    bursts.clear()
    shields.clear()
    event_count = 0

func _event(game, id: String, kind: String, amount: float = 0.0) -> void:
    if id not in IDS or game.mode != "playing": return
    if bursts.size() >= 8: bursts.pop_front()
    bursts.append({"id":id,"kind":kind,"at":game.run_time,"pos":game.player_pos,"value":amount})
    event_count += 1
    var data := {"id":id,"kind":kind,"value":amount,"at":game.run_time}
    if recorder != null: recorder.event(game,"passive_vfx",data)
    print("Batch VFX event: ", JSON.stringify(data))
    if kind in ["shield","heal","flex"] and game.combat_audio != null:
        game.combat_audio.play_event("batch_"+id,game.run_time,3)

func shield_granted(game, source: String, amount: float, duration: float) -> void:
    super.shield_granted(game,source,amount,duration)
    if source not in ["big-chad","too-sigma"] or amount <= 0.0: return
    shields[source] = {"remaining":amount,"until":game.run_time+duration}
    _event(game,source,"shield",amount)

func healed(game, source: String, effective: float) -> void:
    super.healed(game,source,effective)
    # Shield acquisition never produces a restoration plume. Only actual HP restored.
    if source == "so-back" and effective > 0.0: _event(game,source,"heal",effective)

func absorbed(game, amount: float) -> void:
    super.absorbed(game,amount)
    if amount <= 0.0: return
    for id: String in shields:
        var remaining: float = game.weapon_shields.get(id,{}).get("remaining",0.0)
        var consumed: float = maxf(0.0,float(shields[id].remaining)-remaining)
        if consumed > 0.0:
            _event(game,id,"absorb",consumed)
            shields[id].remaining = remaining

func flex_started(game) -> void:
    super.flex_started(game)
    for id in ["w-squad","absolute-cinema"]:
        if game._passive_level(id) > 0: _event(game,id,"flex")

func synchronize(game) -> void:
    super.synchronize(game)
    if game.mode != "playing": return
    for i in range(bursts.size()-1,-1,-1):
        if game.run_time-float(bursts[i].at) >= float(TIMING[bursts[i].id][1]): bursts.remove_at(i)
    for id: String in shields.keys():
        var entry: Dictionary = game.weapon_shields.get(id,{})
        var remaining: float = entry.get("remaining",0.0)
        if entry.is_empty() or remaining <= 0.0 or game.run_time >= float(entry.get("until",0.0)):
            _event(game,id,"end")
            shields.erase(id)
        else: shields[id] = entry.duplicate()

func _sprite(canvas: CanvasItem, id: String, point: Vector2, extent: Vector2, alpha: float, angle: float = 0.0) -> void:
    var texture: Texture2D = textures.get(id)
    if texture == null or alpha <= 0.0: return
    canvas.draw_set_transform(point,angle)
    canvas.draw_texture_rect(texture,Rect2(-extent*0.5,extent),false,Color(1,1,1,alpha))
    canvas.draw_set_transform(Vector2.ZERO)

func draw_ground(game, canvas: CanvasItem) -> void:
    super.draw_ground(game,canvas)
    var reduced: bool = game.profile.settings.reducedMotion
    var now: float = game.run_time
    # Status artwork follows real remaining protection and stored deadlines.
    for id: String in shields:
        var remaining: float = game.weapon_shields.get(id,{}).get("remaining",0.0)
        if remaining <= 0.0 or now >= float(shields[id].until): continue
        var fade := clampf((float(shields[id].until)-now)/0.35,0.0,1.0)
        var size := Vector2(112,94) if id == "big-chad" else Vector2(94,128)
        _sprite(canvas,id,game.player_pos+Vector2(0,-7),size,0.60*fade)
    if game._passive_level("w-squad") > 0 and now < float(game.passive_timers.get("w_squad_until",0.0)):
        var fade := clampf((float(game.passive_timers.w_squad_until)-now)/0.35,0.0,1.0)
        _sprite(canvas,"w-squad",game.player_pos+Vector2(-54,12),Vector2(82,64),0.62*fade,-0.12)
    if game._passive_level("absolute-cinema") > 0 and game.flex_time > 0.0:
        _sprite(canvas,"absolute-cinema",game.player_pos+Vector2(0,12),Vector2(102,102),0.40*clampf(game.flex_time/0.4,0,1),-0.25)
    for effect: Dictionary in bursts:
        var age: float = now-float(effect.at)
        var timing: Array = TIMING[effect.id]
        var life: float = timing[1]
        if age < 0.0 or age >= life: continue
        var punch := 1.0-pow(1.0-clampf(age/float(timing[0]),0.0,1.0),4.0)
        var fade := 1.0-smoothstep(float(timing[0]),life,age)
        var point: Vector2 = effect.pos
        var extent := Vector2(140,115)
        var angle := 0.0
        match str(effect.id):
            "big-chad":
                extent = Vector2(142,112)
                point += Vector2(0,8)
            "too-sigma":
                extent = Vector2(125,170)
                point += Vector2(0,-13)
            "so-back":
                extent = Vector2(106,142)
                point += Vector2(18,-13 if reduced else -13-37*smoothstep(0.0,life,age))
                angle = -0.15
            "w-squad":
                extent = Vector2(180,110)
                point += Vector2(-22,10)
                angle = -0.12
            "absolute-cinema":
                extent = Vector2(168,168)
                angle = -0.25 if reduced else lerpf(-0.43,-0.25,punch)
        if effect.kind == "absorb":
            extent *= 0.66
            point += Vector2(23,-12)
            fade *= 0.85
        elif effect.kind == "end":
            extent *= 0.80
            fade *= 0.36
        var scale := 1.0 if reduced else lerpf(0.42,1.05,punch)*(1.0+0.07*smoothstep(0.20,life,age))
        if effect.id == "w-squad" and not reduced:
            extent.y *= lerpf(0.76,1.0,punch)
        # Two briefly misregistered ink impressions give activation weight without glow.
        if age < 0.10 and effect.kind not in ["end","absorb"]:
            _sprite(canvas,effect.id,point+Vector2(-4,3),extent*scale*1.13,fade*0.28,angle)
        _sprite(canvas,effect.id,point,extent*scale,fade*(0.68 if reduced else 0.94),angle)
