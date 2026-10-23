extends SceneTree
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)
func verify() -> void:
    root.size = Vector2i(1280,720)
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    await process_frame
    game.start_run(0)
    var hud = game.presentation.spotlight_hud
    hud.sync(Vector2(1280,720))
    game.run_time = 120
    game.wave = 2
    hud.sync(Vector2(1280,720))
    check(hud.banner_visible() and hud.banner_title == "WAVE 2" and hud.banner_subtitle == "COMMENT SECTION","Wave banner follows actual canonical state")
    var before: float = hud.banner_until
    hud.sync(Vector2(1280,720))
    check(hud.banner_until == before,"Refresh cannot prolong a banner")
    game.mode = "paused"
    check(not hud.banner_visible(),"Pause does not expose friendly transition overlay")
    game.mode = "playing"
    game._spawn_enemy("hater",{"pos":Vector2(760,550)})
    game.enemies.back()["phase"] = "warning"
    check(not hud.banner_visible(),"Enemy warning suppresses optional transition emphasis")
    game.enemies.clear()
    game.run_time = before+0.01
    check(not hud.banner_visible(),"Banner expires on active simulation time")
    game.camera.zoom = Vector2.ONE
    game.camera.position = Vector2(800,565)
    var plate: Rect2 = hud.boss_rectangle({"pos":Vector2(724,445)})
    check(plate.position.x == 16 and plate.size.x <= 300,"Boss plate shifts aside when its silhouette would be covered")
    game.boss_spawned = true
    game.run_time = 720
    hud.sync(Vector2(1280,720))
    check(hud.banner_title == "FULL HATER MODE","Berserk banner follows 120-second boss deadline")
    game.start_run(0)
    hud.sync(Vector2(1280,720))
    check(not hud.banner_visible(),"Restart clears old encounter feedback")
    game.queue_free()
    if failures.is_empty(): print("PASS: Simulation-bound wave/boss HUD feedback and danger priority"); quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
