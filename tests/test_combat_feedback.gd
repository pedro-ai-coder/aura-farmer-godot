extends SceneTree
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile=ProfileStoreScript.defaults()
    func _save_profile() -> void: pass
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func verify() -> void:
    var game = ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.start_run(0)
    game._spawn_enemy("npc", {"pos":game.player_pos+Vector2(80,0)})
    var enemy: Dictionary = game.enemies[0]
    enemy["born"] = 0.0
    enemy["hp"] = 100.0
    game._hit_enemy(enemy, 20.0)
    expect(enemy["hp"] == 80.0 and game.combat_feedback.size() == 1,"Successful damage produces one impact with unchanged damage")
    game._hit_enemy(enemy, 0.0)
    expect(game.combat_feedback.size() == 1,"Zero damage creates no impact")
    var stamp: float = game.run_time
    game.mode = "paused"
    game._process(1.0)
    expect(game.run_time == stamp and game.combat_feedback.size() == 1,"Pause freezes feedback and simulation together")
    game.mode = "playing"
    game._hit_enemy(enemy, 100.0)
    expect(game.enemies.is_empty() and game.defeated_visuals.size() == 1,"Death feedback does not retain a live collision enemy")
    expect(game.combat_feedback.back()["kind"] == "defeat","Death has its own bounded feedback")
    var rng_before: int = game.rng.state
    for i in range(100): game._combat_cue("hit",Vector2.ZERO)
    expect(game.rng.state == rng_before,"Visual feedback never consumes gameplay RNG")
    expect(game.combat_feedback.size() == 64,"Dense combat feedback is bounded")
    game.enemies.clear();game.pickups.clear();game.spawn_timer=INF
    game._advance(0.4)
    expect(game.combat_feedback.is_empty(),"Active simulation expires feedback")
    game._combat_cue("hit",Vector2.ZERO)
    game.start_run(0)
    expect(game.combat_feedback.is_empty(),"Restart clears transient feedback")
    game.max_hp=129.6;game.hp=129.6
    game.clean_cut_skin.hud_layout()
    expect(game.clean_cut_skin.hp.text.contains("HP 130 / 130"),"Fractional maximum uses the same rounding as current HP")
    expect(is_equal_approx(game.hp,129.6),"HUD formatting does not clamp simulation HP")
    game.start_run(0)
    game.wave=2
    game.movement_direction=Vector2(0.15,0)
    game._spawn_phase_crystal()
    expect(game.player_pos.distance_to(game.pickups[0]["pos"])>45.0,"Slow analog input cannot spawn the crystal inside collection range")
    game.pickups.append({"pos":game.player_pos,"kind":"magnet","xp":0.0})
    game._collect_drops()
    expect(game.total_xp == 80.0 and game.pickups.is_empty(),"Magnet collects the phase crystal once without extra XP")
    game.queue_free()
    if failures.is_empty(): print("PASS: combat feedback lifecycle, bounded effects, fractional HP and phase-crystal magnet");quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
