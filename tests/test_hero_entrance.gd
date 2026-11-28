extends SceneTree

const Motion = preload("res://scripts/entrance_choreography.gd")
const Maps = preload("res://scripts/solo_maps.gd")
const Framing = preload("res://scripts/camera_framing.gd")
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(ok: bool, reason: String) -> void:
    if not ok:
        failures.append(reason)

func _initial(game) -> Array:
    return [game.hero.id, game.hero_appearance, game.map_id, game.player_pos, game.run_time,
        game.rng.state, game.enemies.size(), game.total_xp, game.hp, game.weapons.duplicate(true), game.spawn_timer]

func _verify() -> void:
    var garage = load("res://scenes/signal_breaker_garage.tscn").instantiate()
    root.add_child(garage)
    var game = garage.game
    _expect(garage.active and game.mode == "menu", "Startup opens Garage")
    garage.start_selected()
    game.set_process(false)
    for arena in Maps.NAMES:
        var expected := Vector2(724, 540) if arena == Maps.RUIN_ALLEY else Maps.FactoryGeometry.SPAWN
        for appearance in ["original", "female"]:
            for index in range(game.HEROES.size()):
                game.map_id = arena
                game.hero_appearance = appearance
                game.start_run(index)
                var baseline := _initial(game)
                for skip in [false, true]:
                    game._return_to_menu()
                    game.open_map_select(index)
                    game.map_select._select(arena)
                    var prior := _initial(game)
                    var old_id: String = game.run_id
                    game.profile.settings.reducedMotion = appearance == "female"
                    game.map_select._start_run()
                    var entrance = game.hero_entrance
                    var label := "%s / %s / %s" % [arena, appearance, game.HEROES[index].id]
                    _expect(game.mode == "entrance" and entrance.running and not game.layer.visible, label + " enters cinematic")
                    _expect(entrance.stage.hero_id == game.HEROES[index].id and entrance.stage.appearance == appearance, label + " uses selected atlas")
                    _expect(entrance.stage.arena == arena and entrance.spawn == expected, label + " uses selected arena spawn")
                    _expect(entrance.reduced == (appearance == "female"), label + " respects Reduced Motion")
                    game._advance(1.0)
                    _expect(_initial(game) == prior and game.run_id == old_id, label + " holds gameplay state")
                    game.start_selected_map(arena)
                    _expect(game.run_id == old_id, label + " rejects duplicate map confirmation")
                    if skip:
                        entrance.skip.pressed.emit()
                    else:
                        entrance.age = Motion.COUNTDOWN
                        entrance._sync()
                        _expect(entrance._count() == 3, label + " starts 3–2–1")
                        entrance.age = Motion.END - 0.01
                        entrance._process(0.02)
                    _expect(game.mode == "playing" and _initial(game) == baseline and game.run_id != old_id, label + " matches the ordinary start")
                    var new_id: String = game.run_id
                    entrance.complete()
                    _expect(game.run_id == new_id, label + " cannot initialize twice")
                print("PASS: ", Maps.NAMES[arena], " / ", game.hero_entrance.hero_name, " / complete + skip")
    for view in [Vector2(1440, 900), Vector2(844, 390), Vector2(390, 844)]:
        var lane := Vector2(66, 198)
        var spawn := Vector2(724, 540)
        for time in [0.0, Motion.REVEAL, Motion.SIGNATURE, Motion.HANDOFF]:
            var still := Motion.sample(time, view, spawn, lane, true, true)
            _expect(still == Motion.sample(time + 0.2, view, spawn, lane, true, true), "Reduced Motion holds each composition")
        var final := Motion.sample(Motion.COUNTDOWN, view, spawn, lane, true, false)
        var zoom := Framing.zoom_for(view, true)
        _expect(final.feet == spawn and final.zoom == zoom and final.center == Framing.clamp_center(spawn, view, zoom), "Countdown aligns with real camera and spawn")
    game._finish(false)
    game.retry_button.pressed.emit()
    _expect(game.mode == "playing" and not game.hero_entrance.running, "Retry starts without replay")
    game._return_to_menu()
    garage._process(0.0)
    _expect(garage.active and not game.hero_entrance.visible, "Results return to Garage")
    for failure in failures:
        push_error(failure)
    quit(int(not failures.is_empty()))
