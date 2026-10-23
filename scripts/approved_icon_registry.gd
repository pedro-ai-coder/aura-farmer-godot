class_name ApprovedIconRegistry
extends RefCounted

## Presentation only. Source approval and byte hashes are enforced before export.
## Runtime PNGs are imported textures; their original bytes are not a PCK hash contract.
const MANIFEST := "res://assets/runtime-icons/manifest.json"
const ROOT := "res://assets/runtime-icons/"
var issues: Array[String] = []
var _entries: Dictionary = {}
var _cache: Dictionary = {}
var _loader: Callable

func _init(data = null, texture_loader: Callable = Callable()) -> void:
    _loader = texture_loader
    if data == null:
        data = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    if not data is Dictionary or data.get("schema_version") != 1 or not data.get("icons") is Array:
        issues.append("Invalid approved icon manifest")
        return
    for row in data["icons"]:
        if not row is Dictionary:
            issues.append("Invalid icon row")
            break
        var category := str(row.get("category",""))
        var id := str(row.get("id",""))
        var hash_value := str(row.get("promoted_sha256",""))
        var folder := "weapons" if category == "weapon" else "passives"
        var path := ROOT + folder + "/" + id + "/" + hash_value + ".png"
        var key := category + ":" + id
        if category not in ["weapon","passive"] or id.is_empty() or id.contains("/") or id.contains("..") or hash_value.length() != 64 or not hash_value.is_valid_hex_number(false) or row.get("resource_path") != path or row.get("source_sha256") != hash_value or row.get("approval_status") != "CREATOR_APPROVED" or str(row.get("approval_reference","")).strip_edges().is_empty() or _entries.has(key):
            issues.append("Rejected icon mapping: " + key)
            break
        _entries[key] = path
    if not issues.is_empty(): _entries.clear()

func texture(category: String, id: String) -> Texture2D:
    var key := category + ":" + id
    if _cache.has(key): return _cache[key] as Texture2D
    var result: Texture2D = null
    if _entries.has(key):
        var path: String = _entries[key]
        var resource = _loader.call(path) if _loader.is_valid() else (load(path) if ResourceLoader.exists(path) else null)
        if resource is Texture2D: result = resource
        else: issues.append("Approved icon cannot load: " + key)
    _cache[key] = result
    return result

func missing_mappings(category: String, ids: Array) -> Array[String]:
    # Explicit validation diagnostic; expected pending icons never spam frame logs.
    var missing: Array[String] = []
    for id in ids:
        if texture(category,str(id)) == null: missing.append(category + ":" + str(id))
    return missing
