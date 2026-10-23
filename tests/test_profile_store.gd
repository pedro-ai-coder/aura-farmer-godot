extends SceneTree

const Store = preload("res://scripts/profile_store.gd")
var failures: Array[String] = []

func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var legacy := {"schemaVersion": 1, "selectedCharacterId": "alpha", "unlockedCharacters": ["nerd", "beta", "unknown"], "lifetime": {"xpCollected": 600, "runs": 5, "wins": 2}, "settings": {"reduceMotion": true}, "unrecognized": "preserve me"}
    var snapshot := legacy.duplicate(true)
    var profile: Dictionary = Store.read_data(null, legacy)
    _expect(profile["selected"] == "alpha" and profile["xp"] == 600.0, "Legacy selection and lifetime totals migrate")
    _expect(profile["unlocked"].has("nerd") and profile["unlocked"].has("beta") and not profile["unlocked"].has("unknown"), "Preserve recognized historical unlocks")
    _expect(profile["settings"]["reducedMotion"] and profile["legacy"] == snapshot and legacy == snapshot, "Migration preserves preferences and the untouched legacy snapshot")
    var slice := Store.read_data(null, null, {"version": 1, "runs": 7, "wins": 3, "best_wave": 5, "total_kills": 200})
    _expect(slice["runs"] == 7 and slice["total_kills"] == 200, "Godot slice totals survive schema upgrade")
    var result := {"id": "run-1", "hero": "sigma", "won": true, "time": 1000.0, "wave": 5, "level": 25, "kills": 30, "xp": 200, "healing": 5, "protection": 10, "damage": 900, "flexes": 2}
    _expect(is_equal_approx(Store.read_data({"version":2,"settings":{"masterVolume":0.37}})["settings"]["masterVolume"],0.37),"Optional master volume survives v2 normalization")
    _expect(Store.read_data({"version":2,"settings":{"masterVolume":2}})["settings"]["masterVolume"] == 1.0,"Master volume clamps safely without changing the profile version")
    _expect(Store.read_data({"version":2,"settings":{"masterVolume":"bad"}})["settings"]["masterVolume"] == 1.0,"Malformed master volume uses the legacy full-volume default")
    var corrupt := {"version": 2, "selected": "beta", "unlocked": ["ohio"], "results": [result, result, {"id": "broken"}], "runs": -10, "xp": "bad", "settings": "bad"}
    var clean := Store.read_data(corrupt)
    _expect(clean["results"].size() == 1 and clean["selected"] == "sigma", "Corrupt and duplicate results are rejected; only solo heroes can be selected")
    _expect(clean["runs"] == 0 and clean["xp"] == 0 and clean["settings"]["sound"], "Malformed totals/settings receive safe defaults")
    var base := Store.defaults()
    _expect(Store.record(base, result, "playing") == base, "An unfinished run cannot change profile progression")
    var recorded := Store.record(base, result, "won")
    _expect(recorded["runs"] == 1 and recorded["wins"] == 1 and recorded["xp"] == 200, "Only completed results update totals")
    _expect(Store.record(recorded, result, "won") == recorded, "A result ID cannot be counted twice")
    _expect(recorded["unlocked"] == Store.HEROES, "Proposed new unlock thresholds are not silently enabled")
    for i in range(45):
        var next := result.duplicate(true)
        next["id"] = "history-" + str(i)
        recorded = Store.record(recorded, next, "won")
    _expect(recorded["results"].size() == 40 and recorded["runs"] == 46 and recorded["xp"] == 9200, "History is bounded while lifetime totals remain intact")
    var path := "user://profile_store_regression.json"
    _expect(Store.save_profile(recorded, path), "Native v2 profile writes atomically")
    _expect(JSON.parse_string(FileAccess.get_file_as_string(path))["runs"] == 46, "Native save round-trips")
    DirAccess.remove_absolute(path)
    _expect(not Store.save_profile(recorded, "user://missing-profile-directory/profile.json"), "Unavailable storage returns failure without blocking gameplay")
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.call("start_run", 0)
    var before: int = game.get("profile")["runs"]
    game.call("_return_to_menu")
    _expect(game.get("profile")["runs"] == before, "Abandoning a run never records a result")
    game.call("start_run", 0)
    game.call("_finish", false)
    game.call("_finish", false)
    _expect(game.get("profile")["runs"] == before + 1, "Repeated terminal callbacks cannot duplicate results")
    game.call("start_run", 1)
    _expect(game.get("run_metrics")["damage"] == 0.0 and game.get("run_metrics")["flexes"] == 0, "Restart clears run statistics without resetting profile totals")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Phaser v2/v1 and Godot migration, corrupt data, unique completed results, bounded history, atomic storage and restart")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
