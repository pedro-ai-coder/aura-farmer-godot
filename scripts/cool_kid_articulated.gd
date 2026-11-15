extends RefCounted
## EXPERIMENTAL review only. Pure sampled presentation, canonical clocks, no RNG.
const ROOT := "res://assets/art-candidates/cool-kid/articulated-rig-v1/"
const ART_COMMIT := "5ba1bfb24624d5c84f7d9994ebb719986b43871c"
const MANIFEST_SHA := "748e327c37c8743d827b5ecff79dfb781455477bc11644caa86ef75132e51b24"
const SCALE := 64.0/289.0
const ORIGIN := Vector2(109,289)
var enabled := false
var valid := false
var reason := "not prepared"
var parts: Array = []
var textures: Array[Texture2D] = []
var pivots: Dictionary = {}
var transforms: Dictionary = {}

func _init() -> void:
    enabled = OS.get_cmdline_user_args().has("--cool-kid-rig-review")
    if OS.has_feature("web"):
        enabled = str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('coolKidRig')",true)) == "1"
    # Candidate resources are never loaded in ordinary production playback.
    if enabled: prepare()

func prepare(root_path: String = ROOT, expected: String = MANIFEST_SHA) -> bool:
    valid = false
    reason = "invalid manifest or missing resource"
    parts.clear(); textures.clear(); pivots.clear(); transforms.clear()
    var path := root_path+"manifest.json"
    if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != expected: return false
    var data = JSON.parse_string(FileAccess.get_file_as_string(path))
    if not data is Dictionary or data.get("hero_id","") != "cool-kid" or data.get("status","") != "CANDIDATE_NOT_APPROVED": return false
    var entries: Array = data.get("parts",[])
    if entries.size() != 16: return false
    for entry in entries:
        var name: String = str(entry.get("name",""))
        var parent: String = str(entry.get("parent",""))
        var pivot: Array = entry.get("pivot",[])
        if name.is_empty() or pivots.has(name) or pivot.size()!=2 or (parent!="root" and not pivots.has(parent)): return false
        var resource: String = root_path+str(entry.get("file",""))
        if not ResourceLoader.exists(resource): return false
        var tex := load(resource) as Texture2D
        if tex==null or tex.get_size()!=Vector2(194,292): return false
        # PNG source bytes are removed by Godot export. Verify decoded pixels
        # once at preparation, independent of imported texture container format.
        var image := tex.get_image()
        image.convert(Image.FORMAT_RGBA8)
        var digest := HashingContext.new()
        digest.start(HashingContext.HASH_SHA256);digest.update(image.get_data())
        if digest.finish().hex_encode()!=str(entry.get("rgba_sha256","")):
            reason="decoded pixel mismatch: "+name
            return false
        pivots[name]=Vector2(float(pivot[0]),float(pivot[1]))
        transforms[name]=Transform2D.IDENTITY
        parts.append(entry); textures.append(tex)
    reason = "valid pinned candidate"
    valid = true
    return true

func supports(hero_id: String, appearance: String, state: String, context: Dictionary) -> bool:
    if not enabled or not valid or hero_id!="cool-kid" or appearance!="original" or bool(context.get("reduced_motion",false)): return false
    if state not in ["idle","run","attack","hurt","flex-in","flex-loop","flex-out","defeat"]: return false
    var heading := float(context.get("heading",0.0)) if bool(context.get("moving",false)) else float(context.get("facing",0.0))
    return sin(heading)>=-0.35 and cos(heading)>=-0.4

static func around(pivot: Vector2, angle: float, offset: Vector2 = Vector2.ZERO) -> Transform2D:
    var result := Transform2D(angle,Vector2.ZERO)
    result.origin = pivot+offset-result.basis_xform(pivot)
    return result

