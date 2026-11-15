extends RefCounted
## Newly drawn 64-frame character sheets. No pose-reuse animation transforms.
## Existing gameplay timing/state precedence remains owned by hero_animation.gd.
const Canonical = preload("res://scripts/hero_animation.gd")
const ApprovedPortraits = preload("res://scripts/approved_hero_sheets.gd")
const ROOT := "res://assets/production/heroes/full-atlases-v2/"
const MANIFEST := ROOT + "manifest.json"
var manifest: Dictionary = {}
var sequences: Dictionary = {}
var cache: Dictionary = {}
## Creator approved the Cool Kid composition and roster expansion on 2026-11-15.
## A/B switch: existing pixels only, no mirrored lettering or invented frames.
var layered_locomotion_enabled := true
## Calibrated below embedded hands/props. Heavy shields require a lower seam
## so their silhouette remains owned by the action drawing, not running legs.
const WAIST_BY_IDENTITY := {"the-sigma":142.0,"cool-kid":142.0,"pixel-vixen":144.0,"byte-baddie":136.0,"alpha-chad":138.0,"block-queen":142.0}

func _init() -> void:
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    if parsed is Dictionary:
        manifest = parsed.get("heroes", {})
        sequences = parsed.get("sequences", {})

static func slug(hero_id: String, appearance: String) -> String:
    return ApprovedPortraits.slug(hero_id,appearance)

static func path(hero_id: String, appearance: String, usage: String) -> String:
    var identity := slug(hero_id,appearance)
    if identity.is_empty(): return ""
    if usage == "atlas": return ROOT+identity+"/atlas.png"
    return ApprovedPortraits.path(hero_id,appearance,usage)

func texture(hero_id: String, appearance: String, usage: String) -> Texture2D:
    var resource := path(hero_id,appearance,usage)
    if resource.is_empty() or not manifest.has(slug(hero_id,appearance)): return null
    if not cache.has(resource):
        if not ResourceLoader.exists(resource): return null
        cache[resource] = load(resource) as Texture2D
    return cache[resource] as Texture2D

func prepare(hero_id: String, appearance: String) -> bool:
    var identity := slug(hero_id,appearance)
    if not manifest.has(identity): return false
    if int(manifest[identity].get("unique_frame_count",0)) != 64: return false
    for usage in ["selection","hud","atlas"]:
        if texture(hero_id,appearance,usage) == null: return false
    return true

static func frame_index(phase: String, context: Dictionary) -> int:
    var facing := float(context.get("facing",context.get("heading",0.0)))
    var rear := sin(facing) < -0.35
    if phase == "defeat":
        return 58+clampi(int(float(context.get("defeat",0.0))*8.0),0,5)
    if phase == "hurt":
        return (50 if rear else 48)+(0 if float(context.get("hurt",0.18))>0.09 else 1)
    if phase.begins_with("flex"):
        var hero_id := str(context.get("hero_id","sigma"))
        var original: Dictionary = Canonical.pose(hero_id,context)
        var canonical_frame := int(original["frame"])
        var age := float(context.get("flex_age",0.0))
        if phase == "flex-out":
            return 56+(0 if float(context.get("flex",0.25))>0.125 else 1)
        if phase == "flex-in":
            return 52+clampi(int(age*2.0/(0.4 if hero_id=="alpha" else 0.25)),0,1)
        if hero_id == "alpha":
            # Follow the existing gather/raise/slam/recovery cycle, not an
            # unrelated fast loop that depicts extra gameplay slams.
            return int({41:52,42:57,43:53,44:53,45:54,46:55,47:57}.get(canonical_frame,57))
        if hero_id == "cool-kid":
            return int({26:54,27:55,28:56}.get(canonical_frame,56))
        return [53,54,55,56][posmod(canonical_frame-43,4)]
    if phase == "attack":
        var elapsed := maxf(0.0,0.22-float(context.get("attack",0.22)))
        # The airborne cap in the study drawings is not another projectile.
        # Keep the authored holding pose before release, then the empty hand.
        # Only the real No Cap projectile may depict a released cap in flight.
        if str(context.get("hero_id",""))=="sigma" and str(context.get("appearance","original"))=="original":
            return (44 if rear else 40)+(0 if elapsed<0.055 else 3)
        return (44 if rear else 40)+clampi(int(elapsed*4.0/0.22),0,3)
    if phase == "run":
        var direction := posmod(roundi(float(context.get("heading",0.0))/(PI/4.0)),8)
        return direction*4+posmod(int(float(context.get("walk",0.0))*9.0),4)
    var idle_step := 0 if bool(context.get("reduced_motion",false)) else posmod(int(float(context.get("time",0.0))*4.0),4)
    return (36 if rear else 32)+idle_step

