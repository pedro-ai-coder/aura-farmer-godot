class_name ProfileStore
extends RefCounted

## Shared Phaser v2 contract. Never overwrite either legacy storage key/file.
const SAVE_KEY := "aura-farmer:profile:v2"
const LEGACY_KEY := "aura-farmer:profile:v1"
const PATH := "user://profile_v2.json"
const SLICE_PATH := "user://godot_slice_profile_v1.json"
const HEROES := ["sigma", "cool-kid", "alpha"]
const CHARACTER_IDS := ["sigma", "nerd", "six-seven", "cool-kid", "ohio", "rizzler", "alpha", "fanum", "beta"]

static func defaults() -> Dictionary:
    return {"version": 2, "selected": "sigma", "unlocked": HEROES.duplicate(), "results": [], "xp": 0.0, "wins": 0, "runs": 0, "best_wave": 1, "total_kills": 0, "settings": {"reducedMotion": false, "sound": true, "masterVolume": 1.0}}

static func _volume(value: Variant) -> float:
    if (value is int or value is float) and is_finite(float(value)): return clampf(float(value),0.0,1.0)
    return 1.0

static func _number(value: Variant) -> float:
    if (value is int or value is float) and is_finite(float(value)) and float(value) >= 0.0:
        return float(value)
    return 0.0

static func _dictionary(value: Variant) -> Dictionary:
    return value if value is Dictionary else {}

static func _unlocks(profile: Dictionary, value: Variant) -> void:
    if value is Array:
        for id in value:
            if CHARACTER_IDS.has(id) and not profile["unlocked"].has(id):
                profile["unlocked"].append(id)

static func normalize_result(value: Variant) -> Dictionary:
    if not value is Dictionary:
        return {}
    if not value.get("id") is String or value["id"].is_empty() or not HEROES.has(value.get("hero")) or not value.get("won") is bool:
        return {}
    var time: Variant = value.get("time")
    if not (time is int or time is float) or not is_finite(float(time)) or float(time) < 0.0:
        return {}
    var result := {"id": value["id"], "hero": value["hero"], "won": value["won"], "time": float(time)}
    for key in ["kills", "flexes", "xp", "damage", "healing", "protection"]:
        result[key] = _number(value.get(key))
    result["kills"] = int(result["kills"])
    result["flexes"] = int(result["flexes"])
    result["wave"] = clampi(int(_number(value.get("wave"))), 1, 5)
    result["level"] = clampi(int(_number(value.get("level"))), 1, 25)
    return result

static func read_data(v2: Variant, legacy: Variant = null, slice: Variant = null) -> Dictionary:
    var profile := defaults()
    if v2 is Dictionary and v2.get("version") == 2:
        if HEROES.has(v2.get("selected")): profile["selected"] = v2["selected"]
        _unlocks(profile, v2.get("unlocked"))
        var unique: Dictionary = {}
        var rows: Variant = v2.get("results")
        if rows is Array:
            for row in rows:
                var result := normalize_result(row)
                if not result.is_empty(): unique[result["id"]] = result
        var values := unique.values()
        profile["results"] = values.slice(maxi(0, values.size() - 40))
        for key in ["xp", "wins", "runs", "total_kills"]: profile[key] = _number(v2.get(key))
        profile["best_wave"] = clampi(int(_number(v2.get("best_wave"))), 1, 5)
        var settings := _dictionary(v2.get("settings"))
        profile["settings"] = {"reducedMotion": settings.get("reducedMotion") == true, "sound": settings.get("sound") != false, "masterVolume": _volume(settings.get("masterVolume",1.0))}
        if v2.has("legacy"): profile["legacy"] = v2["legacy"]
        return profile
    if legacy is Dictionary and legacy.get("schemaVersion") == 1:
        profile["legacy"] = legacy.duplicate(true)
        if HEROES.has(legacy.get("selectedCharacterId")): profile["selected"] = legacy["selectedCharacterId"]
        _unlocks(profile, legacy.get("unlockedCharacters"))
        var lifetime := _dictionary(legacy.get("lifetime"))
        profile["xp"] = _number(lifetime.get("xpCollected"))
        profile["wins"] = _number(lifetime.get("wins"))
        profile["runs"] = _number(lifetime.get("runs"))
        profile["settings"]["reducedMotion"] = _dictionary(legacy.get("settings")).get("reduceMotion") == true
    elif slice is Dictionary and slice.get("version") == 1:
        profile["legacy"] = {"godotSlice": slice.duplicate(true)}
        for key in ["runs", "wins", "total_kills"]: profile[key] = _number(slice.get(key))
        profile["best_wave"] = clampi(int(_number(slice.get("best_wave"))), 1, 5)
    return profile

static func record(profile: Dictionary, value: Dictionary, mode: String) -> Dictionary:
    if mode != "won" and mode != "lost":
        return profile
    var result := normalize_result(value)
    if result.is_empty() or result["won"] != (mode == "won"):
        return profile
    for previous: Dictionary in profile["results"]:
        if previous["id"] == result["id"]: return profile
    var next := profile.duplicate(true)
    next["results"].append(result)
    if next["results"].size() > 40: next["results"].pop_front()
    next["runs"] = int(next["runs"]) + 1
    next["wins"] = int(next["wins"]) + (1 if result["won"] else 0)
    next["xp"] = float(next["xp"]) + float(result["xp"])
    next["total_kills"] = int(next["total_kills"]) + int(result["kills"])
    next["best_wave"] = maxi(int(next["best_wave"]), int(result["wave"]))
    # Preserve historical unlocks; new unlock thresholds remain proposed in GDD 7.1.
    return next

static func parse_json(raw: String) -> Variant:
    var parser := JSON.new()
    if raw.is_empty() or parser.parse(raw) != OK: return null
    return parser.data

static func _file(path: String) -> Variant:
    if not FileAccess.file_exists(path): return null
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null: return null
    return parse_json(file.get_as_text())

static func _web_value(key: String) -> String:
    if not OS.has_feature("web"): return ""
    var result: Variant = JavaScriptBridge.eval("(function(){try{return localStorage.getItem(" + JSON.stringify(key) + ") || '';}catch(e){return '';}})()", true)
    return result if result is String else ""

static func load_profile() -> Dictionary:
    var web_v2 := _web_value(SAVE_KEY)
    var current: Variant = parse_json(web_v2) if not web_v2.is_empty() else _file(PATH)
    var old := _web_value(LEGACY_KEY)
    return read_data(current, parse_json(old) if not old.is_empty() else null, _file(SLICE_PATH))

static func save_profile(profile: Dictionary, native_path: String = PATH) -> bool:
    var raw := JSON.stringify(profile)
    if OS.has_feature("web"):
        var saved: Variant = JavaScriptBridge.eval("(function(){try{localStorage.setItem(" + JSON.stringify(SAVE_KEY) + "," + JSON.stringify(raw) + ");return true;}catch(e){return false;}})()", true)
        return saved == true
    var file := FileAccess.open(native_path + ".tmp", FileAccess.WRITE)
    if file == null: return false
    file.store_string(raw)
    file.flush()
    var error := file.get_error()
    file.close()
    if error != OK: return false
    return DirAccess.rename_absolute(native_path + ".tmp", native_path) == OK
