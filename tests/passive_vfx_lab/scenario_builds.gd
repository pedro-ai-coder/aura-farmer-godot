extends RefCounted
# Kit selection and build validation from QA Scenario Mode (#105).
const OfferRules = preload("res://scripts/solo_offer_rules.gd")

const KIT_WEAPONS := {
    "sigma":["no-cap","ratio-blaster","brainrot-feed"],
    "cool-kid":["keyboard-warrior","ban-hammer","touch-grass"],
    "alpha":["cope-shield","chad-hands","personal-space"]
}
const KIT_ROLES := {"sigma":"ranged","cool-kid":"melee","alpha":"tank"}

static func valid_build(game, hero_id: String, build: Dictionary) -> bool:
    if not KIT_ROLES.has(hero_id) or not build.has("weapons") or not build.has("passives"):
        return false
    var ws: Array = build["weapons"]
    var ps: Array = build["passives"]
    if ws.is_empty() or ws.size()>3 or ps.size()>5:return false
    var ids: Dictionary={}
    var legendary := 0
    for item: Dictionary in ws+ps:
        var id := str(item.get("id",""))
        var rarity := str(item.get("rarity",""))
        var level := int(item.get("level",0))
        if ids.has(id) or not OfferRules.legal_item(id,rarity,level,KIT_ROLES[hero_id],game.WEAPONS):
            return false
        ids[id]=true
        if rarity=="legendary":legendary+=1
    return legendary<=1
