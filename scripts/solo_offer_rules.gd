class_name SoloOfferRules
extends RefCounted

## GDD §10 implementation of the Phaser demo's 23-passive subset.
## Content IDs/roles/names stay in exact sync with the pinned Phaser catalog.

const PASSIVE_DATA: Dictionary = {"main-character":{"name":"Main Character Energy","rarity":"common","role":""},"terminally-online":{"name":"Terminally Online","rarity":"common","role":""},"built-different":{"name":"Built Different","rarity":"common","role":""},"thick-skin":{"name":"Thick Skin","rarity":"common","role":""},"caught-4k":{"name":"Caught in 4K","rarity":"common","role":""},"big-meme":{"name":"Big Meme Energy","rarity":"common","role":""},"timeline":{"name":"Across the Timeline","rarity":"common","role":"ranged"},"hands-on-sight":{"name":"Hands On Sight","rarity":"common","role":"melee"},"cope-harder":{"name":"Cope Harder","rarity":"common","role":"tank"},"certified-w":{"name":"Certified W","rarity":"common","role":""},"no-cap-streak":{"name":"No Cap Streak","rarity":"rare","role":"ranged"},"w-wifi":{"name":"W Wi-Fi","rarity":"rare","role":"ranged"},"let-him-cook":{"name":"Let Him Cook","rarity":"rare","role":"melee"},"homie-check":{"name":"Homie Check","rarity":"rare","role":"melee"},"big-chad":{"name":"Big Chad Energy","rarity":"rare","role":"tank"},"its-over":{"name":"It's So Over","rarity":"epic","role":""},"aura-viral":{"name":"Aura Goes Viral","rarity":"epic","role":""},"so-back":{"name":"We Are So Back","rarity":"epic","role":""},"six-to-seven":{"name":"Six → Seven","rarity":"epic","role":""},"absolute-cinema":{"name":"Absolute Cinema","rarity":"legendary","role":""},"w-squad":{"name":"W Squad","rarity":"legendary","role":""},"too-sigma":{"name":"Too Sigma to Fall","rarity":"legendary","role":""},"no-u":{"name":"No U","rarity":"legendary","role":""}}
const WEIGHTS: Array = [[90, 10, 0], [70, 28, 2], [45, 45, 10], [25, 50, 25], [10, 50, 40]]
const RARITIES: Array = ["common", "rare", "epic"]
const CAPS: Dictionary = {"common": 4, "rare": 3, "epic": 2, "legendary": 1}

static func _find_item(equipment: Array, id: String) -> Dictionary:
    for item in equipment:
        if item["id"] == id:
            return item
    return {}

static func rarity_available(wave: int, rarity: String) -> bool:
    var index: int = RARITIES.find(rarity)
    return index >= 0 and WEIGHTS[clampi(wave - 1, 0, 4)][index] > 0

static func valid_passive(id: String, role: String, wave: int) -> bool:
    if not PASSIVE_DATA.has(id):
        return false
    var definition: Dictionary = PASSIVE_DATA[id]
    if definition["rarity"] == "legendary" or not rarity_available(wave, definition["rarity"]):
        return false
    return definition["role"] == "" or definition["role"] == role

