extends RefCounted

# Review-only deterministic route/aim policy for ordinary-health acceptance.
# This file is never used by the shipping game. It neither writes to simulation
# state nor consumes RNG. The original avoidance controller remains the baseline.
const World = preload("res://scripts/solo_world_rules.gd")
const Recovery = preload("res://scripts/recovery_rules.gd")
const EnemyRules = preload("res://scripts/solo_enemy_rules.gd")

static func goal(game, patrol: Vector2) -> Dictionary:
    var result := {"kind":"patrol","pos":patrol}
    var health_ratio: float = clampf(float(game.hp) / maxf(1.0,float(game.max_hp)),0.0,1.0)
    var position: Vector2 = game.player_pos
    var best_score := 0.0
    var xp_waiting := 0.0
    for item: Dictionary in game.pickups:
        if item.get("kind","") == "aura":
            xp_waiting += float(item.get("xp",0.0))
    if health_ratio < 0.75 and float(game.run_time) >= float(game.safe_spot_ready_at):
        var distance := position.distance_to(Recovery.SAFE_SPOT)
        if distance <= 500.0:
            var score := 700.0 * (1.0-health_ratio) + 80.0 - distance
            if score > best_score:
                best_score = score
                result = {"kind":"station","pos":Recovery.SAFE_SPOT}
    for item: Dictionary in game.pickups:
        var kind: String = str(item.get("kind",""))
        if kind != "snack" and kind != "magnet":
            continue
        var destination: Vector2 = item["pos"]
        if not World.walkable(destination,12.0):
            continue
        var distance := position.distance_to(destination)
        if distance > 440.0:
            continue
        var value := 0.0
        if kind == "snack" and health_ratio < 0.85:
            value = 750.0 * (1.0-health_ratio) + 95.0
        elif kind == "magnet" and xp_waiting >= 30.0:
            value = 170.0 + minf(250.0,xp_waiting*0.15)
        var score := value - distance
        # Do not assume an obstacle is traversable simply because its graphic
        # does not fill its collider. Other routes can be found on later ticks.
        if not World.clear_line(position,destination):
            score -= 150.0
        if score > best_score:
            best_score = score
            result = {"kind":kind,"pos":destination}
    return result

static func movement(game, target: Dictionary) -> Vector2:
    var destination: Vector2 = target["pos"]
    var location: Vector2 = game.player_pos
    var station_hold: bool = str(target["kind"]) == "station" and location.distance_to(Recovery.SAFE_SPOT) <= Recovery.SAFE_RADIUS-20.0
    var best_direction := Vector2.ZERO
    var best_score := -INF
    var step: float = float(game.hero["speed"])*0.1
    if float(game.flex_time) > 0.0 and str(game.hero["id"]) == "cool-kid":
        step *= 1.25
    for option in range(17):
        var direction := Vector2.ZERO if option == 16 else Vector2.from_angle(float(option)*TAU/16.0)
        var next: Vector2 = World.move(location,direction*step,16.0)
        if direction != Vector2.ZERO and next.distance_to(location) < 2.0:
            continue
        var score := -next.distance_to(destination)*0.75
        if not World.in_floor(next,25.0):
            score -= 1000.0
        for enemy: Dictionary in game.enemies:
            if float(game.run_time) < float(enemy.get("born",0.0)):
                continue
            var gap: float = next.distance_to(enemy["pos"])-float(enemy["radius"])-16.0
            if gap < 100.0:
                score -= pow(maxf(0.0,100.0-gap)/20.0,2.0)*5.0
            if gap < 22.0:
                score -= 180.0
        for shot: Dictionary in game.hostile_shots:
            var velocity: Vector2 = Vector2(shot["dir"])*float(shot["speed"])
            var eta := 0.0
            if velocity.length_squared() > 0.0:
                eta = clampf((next-Vector2(shot["pos"])).dot(velocity)/velocity.length_squared(),0.0,0.45)
            var closest: Vector2 = Vector2(shot["pos"])+velocity*eta
            var miss_distance := next.distance_to(closest)
            if miss_distance < 42.0:
                score -= pow((42.0-miss_distance)/10.0,2.0)*8.0
        for hazard: Dictionary in game.hazard_zones:
            if float(hazard["end"]) < float(game.run_time) or float(hazard["at"]) > float(game.run_time)+0.8:
                continue
            if game._hazard_contains(hazard,next,18.0):
                score -= 480.0 if float(hazard["at"]) <= float(game.run_time) else 240.0
        if station_hold:
            # The approved zone requires two continuous active seconds. Staying
            # inside is useful, but a real imminent enemy hit can still drive
            # the unprotected controller to evade and reset its charge.
            score += 105.0 if next.distance_to(Recovery.SAFE_SPOT) <= Recovery.SAFE_RADIUS-20.0 else -210.0
            if direction == Vector2.ZERO:
                score += 25.0
        elif direction == Vector2.ZERO and location.distance_to(destination) < 12.0:
            score += 15.0
        if score > best_score:
            best_score = score
            best_direction = direction
    return best_direction

static func aim_target(game) -> Dictionary:
    var result: Dictionary = {}
    var best := -INF
    var hero_id: String = str(game.hero["id"])
    var limit := 600.0 if hero_id == "sigma" else (165.0 if hero_id == "cool-kid" else 190.0)
    if hero_id == "alpha" and float(game.flex_time) <= 0.0 and float(game.aura) < 100.0:
        return result
    if hero_id == "cool-kid" and float(game.flex_time) <= 0.0 and float(game.aura) < 100.0:
        return result
    for enemy: Dictionary in game.enemies:
        if float(game.run_time) < float(enemy.get("born",0.0)) or float(enemy["hp"]) <= 0.0:
            continue
        var distance: float = Vector2(game.player_pos).distance_to(enemy["pos"])
        if distance > limit or not World.clear_line(game.player_pos,enemy["pos"]):
            continue
        var kind: String = str(enemy["kind"])
        var priority := 500.0 if EnemyRules.DATA[kind]["boss"] else (180.0 if kind == "ping-sniper" or kind == "doomscroller" else 0.0)
        var score: float = priority-distance
        if result.is_empty() or score > best or (is_equal_approx(score,best) and int(enemy["id"]) < int(result["id"])):
            result = enemy
            best = score
    return result

static func should_use_flex(game, target: Dictionary) -> bool:
    if float(game.aura) < 100.0 or float(game.flex_lock) > 0.0 or str(game.mode) != "playing":
        return false
    if str(game.hero["id"]) == "sigma":
        return not game._nearest_target(600.0).is_empty()
    if target.is_empty():
        return false
    var distance: float = Vector2(game.player_pos).distance_to(target["pos"])
    return distance <= (120.0 if str(game.hero["id"]) == "cool-kid" else 155.0)