static func composition(identity: String, phase: String, context: Dictionary) -> Dictionary:
    if not WAIST_BY_IDENTITY.has(identity) or not bool(context.get("moving",false)):
        return {}
    if phase!="attack" and not phase.begins_with("flex"): return {}
    # Attack has front/rear drawings. The shared Flex drawings are frontal:
    # turning their legs backward would contradict the authored torso view.
    var rear := phase=="attack" and sin(float(context.get("facing",0.0))) < -0.35
    var step := posmod(int(float(context.get("walk",0.0))*9.0),4)
    return {"lower_frame":(24 if rear else 8)+step,"seam":float(WAIST_BY_IDENTITY[identity])}

func draw(canvas: CanvasItem, position: Vector2, hero_id: String, appearance: String, pose: Dictionary, context: Dictionary) -> bool:
    var identity := slug(hero_id,appearance)
    var atlas := texture(hero_id,appearance,"atlas")
    if atlas == null: return false
    var entry: Dictionary = manifest[identity]
    var playback := context.duplicate()
    playback["hero_id"] = hero_id
    playback["appearance"] = appearance
    var phase := str(pose.get("state","idle"))
    var index := frame_index(phase,playback)
    var frame: Dictionary = entry["frames"][index]
    var rect: Array = frame["cell_rect"]
    var pivot: Array = entry["foot_pivot"]
    var factor := float(entry["world_scale"])
    var layers := composition(identity,phase,playback) if layered_locomotion_enabled else {}
    if not layers.is_empty():
        # Lower body retains the existing distance-driven gait. Each seam
        # excludes hands/shield tips embedded above the run trousers/boots.
        # Front/back legs match the authored torso view; do not reflect CPK.
        # This does not claim missing eight-direction attack art exists.
        var lower: Array = entry["frames"][int(layers["lower_frame"])]["cell_rect"]
        var seam: float=layers["seam"]
        _draw_region(canvas,position,atlas,lower,pivot,factor,seam,float(lower[3])-seam)
        _draw_region(canvas,position,atlas,rect,pivot,factor,0.0,seam)
        return true
    canvas.draw_set_transform(position)
    canvas.draw_texture_rect_region(atlas,
        Rect2(Vector2(-float(pivot[0]),-float(pivot[1]))*factor,Vector2(float(rect[2]),float(rect[3]))*factor),
        Rect2(float(rect[0]),float(rect[1]),float(rect[2]),float(rect[3])))
    canvas.draw_set_transform(Vector2.ZERO)
    return true

static func _draw_region(canvas: CanvasItem, at: Vector2, atlas: Texture2D, rect: Array, pivot: Array, factor: float, top: float, height: float) -> void:
    canvas.draw_set_transform(at)
    canvas.draw_texture_rect_region(atlas,
        Rect2(Vector2(-float(pivot[0]),top-float(pivot[1]))*factor,Vector2(float(rect[2]),height)*factor),
        Rect2(float(rect[0]),float(rect[1])+top,float(rect[2]),height))
    canvas.draw_set_transform(Vector2.ZERO)
