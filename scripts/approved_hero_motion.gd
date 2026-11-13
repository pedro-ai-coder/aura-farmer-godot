extends RefCounted

## Creator-approved 2026-11-13 presentation. Never writes simulation or saves.
const Canonical = preload("res://scripts/hero_animation.gd")
const ROOT := "res://assets/production/hero-motion-v3/"
const SHEET := "hero-motion-v3"
const CELL := 512
const PIVOT := Vector2(256,464)
const HEIGHT := 70.0
static var metadata: Dictionary = {}
var resources: Dictionary = {}
var samplers: Dictionary = {}

static func slug(hero_id: String, appearance: String) -> String:
    return {"sigma":"pixel-vixen","cool-kid":"byte-baddie","alpha":"block-queen"}.get(hero_id,"") if appearance=="female" else {"sigma":"sigma","cool-kid":"cool-kid","alpha":"alpha-chad"}.get(hero_id,"")

static func rows() -> Dictionary:
    if metadata.is_empty():
        var parsed = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"manifest.json"))
        if parsed is Dictionary: metadata=parsed.get("heroes",{})
    return metadata

func texture(name: String, role: String) -> Texture2D:
    var key := name+":"+role
    if not resources.has(key):
        var path := ROOT+name+"/"+role+".png"
        resources[key]=load(path) as Texture2D if ResourceLoader.exists(path) else null
    return resources[key] as Texture2D

func prepare(hero_id: String, appearance: String) -> bool:
    var name := slug(hero_id,appearance)
    return rows().has(name) and texture(name,"run")!=null and texture(name,"portrait")!=null

static func pose(hero_id: String, appearance: String, state: Dictionary) -> Dictionary:
    var canonical := Canonical.pose(hero_id,state)
    var phase: String=canonical["state"]
    var moving: bool=state.get("moving",false) and phase!="defeat"
    # Locomotion is a base layer, not an alternative to attack/hurt/Flex.
    # Running attacks, damage and Flex keep their gait and registration.
    # At rest retain the approved standing identity; do not freeze a stride as
    # an invented idle pose. Authored transition/action poses remain an art gap.
    var flip: bool=state.get("body_flip",canonical["flip"])
    var horizontal := cos(float(state.get("heading",0.0)))
    if moving and absf(horizontal)>0.1: flip=horizontal<0.0
    var attacking: bool=float(state.get("attack",0.0))>0.0
    var aim_x:=cos(float(state.get("facing",0.0)))
    if int(state.get("attack_stage",0))>0 and absf(aim_x)>0.15: flip=aim_x<0.0
    var gait:=float(state.get("walk",0.0))*12.0
    var frame:=posmod(int(gait),8) if moving else -1
    var reduced: bool=state.get("reduced_motion",false)
    # Ranged recoil, a sharper melee follow-through, and a grounded tank brace.
    # These restrained torso offsets cannot substitute for authored action poses.
    var strength:=1.5 if hero_id=="sigma" else 2.4 if hero_id=="cool-kid" else 1.0
    var weight:=float(state.get("attack_weight",0.0))
    var torso:=Vector2(-weight*strength,absf(weight)*(0.8 if hero_id=="alpha" else 0.3))
    if phase=="hurt": torso=Vector2(-1.4,0.6)*clampf(float(state.get("hurt",0.0))/0.18,0.0,1.0)
    if reduced or phase=="defeat": torso=Vector2.ZERO
    var tint:=Color(1.0,0.72,0.72) if phase=="hurt" else Color.WHITE
    return {"sheet":SHEET,"slug":slug(hero_id,appearance),"state":phase,
        "frame":frame,"flip":flip,"locomotion":"run" if moving else "idle",
        "attack_active":attacking,"attack_stage":state.get("attack_stage",0),
        "torso":torso,"grip_offset":torso*Vector2(-1,1) if flip else torso,"tint":tint}

# Measured on the unchanged hero-motion-v3 textures, in source pixels.
# These locate embedded equipment, not invented independent weapon poses.
const EMBEDDED_POINTS := {
    "pixel-vixen": [Vector2(387,223), Vector2(660,550)],
    "sigma": [Vector2(405,243), Vector2(800,765)],
    "cool-kid": [Vector2(338,176), Vector2(245,325)],
    "byte-baddie": [Vector2(290,220), Vector2(595,455)]
}

