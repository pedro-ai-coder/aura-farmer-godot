extends SceneTree

var failures: Array[String] = []

func _expect(ok: bool, description: String) -> void:
    if not ok:
        failures.append(description)

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    get_root().add_child(game)
    var catalog: Dictionary = game.get("WEAPONS")
    for hero in range(3):
        game.call("start_run", hero)
        game.set("run_time", 540.0)
        game.call("_check_legendary_window")
        _expect(game.get("mode") == "legendary", "Legendary modal at 9:00")
        var offers: Array = game.get("legendary_offers")
        _expect(offers.size() == 6, "Six legendary cards")
        if offers.size() < 6:
            continue
        var options := []
        var passive_count := 0
        var weapon_count := 0
        for card in offers:
            options.append(str(card["id"]))
            _expect(card["rarity"] == "legendary", "Card is legendary")
            _expect(card["level"] == 1, "Legendary cap level 1")
            if card["type"] == "passive":
                passive_count += 1
            else:
                weapon_count += 1
                _expect(catalog[card["id"]]["role"] == game.get("hero")["role"], "Legendary weapon role")
        _expect(passive_count == 3 and weapon_count == 3, "Three passives and three weapons")
        var unique_ids: Dictionary = {}
        for id in options:
            unique_ids[id] = true
        _expect(unique_ids.size() == 6, "No duplicate legendary card IDs")
        game.call("_defer_legendary")
        _expect(game.get("mode") == "playing", "Deferring resumes run")
        game.set("run_time", 720.0)
        game.call("_check_legendary_window")
        _expect(game.get("mode") == "legendary", "Legendary modal returns at 12:00")
        var same: Array = game.get("legendary_offers")
        for i in range(6):
            _expect(same[i]["id"] == options[i], "No reroll on deferral")
        game.call("pick_upgrade", 0)
        game.call("_confirm_selection")
        _expect(game.get("legendary_spent"), "Legendary selection consumes entitlement")
        _expect(game.get("mode") == "playing", "Legendary selection resumes play")
        _expect((game.get("passives") as Array).size() == 1, "Selected legendary occupies one passive slot")
        game.call("_check_legendary_window")
        _expect(game.get("mode") == "playing", "Entitlement cannot repeat")

    game.call("start_run", 0)
    game.set("run_time", 900.0)
    game.call("_open_legendary")
    _expect(game.get("mode") == "playing", "Legendary window expired before boss")

    game.queue_free()
    if failures.is_empty():
        print("PASS: 9:00/12:00 same six cards, legal role, defer, one-per-run and expiry")
        quit(0)
    else:
        for issue in failures:
            push_error(issue)
        quit(1)
