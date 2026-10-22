extends RefCounted

## Canonical GDD §§5.3, 10, 12, 25.1 (22 October 2026).
## Clock only: no implicit HP, XP, density, damage or drop rebalance.
const WAVE_SECONDS := 120.0
const HATER_AT := 60.0
const LEGENDARY_FIRST := 360.0
const LEGENDARY_REPRISE := 480.0
const LEGENDARY_DEADLINE := 595.0
const BOSS_WARNING := 570.0
const BOSS_AT := 600.0
const BERSERK_AT := 720.0
const LAST_EFFORT_AT := 840.0
const EVENT_SCHEDULE: Array = [
    {"at":135.0, "kind":"reply-guy"},
    {"at":255.0, "kind":"mod-supremo"},
    {"at":375.0, "kind":"ohio-express"},
    {"at":495.0, "kind":"doomscroll-prime"}
]

static func warning(time: float) -> String:
    if time >= LAST_EFFORT_AT: return "LAST PUSH! / FULL HATER MODE"
    if time >= BERSERK_AT: return "FULL HATER MODE"
    if time >= BOSS_AT: return "BERSERK IN %ds" % ceili(BERSERK_AT-time)
    if time >= BOSS_WARNING: return "BIG HATER IN %ds" % ceili(BOSS_AT-time)
    return ""
