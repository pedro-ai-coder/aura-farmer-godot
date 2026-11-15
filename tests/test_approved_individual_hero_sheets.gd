extends SceneTree
const Sheets = preload("res://scripts/full_hero_atlases.gd")
const Visuals = preload("res://scripts/approved_visuals.gd")
const Appearance = preload("res://scripts/hero_appearance.gd")
var failures: Array[String] = []
func expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func _initialize() -> void:
    var visuals := Visuals.new()
    var sheets = visuals.hero_sheets
    expect(visuals.pixel_vixen_cpk_atlas == null,"Rejected CPK v1 atlas is never loaded into the active renderer")
    for id in ["sigma","cool-kid","alpha"]:
        for appearance in ["original","female"]:
            expect(Appearance.can_start(appearance,id),"Every approved identity is startable")
            expect(visuals.prepare_appearance(id,appearance),"All atlas/HUD/selection resources prepare")
            var identity: String = Sheets.slug(id,appearance)
            var atlas: Texture2D = sheets.texture(id,appearance,"atlas")
            var entry: Dictionary = sheets.manifest[identity]
            var dimensions: Array = entry["dimensions"]
            expect(atlas != null and atlas.get_size()==Vector2(dimensions[0],dimensions[1]),"Registered full atlas geometry: "+identity)
            expect(atlas == sheets.texture(id,appearance,"atlas"),"Strong cache retains each atlas texture")
            for usage in ["selection","hud"]:
                var portrait: Texture2D = visuals.cosmetic_portrait(id,appearance,usage)
                expect(portrait != null and portrait.resource_path==Sheets.path(id,appearance,usage),"Current approved identity in "+usage)
            var image := atlas.get_image()
            if image.is_compressed(): image.decompress()
            image.convert(Image.FORMAT_RGBA8)
            expect(entry["frames"].size()==64,"All 64 animation slots are present")
            for index in range(64):
                var rect: Array = entry["frames"][index]["cell_rect"]
                var cell := image.get_region(Rect2i(rect[0],rect[1],rect[2],rect[3]))
                expect(cell.get_used_rect().has_area(),"Every newly drawn pose has visible pixels")
                expect(cell.get_pixel(0,0).a==0.0,"No sheet rectangle behind sprites")
    expect(Sheets.slug("byte-baddie","female").is_empty(),"Appearance slugs never become gameplay kit IDs")
    for phase in ["idle","run","attack","hurt","flex-in","flex-loop","flex-out","defeat"]:
        for time in range(10):
            var index := Sheets.frame_index(phase,{"walk":float(time)*0.1,"attack":float(time)*0.02})
            expect(index>=0 and index<64,"All lifecycle phases resolve a registered authored pose")
    if failures.is_empty():
        print("PASS: six identities, full atlas routing, cached textures, 384 authored cells, lifecycle states and rejected-atlas exclusion")
        quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