func _leg(side: String, phase: float, heading: float, pelvis: Transform2D) -> void:
    var hip: Vector2 = pivots["thigh_"+side]
    var knee: Vector2 = pivots["shin_"+side]
    var ankle: Vector2 = pivots["foot_"+side]
    var q := fposmod(phase,1.0)
    # 22% ground contact, remaining swing with lift. World-space stance travels
    # backwards at exactly canonical speed: cycle is 60 world pixels.
    var travel := 60.0*0.22/SCALE
    var stride := travel*(0.5-q/0.22) if q<0.22 else lerpf(-travel*0.5,travel*0.5,(q-0.22)/0.78)
    var lift := 0.0 if q<0.22 else sin((q-0.22)/0.78*PI)*14.0
    var target := ankle+Vector2(cos(heading)*stride,sin(heading)*stride*0.35-lift)
    var world_hip := pelvis*hip
    var to := target-world_hip
    var a := hip.distance_to(knee)
    var b := knee.distance_to(ankle)
    var distance := clampf(to.length(),absf(a-b)+0.01,a+b-0.01)
    target = world_hip+to.normalized()*distance
    var bend := acos(clampf((a*a+distance*distance-b*b)/(2.0*a*distance),-1.0,1.0))
    var upper_angle := to.angle()+(-bend if side=="l" else bend)-(knee-hip).angle()
    var upper := around(hip,upper_angle,world_hip-hip)
    var new_knee := upper*knee
    var lower_angle := (target-new_knee).angle()-(ankle-knee).angle()
    var lower := around(knee,lower_angle,new_knee-knee)
    transforms["thigh_"+side]=upper
    transforms["shin_"+side]=lower
    # The sneaker stays level rather than inheriting the shin rotation.
    transforms["foot_"+side]=Transform2D(0.0,target-ankle)

func sample(state: String, context: Dictionary) -> void:
    var time := float(context.get("time",0.0))
    var walk := float(context.get("walk",0.0))
    var moving := bool(context.get("moving",false)) and state!="defeat"
    var phase := walk*190.0/60.0
    var breath := sin(time*2.6)
    var beat := sin(phase*TAU)
    var lean := 0.012*breath
    var action := 0.0
    if state=="attack":
        var u := clampf((0.22-float(context.get("attack",0.22)))/0.22,0.0,1.0)
        # Authored anticipation, strike and recovery knots; visual only.
        action = lerpf(0.0,-0.16,u/0.25) if u<0.25 else lerpf(-0.16,0.25,(u-0.25)/0.25) if u<0.5 else lerpf(0.25,0.0,smoothstep(0.5,1.0,u))
        lean += action*0.3
    elif state=="hurt":
        lean = -0.09*sin(clampf((0.18-float(context.get("hurt",0.18)))/0.18,0.0,1.0)*PI)
    elif state.begins_with("flex"):
        var envelope := smoothstep(0.0,0.25,float(context.get("flex_age",0.0)))*smoothstep(0.0,0.25,float(context.get("flex",0.0)))
        action = -0.16*envelope
        lean = -0.025*envelope
    elif state=="defeat":
        lean = smoothstep(0.0,0.7,float(context.get("defeat",0.0)))*0.65
    var pelvis := around(pivots["pelvis"],0.0,Vector2(0,5.0-absf(beat)*2.0) if moving else Vector2.ZERO)
    transforms["pelvis"]=pelvis
    if moving:
        var heading := float(context.get("heading",0.0))
        _leg("l",phase,heading,pelvis);_leg("r",phase+0.5,heading,pelvis)
    else:
        for id in ["thigh_l","shin_l","foot_l","thigh_r","shin_r","foot_r"]:transforms[id]=pelvis
    var torso := pelvis*around(pivots["torso"],lean+(-0.018*beat if moving else 0.0),Vector2(0,breath*0.65))
    transforms["torso"]=torso
    transforms["upper_r"]=torso*around(pivots["upper_r"],action*0.2+(0.025*beat if moving else 0.0))
    transforms["fore_r"]=transforms["upper_r"]*around(pivots["fore_r"],action*0.2)
    transforms["upper_l"]=torso*around(pivots["upper_l"],action+(-0.025*beat if moving else 0.0))
    transforms["fore_l"]=transforms["upper_l"]*around(pivots["fore_l"],-action*0.25)
    transforms["keyboard"]=transforms["fore_l"]
    transforms["hand"]=transforms["fore_l"]
    transforms["head"]=torso*around(pivots["head"],-lean*0.65+sin(time*2.6-0.3)*0.008)
    transforms["pompom"]=transforms["head"]*around(pivots["pompom"],sin((phase*TAU if moving else time*2.6)-0.65)*(0.045 if moving else 0.025))

func draw(canvas: CanvasItem, position: Vector2, hero_id: String, appearance: String, pose: Dictionary, context: Dictionary) -> bool:
    var state := str(pose.get("state","idle"))
    if not supports(hero_id,appearance,state,context): return false
    sample(state,context)
    var base := Transform2D(0.0,Vector2(SCALE,SCALE),0.0,position-ORIGIN*SCALE)
    for i in range(parts.size()):
        canvas.draw_set_transform_matrix(base*transforms[str(parts[i]["name"])])
        canvas.draw_texture(textures[i],Vector2.ZERO)
    canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
    return true
