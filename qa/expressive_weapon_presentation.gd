extends "res://scripts/weapon_presentation.gd"
## EXPERIMENTAL visual-only QA observer. The canonical weapon models,
## attack scheduling, projectile speed and damage are untouched.
const ID:="wave5-expressive-feedback-v1"
const IMPACT_LIFE:=0.32
const GESTURE_POST_LIFE:=0.42
const POSE_POST_LIFE:=0.34

func queued(model: Dictionary, clock: float, weapons: Array, shot: bool) -> void:
    super.queued(model,clock,weapons,shot)
    # Only retain already-authoritative gesture visuals for longer.
    var event: Dictionary=gestures[(gesture_cursor-1+MAX_GESTURES)%MAX_GESTURES]
    if not event["model"].is_empty():
        event["until"]=maxf(float(event["until"]),float(model["at"])+GESTURE_POST_LIFE)

func contact(id: String, enemy: Dictionary, point: Vector2, direction: Vector2,
        hp_before: float, shield_before: float, clock: float, weight: float=1.0) -> void:
    var before: int=impact_cursor
    super.contact(id,enemy,point,direction,hp_before,shield_before,clock,weight)
    if impact_cursor==before:return # No actual authoritative HP/shield change.
    var event: Dictionary=impacts[(impact_cursor-1+MAX_IMPACTS)%MAX_IMPACTS]
    event["until"]=clock+IMPACT_LIFE

func replaces(cue: Dictionary, clock: float) -> bool:
    var point: Vector2=cue["pos"]
    var slot: int=replaced_cues.get(Vector3(point.x,point.y,float(cue["at"])),-1)
    return slot>=0 and clock<float(impacts[slot]["until"])

func decorate_pose(state: Dictionary, clock: float) -> void:
    if bool(state.get("lost",false)) or float(state.get("hurt",0.0))>0.0 or float(state.get("flex",0.0))>0.0:
        return
    var event: Dictionary=current(clock)
    if event.is_empty():return
    var model: Dictionary=event["model"]
    var at:=float(model["at"])
    # The existing three approved hero attack frames are spread across a
    # longer visible period; simulation attack timestamps are unchanged.
    state["attack"]=0.22 if clock<at else maxf(0.001,0.22*(1.0-(clock-at)/POSE_POST_LIFE))
    var facing: Vector2=model.get("direction",model.get("facing",Vector2.RIGHT))
    state["facing"]=facing.angle()

func draw_impacts(canvas: CanvasItem, clock: float, reduced: bool) -> void:
    for event: Dictionary in impacts:
        var age:=clock-float(event["at"])
        if age<0.0 or clock>=float(event["until"]):continue
        var id: String=event["id"]
        var point: Vector2=event["point"]
        var fade:=clampf(1.0-age/IMPACT_LIFE,0.0,1.0)
        if bool(event["blocked"]):
            canvas.draw_arc(point,10,0,TAU,16,Color("4ea3ff",fade),2.5)
            continue
        var cell:=0 if id in ["no-cap","ban-hammer","chad-hands"] else 1 if id in ["ratio-blaster","keyboard-warrior","touch-grass"] else 2
        var extent: float=(30.0 if id in ["ban-hammer","chad-hands"] else 23.0)*float(event["weight"])
        if not reduced:extent*=1.0+0.18*sin(clampf(age/IMPACT_LIFE,0.0,1.0)*PI)
        canvas.draw_texture_rect_region(Art.IMPACTS,
            Rect2(point-Vector2.ONE*extent*0.5,Vector2.ONE*extent),
            Rect2(cell*64,0,64,64),Color(1,1,1,fade))
