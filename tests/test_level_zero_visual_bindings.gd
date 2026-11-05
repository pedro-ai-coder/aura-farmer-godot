extends SceneTree
## Source-level visual bridge contract. Not a real art/rendering or playthrough test.
const Visuals = preload("res://scripts/level_zero/visual_assets_v1.gd")
var problems: Array[String] = []

func _initialize() -> void:
    call_deferred("check")

func require(ok: bool, message: String) -> void:
    if not ok:
        problems.append(message)

func check() -> void:
    var art = Visuals.new()
    var rect: Rect2 = Visuals.cover_rect(Vector2(1672.0,941.0),Rect2(Vector2.ZERO,Vector2(1448.0,1086.0)))
    require(is_equal_approx(rect.size.y,941.0) and rect.size.x < 1672.0, "Cover crop preserves aspect without stretching")
    require(art.boss_texture == null or art.boss_height > 0.0, "Sprite requires a valid foot-pivot/scale contract")
    var normal = load("res://scenes/main.tscn").instantiate()
    root.add_child(normal)
    normal.set_process(false)
    require(normal.presentation_boss_portrait() == null, "Normal game uses approved atlas portrait")
    require(normal.wave_count() == 5 and normal.encounter_kind() == "boss", "Ruin Alley schedule unchanged")
    normal.queue_free()
    var level = load("res://scenes/level_zero.tscn").instantiate()
    root.add_child(level)
    level.set_process(false)
    require(level.wave_count() == 3 and level.encounter_kind() == level.Candidate.BOSS_ID, "Level Zero encounter unchanged")
    require(level.visual_assets != null, "Experimental-only bridge installed")
    require(level.presentation_boss_portrait() == level.visual_assets.boss_texture, "Level Zero HUD reuses the exact same experimental boss texture")
    level.queue_free()
    if problems.is_empty():
        print("LEVEL_ZERO_VISUAL_BRIDGE: PASS (no art/render review)")
    else:
        for error in problems:
            push_error(error)
    quit(0 if problems.is_empty() else 1)
