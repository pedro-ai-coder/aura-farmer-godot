extends RefCounted

## One cosmetic resource resolver. Never substitutes original/male resources.
## Frame masks retain generated source pixels and remove adjacent poses.
const Appearance = preload("res://scripts/hero_appearance.gd")
var textures: Dictionary = {}
var frames: Dictionary = {}
var availability: Dictionary = {}

func has_assets(hero_id: String) -> bool:
    if not availability.has(hero_id):
        availability[hero_id] = Appearance.can_start("female",hero_id)
    return bool(availability[hero_id])

func texture(hero_id: String, usage: String) -> Texture2D:
    if not has_assets(hero_id): return null
    var key := hero_id+":"+usage
    if not textures.has(key):
        var path := Appearance.asset_path(hero_id,usage)
        if path.is_empty(): return null
        textures[key] = load(path) as Texture2D
    return textures[key] as Texture2D

func prepare(hero_id: String) -> bool:
    if not has_assets(hero_id): return false
    # Preserve the existing Pixel Vixen playback and source registration.
    if hero_id == "sigma": return texture(hero_id,"atlas") != null
    if frames.has(hero_id): return not frames[hero_id].is_empty()
    var manifest = JSON.parse_string(FileAccess.get_file_as_string(Appearance.manifest_path(hero_id)))
    if not manifest is Dictionary or manifest.get("hero_id") != hero_id: return false
    var geometry_path := Appearance.manifest_path(hero_id).get_base_dir()+"/frames.json"
    if FileAccess.get_sha256(geometry_path) != str(manifest.get("frame_geometry_sha256","")): return false
    var decoded = JSON.parse_string(FileAccess.get_file_as_string(geometry_path))
    if not decoded is Array: return false
    var entries: Array = decoded
    if entries.size() != 24 or float(manifest.get("world_scale",0.0)) <= 0.0: return false
    var atlas := texture(hero_id,"atlas")
    if atlas == null: return false
    var source := atlas.get_image()
    if source == null: return false
    if source.is_compressed() and source.decompress() != OK: return false
    source.convert(Image.FORMAT_RGBA8)
    var bounds := Rect2i(Vector2i.ZERO,source.get_size())
    var prepared: Array[Dictionary] = []
    for entry: Dictionary in entries:
        var r: Array = entry.get("source_rect",[])
        var p: Array = entry.get("pivot",[])
        var masks: Array = entry.get("mask_rects",[])
        if r.size()!=4 or p.size()!=2 or masks.is_empty(): return false
        var region := Rect2i(int(r[0]),int(r[1]),int(r[2]),int(r[3]))
        if not region.has_area() or not bounds.encloses(region): return false
        var image := Image.create_empty(region.size.x,region.size.y,false,Image.FORMAT_RGBA8)
        image.fill(Color.TRANSPARENT)
        for mask: Array in masks:
            if mask.size()!=4: return false
            var clip := Rect2i(int(mask[0]),int(mask[1]),int(mask[2]),int(mask[3]))
            if not clip.has_area() or not Rect2i(Vector2i.ZERO,region.size).encloses(clip): return false
            image.blit_rect(source,Rect2i(region.position+clip.position,clip.size),clip.position)
        if not image.get_used_rect().has_area(): return false
        prepared.append({"texture":ImageTexture.create_from_image(image),
            "pivot":Vector2(float(p[0]),float(p[1])),"source_rect":Rect2(region),
            "scale":float(manifest["world_scale"])})
    frames[hero_id] = prepared
    return true

func frame(hero_id: String, index: int) -> Dictionary:
    if not frames.has(hero_id) and not prepare(hero_id): return {}
    var poses: Array = frames.get(hero_id,[])
    return {} if poses.is_empty() else poses[clampi(index,0,poses.size()-1)]
