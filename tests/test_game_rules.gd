extends SceneTree

func _initialize() -> void:
    var failures: Array[String] = []

    if GameRules.MAX_WEAPONS != 3:
        failures.append("Three weapon slots are required")
    if GameRules.MAX_PASSIVES != 5:
        failures.append("Five passive slots are required")
    if not GameRules.can_equip(3, 5):
        failures.append("A legal loadout was rejected")
    if GameRules.can_equip(4, 5) or GameRules.can_equip(3, 6):
        failures.append("An illegal loadout was accepted")
    if GameRules.can_equip(-1, 0):
        failures.append("Negative slot counts were accepted")

    var expected_caps: Dictionary = {"common": 4, "rare": 3, "epic": 2, "legendary": 1}
    for rarity in expected_caps.keys():
        if GameRules.level_cap(rarity) != int(expected_caps[rarity]):
            failures.append("Incorrect cap for %s" % rarity)
    if GameRules.level_cap("invalid") != 0:
        failures.append("Unknown rarities must be rejected")

    if failures.is_empty():
        print("PASS: foundational GDD contract checks")
        quit(0)
    else:
        for failure: String in failures:
            push_error(failure)
        quit(1)
