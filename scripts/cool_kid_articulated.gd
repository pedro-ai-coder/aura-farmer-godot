extends RefCounted
## CANDIDATE only. Existing immediate renderer, shared hierarchy, eight authored views.
const Motion=preload("res://scripts/cool_kid_motion.gd")
const ROOT := "res://assets/art-candidates/cool-kid/articulated-rig-v2/"
const ART_COMMIT := "e4f4a43fc166dea6bb9cea494e3c09e445f35811"
const MANIFEST_SHA := "53dfcae7594fe940d4a1c7f36254ef3e99a9a25a98b1ea1aabb07f353507c022"
const SCALE := 64.0/147.0
const ORIGIN := Vector2(96,180)
const STATES := ["idle","run","attack","hurt","flex-in","flex-loop","flex-out","defeat"]
const STRIDE := 32.0
const STANCE := 0.45
const FRONT_ORDER := [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
const REAR_LEFT_ORDER := [0,1,2,3,4,5,6,8,9,11,12,13,7,10,14,15]
const REAR_RIGHT_ORDER := [0,1,2,3,4,5,6,10,11,9,12,13,7,8,14,15]
var sampled_view := 0
var enabled := false
var valid := false
var reason := "not prepared"
var views: Array = []
var parts: Array = []
var textures: Array = []
var pivots: Dictionary = {}
var transforms: Dictionary = {}
var view := 0
var previous_view := 0
var view_age := 1.0
var last_time := -1.0
var motion_gain := 0.0
var last_draw_time := -1.0
var displayed_state := "idle"
var contact_targets := [Vector2.ZERO,Vector2.ZERO]
var contact_phases := [false,false]
var contact_anchors := [Vector2.ZERO,Vector2.ZERO]
var contact_valid := [false,false]
var reach_releases := 0
var actor_position := Vector2.ZERO

func _init() -> void:
    enabled=OS.get_cmdline_user_args().has("--cool-kid-rig-review")
    if OS.has_feature("web"):
        enabled=str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('coolKidRig')",true))=="1"
    if enabled:prepare()

func prepare(root_path: String=ROOT, expected: String=MANIFEST_SHA) -> bool:
    valid=false;reason="invalid manifest or missing resource"
    views.clear();parts.clear();textures.clear();pivots.clear();transforms.clear()
    last_time=-1.0;last_draw_time=-1.0;motion_gain=0.0
    contact_valid.fill(false);contact_phases.fill(false)
    var path:=root_path+"manifest.json"
    if not FileAccess.file_exists(path) or FileAccess.get_sha256(path)!=expected:return false
    var data=JSON.parse_string(FileAccess.get_file_as_string(path))
    if not data is Dictionary or data.get("hero_id","")!="cool-kid" or data.get("status","")!="CANDIDATE_NOT_APPROVED":return false
    if data.get("views",[]).size()!=8:return false
    for definition in data["views"]:
        var entries: Array=definition.get("parts",[])
        if entries.size()!=16 or int(definition.get("sector",-1))!=views.size():return false
        var joints: Dictionary={};var images: Array=[];var matrices: Dictionary={}
        for entry in entries:
            var id:=str(entry.get("name",""));var parent:=str(entry.get("parent",""));var pivot: Array=entry.get("pivot",[])
            if id.is_empty() or joints.has(id) or pivot.size()!=2 or (parent!="root" and not joints.has(parent)):return false
            var resource:=root_path+str(entry.get("file",""))
            if not ResourceLoader.exists(resource):return false
            var texture=load(resource) as Texture2D
            if texture==null or texture.get_size()!=Vector2(192,192):return false
            var image:=texture.get_image();image.convert(Image.FORMAT_RGBA8)
            var digest:=HashingContext.new();digest.start(HashingContext.HASH_SHA256);digest.update(image.get_data())
            if digest.finish().hex_encode()!=str(entry.get("rgba_sha256","")):
                reason="decoded pixel mismatch: "+resource;return false
            joints[id]=Vector2(float(pivot[0]),float(pivot[1]));matrices[id]=Transform2D.IDENTITY;images.append(texture)
        views.append({"parts":entries,"textures":images,"pivots":joints,"transforms":matrices})
    _use_view(0);view=0;previous_view=0;view_age=1.0
    valid=true;reason="valid pinned candidate / eight directions";return true

func _use_view(index: int) -> void:
    sampled_view=index
    parts=views[index]["parts"];textures=views[index]["textures"];pivots=views[index]["pivots"];transforms=views[index]["transforms"]

func fallback_reason(hero_id: String, appearance: String, state: String, context: Dictionary) -> String:
    if not enabled:return "LEGACY selected"
    if not valid:return "INVALID RIG: "+reason
    if hero_id!="cool-kid" or appearance!="original":return "identity outside Cool Kid original scope"
    if bool(context.get("reduced_motion",false)):return "reduced motion: approved legacy"
    if state not in STATES:return "unsupported state: "+state
    return ""
func supports(hero_id: String, appearance: String, state: String, context: Dictionary) -> bool:
    return fallback_reason(hero_id,appearance,state,context).is_empty()
static func sector(context: Dictionary) -> int:
    return posmod(roundi(float(context.get("heading",0.0) if bool(context.get("moving",false)) else context.get("facing",0.0))/(PI/4)),8)
static func around(pivot: Vector2, angle: float, offset: Vector2=Vector2.ZERO) -> Transform2D:
    var result:=Transform2D(angle,Vector2.ZERO)
    result.origin=pivot+offset-result.basis_xform(pivot)
    return result

func _leg(side: String, phase: float, heading: float, pelvis: Transform2D, gain: float, lock_contacts: bool) -> void:
    var index:=0 if side=="l" else 1
    var hip: Vector2=pivots["thigh_"+side];var knee: Vector2=pivots["shin_"+side];var ankle: Vector2=pivots["foot_"+side]
    var q:=fposmod(phase,1.0)
    var contact_fraction:=lerpf(STANCE,0.30,absf(sin(heading)))
    var stance:=q<contact_fraction
    var u:=q/contact_fraction if stance else (q-contact_fraction)/(1.0-contact_fraction)
    # Linear contact trajectory cancels canonical travel; authored lift/recovery
    # uses smooth knots, with toe-off delayed until the planted interval ends.
    var stride:=lerpf(0.5,-0.5,u) if stance else lerpf(-0.5,0.5,smoothstep(0.0,1.0,u))
    var lift:=0.0 if stance else (smoothstep(0.0,0.35,u)*(1.0-smoothstep(0.65,1.0,u)))*11.0
    var neutral:=Vector2(hip.x+(-8.0 if index==0 else 8.0),171.0)
    var target:=neutral+Vector2.from_angle(heading)*stride*STRIDE*contact_fraction/SCALE*gain-Vector2(0,lift*gain)
    if lock_contacts:
        if stance and gain>0.85:
            if not contact_phases[index] or not contact_valid[index]:
                contact_anchors[index]=actor_position+(target-ORIGIN)*SCALE;contact_valid[index]=true
            target=(contact_anchors[index]-actor_position)/SCALE+ORIGIN
        else:contact_valid[index]=false
        contact_phases[index]=stance
    var world_hip:=pelvis*hip
    var to:=target-world_hip
    # Candidate hidden anatomy gives a continuous overlap at both joints.
    var a:=hip.distance_to(knee);var b:=knee.distance_to(ankle)
    var distance:=clampf(to.length(),absf(a-b)+1.0,a+b-0.1)
    if lock_contacts and stance and absf(distance-to.length())>0.0001:
        contact_valid[index]=false;reach_releases+=1
    target=world_hip+to.normalized()*distance
    var bend:=acos(clampf((a*a+distance*distance-b*b)/(2.0*a*distance),-1.0,1.0))
    # Knees bend in travel direction; front/rear retain separated lanes.
    var bend_sign:=(-1.0 if cos(heading)<-0.25 else 1.0) if absf(sin(heading))<0.4 else (-1.0 if index==0 else 1.0)
    var knee_target:=world_hip+Vector2.from_angle(to.angle()+bend*bend_sign)*a
    var upper:=around(hip,(knee_target-world_hip).angle()-(knee-hip).angle(),world_hip-hip)
    # Translate to the solved knee (source segment lengths remain unscaled).
    var lower:=around(knee,(target-knee_target).angle()-(ankle-knee).angle(),knee_target-knee)
    transforms["thigh_"+side]=upper;transforms["shin_"+side]=lower
    transforms["foot_"+side]=around(ankle,0.0 if stance else -0.15*sin(u*PI)*cos(heading),target-ankle)
    contact_targets[index]=target

func _follow_grip(torso: Transform2D) -> void:
    var shoulder: Vector2=pivots["upper_r"]
    var elbow: Vector2=pivots["fore_r"]
    var wrist: Vector2=pivots["fore_l"]
    var origin:=torso*shoulder
    var target: Vector2=transforms["fore_l"]*wrist
    var a:=shoulder.distance_to(elbow);var b:=elbow.distance_to(wrist)
    var to:=target-origin
    var distance:=clampf(to.length(),absf(a-b)+0.01,a+b-0.01)
    var bend:=acos(clampf((a*a+distance*distance-b*b)/(2.0*a*distance),-1.0,1.0))
    var sign_bend: float=1.0 if (wrist-shoulder).cross(elbow-shoulder)>=0.0 else -1.0
    var solved:=origin+Vector2.from_angle(to.angle()+bend*sign_bend)*a
    transforms["upper_r"]=around(shoulder,(solved-origin).angle()-(elbow-shoulder).angle(),origin-shoulder)
    transforms["fore_r"]=around(elbow,(target-solved).angle()-(wrist-elbow).angle(),solved-elbow)

func sample(state: String, context: Dictionary, direction: int=-1, gain: float=-1.0, lock_contacts: bool=false) -> void:
    _use_view(sector(context) if direction<0 else direction)
    var time:=float(context.get("time",0.0));var walk:=float(context.get("walk",0.0))
    var moving:=bool(context.get("moving",false)) and state!="defeat"
    var amount: float=(1.0 if moving else 0.0) if gain<0.0 else gain
    var phase:=walk*190.0/STRIDE
    var q:=fposmod(phase,0.5)*2.0
    # Authored contact compression → passing rise → landing. Twice per cycle.
    var weight:=lerpf(4.0,-1.5,smoothstep(0.0,0.48,q)) if q<0.48 else lerpf(-1.5,4.0,smoothstep(0.48,1.0,q))
    var swing:=sin(phase*TAU)*amount
    var action:=Motion.action(state,context)
    var defeat:=smoothstep(0.0,0.75,float(context.get("defeat",0.0))) if state=="defeat" else 0.0
    var heading:=float(context.get("heading",0.0))
    var crouch:=8.0+5.0*maxf(0.0,-sin(heading))
    var pelvis:=around(pivots["pelvis"],0.018*swing,Vector2(1.3*swing,(crouch+weight)*amount+defeat*10.0))
    transforms["pelvis"]=pelvis
    _leg("l",phase,heading,pelvis,amount,lock_contacts);_leg("r",phase+0.5,heading,pelvis,amount,lock_contacts)
    var breath:=sin(time*2.6)*0.5*(1.0-amount)
    var torso:=pelvis*around(pivots["torso"],action.y-0.045*swing,Vector2(0,breath))
    transforms["torso"]=torso
    # Both wrists and the prop share the left grip chain. Shoulder counterdrive
    # and the free elbow communicate action without rotating detached hands.
    transforms["upper_l"]=torso*around(pivots["upper_l"],action.x-0.055*swing)
    transforms["fore_l"]=transforms["upper_l"]*around(pivots["fore_l"],action.z+0.035*swing)
    transforms["keyboard"]=transforms["fore_l"];transforms["hand"]=transforms["fore_l"]
    _follow_grip(torso)
    transforms["head"]=torso*around(pivots["head"],-action.y*0.75+0.03*swing,Vector2(0,-weight*amount*0.30))
    transforms["pompom"]=transforms["head"]*around(pivots["pompom"],sin(phase*TAU-0.8)*0.10*amount+sin(time*2.6-0.5)*0.025*(1.0-amount))
    if defeat>0.0:
        # One connected ground-pivot collapse, followed by small settling motion.
        var collapse:=around(Vector2(100,175),-1.45*defeat,Vector2(-10.0*defeat,-12.0*defeat))
        for id in transforms:transforms[id]=collapse*transforms[id]

func draw(canvas: CanvasItem, position: Vector2, hero_id: String, appearance: String, pose: Dictionary, context: Dictionary) -> bool:
    var state:=str(pose.get("state","idle"))
    if not supports(hero_id,appearance,state,context):return false
    var time:=float(context.get("time",0.0))
    var dt:=clampf(time-last_time,0.0,0.1) if last_time>=0.0 else 0.0
    if time<last_time:contact_valid.fill(false);motion_gain=0.0
    last_time=time;last_draw_time=time;displayed_state=state
    var desired:=1.0 if bool(context.get("moving",false)) and state!="defeat" else 0.0
    motion_gain=move_toward(motion_gain,desired,dt/0.075)
    var next:=sector(context)
    if next!=view:
        previous_view=view;view=next;view_age=0.0;contact_valid.fill(false);contact_phases.fill(false)
    view_age+=dt
    var base:=Transform2D(0.0,Vector2(SCALE,SCALE),0.0,position-ORIGIN*SCALE)
    actor_position=position
    # Brief full-view dissolve preserves handed lettering; never reflect art.
    var blend:=smoothstep(0.0,0.075,view_age)
    if blend<1.0 and previous_view!=view:
        sample(state,context,previous_view,motion_gain)
        _draw_parts(canvas,base,1.0-blend)
    sample(state,context,view,motion_gain,true)
    _draw_parts(canvas,base,blend if previous_view!=view else 1.0)
    canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
    return true
func _draw_parts(canvas: CanvasItem, base: Transform2D, alpha: float) -> void:
    var order: Array=REAR_LEFT_ORDER if (sampled_view==5 or sampled_view==6) else REAR_RIGHT_ORDER if sampled_view==7 else FRONT_ORDER
    for i: int in order:
        canvas.draw_set_transform_matrix(base*transforms[str(parts[i]["name"])])
        canvas.draw_texture(textures[i],Vector2.ZERO,Color(1,1,1,alpha))
