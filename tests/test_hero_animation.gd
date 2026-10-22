extends SceneTree

const HeroPoses = preload("res://scripts/hero_animation.gd")
var failures: Array[String] = []

func _initialize() -> void: call_deferred("_verify")
func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _verify() -> void:
    for id in ["sigma","cool-kid","alpha"]:
        var idle := HeroPoses.pose(id,{"time":0.0})
        check(idle["state"] == "idle","Stationary heroes use idle")
        for direction in range(8):
            var run := HeroPoses.pose(id,{"moving":true,"heading":direction*PI/4,"walk":0.2,"facing":PI})
            check(run["state"] == "run","All eight directions use run")
            check(run["scale"] == idle["scale"] or run["sheet"] == "rear-v2","Scale is fixed per sheet")
        var lost := HeroPoses.pose(id,{"lost":true,"defeat":8.0,"hurt":0.1,"flex":1.0})
        check(lost["state"] == "defeat" and lost["frame"] == (32 if id == "cool-kid" else 40),"Defeat overrides combat and holds final frame")
        check(HeroPoses.pose(id,{"hurt":0.1,"flex":1.0})["state"] == "hurt","Damage pose overrides Flex")
        check(HeroPoses.pose(id,{"attack":0.22})["frame"] == (26 if id == "cool-kid" else 34),"Attack starts at first authored frame")
        check(HeroPoses.pose(id,{"attack":0.01})["frame"] == (28 if id == "cool-kid" else 36),"Attack reaches last authored frame")
        check(HeroPoses.pose(id,{"flex":0.1,"flex_age":4.9})["state"] == "flex-out","Flex has an exit pose")
    for impact in [0.0,2.0,4.0]:
        check(HeroPoses.pose("alpha",{"flex":6.0-impact,"flex_age":impact})["frame"] == 44,"Alpha impact animation follows actual slam cadence")
    check(HeroPoses.pose("alpha",{"flex":1.0,"flex_age":5.0})["frame"] == 42,"Alpha braces between impacts")
    var visuals = load("res://scripts/approved_visuals.gd")
    var enemy := {"attack_pose":{"start":0.0,"impact":0.5,"end":0.9,"angle":0.0},"hurt_at":0.49}
    check(visuals.enemy_pose_frame(enemy,0.49) == 4,"Damage cannot hide enemy windup")
    check(visuals.enemy_pose_frame(enemy,0.55) == 5,"Attack impact uses authored impact")
    check(visuals.enemy_pose_frame(enemy,0.8) == 0,"Recovery returns to neutral instead of repeating windup")
    check(visuals.enemy_pose_frame(enemy,0.55,0.2) == 7,"Death overrides attack")
    var game = load("res://scripts/solo_run.gd").new()
    root.add_child(game)
    game.set_process(false)
    game.start_run(0)
    game._move_player(0.1)
    check(game.hero_pose()["state"] == "idle" and game.visual_walk == 0,"No walk on stationary player")
    game.player_pos = Vector2(646.01,550)
    game.touch_direction = Vector2.LEFT
    game._move_player(0.1)
    check(game.visual_walk == 0,"Wall-blocked movement cannot advance walk clock")
    game.touch_direction = Vector2.RIGHT
    game._move_player(0.1)
    check(game.visual_walk > 0,"Actual travel advances walk")
    game.attack_flash = 0.2
    game.attack_visuals.append({"life":0.5})
    var before: float = game.visual_walk
    game.mode = "paused"
    game._process(0.1)
    check(game.attack_flash == 0.2 and game.attack_visuals[0]["life"] == 0.5 and game.visual_walk == before,"Pause freezes attack and motion presentation")
    game.mode = "lost"
    game._process(0.1)
    check(game.visual_defeat > 0 and game.run_time == 0,"Only defeat playback continues after loss")
    game.start_run(0)
    game._spawn_enemy("npc",{"pos":Vector2(800,600)})
    var victim: Dictionary = game.enemies.back()
    game._hit_enemy(victim,1e6)
    check(game.defeated_visuals.size() == 1 and not game.enemies.has(victim),"Defeated snapshot renders without remaining in combat")
    game.start_run(0)
    check(game.defeated_visuals.is_empty(),"Restart clears death presentation")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Authored hero poses, fixed sheet scales, Flex timing, defeat, travel clock and pause")
        quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
