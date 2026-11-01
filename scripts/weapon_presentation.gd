extends RefCounted
## Read-only observer of queued attacks and actual resolved contacts. Fixed pools
## are separate from serialized simulation state. No callbacks into gameplay.
const Art=preload("res://scripts/weapon_presence_art.gd")
const Attach=preload("res://scripts/weapon_attachments.gd")
const INK=Color("13233a")
const PAPER=Color("fff9e9")
const GOLD=Color("f8c45f")
const TEAL=Color("6eaab0")
const MAX_GESTURES=24
const MAX_IMPACTS=48
const SHIELD_SOURCES=["cope-shield","unbothered","my-aura"]
const PROP_GRIPS={"ratio-blaster":Vector2(99,181),"brainrot-feed":Vector2(128,193),"ban-hammer":Vector2(196,209),"touch-grass":Vector2(51,209)}
var gestures: Array[Dictionary]=[]
var impacts: Array[Dictionary]=[]
var reactions: Dictionary={}
var replaced_cues: Dictionary={}
var grades: Dictionary={}
var gesture_cursor:=0
var impact_cursor:=0
var emitted_contacts:=0

func _init() -> void:
    for i in range(MAX_GESTURES):gestures.append({"until":-1.0,"model":{},"id":"","queued":0.0,"level":1,"legendary":false,"shot":false})
    for i in range(MAX_IMPACTS):impacts.append({"until":-1.0,"at":0.0,"id":"","enemy":-1,"point":Vector2.ZERO,"direction":Vector2.RIGHT,"blocked":false,"weight":1.0,"cue_key":Vector3.ZERO})

func reset() -> void:
    for event in gestures:event["until"]=-1.0;event["model"]={}
    for event in impacts:event["until"]=-1.0
    reactions.clear();replaced_cues.clear();grades.clear();gesture_cursor=0;impact_cursor=0;emitted_contacts=0

func queued(model: Dictionary, clock: float, weapons: Array, shot: bool) -> void:
    var event: Dictionary=gestures[gesture_cursor]
    gesture_cursor=(gesture_cursor+1)%MAX_GESTURES
    event["id"]=str(model["id"]);event["model"]=model;event["queued"]=clock
    event["until"]=float(model["at"])+0.28;event["shot"]=shot
    event["level"]=1;event["legendary"]=false
    for weapon: Dictionary in weapons:
        if weapon["id"]==model["id"]:event["level"]=int(weapon["level"]);event["legendary"]=weapon["rarity"]=="legendary";break
    grades[event["id"]]=1.0+0.04*clampi(int(event["level"])-1,0,3)+(0.08 if event["legendary"] else 0.0)

func synchronize(areas: Array, shots: Array, clock: float) -> void:
    # Cancellation (e.g. encounter transition) cannot become a cosmetic attack.
    for event in gestures:
        if clock>float(event["until"]):continue
        var model: Dictionary=event["model"]
        if model.is_empty():continue
        var unresolved: bool=clock<float(model["at"]) if event["shot"] else not bool(model["impact_shown"])
        if unresolved and not (shots.has(model) if event["shot"] else areas.has(model)):
            event["until"]=-1.0;event["model"]={}

func contact(id: String, enemy: Dictionary, point: Vector2, direction: Vector2, hp_before: float, shield_before: float, clock: float, weight: float=1.0) -> void:
    var hp_changed:=float(enemy["hp"])<hp_before
    var shield_changed:=float(enemy.get("shield",0.0))<shield_before
    if not hp_changed and not shield_changed:return
    var slot:=impact_cursor;var event: Dictionary=impacts[slot]
    var old_id: int=event["enemy"]
    if reactions.get(old_id,-1)==slot:reactions.erase(old_id)
    if replaced_cues.get(event["cue_key"],-1)==slot:replaced_cues.erase(event["cue_key"])
    impact_cursor=(impact_cursor+1)%MAX_IMPACTS
    event["at"]=clock;event["until"]=clock+0.18;event["id"]=id;event["enemy"]=int(enemy["id"])
    event["point"]=point+Vector2(0,-22);event["direction"]=direction.normalized()
    # Only compact contact detail strengthens with real level/rarity. The
    # authoritative sector, pulse radius and projectile collision never grow.
    event["blocked"]=not hp_changed;event["weight"]=clampf(weight*float(grades.get(id,1.0)),1.0,1.3)
    reactions[int(enemy["id"])]=slot;emitted_contacts+=1
    event["cue_key"]=Vector3(point.x,point.y-18,clock)
    replaced_cues[event["cue_key"]]=slot

