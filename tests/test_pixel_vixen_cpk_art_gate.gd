extends SceneTree
## The former CPK v1 atlas was rejected. Check the accepted replacement route.
const Visuals = preload("res://scripts/approved_visuals.gd")
const Sheets = preload("res://scripts/approved_hero_sheets.gd")
func _initialize() -> void:
    var visuals := Visuals.new()
    var atlas: Texture2D = visuals.hero_sheets.texture("sigma","female","atlas")
    if visuals.pixel_vixen_cpk_atlas != null or atlas == null or atlas.resource_path != Sheets.path("sigma","female","atlas"):
        push_error("Approved individual Pixel Vixen sheet must replace the rejected CPK v1 derivative")
        quit(1)
        return
    print("PASS: approved individual Pixel Vixen replacement active; rejected CPK v1 derivative excluded")
    quit()
