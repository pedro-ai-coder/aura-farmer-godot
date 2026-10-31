class_name WebPlatform
extends RefCounted

static func install() -> void:
    if OS.has_feature("web"):
        if OS.has_feature("performance_review"):
            JavaScriptBridge.eval(FileAccess.get_file_as_string("res://web/performance.js"),true)
        JavaScriptBridge.eval(FileAccess.get_file_as_string("res://web/platform.js"),true)

static func metrics(mode: String = "") -> Dictionary:
    if not OS.has_feature("web"): return {}
    if not mode.is_empty():
        JavaScriptBridge.eval("if(window.__auraPlatform)window.__auraPlatform.setMode("+JSON.stringify(mode)+")",true)
    var raw = JavaScriptBridge.eval("window.__auraPlatform ? window.__auraPlatform.metrics() : '{}'",true)
    var parsed = JSON.parse_string(str(raw))
    return parsed if parsed is Dictionary else {}
