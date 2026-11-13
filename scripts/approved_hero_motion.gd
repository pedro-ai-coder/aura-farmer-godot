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
    var moving: bool=state.get("moving",false)
    var running := phase=="run" or (phase.begins_with("flex") and moving)
    var flip: bool=canonical["flip"]
    var horizontal := cos(float(state.get("heading",0.0)))
    if moving and absf(horizontal)>0.1: flip=horizontal<0.0
    return {"sheet":SHEET,"slug":slug(hero_id,appearance),"state":phase,
        "frame":posmod(int(float(state.get("walk",0.0))*12.0),8) if running else -1,
        "flip":flip}

func draw(canvas: CanvasItem, pos: Vector2, hero_id: String, descriptor: Dictionary) -> bool:
    if descriptor.get("sheet","")!=SHEET: return false
    var name: String=descriptor.get("slug","")
    var info: Dictionary=rows().get(name,{})
    if info.is_empty() or info.get("hero_id","")!=hero_id: return false
    var index: int=int(descriptor["frame"])
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
    if index>=0:
        canvas.draw_texture_rect_region(filtered,Rect2(-PIVOT*factor,Vector2.ONE*CELL*factor),Rect2(posmod(index,4)*CELL,int(index/4)*CELL,CELL,CELL))
    else:
        # Only run frames and full-body portraits were approved. Non-run body
        # states use that same identity; canonical weapon/Flex VFX remain live.
        var origin := Vector2(image.get_width()*0.5,image.get_height()-16)
        canvas.draw_texture_rect(filtered,Rect2(-origin*factor,image.get_size()*factor),false)
    canvas.draw_set_transform(Vector2.ZERO)
    return true
