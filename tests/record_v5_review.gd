extends SceneTree

## Staged native QA reel; never ordinary-health, human-play or device/FPS acceptance.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func _initialize() -> void: call_deferred("record")
func hold(game, frames: int) -> void:
    for frame in range(frames):
        game._process(1.0/30.0)
        await process_frame

func record() -> void:
    root.size = Vector2i(1280,720)
    var game = ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    await hold(game,30)
    for index in range(3):
        game._return_to_menu()
        game.presentation.open_heroes()
        game.presentation.select_hero(index)
        await hold(game,25)
        game.presentation.home.start_button.emit_signal("pressed")
        game.touch_direction = Vector2.RIGHT
        await hold(game,25)
        game.touch_direction = Vector2.DOWN
        await hold(game,25)
        game.touch_direction = Vector2.ZERO
        game.spawn_timer = INF
        game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(70,0)})
        var target: Dictionary = game.enemies.back()
        target["hp"] = 10000.0 # Visual timing fixture, not production HP or survival evidence.
        target["max"] = 10000.0
        target["speed"] = 0.0
        game.manual_aim = true
        game.aim_point = target["pos"]
        game.aura = 100
        game._use_flex()
        await hold(game,180 if index != 1 else 150)
        game._toggle_pause()
        await hold(game,25)
        if index == 0:
            game.presentation.open_build()
            await hold(game,25)
            game.presentation.close_auxiliary()
            game.presentation.open_settings("paused")
            await hold(game,25)
            game.presentation.close_auxiliary()
        game.presentation.secondary.resume.emit_signal("pressed")
        game._gain_xp(100)
        game._open_choice()
        game.pick_upgrade(0)
        await hold(game,25)
        game.confirm_button.emit_signal("pressed")
    game.mode = "playing"
    game.run_time = 360
    game._open_legendary()
    game.pick_upgrade(0)
    await hold(game,30)
    game._defer_legendary()
    game.mode = "playing"
    game.run_time = 600
    game._spawn_logic(0)
    await hold(game,60)
    game.run_time = 720
    game._show_ui()
    await hold(game,35)
    game._finish(false)
    await hold(game,35)
    game.queue_free()
    quit()
