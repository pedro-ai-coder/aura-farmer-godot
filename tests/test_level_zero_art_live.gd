extends SceneTree
## Experimental review gate: source PNGs really import as Godot textures.
## It intentionally fails instead of allowing an unchanged Ruin Alley/Beta Bot preview.
var failures: Array[String] = []
const Visuals = preload("res://scripts/level_zero/visual_assets_v1.gd")

func _initialize() -> void:
    call_deferred("_verify")

func check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)

func _verify() -> void:
    var v = Visuals.new()
    check(v.ground_texture != null, "Print-factory background candidate loaded")
    check(v.foreground_texture != null, "Transparent corner poster candidate loaded")
    check(v.boss_texture != null, "Hater Imitation standalone candidate loaded")
    if v.ground_texture != null:
        check(v.ground_texture.get_size() == Vector2(1672,941), "Original arena dimensions")
    if v.foreground_texture != null:
        check(v.foreground_texture.get_size() == Vector2(1672,941), "Original foreground dimensions")
    if v.boss_texture != null:
        check(v.boss_texture.get_size() == Vector2(1312,1199), "Original Hater Imitation dimensions")
    check(v.boss_height > 0.0, "Boss presentation pivot and height contract")
    var level = load("res://scenes/level_zero.tscn").instantiate()
    root.add_child(level)
    level.set_process(false)
    check(level.visual_assets.ground_texture != null, "Level Zero adapter receives restored visual assets")
    check(level.encounter_kind() == level.Candidate.BOSS_ID, "Boss game kind unchanged")
    level.queue_free()
    if failures.is_empty():
        print("PASS: experimental Level Zero original PNGs imported; normal gameplay untouched")
    else:
        for failure in failures:
            push_error(failure)
    quit(0 if failures.is_empty() else 1)
