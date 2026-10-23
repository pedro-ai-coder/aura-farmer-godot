extends SceneTree

## Verifies Phaser-approved artwork, including all original masked enemy animations.
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
        "phone-guy", "hater", "big-hater",
        "enemies-a-v2", "enemies-b-v2", "events-v2", "haters-v2", "enemies"
    ]
    var missing: Array[String] = []
    for name in required:
        var texture: Texture2D = visuals.texture(name)
        if texture == null:
            missing.append(name)
        elif texture.get_width() <= 0 or texture.get_height() <= 0:
            missing.append(name + " (invalid dimensions)")
    for kind in [
        "npc", "hater", "reply-goblin", "beta", "ratio-ram", "doomscroller",
        "hype-bot", "fanum-leech", "ping-sniper", "copium-puffer",
        "comment-mod", "reply-guy", "mod-supremo", "ohio-express",
        "doomscroll-prime", "boss", "boss-berserk"
    ]:
        for frame in [0, 4, 7]:
            var sprite: Texture2D = visuals.enemy_frame(kind, frame)
            if sprite == null or sprite.get_width() <= 0 or sprite.get_height() <= 0:
                missing.append(kind + " (frame " + str(frame) + ")")
    # Art candidates must remain outside the imported resource namespace.
    for candidate in [
        "res://assets/art-production/character-hype-clean-cut/v1/weapons/chad-hands/icon-v5-candidate.png",
        "res://assets/art-production/character-hype-clean-cut/v1/passives/touch-grass/icon-v5-candidate.svg"
    ]:
        if ResourceLoader.exists(candidate):
            missing.append(candidate + " (unapproved candidate imported)")
    if missing.is_empty():
        print("PASS: All 19 approved art assets and 17 enemy animations loaded as Godot textures")
        quit(0)
    else:
        for name in missing:
            push_error("Missing or unreadable approved sprite: " + name)
        quit(1)
