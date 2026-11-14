extends RefCounted
## Approved 2026-11-14 pixels, cached for the lifetime of the renderer.
## Only presentation transforms; never changes simulation state or consumes RNG.
const ROOT := "res://assets/production/heroes/individual-sheets-v1/"
const MANIFEST := ROOT + "manifest.json"
const IDENTITIES := {"sigma":"the-sigma", "cool-kid":"cool-kid", "alpha":"alpha-chad"}
const FEMALE := {"sigma":"pixel-vixen", "cool-kid":"byte-baddie", "alpha":"block-queen"}
var manifest: Dictionary = {}
var cache: Dictionary = {}

func _init() -> void:
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    if parsed is Dictionary: manifest = parsed.get("heroes", {})

static func slug(hero_id: String, appearance: String) -> String:
    return str((FEMALE if appearance == "female" else IDENTITIES).get(hero_id, ""))

static func path(hero_id: String, appearance: String, usage: String) -> String:
    var identity := slug(hero_id, appearance)
    var filename: String = {"selection":"portrait", "hud":"hud", "atlas":"atlas"}.get(usage, "")
    return "" if identity.is_empty() or filename.is_empty() else ROOT + identity + "/" + filename + ".png"

func texture(hero_id: String, appearance: String, usage: String) -> Texture2D:
    var resource := path(hero_id, appearance, usage)
    if resource.is_empty() or not manifest.has(slug(hero_id, appearance)): return null
    if not cache.has(resource):
        if not ResourceLoader.exists(resource): return null
        cache[resource] = load(resource) as Texture2D
    return cache[resource] as Texture2D

func prepare(hero_id: String, appearance: String) -> bool:
    for usage in ["selection", "hud", "atlas"]:
        if texture(hero_id, appearance, usage) == null: return false
    return true

static func frame_index(phase: String, context: Dictionary) -> int:
    if phase == "defeat" or phase == "hurt": return 11
    if phase == "attack":
        return 8 + clampi(int((0.22-float(context.get("attack",0.15)))*3.0/0.22),0,2)
    if phase.begins_with("flex"):
        return 8 if phase == "flex-in" else 10 if phase == "flex-out" else 9
    if phase == "run": return [5,6,7,6][posmod(int(float(context.get("walk",0.0))*9.0),4)]
    return 4

func draw(canvas: CanvasItem, position: Vector2, hero_id: String, appearance: String, pose: Dictionary, context: Dictionary) -> bool:
    var identity := slug(hero_id,appearance)
    var atlas := texture(hero_id,appearance,"atlas")
    if atlas == null: return false
    var entry: Dictionary = manifest[identity]
    var phase := str(pose.get("state","idle"))
    var index := frame_index(phase,context)
    var heading := float(context.get("heading",0.0))
    # Authored rear/front views cover opposite headings without reflecting CPK.
    # Do not fake an opposite contact by mirroring lettering or swapping shields.
    if phase == "run":
        if sin(heading) < -0.55: index = 3
        elif cos(heading) * (-1.0 if identity == "pixel-vixen" else 1.0) < -0.4: index = 0
    var elapsed := float(context.get("time",0.0))
    var reduced := bool(context.get("reduced_motion",false))
    var offset := Vector2.ZERO
    var scale := Vector2.ONE
    var rotation := 0.0
    if phase == "defeat":
        rotation = minf(1.0,float(context.get("defeat",0.0))*3.0)*PI*0.46
    elif not reduced:
        if phase == "run":
            offset.y = -absf(sin(float(context.get("walk",0.0))*9.0*PI))*2.0
        elif phase == "idle":
            scale.y = 1.0 + sin(elapsed*3.0)*0.009
        elif phase == "hurt":
            offset.x = sin(elapsed*65.0)*1.4
        elif phase.begins_with("flex"):
            offset.y = -absf(sin(float(context.get("flex_age",0.0))*8.0))*1.5
    var factor := float(entry["world_scale"])
    canvas.draw_set_transform(position+offset,rotation,scale)
    var source := Rect2(index%4*384,int(index/4)*352,384,352)
    canvas.draw_texture_rect_region(atlas,Rect2(Vector2(-192,-330)*factor,Vector2(384,352)*factor),source)
    canvas.draw_set_transform(Vector2.ZERO)
    return true