func replaces(cue: Dictionary, clock: float) -> bool:
    var point: Vector2=cue["pos"]
    var slot: int=replaced_cues.get(Vector3(point.x,point.y,float(cue["at"])), -1)
    return slot>=0 and clock<float(impacts[slot]["at"])+0.20

func reaction(enemy: Dictionary, clock: float, reduced: bool) -> Vector2:
    if reduced or not reactions.has(int(enemy["id"])) or str(enemy["phase"]) in ["warning","charge-warning","charging"] or enemy["kind"]=="boss":return Vector2.ZERO
    var event: Dictionary=impacts[reactions[int(enemy["id"])]]
    var age:=clock-float(event["at"])
    if age<0.0 or age>0.14 or event["blocked"]:return Vector2.ZERO
    return Vector2(event["direction"])*2.5*(1.0-age/0.14)

func current(clock: float) -> Dictionary:
    var selected: Dictionary={};var latest:=-INF;var upcoming: Dictionary={};var earliest:=INF
    for event in gestures:
        if clock>float(event["until"]):continue
        var model: Dictionary=event["model"]
        if model.is_empty() or (not bool(model.get("primary",true)) and not event["shot"]):continue
        var at: float=model["at"]
        if not event["shot"] and clock>=at and not bool(model["impact_shown"]):continue
        if bool(model.get("second",false)) and clock<at:continue
        if clock>=at and at>=latest:selected=event;latest=at
        elif clock<at and at<earliest:upcoming=event;earliest=at
    # A meaningful queued windup owns the hand once the previous strike resolves.
    if not upcoming.is_empty() and (selected.is_empty() or clock-latest>0.15):return upcoming
    return selected

static func stage(event: Dictionary, clock: float) -> int:
    var at: float=event["model"]["at"]
    return 1 if clock<at else 2 if clock-at<0.10 else 3

func decorate_pose(state: Dictionary, clock: float) -> void:
    # Only solo_run's fresh, local animation descriptor is edited. In particular
    # visual_facing (also used by canonical Flex aim) must never be written here.
    if bool(state.get("lost",false)) or float(state.get("hurt",0.0))>0 or float(state.get("flex",0.0))>0:return
    var event:=current(clock)
    if event.is_empty():return
    var model: Dictionary=event["model"];var at: float=model["at"]
    state["attack"]=0.22 if clock<at else maxf(0.001,0.145-(clock-at)*0.52)
    var facing: Vector2=model.get("direction",model.get("facing",Vector2.RIGHT))
    state["facing"]=facing.angle()

static func sprite(canvas: CanvasItem, texture: Texture2D, at: Vector2, size: Vector2, angle: float=0.0, tint: Color=Color.WHITE, flip: bool=false) -> void:
    canvas.draw_set_transform(at,angle,Vector2(-1,1) if flip else Vector2.ONE)
    canvas.draw_texture_rect(texture,Rect2(-size*0.5,size),false,tint)
    canvas.draw_set_transform(Vector2.ZERO)

static func prop(canvas: CanvasItem, id: String, grip: Vector2, size: Vector2, angle: float, tint: Color, flip: bool) -> void:
    var pivot: Vector2=PROP_GRIPS.get(id,Vector2(128,128))
    canvas.draw_set_transform(grip,angle,Vector2(-1,1) if flip else Vector2.ONE)
    canvas.draw_texture_rect(Art.TEXTURES[id],Rect2(-pivot*size/256.0,size),false,tint)
    canvas.draw_set_transform(Vector2.ZERO)

