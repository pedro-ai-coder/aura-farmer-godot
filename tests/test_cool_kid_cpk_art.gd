extends SceneTree
const CPK = preload("res://scripts/cool_kid_cpk_animation.gd")
const Canonical = preload("res://scripts/hero_animation.gd")
const Visuals = preload("res://scripts/approved_visuals.gd")
const Trace = preload("res://tests/frame_pacing/state_trace.gd")
var failures: Array[String] = []

class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
    if not ok and not failures.has(message): failures.append(message)

func verify() -> void:
    var visuals := Visuals.new()
    check(visuals.cool_kid_cpk_atlas != null,"Verified atlas loads")
    check(visuals.cool_kid_cpk_atlas.get_size() == Vector2(1008,1008),"Imported geometry")
    var altered: Image = visuals.cool_kid_cpk_atlas.get_image().duplicate()
    altered.set_pixel(72,60,Color.MAGENTA)
    check(not Visuals._cool_kid_texture_valid(ImageTexture.create_from_image(altered)),"Changed imported pixels fail integrity gate")
    var image := visuals.cool_kid_cpk_atlas.get_image()
    for index in range(49):
        var frame := image.get_region(Rect2i(CPK.source_rect(index)))
        var bounds := frame.get_used_rect()
        check(bounds.size.x > 20 and bounds.size.y > 20,"Every pose has visible art")
        check(bounds.position.x > 1 and bounds.position.y > 1 and bounds.end.x < 143 and bounds.end.y < 143,"No clipping/neighbour bleed")
    for state in [{},{"moving":true},{"attack":0.22},{"attack":0.145},{"hurt":0.18,"flex":2.0},{"flex":5.0,"flex_age":0.1},{"flex":3.0,"flex_age":2.0},{"flex":0.1,"flex_age":4.9},{"lost":true,"defeat":0.4,"hurt":0.1}]:
        var before := var_to_bytes(state)
        var pose := CPK.pose(state)
        check(pose["state"] == Canonical.pose("cool-kid",state)["state"],"Canonical precedence/deadlines")
        check(before == var_to_bytes(state),"Presentation does not mutate state")
    check(CPK.pose({"attack":0.22})["frame"] == 16,"Windup has raised bat")
    check(CPK.pose({"attack":0.145})["frame"] == 18,"Execution starts at existing impact descriptor")
    check(CPK.pose({"lost":true,"defeat":0.375})["frame"] == 41,"Defeat settles at existing deadline")
    for direction in range(8):
        for step in range(28):
            var pose := CPK.pose({"moving":true,"heading":direction*PI/4,"walk":step/63.0})
            check(pose["frame"] >= 7 and pose["frame"] <= 13 and pose["scale"] == 0.75,"All headings use declared side run at fixed scale")
    var legacy := ReviewRun.new()
    var current := ReviewRun.new()
    root.add_child(legacy); root.add_child(current)
    legacy.set_process(false); current.set_process(false)
    legacy.art.cool_kid_cpk_atlas = null
    for appearance in ["original","female"]:
        for game in [legacy,current]:
            game.hero_appearance = appearance
            game.start_run(1)
            game.rng.seed = 451
        for step in range(360):
            for game in [legacy,current]:
                game.touch_direction = Vector2.RIGHT if step < 180 else Vector2.LEFT
                game._process(1.0/60.0)
                game.hero_pose()
            for key in Trace.KEYS:
                check(var_to_bytes(legacy.get(key)) == var_to_bytes(current.get(key)),"Art-only parity: "+key)
            check(legacy.rng.state == current.rng.state,"Exact RNG parity")
        check(current.hero_pose()["sheet"] == ("byte-baddie" if appearance == "female" else CPK.SHEET),"Appearance isolation")
        check(legacy.hero_pose()["sheet"] != CPK.SHEET,"Legacy fallback remains usable")
        current.mode = "lost"; current.visual_defeat = 1.0
        check(current.hero_pose()["state"] == "defeat","Lost state")
        current.start_run(1)
        check(current.hero_pose()["state"] == "idle" and current.visual_defeat == 0.0,"Restart resets presentation")
    legacy.queue_free(); current.queue_free()
    if failures.is_empty():
        print("PASS: CPK import/alpha/padding, timing, state precedence, eight headings, restart, Byte Baddie and 720 exact gameplay/RNG parity steps")
        quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
