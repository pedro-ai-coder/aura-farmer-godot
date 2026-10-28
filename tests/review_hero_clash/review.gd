extends "res://scripts/solo_run.gd"
## Launch this scene explicitly. F8 switches A/B/C; all game controls remain live.
const CANDIDATES := ["a","b","c"]
var review_adapter

func _load_profile() -> void:
    profile = ProfileStoreScript.defaults()

func _save_profile() -> void:
    pass

func _ready() -> void:
    super._ready()
    review_adapter = preload("adapter.gd").new()
    add_child(review_adapter)
    var selected: String = "a"
    for argument in OS.get_cmdline_user_args():
        if argument.begins_with("--candidate="):
            var requested: String = argument.trim_prefix("--candidate=").to_lower()
            if requested in CANDIDATES:
                selected = requested
    review_adapter.install(self,selected)

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
        var current_index: int = CANDIDATES.find(review_adapter.typography.candidate)
        review_adapter.typography.candidate = CANDIDATES[(current_index+1)%CANDIDATES.size()]
        review_adapter.typography.cache.clear()
        review_adapter.last_key = ""
        review_adapter.refresh()
        get_viewport().set_input_as_handled()
