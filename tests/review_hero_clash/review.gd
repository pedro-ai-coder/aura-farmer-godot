extends "res://scripts/solo_run.gd"
## Launch this scene explicitly. F8 switches the candidate; all game controls remain live.
var review_adapter
func _load_profile() -> void: profile = ProfileStoreScript.defaults()
func _save_profile() -> void: pass
func _ready() -> void:
    super._ready()
    review_adapter = preload("adapter.gd").new()
    add_child(review_adapter)
    review_adapter.install(self,"b" if "--candidate=b" in OS.get_cmdline_user_args() else "a")
func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_F8:
        review_adapter.typography.candidate = "b" if review_adapter.typography.candidate == "a" else "a"
        review_adapter.typography.cache.clear()
        review_adapter.refresh()
        get_viewport().set_input_as_handled()
