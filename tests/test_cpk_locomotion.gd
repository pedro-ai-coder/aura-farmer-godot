extends SceneTree

const Proposed = preload("res://scripts/proposed_cpk_art.gd")
const Sigma = preload("res://scripts/sigma_cpk_animation.gd")
const Cool = preload("res://scripts/cool_kid_cpk_animation.gd")
const Vixen = preload("res://scripts/pixel_vixen_animation.gd")
var failures: Array[String] = []

func _initialize() -> void: call_deferred("verify")
func check(value: bool, message: String) -> void:
    if not value: failures.append(message)

func pose(id: String, appearance: String, state: Dictionary) -> Dictionary:
    if id == "sigma": return Vixen.pose(state) if appearance == "female" else Sigma.pose(state)
    if id == "cool-kid" and appearance == "original": return Cool.pose(state)
    return Proposed.pose(id,appearance,state)

func verify() -> void:
    for id in ["sigma", "cool-kid", "alpha"]:
        for appearance in ["original", "female"]:
            var name: String = id + "/" + appearance
            check(pose(id,appearance,{})["state"] == "idle", name + " idle")
            var frames := {}
            for step in range(8):
                var state := {"moving":true,"heading":0.0,"facing":PI,"walk":step/9.0}
                var run := pose(id,appearance,state)
                check(run["state"] == "run" and not run["flip"], name + " right")
                frames[run["frame"]] = true
                state["heading"] = PI
                check(pose(id,appearance,state)["flip"], name + " left")
            check(frames.size() >= 4, name + " advances through run frames")
            for event in [{"attack":0.1}, {"hurt":0.1}, {"flex":1.0,"flex_age":0.0}, {"flex":1.0,"flex_age":1.0}, {"flex":0.1,"flex_age":1.0}, {"lost":true}]:
                check(pose(id,appearance,event)["state"] != "idle", name + " event state")
    var game = load("res://scripts/solo_run.gd").new()
    root.add_child(game)
    game.set_process(false)
    game.start_run(0)
    game.player_pos = Vector2(646.01,550)
    game.touch_direction = Vector2.LEFT
    game._move_player(0.1)
    check(not game.visual_moving and game.hero_pose()["state"] == "idle", "Blocked movement is idle")
    game.touch_direction = Vector2.RIGHT
    game._move_player(0.1)
    check(game.visual_moving and game.hero_pose()["state"] == "run", "Actual movement runs")
    game.touch_direction = Vector2.ZERO
    game._move_player(0.1)
    check(not game.visual_moving and game.hero_pose()["state"] == "idle", "Stopping returns to idle")
    game.queue_free()
    if failures.is_empty():
        print("PASS: six appearance state and locomotion playback checks")
        quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
