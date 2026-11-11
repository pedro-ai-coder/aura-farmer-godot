extends SceneTree
## Run via an absolute filesystem --script path with --main-pack game.pck.
## Tests are excluded from the shipping package, so this probe stays external.
func _initialize() -> void:
    var visuals = load("res://scripts/approved_visuals.gd").new()
    if visuals.cool_kid_cpk_atlas == null:
        push_error("Exported PCK did not activate verified Cool Kid CPK art")
        quit(1)
        return
    print("PASS: Exported PCK activates verified Cool Kid renderer without source PNG")
    quit()
