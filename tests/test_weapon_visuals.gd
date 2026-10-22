extends SceneTree

## Ensure every GDD weapon has its exact Phaser Option A visual identity.
## These markers are presentation only; weapon damage is tested separately.
var failures: Array[String] = []

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var visuals = load("res://scripts/weapon_visuals.gd")
    var expected := {
        "ratio-blaster":"dart", "no-cap":"cap", "brainrot-feed":"phone",
        "keyboard-warrior":"keyboard", "ban-hammer":"hammer",
        "touch-grass":"leaf", "cope-shield":"shield",
        "chad-hands":"fists", "personal-space":"segments"
    }
    _expect(visuals.MOTIFS.size() == 9, "Exactly nine approved weapon motifs")
    for id in expected.keys():
        _expect(visuals.motif(id) == expected[id], "Correct Phaser motif for " + id)
    _expect(visuals.motif("unknown") == "", "Do not invent visuals for missing weapons")

    var game = load("res://scenes/main.tscn").instantiate()
    get_root().add_child(game)
    for index in range(3):
        game.call("start_run", index)
        game.call("_spawn_enemy", "npc")
        var foes: Array = game.get("enemies")
        var foe: Dictionary = foes[0]
        foe["pos"] = Vector2(game.get("player_pos")) + Vector2(70.0, 0.0)
        foe["hp"] = 1000000.0
        foe["max"] = 1000000.0
        game.call("_fire_weapons", 0.1)
        var cues: Array = game.get("attack_visuals")
        var shots: Array = game.get("player_shots")
        var expected_id: String = ["no-cap", "keyboard-warrior", "cope-shield"][index]
        if expected_id == "no-cap":
            # Ranged attacks render their approved motif at the travelling shot position.
            # They must not invent an immediate hit cue before the projectile arrives.
            _expect(cues.is_empty(), "No Cap does not create an instant-hit visual cue")
            _expect(shots.size() == 1, "No Cap creates one visible travelling projectile")
            if shots.size() == 1:
                _expect(shots[0]["id"] == expected_id, "Projectile retains its approved visual motif")
                _expect(shots[0]["remaining"] > 0.0, "Projectile remains visible during travel")
        else:
            _expect(shots.is_empty(), "Melee and tank starters do not spawn ranged projectiles")
            _expect(cues.size() == 1, "Contact starter attack creates one visual cue")
            if cues.size() == 1:
                _expect(cues[0]["id"] == expected_id, "Visual cue matches starter weapon")
                _expect(cues[0]["life"] > 0.0, "Cue has a short visible lifetime")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Nine Phaser Option A weapon motifs, travelling No Cap and contact starter cues")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
