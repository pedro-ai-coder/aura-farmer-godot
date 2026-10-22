extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _card(id: String, kind: String = "passive", level: int = 1) -> Dictionary:
    return {"id": id, "type": kind, "rarity": "common", "level": level}

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.call("start_run", 0)
    game.set("run_time", 119.99)
    game.call("_advance", 0.02)
    _expect(game.get("wave") == 2 and game.get("total_xp") == 80.0, "Wave transition credits exactly its approved XP")
    _expect(game.get("mode") == "choice", "Transition pauses immediately for a pending level choice")
    var frozen_time: float = game.get("run_time")
    game.call("_advance", 0.10)
    _expect(game.get("run_time") == frozen_time, "A modal cannot advance the simulation even through direct stepping")
    game.call("start_run", 0)
    game.set("level", 25)
    game.call("_recompute_max_hp")
    game.set("hp", 50.0)
    game.call("_gain_xp", 1710.0)
    _expect(game.get("pending_choices") == 0 and game.get("xp") == 0.0, "Level cap consumes equivalent XP without new choices")
    _expect(is_equal_approx(game.get("hp"), 50.0 + 0.05 * 148.0), "Level-cap recovery is limited by its 20-second cooldown")
    game.set("run_time", 20.0)
    game.call("_gain_xp", 855.0)
    _expect(is_equal_approx(game.get("hp"), 50.0 + 0.10 * 148.0), "Level-cap recovery becomes available after twenty seconds")
    game.call("start_run", 0)
    game.set("run_time", 0.99)
    game.call("_primary_activation", Vector2.ZERO)
    game.call("_primary_activation", Vector2.ZERO)
    game.set("run_time", 1.01)
    game.call("_primary_activation", Vector2.ZERO)
    _expect(game.get("aura") == 2.0, "Primary Aura cap uses a rolling second, not an integer-boundary exploit")
    game.call("start_run", 0)
    game.call("_apply_card", _card("built-different"))
    game.call("_apply_card", _card("built-different", "upgrade_passive", 2))
    _expect(is_equal_approx(game.get("max_hp"), 116.0), "Built Different uses additive levels, not compounding")
    var passives: Array = game.get("passives")
    for id in ["main-character", "thick-skin", "caught-4k", "big-meme"]:
        passives.append({"id": id, "rarity": "common", "level": 1})
    game.call("_apply_card", _card("certified-w"), "built-different")
    _expect(game.get("max_hp") == 100.0 and game.get("hp") <= 100.0, "Replacing max-HP passive removes its entire contribution")
    game.call("start_run", 0)
    game.set("run_time", 100.0)
    game.call("_apply_card", {"id":"w-wifi", "type":"passive", "rarity":"rare", "level":1})
    _expect(game.get("passive_timers")["wifi_next"] == 112.0, "Periodic passive waits a full interval after acquisition")
    var rules = load("res://scripts/solo_passive_rules.gd")
    _expect(is_equal_approx(rules.weapon_frequency([{"id":"terminally-online","level":2},{"id":"aura-viral","level":1}], {"viral_until":10.0}, 1.0, Vector2.ZERO), 0.22), "Permanent frequency combines with strongest temporary buff")
    game.call("start_run", 0)
    var drops: Array = game.get("pickups")
    drops.append({"kind":"aura", "xp": 100.0, "pos": Vector2(300,500)})
    game.set("run_time", 600.0)
    game.call("_spawn_logic", 0.0)
    _expect(game.get("total_xp") == 100.0 and game.get("pickups").is_empty(), "Boss transition collects existing XP exactly once")
    game.call("_finish", false)
    var total: float = game.get("total_xp")
    game.call("_gain_xp", 100.0)
    _expect(game.get("total_xp") == total, "Results reject late XP")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Wave pause, level-cap recovery, rolling Aura, passive replacement/periodicity, frequency stacking and terminal isolation")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
