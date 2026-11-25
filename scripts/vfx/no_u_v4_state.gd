extends RefCounted
const ICE := Color("#65fff0")
const VOID := Color("#160d25")
## Fixed world-space pulse, resolved hit accents, and live No U state markers.

const TRAVEL := 0.24
const PULSE_LIFE := 0.46
const CONTACT_LIFE := 0.23
const MAX_CONTACTS := 48
const EDGE := Color("#61eafa")
const CORE := Color("#dbfbff")
const INK := Color("#122535")
const STATUS := Color("#8ec4dc")

var _origin := Vector2.ZERO
var _radius := 0.0
var _at := -INF
var _contacts := PackedVector2Array()
var _weakened: Dictionary = {}
var _latest_weaken_until := -INF


func pulse(center: Vector2, radius: float, at: float, hits: Array[Dictionary], weakened: Dictionary) -> void:
    _origin = center
    _radius = radius
    _at = at
    _contacts.clear()
    for index in mini(hits.size(), MAX_CONTACTS):
        _contacts.append(hits[index]["pos"])
    _weakened = weakened
    _latest_weaken_until = -INF
    for status: Array in weakened.values():
        _latest_weaken_until = maxf(_latest_weaken_until, float(status[1]))


var _incoming := Vector2.ZERO
var _lethal: Dictionary = {}

func incoming(source: Vector2, center: Vector2, _hazard: bool) -> void:
    _incoming = center.direction_to(source)

func classify(hits: Array[Dictionary], survivors: Array[Dictionary]) -> void:
    _lethal.clear()
    var live := {}
    for enemy in survivors:
        live[enemy.id] = true
    for index in mini(hits.size(), MAX_CONTACTS):
        var hit: Dictionary = hits[index]
        if not live.has(hit.id):
            _lethal[hit.id] = hit.pos

func clear() -> void:
    _at = -INF
    _contacts.clear()
    _weakened = {}
    _latest_weaken_until = -INF
    _lethal.clear()
    _incoming = Vector2.ZERO

func has_weaken_marker(enemy: Dictionary, now: float) -> bool:
    var applied = _weakened.get(enemy["id"])
    return applied != null and now >= float(enemy["born"]) and now < float(enemy.get("weaken_until", 0.0)) \
        and enemy.get("weaken_until") == applied[1] and enemy.get("weaken") == applied[0]


func draw_weakened(canvas: CanvasItem, enemies: Array[Dictionary], now: float) -> void:
    if now > _latest_weaken_until + 0.28:
        return
    # At most two fade groups (normal / boss), independent of crowd size.
    var groups: Array[PackedVector2Array] = [PackedVector2Array(), PackedVector2Array()]
    var backs: Array[PackedVector2Array] = [PackedVector2Array(), PackedVector2Array()]
    var alphas := [1.0, 1.0]
    var expires := PackedVector2Array()
    var expire_alpha := 0.0
    for enemy in enemies:
        var applied = _weakened.get(enemy.id)
        if applied == null or now < float(enemy.born):
            continue
        if enemy.get("weaken_until") != applied[1] or enemy.get("weaken") != applied[0]:
            continue
        var remaining := float(applied[1]) - now
        var at: Vector2 = enemy.pos + Vector2(float(enemy.radius) + 10.0, -22.0)
        if remaining <= 0.0:
            if remaining > -0.28:
                expire_alpha = maxf(expire_alpha, 1.0 - smoothstep(0.0, 0.28, -remaining))
                expires.append(at + Vector2(-6,10)); expires.append(at + Vector2(-2,10))
                expires.append(at + Vector2(2,10)); expires.append(at + Vector2(6,10))
            continue
        var group := 1 if float(applied[0]) < 0.15 else 0
        alphas[group] = lerpf(0.35, 1.0, smoothstep(0.0, 0.25, remaining))
        backs[group].append(at + Vector2(0,-7)); backs[group].append(at + Vector2(0,23))
        # Broken sword, displaced tip, downward chevrons. Never a vulnerability/up marker.
        groups[group].append(at + Vector2(-3,-4)); groups[group].append(at + Vector2(-3,1))
        groups[group].append(at + Vector2(-7,1)); groups[group].append(at + Vector2(1,1))
        groups[group].append(at + Vector2(0,4)); groups[group].append(at + Vector2(3,7))
        for row in 2:
            var y := 8.0 + row * 6.0
            groups[group].append(at + Vector2(-6,y)); groups[group].append(at + Vector2(0,y+5))
            groups[group].append(at + Vector2(0,y+5)); groups[group].append(at + Vector2(6,y))
        var duration := 2.0 if group == 1 else 4.0
        groups[group].append(at + Vector2(-7,22))
        groups[group].append(at + Vector2(-7 + 14 * clampf(remaining / duration, 0, 1),22))
    for group in 2:
        if backs[group].is_empty():
            continue
        canvas.draw_multiline(backs[group], Color(VOID, 0.88 * alphas[group]), 21.0)
        canvas.draw_multiline(groups[group], Color(VOID, alphas[group]), 4.0, true)
        canvas.draw_multiline(groups[group], Color(ICE, alphas[group]), 1.8, true)
    if not expires.is_empty():
        canvas.draw_multiline(expires, Color(ICE, expire_alpha * 0.65), 2.0, true)
