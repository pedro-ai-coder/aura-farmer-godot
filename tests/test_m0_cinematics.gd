extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    _expect(game.mode == "menu", "Startup enters menu")
    game.start_run(0)
    game.six_to_seven_qa = true # Isolate result persistence.
    var cinema = game.big_hater_presentation
    _expect(cinema.encounter == cinema.INTRO and cinema.encounter_visible(), "Intro starts with the run")
    game._toggle_pause()
    var paused_at: float = game.run_time
    game._advance(1.0)
    _expect(not cinema.encounter_visible() and game.run_time == paused_at, "Pause hides the cue and freezes its clock")
    game._toggle_pause()
    _expect(cinema.encounter_visible(), "Resume restores the cue")
    game._advance(0.69)
    _expect(not cinema.encounter_visible() and game.enemies.is_empty(), "Intro expires before the encounter")
    game._advance(0.02)
    _expect(cinema.encounter == cinema.FIRST_POST and game.enemies.size() == 1, "First combat follows the first spawn")
    var first_at: float = cinema.encounter_at
    game.spawn_timer = 0.0
    game._advance(0.02)
    _expect(cinema.encounter_at == first_at, "Later enemies do not replay first combat")

    game.legendary_spent = true
    game.event_index = 4
    game.spawn_timer = 1e9
    game.wave = 2
    game.run_time = 239.99
    game._advance(0.02)
    _expect(game.wave == 3 and cinema.encounter == cinema.VIRAL, "Viral cue follows Wave 3")
    game.wave = 5
    game.run_time = 569.99
    game._advance(0.02)
    _expect(cinema.encounter == cinema.WARNING and not game.boss_spawned, "Warning precedes the boss")
    game.pickups.clear() # Keep the synthetic clock jump out of an XP choice.
    game.run_time = 599.99
    game._advance(0.02)
    _expect(game.boss_spawned and cinema.entrance_at == game.run_time and not cinema.encounter_visible(), "Entrance uses the original spawn clock")
    var boss: Dictionary = game.enemies[0]
    game.run_time = float(boss["born"])
    game._hit_enemy(boss, 1e9)
    _expect(game.mode == "won" and cinema.celebrating and not game.layer.visible, "Boss defeat starts victory reveal")
    game.finish_visual_age = cinema.results_at()
    cinema.update()
    _expect(game.layer.visible and game.retry_button.visible, "Victory reveals actionable results on the original clock")

    game.retry_button.pressed.emit()
    _expect(game.mode == "playing" and cinema.encounter == cinema.INTRO and cinema.entrance_at == -INF, "Retry clears old cues and restarts intro")
    game.six_to_seven_qa = true
    game.profile.settings.reducedMotion = false
    game._finish(false)
    _expect(cinema.defeat_accent_visible() and game.layer.visible and game.retry_button.visible, "Defeat leaves results immediately actionable")
    game.visual_defeat = cinema.DEFEAT_LENGTH
    _expect(not cinema.defeat_accent_visible(), "Defeat accent expires")
    game.retry_button.pressed.emit()
    game.six_to_seven_qa = true
    game.profile.settings.reducedMotion = true
    _expect(cinema.encounter_visible(), "Reduced Motion retains the intro card")
    game._finish(false)
    _expect(not cinema.defeat_accent_visible() and game.retry_button.visible, "Reduced Motion skips the defeat accent")
    if failures.is_empty():
        print("PASS: M0 cinematic boundaries, pause, boss, outcomes, retry and Reduced Motion")
    for failure in failures:
        push_error(failure)
    quit(int(not failures.is_empty()))
