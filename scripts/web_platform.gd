class_name WebPlatform
extends RefCounted

static func install() -> void:
    if OS.has_feature("web"):
        JavaScriptBridge.eval(FileAccess.get_file_as_string("res://web/platform.js"),true)

static func metrics() -> Dictionary:
    if not OS.has_feature("web"): return {}
    var raw = JavaScriptBridge.eval("window.__auraPlatform ? window.__auraPlatform.metrics() : '{}'",true)
    var parsed = JSON.parse_string(str(raw))
    return parsed if parsed is Dictionary else {}
