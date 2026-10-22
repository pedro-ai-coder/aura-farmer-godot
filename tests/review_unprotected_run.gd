extends SceneTree

# Autonomous acceptance controller: no invulnerability, clock jumps, XP or damage grants.
class AuditedRun extends "res://scripts/solo_run.gd":
    var audit_damage := false
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass
    func _deal_damage_to_player(amount: float, source: Dictionary = {}, contact: bool = false, hazard: bool = false) -> void:
        var before := hp
        super._deal_damage_to_player(amount,source,contact,hazard)
        if audit_damage and hp < before: print("DAMAGE ",run_time," ",source.get("kind","unknown")," ",before-hp," contact=",contact," pos=",player_pos)

func _initialize() -> void: call_deferred("_run")
func _run() -> void:
    root.size = Vector2i(1280,720)
    var game = AuditedRun.new()
    root.add_child(game)
    game.set_process(false)
    var args := OS.get_cmdline_user_args()
    var heroes := [int(args[0])] if args.size() > 0 else [0,1,2]
    game.audit_damage = args.has("--audit")
    var run_seed := int(args[1]) if args.size() > 1 else 451
    for hero_index in heroes:
        game.start_run(hero_index)
        game.rng.seed = run_seed
        var choices := 0
        var minimum_hp: float = game.hp
        for frame in range(18000):
            if game.mode in ["won","lost"]: break
            if game.mode in ["choice","legendary"]:
                var cards: Array = game.legendary_offers if game.mode == "legendary" else game.selection
                var best := -INF
                var index := 0
                for i in range(cards.size()):
                    var card: Dictionary = cards[i]
                    var id: String = card.get("id","")
                    var score := 0.0
                    if str(card.get("type","")).contains("weapon"): score = 80.0
                    if card.get("type","") == "weapon": score += 40
                    if card.get("type","") == "promote_weapon": score += 45
                    if id == "main-character": score = 75
                    if id == "built-different": score = 60
                    if id == "certified-w": score = 60
                    if id == "caught-4k": score = 95
                    if id == "thick-skin": score = 50
                    if card.get("rarity","") == "legendary":
                        score += 80
                        if id == game.hero["starter"]: score += 30
                    if score > best:
                        best = score
                        index = i
                game.pick_upgrade(index)
                game._confirm_selection()
                choices += 1
            elif game.mode == "replace":
                game.pick_upgrade(0)
                game._confirm_selection()
            elif game.mode == "playing":
                var radial: Vector2 = (game.player_pos-Vector2(740,620))/Vector2(370,205)
                var angle := radial.angle()+0.65
                var target: Vector2 = Vector2(740,620)+Vector2(cos(angle)*370,sin(angle)*205)
                var best := INF
                for drop: Dictionary in game.pickups:
                    var distance: float = game.player_pos.distance_to(drop["pos"])
                    if drop.get("kind","") == "snack" and game.hp < game.max_hp*0.82: distance *= 0.2
                    if drop.get("kind","") == "magnet": distance *= 0.3
                    if distance < best and distance < 65:
                        best = distance
                        target = drop["pos"]
                if game.hp < game.max_hp*0.4 and game.run_time >= game.safe_spot_ready_at:
                    target = Vector2(1100,565)
                var desired: Vector2 = (target-game.player_pos).normalized()
                if game.player_pos.distance_to(target) < 8: desired = Vector2.ZERO
                var winning := -INF
                var movement: Vector2 = desired
                for option in range(17):
                    var direction := Vector2.ZERO if option == 16 else Vector2.from_angle(option*TAU/16)
                    var next: Vector2 = game.SoloWorldRulesScript.move(game.player_pos,direction*45,16)
                    if direction != Vector2.ZERO and next.distance_to(game.player_pos) < 15: continue
                    var score: float = -next.distance_to(target)*0.65
                    if not game.SoloWorldRulesScript.in_floor(next,75): score -= 10000
                    for enemy: Dictionary in game.enemies:
                        if game.run_time < float(enemy.get("born",0)): continue
                        var gap: float = next.distance_to(enemy["pos"])-float(enemy["radius"])-16
                        if gap < 125: score -= pow(maxf(0,125-gap)/20,2)*4
                        if gap < 15: score -= 200
                    for shot: Dictionary in game.hostile_shots:
                        if next.distance_to(shot["pos"]) < 50: score -= 40
                    for hazard: Dictionary in game.hazard_zones:
                        if game._hazard_contains(hazard,next,22): score -= 300
                    if direction == Vector2.ZERO and game.player_pos.distance_to(target) < 15: score += 10
                    if score > winning:
                        winning = score
                        movement = direction
                var priority: Dictionary = {}
                for enemy: Dictionary in game.enemies:
                    if game.SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"] and game.player_pos.distance_to(enemy["pos"]) < 590 and game.SoloWorldRulesScript.clear_line(game.player_pos,enemy["pos"]): priority = enemy
                game.manual_aim = game.hero["role"] == "ranged" and not priority.is_empty()
                if game.manual_aim: game.aim_point = priority["pos"]
                game.touch_direction = movement
                if game.aura >= 100: game._use_flex()
                game._process(0.1)
                minimum_hp = minf(minimum_hp,game.hp)
            else: break
        print("UNPROTECTED RESULT ",JSON.stringify({"hero":game.hero["id"],"seed":run_seed,"mode":game.mode,"seconds":game.run_time,"hp":game.hp,"minimum_hp":minimum_hp,"level":game.level,"kills":game.kills,"boss":game.boss_spawned,"choices":choices,"healing":game.run_metrics["healing"],"flexes":game.run_metrics["flexes"],"recovery":game.recovery_counts,"station_uses":game.safe_spot_uses,"weapons":game.weapons,"passives":game.passives}))
    game.queue_free()
    quit()
