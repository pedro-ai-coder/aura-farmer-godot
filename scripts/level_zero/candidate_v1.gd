extends RefCounted
## EXPERIMENTAL v1. Nothing here supersedes operational GDD V3.
const VERSION := "level-zero/0.1.0"
const STATUS := "EXPERIMENTAL"
const WAVE_COUNT := 3
const BOSS_AT := 360.0
const WARNING_AT := 330.0
const BOSS_ID := "experimental-lz-prototype-v1"
const BOSS := {"name":"HATER IMITATION", "hp":2400, "speed":32, "damage":14,
    "xp":0, "wave":3, "radius":36, "boss":true}
const VISUAL_KIND := "beta"
const FIRST_ATTACK_DELAY := 2.0
const ATTACK_INTERVAL := 4.0
const SLAM := {"radius":200.0, "delay":1.0, "active":0.12, "damage":28.0}
const BEAM := {"radius":600.0, "delay":1.2, "active":0.1, "damage":24.0}
const INTRO := "The Feed has an answer for everyone.\nCPK has a question: who said we had to listen?\n\nThree waves. One imitation. The real Big Hater is still out there.\nMove: WASD / arrows / touch. Auto-attacks. Flex: Space / button."
