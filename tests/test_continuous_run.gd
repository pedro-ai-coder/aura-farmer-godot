extends SceneTree

# Protected-player integration fixture. Real spawns, weapons, drops and offers;
# 0.25-second frames use the production fixed substeps; no clock jumps or XP grants.
# Survival/balance, rendered FPS and human acceptance are deliberately excluded.
class ProtectedRun extends "res://scripts/solo_run.gd":
    func _deal_damage_to_player(_amount: float, _source: Dictionary = {}, _contact: bool = false, _hazard: bool = false) -> void:
        pass

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _verify() -> void:
    var game = ProtectedRun.new()
    root.add_child(game)
    game.set_process(false)
    var started := Time.get_ticks_msec()
    for hero_index in range(3):
        game.start_run(hero_index)
        game.rng.seed = 451
        var waves: Array[int] = []
        var choices := 0
        var legendary := 0
        var max_pending := 0
        for frame in range(6000):
            if game.mode == "won" or game.mode == "lost": break
            if game.mode == "legendary":
                var index := 0
                for i in range(game.legendary_offers.size()):
                    if game.legendary_offers[i]["id"] == game.hero["starter"]: index = i
                game.pick_upgrade(index)
                game._confirm_selection()
                legendary += 1
            elif game.mode == "choice":
                var index := 0
                for i in range(game.selection.size()):
                    if game.selection[i]["type"] == "weapon":
                        index = i
                        break
                game.pick_upgrade(index)
                game._confirm_selection()
                choices += 1
            elif game.mode == "replace":
                game.pick_upgrade(0)
                game._confirm_selection()
            elif game.mode == "playing":
                var target: Vector2 = Vector2(724,610)
                var nearest := INF
                for drop: Dictionary in game.pickups:
                    var distance: float = game.player_pos.distance_squared_to(drop["pos"])
                    if distance < nearest:
                        nearest = distance
                        target = drop["pos"]
                if nearest == INF:
                    var enemy: Dictionary = game._nearest_target()
                    if not enemy.is_empty(): target = enemy["pos"]
                var angle: float = (target - game.player_pos).angle() + 0.5 * sin(game.run_time * 2.0)
                game.touch_direction = Vector2.from_angle(angle)
                if game.aura >= 100.0: game._use_flex()
                game._process(0.25)
            else:
                _expect(false, "Continuous fixture encountered an unexpected modal")
                break
            if not waves.has(game.wave): waves.append(game.wave)
            max_pending = maxi(max_pending, game.pending_choices)
            _expect(game.weapons.size() <= 3 and game.passives.size() <= 5, "Inventory caps hold throughout the run")
            for item: Dictionary in game.weapons + game.passives:
                _expect(int(item["level"]) <= int(game.CAP_LEVELS[item["rarity"]]), "Item levels remain legal throughout the run")
            _expect(is_finite(game.hp + game.xp + game.aura + float(game.run_metrics["damage"])), "Run numeric state remains finite")
            if game.run_time >= 1200.0 and game.mode == "playing": break
        _expect(waves == [1,2,3,4,5], "Every hero traverses all five waves without clock jumps")
        _expect(game.run_time >= 900.0 and game.boss_spawned, "Every hero reaches the real boss transition")
        _expect(choices > 0 and legendary == 1, "Actual XP drops and one legendary use real confirmation flows")
        _expect(game.total_xp >= 560.0 and game.kills > 0, "Progression includes wave rewards and combat drops")
        _expect(float(game.run_metrics["damage"]) > 0.0 and int(game.run_metrics["flexes"]) > 0, "Weapons and manual Flex activations participate in the real simulation")
        if game.mode == "playing":
            var boss: Dictionary = {}
            for enemy: Dictionary in game.enemies:
                if enemy["kind"] == "boss": boss = enemy
            _expect(not boss.is_empty(), "Surviving boss remains present for explicit terminal resolution")
            if not boss.is_empty(): game._hit_enemy(boss, 1e9)
        _expect(game.mode == "won", "Controlled continuous run resolves to a unique victory")
        print("CONTINUOUS RUN: ", game.hero["id"], ", time=", game.run_time, ", level=", game.level, ", XP=", game.total_xp, ", kills=", game.kills, ", choices=", choices, ", max queue=", max_pending, "; protected player and explicit final hit if required")
        game.start_run(hero_index)
        _expect(game.level == 1 and game.weapons.size() == 1 and game.passives.is_empty() and game.aura == 0.0 and game.kills == 0, "Restart retains no power from the completed run")
    print("CONTINUOUS CPU ELAPSED: ", Time.get_ticks_msec() - started, " ms; not rendered FPS")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Continuous seeded three-hero progression, legal offers, combat drops, boss result and clean restart")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