static func embedded_anchor(descriptor: Dictionary, weapon_id: String) -> Variant:
    if descriptor.get("sheet", "") != SHEET: return null
    var name: String = descriptor.get("slug", "")
    if not EMBEDDED_POINTS.has(name): return null
    if weapon_id != ("ratio-blaster" if name in ["sigma", "pixel-vixen"] else "keyboard-warrior"): return null
    var running: bool = int(descriptor["frame"]) >= 0
    var info: Dictionary = rows()[name]
    var point: Vector2 = EMBEDDED_POINTS[name][0 if running else 1]
    var dimensions: Array = info["portrait_dimensions"]
    var origin := PIVOT if running else Vector2(float(dimensions[0])*0.5, float(dimensions[1])-16.0)
    var factor: float = HEIGHT/float(info["body_height"] if running else info["idle_height"])
    var extent: float = CELL if running else float(dimensions[1])
    # Match the renderer's piecewise-linear mesh, including the torso reaction.
    var band := clampf(point.y/extent*5.0, 0.0, 5.0)
    var lower := floorf(band)
    var influence := lerpf(1.0-smoothstep(0.40,0.88,lower/5.0),
        1.0-smoothstep(0.40,0.88,minf(5.0,lower+1.0)/5.0),band-lower)
    var local := (point-origin)*factor + Vector2(descriptor.get("torso",Vector2.ZERO))*influence
    if bool(descriptor["flip"]): local.x = -local.x
    return local

func draw(canvas: CanvasItem, pos: Vector2, hero_id: String, descriptor: Dictionary) -> bool:
    if descriptor.get("sheet","")!=SHEET: return false
    var name: String=descriptor.get("slug","")
    var info: Dictionary=rows().get(name,{})
    if info.is_empty() or info.get("hero_id","")!=hero_id: return false
    var index: int=int(descriptor["frame"])
    if index< -1 or index>7:return false
    var image := texture(name,"run" if index>=0 else "portrait")
    if image==null: return false
    var key := name+(":run" if index>=0 else ":portrait")
    if not samplers.has(key):
        var sampler := CanvasTexture.new()
        sampler.diffuse_texture=image
        sampler.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
        samplers[key]=sampler
    var filtered: CanvasTexture=samplers[key]
    var factor: float=HEIGHT/float(info["body_height"] if index>=0 else info["idle_height"])
    canvas.draw_set_transform(pos,0.0,Vector2(-1,1) if bool(descriptor["flip"]) else Vector2.ONE)
    var torso: Vector2=descriptor.get("torso",Vector2.ZERO)
    var tint: Color=descriptor.get("tint",Color.WHITE)
    var source:=Rect2(posmod(index,4)*CELL,int(index/4)*CELL,CELL,CELL) if index>=0 else Rect2(Vector2.ZERO,image.get_size())
    var origin:=PIVOT if index>=0 else Vector2(image.get_width()*0.5,image.get_height()-16)
    if torso.is_zero_approx():
        canvas.draw_texture_rect_region(filtered,Rect2(-origin*factor,source.size*factor),source,tint)
    else:
        # One textured polygon; no second body, portrait overlay or new artwork.
        # Lower vertices stay at the approved foot pivot while the torso reacts.
        var vertices:=PackedVector2Array()
        var uvs:=PackedVector2Array()
        for side in range(2):
            for row in range(6):
                var y:=float(row if side==0 else 5-row)/5.0*source.size.y
                var x:=0.0 if side==0 else source.size.x
                var influence:=1.0-smoothstep(0.40,0.88,y/source.size.y)
                vertices.append((Vector2(x,y)-origin)*factor+torso*influence)
                uvs.append((source.position+Vector2(x,y))/image.get_size())
        canvas.draw_polygon(vertices,PackedColorArray([tint]),uvs,filtered)
    canvas.draw_set_transform(Vector2.ZERO)
    return true
