extends "res://scripts/solo_run.gd"
## Opt-in Solo harness for the original Feedverse layout and proposed artwork.

const FeedverseMapRules = preload("res://experiments/feedverse/map_rules.gd")
@export_range(0, 5) var map_index := 0


func _ready() -> void:
    var maps: Array = JSON.parse_string(FileAccess.get_file_as_string(
        "res://experiments/feedverse/maps.json"))
    if maps.size() != 6:
        push_error("Feedverse map data missing")
        return
    experimental_environment_data = maps[map_index]
    world_rules = FeedverseMapRules.new(experimental_environment_data)
    super._ready()
    call_deferred("_begin_preview")


func _begin_preview() -> void:
    start_run(0)
    if mode != "playing":
        push_error("Could not start Feedverse Solo preview")


func _save_profile() -> void:
    # Previewing a candidate map must not write run or profile progress.
    pass
