extends RefCounted
## Native QA only: unapproved raw source files are never imported or exported.
var root := ""
var rows: Dictionary = {}
var textures: Dictionary = {}
var used: Array[String] = []
func _init(source_root: String) -> void:
    root = source_root
    var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/art/CLEAN_CUT_REVIEW_RESOURCES.json"))
    rows = manifest["resources"]
    assert(not OS.has_feature("web"),"Candidate art is restricted to isolated native QA")
func texture(id: String) -> Texture2D:
    if textures.has(id): return textures[id]
    assert(rows.has(id),"Unlisted review source: "+id)
    var row: Dictionary=rows[id]
    var path := root.path_join(row["path"])
    assert(FileAccess.get_sha256(path)==row["sha256"],"Review source hash mismatch: "+id)
    var image := Image.new()
    var result: int=image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) if path.ends_with(".png") else image.load_svg_from_string(FileAccess.get_file_as_string(path))
    assert(result==OK,"Candidate decode failed: "+id)
    textures[id]=ImageTexture.create_from_image(image)
    used.append(id)
    return textures[id]