func draw_projectiles(canvas: CanvasItem, shots: Array, clock: float, reduced: bool) -> void:
    for shot: Dictionary in shots:
        if clock<float(shot["at"]):continue
        var point: Vector2=shot["pos"]+Vector2(0,-24)
        var direction: Vector2=shot["direction"]
        var angle:=direction.angle()
        var cap: bool=shot["id"]=="no-cap"
        canvas.draw_line(point-direction*(18.0 if cap else 24.0),point,Color(TEAL,0.55),2.0)
        if cap:
            var bank:=0.0 if reduced else sin(clock*22.0)*0.18
            sprite(canvas,Art.TEXTURES["no-cap"],point,Vector2(34,34),bank+clampf(angle,-0.55,0.55),Color.WHITE,direction.x<0)
        else:sprite(canvas,Art.BOLT,point,Vector2(30,12),angle)

func draw_ground(canvas: CanvasItem, pending: Array, clock: float, reduced: bool) -> void:
    # Read real queued geometry; never grow a decorative radius beyond it.
    for event in gestures:
        if event["shot"] or clock>float(event["until"]):continue
        var area: Dictionary=event["model"]
        if area.is_empty():continue
        var at: float=area["at"];var age:=clock-at
        if not bool(area["impact_shown"]) and (age>=0 or not pending.has(area)):continue
        var fade:=1.0 if age<=0.12 else clampf(1.0-(age-0.12)/0.16,0,1)
        var warning:=age<0.0
        var center: Vector2=area["center"];var facing: Vector2=area["facing"]
        var radius: float=area["radius"];var half:=deg_to_rad(float(area["arc"])*0.5)
        var color:=Color(GOLD if bool(event["legendary"]) else TEAL,(0.42 if warning else 0.64)*fade)
        if area["shape"]=="line":
            canvas.draw_line(center,center+facing*radius,color,2.0)
        else:
            canvas.draw_arc(center,radius,facing.angle()-half,facing.angle()+half,40 if half>=PI else 24,color,2.0)
            if half<PI and not warning:
                canvas.draw_line(center,center+facing.rotated(-half)*radius,Color(color,0.20*fade),1.0)
                canvas.draw_line(center,center+facing.rotated(half)*radius,Color(color,0.20*fade),1.0)
        if area["id"]=="brainrot-feed":
            sprite(canvas,Art.TEXTURES["brainrot-feed"],center+Vector2(0,-16),Vector2(26,32),0,Color(1,1,1,fade))
            if not warning:
                var inner:=radius*(0.82 if reduced else clampf(age/0.18,0.2,1.0))
                canvas.draw_arc(center,inner,0,TAU,32,Color("a66bff",0.5*fade),4.0)
        elif area["id"]=="personal-space" and not warning:
            var inner:=radius*(0.72 if reduced else clampf(age/0.18,0.12,1.0))
            canvas.draw_arc(center,inner,0,TAU,40,Color("a66bff",0.65*fade),4.0)
        elif area["id"]=="chad-hands" and bool(area["activation"].get("slam",false)) and bool(area.get("second",false)) and not warning:
            canvas.draw_arc(center,radius*0.8,0,TAU,32,Color(GOLD,0.55*fade),3.0)

