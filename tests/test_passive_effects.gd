extends SceneTree

## Headless contract tests for GDD §9 continuous buffs, hit caps and support triggers.

var problems: Array[String] = []

func _expect(valid: bool, message: String) -> void:
    if not valid:
        problems.append(message)

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var rules = load("res://scripts/solo_passive_rules.gd")
    var common: Array = [
        {"id":"main-character", "rarity":"common", "level":3},
        {"id":"terminally-online", "rarity":"common", "level":2},
        {"id":"hands-on-sight", "rarity":"common", "level":2},
        {"id":"its-over", "rarity":"epic", "level":2}
    ]
    _expect(is_equal_approx(rules.weapon_frequency(common, {}, 10.0, Vector2.ZERO), 0.10), "Terminally Online frequency")
    _expect(is_equal_approx(rules.weapon_damage(common, 5, false, 10.0, {}, 0, 0.0), 1.22), "Main Character Energy damage and permanent level bonus")
    _expect(is_equal_approx(rules.area_scale(common), 1.0), "Area is unchanged without Big Meme")
    _expect(is_equal_approx(rules.ranged_range_scale(common), 1.0), "Range is unchanged without Timeline")
    var target := {"pos":Vector2(80, 0), "hp":20.0, "max":100.0}
    _expect(is_equal_approx(rules.damage_to_target(common, target, Vector2.ZERO), 1.14 * 1.25), "Melee range and low health damage multipliers")
    target["hp"] = 70.0
    _expect(is_equal_approx(rules.damage_to_target(common, target, Vector2.ZERO), 1.14), "Low health bonus only below 30%")
    var utility: Array = [
        {"id":"big-meme","rarity":"common","level":2},
        {"id":"timeline","rarity":"common","level":2},
        {"id":"aura-viral","rarity":"epic","level":1},
        {"id":"certified-w","rarity":"common","level":2},
        {"id":"cope-harder","rarity":"common","level":1},
        {"id":"absolute-cinema","rarity":"legendary","level":1}
    ]
    _expect(is_equal_approx(rules.area_scale(utility), 1.12), "Big Meme radius bonus")
    _expect(is_equal_approx(rules.ranged_range_scale(utility), 1.16), "Across the Timeline bonus")
    _expect(is_equal_approx(rules.weapon_frequency(utility, {"viral_until":15.0}, 10.0, Vector2.ZERO), 0.12), "Aura Goes Viral frequency window")
    _expect(is_equal_approx(rules.weapon_damage(utility, 1, true, 10.0, {}, 0, 0.0), 1.25 * 1.20), "Legendary damage and Flex bonus")
    _expect(is_equal_approx(rules.support_scale(utility, true), 1.12 * 1.08), "Support and Tank shield multipliers")

    var game = load("res://scenes/main.tscn").instantiate()
    get_root().add_child(game)
    game.call("start_run", 1)
    game.set("run_time", 2.5)
    game.set("aura", 0.0)
    game.call("_primary_activation", Vector2.ZERO)
    game.call("_primary_activation", Vector2.ZERO)
    game.call("_primary_activation", Vector2.ZERO)
    _expect(is_equal_approx(float(game.get("aura")), 2.0), "At most two primary-hit Aura charges in one second")
    game.set("run_time", 3.5)
    game.call("_primary_activation", Vector2.ZERO)
    _expect(is_equal_approx(float(game.get("aura")), 3.0), "Primary hit Aura charge resets next second")

    game.call("start_run", 2)
    # Append to the actual typed Array[Dictionary], not an untyped property replacement.
    var equipped: Array = game.get("passives")
    equipped.append({"id":"so-back","rarity":"epic","level":1})
    equipped.append({"id":"too-sigma","rarity":"legendary","level":1})
    _expect(int(game.call("_passive_level", "so-back")) == 1, "We Are So Back equipped in typed passive slots")
    _expect(int(game.call("_passive_level", "too-sigma")) == 1, "Too Sigma to Fall equipped in typed passive slots")
    game.call("_deal_damage_to_player", 125.0)
    _expect(float(game.get("hp")) > 0.0 and float(game.get("hp")) < float(game.get("max_hp")) * 0.25, "Damage crosses both nonfatal HP thresholds")
    var timers: Dictionary = game.get("passive_timers")
    _expect(float(timers.get("so_back_ready", 0.0)) > 0.0, "We Are So Back activates only after nonfatal threshold crossing")
    _expect(float(timers.get("too_sigma_ready", 0.0)) > 0.0, "Too Sigma to Fall triggers on nonfatal threshold crossing")
    _expect(float(game.get("shield")) > 0.0, "Emergency passive shields are granted")

    game.call("start_run", 0)
    game.call("_spawn_enemy", "npc")
    var foes: Array = game.get("enemies")
    _expect(foes.size() == 1, "Enemy spawned for target-lock check")
    if foes.size() == 1:
        foes[0]["pos"] = Vector2(game.get("player_pos")) + Vector2(90.0, 0.0)
        game.set("aura", 100.0)
        game.call("_use_flex")
        _expect(is_equal_approx(float(game.get("aura")), 0.0), "Sigma Flex consumes Aura with a legal target")
        _expect(float(game.get("flex_time")) > 0.0, "Sigma Flex activates and starts its duration")
        _expect(not (game.get("sigma_target") as Dictionary).is_empty(), "Sigma Flex locks a target")
    game.queue_free()
    if problems.is_empty():
        print("PASS: GDD passive modifiers, Aura hit caps, low-health shields and Sigma Flex")
        quit(0)
    else:
        for problem in problems:
            push_error(problem)
        quit(1)
