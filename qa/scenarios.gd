extends RefCounted
## Development/review-only synthetic starting states. Never modify canonical rules.
const OfferRules = preload("res://scripts/solo_offer_rules.gd")
const EnemyRules = preload("res://scripts/solo_enemy_rules.gd")
const Clock = preload("res://scripts/solo_clock.gd")

const PRESETS := [
    {"id":"wave1", "name":"Wave 1 / 0:00", "time":0.0, "level":1},
    {"id":"wave3", "name":"Wave 3 / 4:00", "time":240.0, "level":11},
    {"id":"wave4", "name":"Wave 4 / 6:00 (Legendary)", "time":360.0, "level":16},
    {"id":"wave5", "name":"Wave 5 / 8:00", "time":480.0, "level":20},
    {"id":"big-hater", "name":"Big Hater / 10:00", "time":600.0, "level":25}
]
const BUILD_NAMES := ["Balanced", "Damage", "Survival"]
const KIT_WEAPONS := {
    "sigma":["no-cap","ratio-blaster","brainrot-feed"],
    "cool-kid":["keyboard-warrior","ban-hammer","touch-grass"],
    "alpha":["cope-shield","chad-hands","personal-space"]
}
const KIT_ROLES := {"sigma":"ranged","cool-kid":"melee","alpha":"tank"}

static func preset(id: String) -> Dictionary:
    for entry: Dictionary in PRESETS:
        if str(entry["id"]) == id: return entry.duplicate(true)
    return {}

static func make_build(hero_id: String, scenario_id: String, style: String) -> Dictionary:
    var stage := preset(scenario_id)
    if stage.is_empty() or not KIT_WEAPONS.has(hero_id) or not BUILD_NAMES.has(style):
        return {}
    var level: int = int(stage["level"])
    var choices: Array = KIT_WEAPONS[hero_id]
    var gear: Array[Dictionary] = []
    var passives: Array[Dictionary] = []
    var weapon_rarity := "common" if level <= 11 else ("rare" if level <= 20 else "epic")
    var weapon_level := 1 if level == 1 else (2 if level <= 11 else (3 if level <= 20 else 2))
    gear.append({"id":choices[0],"rarity":weapon_rarity,"level":weapon_level})
    if level >= 11:
        gear.append({"id":choices[1],"rarity":"common" if level == 11 else "rare","level":2})
        passives.append({"id":"built-different" if style == "Survival" else "main-character","rarity":"common","level":2})
        passives.append({"id":"thick-skin" if style == "Survival" else "terminally-online","rarity":"common","level":2})
    if level >= 16:
        gear.append({"id":choices[2],"rarity":"rare","level":2})
        passives.append({"id":"certified-w" if style == "Survival" else "aura-viral","rarity":"common" if style == "Survival" else "epic","level":2 if style == "Survival" else 1})
    if level >= 20:
        passives.append({"id":"so-back" if style == "Survival" else "its-over","rarity":"epic","level":1})
        passives.append({"id":"w-squad" if style == "Survival" else "absolute-cinema","rarity":"legendary","level":1})
    if level == 25:
        gear[0]["rarity"] = "epic"
        gear[0]["level"] = 2
        gear[1]["rarity"] = "epic"
        gear[1]["level"] = 2
    return {"weapons":gear,"passives":passives}

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

static func accumulated_xp(level: int) -> float:
    var earned:=0.0
    for current in range(1,level):
        earned+=float(30+8*current+current*current)
    return earned

static func apply(game, scenario_id: String, hero_id: String, appearance: String, style: String, seed: int) -> bool:
    var stage:=preset(scenario_id)
    var build:=make_build(hero_id,scenario_id,style)
    if stage.is_empty() or not KIT_ROLES.has(hero_id) or not ["original","female"].has(appearance) or seed<0:
        return false
    if not valid_build(game,hero_id,build):return false
    var index:=-1
    for i in range(game.HEROES.size()):
        if str(game.HEROES[i]["id"])==hero_id:index=i
    if index<0:return false
    game.hero_appearance=appearance
    game._qa_starting_scenario=true
    game.start_run(index)
    game._qa_starting_scenario=false
    if game.mode!="playing":return false
    var t:=float(stage["time"])
    var level:=int(stage["level"])
    game.run_time=t
    game.wave=mini(5,1+int(t/Clock.WAVE_SECONDS))
    game.level=level
    game.total_xp=accumulated_xp(level)
    game.xp=0.0
    game.weapons.clear()
    for item: Dictionary in build["weapons"]:
        var entry:=item.duplicate(true)
        entry["timer"]=0.0
        game.weapons.append(entry)
    game.passives.clear()
    for item: Dictionary in build["passives"]:game.passives.append(item.duplicate(true))
    game._recompute_max_hp()
    game.hp=game.max_hp
    game.event_index=0
    for event: Dictionary in EnemyRules.EVENT_SCHEDULE:
        if float(event["at"])<=t:game.event_index+=1
    game.legendary_spent=t>=480.0
    game.legendary_first_shown=t>=480.0
    game.legendary_second_shown=t>=480.0
    game.boss_spawned=t>=Clock.BOSS_AT
    game.spawn_timer=5.0 if game.boss_spawned else 0.7
    game.rng.seed=seed
    game.passive_timers.clear()
    for passive: Dictionary in game.passives:
        var id:=str(passive["id"])
        var periodic: Dictionary={"w-wifi":12.0,"big-chad":10.0,"no-u":15.0}
        if periodic.has(id):game.passive_timers[{"w-wifi":"wifi_next","big-chad":"big_chad_next","no-u":"no_u_next"}[id]]=t+float(periodic[id])
    if game.boss_spawned:
        game._spawn_enemy("boss",{"pos":Vector2(724.0,445.0),"telegraph":true})
    game._qa_synthetic=true
    game._qa_scenario={
        "scenario_id":scenario_id,"seed":seed,"hero_id":hero_id,"appearance":appearance,
        "build_style":style,"equipment":build.duplicate(true),"level":level,"time":t,
        "provenance":"controlled_synthetic_fixture_not_played_history"
    }
    game._show_ui()
    game._update_text()
    game._update_camera(0.0,true)
    return true
