extends SceneTree

## Verifies the original Phaser assets really reached the Godot runtime.
## The GitHub workflow must download and hash-check them before importing.

func _initialize() -> void:
    call_deferred("_check")

func _check() -> void:
    var visuals = load("res://scripts/approved_visuals.gd").new()
    var required := [
        "main-menu", "ruin-alley",
        "sigma", "cool-kid", "alpha",
        "sigma-atlas", "cool-kid-atlas", "alpha-atlas",
        "cool-kid-flex-v2", "cool-kid-rear-v2", "alpha-rear-v2",
        "phone-guy", "hater", "big-hater"
    ]
    var missing: Array[String] = []
    for name in required:
        var texture: Texture2D = visuals.texture(name)
        if texture == null:
            missing.append(name)
        elif texture.get_width() <= 0 or texture.get_height() <= 0:
            missing.append(name + " (invalid dimensions)")
    if missing.is_empty():
        print("PASS: All 14 approved art assets loaded as real Godot textures")
        quit(0)
    else:
        for name in missing:
            push_error("Missing or unreadable approved sprite: " + name)
        quit(1)
