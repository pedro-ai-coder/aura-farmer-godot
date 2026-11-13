extends RefCounted

## Preview-only cutout candidates. Original kits, state precedence and RNG stay intact.
const Canonical = preload("res://scripts/hero_animation.gd")
const Female = preload("res://scripts/female_hero_animation.gd")
# Canvas draw commands are deferred; retain resources until the frame renders.
static var atlases: Dictionary = {}
const ROOT := "res://assets/art-candidates/"
static func slug(hero_id: String, appearance: String) -> String:
    if hero_id == "alpha": return "block-queen" if appearance == "female" else "alpha-chad"
    return "byte-baddie" if hero_id == "cool-kid" and appearance == "female" else ""

static func portrait(hero_id: String, appearance: String, usage: String) -> Texture2D:
    var name := slug(hero_id,appearance)
    if name.is_empty(): return null
    # The legacy Byte Baddie portrait derivative contains only the upper body.
    # Its approved master already contains both boots; use those exact bytes
    # for selection/home/results while preserving the HUD resource.
    if name == "byte-baddie" and usage != "hud":
        return load(ROOT+name+"/cpk-v1-proposed/selection-source.png") as Texture2D
    return load(ROOT+name+"/cpk-v1-proposed/"+("hud" if usage == "hud" else "portrait")+".png") as Texture2D

static func pose(hero_id: String, appearance: String, state: Dictionary) -> Dictionary:
    var result: Dictionary = Female.pose(hero_id,state)
    result["sheet"] = slug(hero_id,appearance)+"-proposed"
    return result

static func draw(canvas: CanvasItem, pos: Vector2, hero_id: String, pose_data: Dictionary) -> bool:
    var name := str(pose_data.get("sheet",""))
    if not name.ends_with("-proposed"): return false
    name = name.trim_suffix("-proposed")
    if name not in ["byte-baddie","alpha-chad","block-queen"]: return false
    if not atlases.has(name):
        atlases[name] = load(ROOT+name+"/cpk-v1-proposed/atlas.png") as Texture2D
    var atlas: Texture2D = atlases[name]
    if atlas == null: return false
    var index := clampi(int(pose_data["frame"]),0,23)
    var factor := 0.34 if hero_id == "alpha" else 0.32
    canvas.draw_set_transform(pos,0.0,Vector2(-1,1) if bool(pose_data["flip"]) else Vector2.ONE)
    canvas.draw_texture_rect_region(atlas,Rect2(Vector2(-128,-216)*factor,Vector2(256,256)*factor),Rect2((index%4)*256,int(index/4)*256,256,256))
    canvas.draw_set_transform(Vector2.ZERO)
    return true
