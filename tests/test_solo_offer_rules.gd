extends SceneTree

## Regression checks against GDD §10 and the pinned Phaser solo catalog.

var problems: Array[String] = []

func _assert(condition: bool, name: String) -> void:
    if not condition:
        problems.append(name)

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var rules = load("res://scripts/solo_offer_rules.gd")
    var game = load("res://scenes/main.tscn").instantiate()
    get_root().add_child(game)
    var catalogue: Dictionary = game.get("WEAPONS")
    var passive_data: Dictionary = rules.PASSIVE_DATA
    _assert(passive_data.size() == 23, "Exactly 23 approved playable passives")
    _assert(catalogue.size() == 9, "Exactly nine approved weapons")
    _assert(not rules.valid_passive("absolute-cinema", "ranged", 5), "No legendary in normal choices")
    _assert(not rules.valid_passive("hands-on-sight", "ranged", 2), "No off-role melee passives")
    _assert(rules.valid_passive("hands-on-sight", "melee", 2), "Role-matching passive allowed")
    _assert(not rules.valid_passive("its-over", "ranged", 1), "No epic in wave one")
    _assert(rules.valid_passive("its-over", "ranged", 2), "Epic becomes legal from wave two")
    _assert(not rules.legal_item("built-different", "rare", 1, "ranged", catalogue), "Passive rarity is fixed")
    _assert(not rules.legal_item("no-cap", "epic", 3, "ranged", catalogue), "Epic level 3 is illegal")
    _assert(not rules.legal_item("no-cap", "common", 1, "melee", catalogue), "Weapon must match hero role")

    var legendary_loadout := [{"id":"no-cap", "rarity":"legendary", "level":1, "timer":0.0}]
    var legendary_rng := RandomNumberGenerator.new()
    legendary_rng.seed = 451
    for sample in range(100):
        var cards: Array[Dictionary] = rules.choices("ranged", 5, legendary_loadout, [], catalogue, legendary_rng)
        for card: Dictionary in cards:
            _assert(card["id"] != "no-cap", "Normal offers never downgrade or upgrade an existing legendary")

    var ids := ["sigma", "cool-kid", "alpha"]
    for idx in range(3):
        game.call("start_run", idx)
        var current_hero: Dictionary = game.get("hero")
        var rng := RandomNumberGenerator.new()
        rng.seed = 451
        for wave in range(1, 6):
            for sample in range(25):
                var offers: Array[Dictionary] = rules.choices(str(current_hero["role"]), wave, game.get("weapons"), game.get("passives"), catalogue, rng)
                _assert(offers.size() == 3, "Exactly three choices")
                var seen: Array[String] = []
                for offer: Dictionary in offers:
                    if offer["type"] == "heal":
                        continue
                    _assert(not seen.has(str(offer["id"])), "No duplicate item IDs per offer")
                    seen.append(str(offer["id"]))
                    _assert(rules.legal_item(str(offer["id"]), str(offer["rarity"]), int(offer["level"]), str(current_hero["role"]), catalogue), "Offered item is legal")
                    _assert(offer["rarity"] != "legendary", "No legendary in normal cards")
                    _assert(rules.rarity_available(wave, str(offer["rarity"])), "Current wave permits offer rarity")
        game.call("_gain_xp", 100.0)
        game.call("_open_choice")
        _assert(game.get("mode") == "choice", "Experience opens a modal")
        game.call("pick_upgrade", 0)
        game.call("_confirm_selection")
        _assert(game.get("mode") == "playing" or game.get("mode") == "replace" or (game.get("mode") == "choice" and int(game.get("pending_choices")) > 0), "Selected card must resume, request replacement or open queued choice")

    game.queue_free()
    if problems.is_empty():
        print("PASS: GDD rarity, role, level cap, nonduplicate card and three-hero catalog tests")
        quit(0)
    else:
        for problem in problems:
            push_error(problem)
        quit(1)
