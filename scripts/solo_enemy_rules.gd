class_name SoloEnemyRules
extends RefCounted

## Gameplay identifiers and numeric enemy baselines: canonical GDD §§11–12.
## Exactly 17 kinds from the pinned Phaser solo bestiary, including events and terminal.

const DATA: Dictionary = {"npc":{"name":"Phone Guy","hp":35,"speed":75,"damage":8,"xp":5,"wave":1,"radius":15,"boss":false},"hater":{"name":"Hater","hp":50,"speed":60,"damage":10,"xp":8,"wave":1,"radius":17,"boss":false},"reply-goblin":{"name":"Reply Goblin","hp":25,"speed":125,"damage":6,"xp":6,"wave":2,"radius":12,"boss":false},"beta":{"name":"Beta Bot","hp":120,"speed":45,"damage":16,"xp":12,"wave":2,"radius":21,"boss":false},"ratio-ram":{"name":"Ratio Ram","hp":80,"speed":60,"damage":20,"xp":10,"wave":2,"radius":19,"boss":false},"doomscroller":{"name":"Doomscroller","hp":70,"speed":50,"damage":8,"xp":12,"wave":3,"radius":17,"boss":false},"hype-bot":{"name":"Hype Bot","hp":65,"speed":55,"damage":6,"xp":12,"wave":3,"radius":17,"boss":false},"fanum-leech":{"name":"Fanum Leech","hp":90,"speed":70,"damage":10,"xp":12,"wave":3,"radius":18,"boss":false},"ping-sniper":{"name":"Ping Sniper","hp":60,"speed":40,"damage":24,"xp":12,"wave":4,"radius":16,"boss":false},"copium-puffer":{"name":"Copium Puffer","hp":90,"speed":45,"damage":12,"xp":12,"wave":4,"radius":21,"boss":false},"comment-mod":{"name":"Comment Mod","hp":100,"speed":50,"damage":10,"xp":14,"wave":5,"radius":18,"boss":false},"reply-guy":{"name":"Reply Guy","hp":1400,"speed":40,"damage":14,"xp":120,"wave":2,"radius":32,"boss":true},"mod-supremo":{"name":"Mod Supremo","hp":3200,"speed":32,"damage":28,"xp":240,"wave":3,"radius":36,"boss":true},"ohio-express":{"name":"Ohio Express","hp":2800,"speed":55,"damage":22,"xp":120,"wave":4,"radius":34,"boss":true},"doomscroll-prime":{"name":"Doomscroll Prime","hp":5200,"speed":25,"damage":18,"xp":240,"wave":5,"radius":38,"boss":true},"boss":{"name":"Big Hater","hp":30000,"speed":22,"damage":12,"xp":0,"wave":6,"radius":48,"boss":true},"terminal":{"name":"Silence Terminal","hp":250,"speed":0,"damage":0,"xp":0,"wave":5,"radius":19,"boss":false}}
const Clock = preload("res://scripts/solo_clock.gd")
const EVENT_SCHEDULE: Array = Clock.EVENT_SCHEDULE

static func is_event(kind: String) -> bool:
    return ["reply-guy", "mod-supremo", "ohio-express", "doomscroll-prime"].has(kind)

static func spawn_pool(wave: int, time: float) -> Array[String]:
    var eligible: Array[String] = []
    for id in DATA.keys():
        var enemy: Dictionary = DATA[id]
        if enemy["boss"] or id == "terminal" or int(enemy["wave"]) > wave:
            continue
        if id == "hater" and time < Clock.HATER_AT:
            continue
        eligible.append(id)
    if wave == 1 and time >= Clock.HATER_AT:
        return ["npc", "npc", "npc", "npc", "npc", "npc", "npc", "hater"]
    var weighted: Array[String] = []
    if wave == 2:
        for id in eligible:
            if id != "hater":
                weighted.append(id)
                weighted.append(id)
        weighted.append("hater")
    elif wave >= 3:
        for id in eligible:
            weighted.append(id)
            if id != "doomscroller" and id != "ping-sniper":
                weighted.append(id)
    else:
        weighted = eligible
    return weighted

static func spawn_kind(wave: int, time: float, rng) -> String:
    var pool := spawn_pool(wave, time)
    if pool.is_empty():
        return "npc"
    return pool[rng.randi_range(0, pool.size() - 1)]