func draw_actor(canvas: CanvasItem, point: Vector2, hero_id: String, appearance: String, pose: Dictionary, clock: float, reduced: bool, shield_sources: Dictionary) -> void:
    if pose["state"] in ["hurt","defeat"]:return
    var event:=current(clock)
    if not event.is_empty() and not str(pose["state"]).begins_with("flex"):
        var id: String=event["id"];var model: Dictionary=event["model"]
        var beat:=stage(event,clock);var at: float=model["at"];var age:=clock-at
        var flip: bool=pose["flip"]
        var grip:=point+Attach.grip(hero_id,appearance,beat,flip)
        var facing: Vector2=model.get("direction",model.get("facing",Vector2.RIGHT))
        var sign_x:=-1.0 if flip else 1.0
        var aim:=atan2(facing.y,absf(facing.x))
        var tint:=Color(1,1,1,clampf((float(event["until"])-clock)/0.08,0,1))
        var attached:=not Attach.embedded(id,hero_id,appearance)
        if id=="no-cap":
            # Existing cap/gun silhouettes remain authored; the thrown cap is
            # rendered only by the actual projectile, never another fake shot.
            pass
        elif attached:
            var angle:=aim*sign_x
            var size:=Vector2(42,42)
            if id=="ratio-blaster":
                size=Vector2(43,38)
                if not reduced and age>=0:grip-=facing*2.0*clampf(1.0-age/0.09,0,1)
            elif id=="brainrot-feed":angle=0.0;size=Vector2(29,38)
            elif id=="ban-hammer":
                size=Vector2(64,64)
                var windup:=maxf(0.001,at-float(event["queued"]))
                var progress:=clampf((clock-float(event["queued"]))/windup,0,1)
                angle=sign_x*(lerpf(-0.25,2.15,pow(progress,3)) if beat==1 else lerpf(2.15,1.8,clampf(age/0.24,0,1))) if not reduced else sign_x*2.15
            elif id=="touch-grass":
                size=Vector2(68,68)
                if age>=0:
                    var center: Vector2=model["center"];var radius: float=model["radius"]
                    var half:=deg_to_rad(float(model["arc"])*0.5)
                    var endpoint:=center+facing.rotated(0 if reduced else lerpf(-half,half,clampf(age/0.20,0,1)))*maxf(0,radius-16)
                    # Align the actual approved stem with the same sweep as the
                    # tether; a separately rotating prop looked disconnected.
                    var stem_axis:=Vector2(139*sign_x,-133)
                    angle=(endpoint+Vector2(0,-12)-grip).angle()-stem_axis.angle()
                    var tip:=grip+stem_axis.rotated(angle)*Vector2(68,68)/256.0
                    var previous:=tip
                    for i in range(1,7):
                        var t:=float(i)/6.0
                        var next:=tip.lerp(endpoint+Vector2(0,-12),t)+Vector2(0,-sin(t*PI)*12)
                        next=center+(next-center).limit_length(radius)
                        canvas.draw_line(previous,next,Color(INK,tint.a),5.0)
                        canvas.draw_line(previous,next,Color("78c85c",tint.a),2.5);previous=next
            elif id=="personal-space":attached=false
            if attached:prop(canvas,id,grip,size,angle,tint,flip)
        if id=="ratio-blaster" and age>=0 and age<0.08:
            var muzzle:=grip+Vector2(sign_x*18,-8)
            canvas.draw_texture_rect_region(Art.IMPACTS,Rect2(muzzle-Vector2(9,9),Vector2(18,18)),Rect2(0,0,64,64),Color(1,1,1,tint.a))
        elif id=="keyboard-warrior" and age>=0 and age<0.17:
            # Authored keyboard is already in all four character poses. Two
            # compact key streaks emphasize the real first/second strike only.
            canvas.draw_line(grip+facing*3,grip+facing*21,Color(PAPER,0.8*tint.a),2.5)
            canvas.draw_line(grip+Vector2(0,6)+facing*3,grip+Vector2(0,6)+facing*15,Color(GOLD,0.8*tint.a),2.0)
    var barrier:=false
    for source in SHIELD_SOURCES:
        if shield_sources.has(source) and float(shield_sources[source]["remaining"])>0 and clock<float(shield_sources[source]["until"]):barrier=true;break
    if barrier:
        # Actual shield HP, never implied invulnerability or directional armor.
        var center:=point+Vector2(0,-27)
        canvas.draw_arc(center,27,0,TAU,32,Color("4ea3ff",0.5),2.0)

func draw_impacts(canvas: CanvasItem, clock: float, reduced: bool) -> void:
    for event in impacts:
        var age:=clock-float(event["at"])
        if age<0 or clock>=float(event["until"]):continue
        var id: String=event["id"];var point: Vector2=event["point"]
        var fade:=clampf(1.0-age/0.18,0,1)
        if event["blocked"]:
            canvas.draw_arc(point,10,0,TAU,16,Color("4ea3ff",fade),2.5);continue
        var cell:=0 if id in ["no-cap","ban-hammer","chad-hands"] else 1 if id in ["ratio-blaster","keyboard-warrior","touch-grass"] else 2
        var extent:=(30.0 if id in ["ban-hammer","chad-hands"] else 23.0)*float(event["weight"])
        if not reduced:extent*=1.0+0.18*sin(clampf(age/0.18,0,1)*PI)
        canvas.draw_texture_rect_region(Art.IMPACTS,Rect2(point-Vector2.ONE*extent*0.5,Vector2.ONE*extent),Rect2(cell*64,0,64,64),Color(1,1,1,fade))
