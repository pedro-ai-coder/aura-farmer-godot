extends RefCounted
## Creator-approved Clean Cut V2 runtime artwork. This loader never accesses candidate sources.
const MANIFEST_PATH := "res://assets/runtime-clean-cut/v2/manifest.json"

var rows: Dictionary = {}
var textures: Dictionary = {}

func _init(_unused_source_root: String = "") -> void:
    var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
    assert(payload is Dictionary and payload.get("status", "") == "CREATOR_APPROVED", "Missing approved Clean Cut artwork manifest")
    rows = payload["resources"]
    assert(rows.size() == 84, "Unexpected Clean Cut runtime resource inventory")

func texture(id: String) -> Texture2D:
    if textures.has(id):
        return textures[id]
    assert(rows.has(id), "Unknown approved Clean Cut visual: " + id)
    var item: Dictionary = rows[id]
    assert(item["approval_status"] == "CREATOR_APPROVED", "Unapproved Clean Cut visual: " + id)
    var resource_path: String = str(item["resource_path"])
    assert(resource_path.begins_with("res://assets/runtime-clean-cut/v2/"), "Non-runtime visual path rejected: " + id)
    var result: Resource = ResourceLoader.load(resource_path)
    assert(result is Texture2D, "Missing imported approved Clean Cut texture: " + resource_path)
    textures[id] = result
    return result
