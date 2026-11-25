extends "res://tests/no_u/test_reverse_impact.gd"
## Run the reviewed boundary matrix against the ordinary production resolver.
func v2(game: ReviewRun, map: StringName = Maps.RUIN_ALLEY) -> void:
    super.v2(game, map)
    game.no_u_review = null
    game.no_u_runtime = game.NoUReactive.new()
    game.no_u_vfx = game.NoUV4.new()

func run() -> void:
    # The parent's matrix includes explicit review-only identity/retry assertions.
    # Compare the production resolver to the exact reviewed implementation instead.
    var game := ReviewRun.new()
    var reviewed := ReviewRun.new()
    for item: ReviewRun in [game, reviewed]:
        root.add_child(item)
        item.set_process(false)
    for map: StringName in Maps.NAMES:
        for density in [1, 2]:
            for reduced in [false, true]:
                for item: ReviewRun in [game, reviewed]:
                    item._return_to_menu()
                    item.open_map_select(0)
                    item.start_selected_map(map)
                    item.profile = item.ProfileStoreScript.defaults()
                    item.profile.settings.sound = false
                    item.profile.settings.reducedMotion = reduced
                    item._apply_card({"type":"passive", "id":"no-u", "rarity":"legendary", "level":1})
                    Scenario.new(density, true).prepare(item)
                    item.passive_timers.no_u_next = 0.0
                reviewed.no_u_review = ReverseScenario.new(density, true)
                reviewed.no_u_vfx = load("res://scripts/vfx/no_u_reverse_impact_v4.gd").new()
                check(game.no_u_review == null and game._no_u_is_reactive(), "Ordinary reactive runtime")
                check("Survive HP loss" in game.PassiveFeedbackScript.describe(game,"no-u",1), "Ordinary reactive description")
                for frame in 1200:
                    for item: ReviewRun in [game, reviewed]:
                        if frame == 20:
                            item.shield = 100.0
                            item._deal_damage_to_player(10.0)
                        if frame == 40:
                            item.shield = 5.0
                            item._deal_damage_to_player(10.0)
                            item._deal_damage_to_player(1.0)
                        if frame == 80:
                            item._schedule_hazard(item.player_pos,50.0,0.0,2.0,10.0)
                        if frame == 950:
                            item.hp = item.max_hp
                            item._deal_damage_to_player(1.0)
                        item._process(STEP)
                    var actual := state(game)
                    var expected := state(reviewed)
                    # Production legitimately records results; review deliberately does not.
                    actual.pop_back(); expected.pop_back()
                    if actual != expected:
                        check(false, "Production/review authoritative divergence %s/%d/%s/%d" % [map,density,reduced,frame])
                        break
                    check(game.no_u_vfx._at == reviewed.no_u_vfx._at and game.no_u_vfx._weakened == reviewed.no_u_vfx._weakened, "Presentation event parity")
                    paired_frames += 1
    # Ordinary legal acquisition readiness, no fixture and no periodic activation.
    game._return_to_menu()
    game.start_run(0)
    game.run_time = 5.0
    game._apply_card({"type":"passive", "id":"no-u", "rarity":"legendary", "level":1})
    check(game.no_u_review == null and game.passive_timers.no_u_next == 0.0, "Ordinary acquisition starts ready")
    game.run_time = 25.0
    game._tick_passives(0.0)
    check(game.no_u_vfx._at == -INF, "No periodic production trigger")
    game._deal_damage_to_player(1.0)
    check(game.no_u_vfx._at == 25.0 and game.passive_timers.no_u_next == 40.0, "Ordinary surviving HP trigger")
    game.start_run(0)
    check(game.no_u_vfx._at == -INF and game.no_u_runtime.last_activation == -INF, "Retry resets state")
    game.free()
    reviewed.free()
    print("Production V4: %d assertions / %d exact reviewed-state paired frames / %d failures" % [assertions,paired_frames,failures])
    quit(1 if failures else 0)