static func choices(hero_role: String, wave: int, weapons: Array, passives: Array, catalog: Dictionary, rng: RandomNumberGenerator) -> Array[Dictionary]:
    var candidates: Array[Dictionary] = []
    for id in catalog.keys():
        var weapon: Dictionary = catalog[id]
        if weapon["role"] != hero_role:
            continue
        var old: Dictionary = _find_item(weapons, id)
        if not old.is_empty() and int(old["level"]) < int(CAPS[old["rarity"]]):
            candidates.append({"type":"upgrade_weapon", "id":id, "rarity":old["rarity"], "level":int(old["level"])+1, "category":"upgrade", "label":"UPGRADE "+weapon["name"]+" · LV "+str(int(old["level"])+1)})
        for rarity in RARITIES:
            if not rarity_available(wave, rarity):
                continue
            if old.is_empty():
                candidates.append({"type":"weapon", "id":id, "rarity":rarity, "level":1, "category":"new", "label":"EQUIP "+weapon["name"]+" · "+rarity.to_upper()})
            else:
                if RARITIES.find(rarity) > RARITIES.find(old["rarity"]):
                    candidates.append({"type":"promote_weapon", "id":id, "rarity":rarity, "level":mini(int(old["level"]), int(CAPS[rarity])), "category":"promote", "label":"PROMOTE "+weapon["name"]+" · "+rarity.to_upper()})
    for id in PASSIVE_DATA.keys():
        if not valid_passive(id, hero_role, wave):
            continue
        var definition: Dictionary = PASSIVE_DATA[id]
        var old: Dictionary = _find_item(passives, id)
        if old.is_empty():
            candidates.append({"type":"passive", "id":id, "rarity":definition["rarity"], "level":1, "category":"new", "label":"EQUIP "+definition["name"]+" · "+str(definition["rarity"]).to_upper()})
        elif int(old["level"]) < int(CAPS[old["rarity"]]):
            candidates.append({"type":"upgrade_passive", "id":id, "rarity":old["rarity"], "level":int(old["level"])+1, "category":"upgrade", "label":"UPGRADE "+definition["name"]+" · LV "+str(int(old["level"])+1)})

    var offers: Array[Dictionary] = []
    # GDD: guarantee one equipped-item upgrade if available, but no duplicate ID.
    var upgrades: Array[Dictionary] = []
    for candidate in candidates:
        if candidate["category"] == "upgrade":
            upgrades.append(candidate)
    if not upgrades.is_empty():
        offers.append(upgrades[rng.randi_range(0, upgrades.size() - 1)])

    while offers.size() < 3:
        var available: Array[Dictionary] = []
        for candidate in candidates:
            var already := false
            for offer in offers:
                if offer["id"] == candidate["id"]:
                    already = true
                    break
            if not already:
                available.append(candidate)
        if available.is_empty():
            offers.append({"type":"heal", "id":"heal-" + str(offers.size()), "label":"RECOVER 8% HP"})
            continue
        var categories: Array[String] = []
        for candidate in available:
            var category: String = candidate["category"]
            if not categories.has(category):
                categories.append(category)
        var chosen_category: String = categories[rng.randi_range(0, categories.size() - 1)]
        var group: Array[Dictionary] = []
        for candidate in available:
            if candidate["category"] == chosen_category:
                group.append(candidate)

        var weights: Array = WEIGHTS[clampi(wave - 1, 0, 4)]
        var total := 0.0
        for rarity in RARITIES:
            for candidate in group:
                if candidate["rarity"] == rarity:
                    total += float(weights[RARITIES.find(rarity)])
                    break
        var chosen_rarity := "common"
        var ticket := rng.randf() * total
        for rarity in RARITIES:
            var present := false
            for candidate in group:
                if candidate["rarity"] == rarity:
                    present = true
                    break
            if present:
                ticket -= float(weights[RARITIES.find(rarity)])
                chosen_rarity = rarity
                if ticket <= 0.0:
                    break
        var legal: Array[Dictionary] = []
        for candidate in group:
            if candidate["rarity"] == chosen_rarity:
                legal.append(candidate)
        if legal.is_empty():
            legal = group
        offers.append(legal[rng.randi_range(0, legal.size() - 1)])
    return offers

static func legal_item(id: String, rarity: String, level: int, hero_role: String, weapon_catalog: Dictionary) -> bool:
    if not CAPS.has(rarity) or level < 1 or level > int(CAPS[rarity]):
        return false
    if weapon_catalog.has(id):
        return weapon_catalog[id]["role"] == hero_role
    if not PASSIVE_DATA.has(id):
        return false
    var passive: Dictionary = PASSIVE_DATA[id]
    return passive["rarity"] == rarity and (passive["role"] == "" or passive["role"] == hero_role)
