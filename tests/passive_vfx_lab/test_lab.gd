extends SceneTree

const Lab := preload("res://tests/passive_vfx_lab/lab_run.gd")
var failures := 0

func _initialize() -> void:
    run.call_deferred()

func check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error(message)

func state(game: Lab) -> Array:
    return [game.mode, game.run_time, game.hp, game.max_hp, game.shield, game.kills, game.aura,
        game.primary_hits, game.rng.state, game.run_metrics, game.passive_timers, game.enemies,
        game.weapons, game.player_shots, game.hostile_shots, game.hazard_zones,
        game.cook_stacks, game.cook_expires, game.directional_hits, game.weapon_shields, game.profile.results]

func run() -> void:
    var baseline := Lab.new()
    var candidate := Lab.new()
    candidate.candidate = true
    root.add_child(baseline)
    root.add_child(candidate)
    var comparisons := 0
    for id: String in baseline.SoloOfferRulesScript.PASSIVE_DATA:
        check(baseline.stage(id, false, false, false, false, false), "Illegal baseline " + id)
        check(candidate.stage(id, false, false, true, false, false), "Illegal candidate " + id)
        var seen := {}
        var peak_cook := 0
        var flex_seen := false
        for frame in 420:
            baseline.tick()
            candidate.tick()
            check(state(baseline) == state(candidate), "%s simulation or RNG changed on frame %d" % [id, frame])
            seen.merge(candidate.passive_timers)
            peak_cook = maxi(peak_cook, candidate.cook_stacks)
            flex_seen = flex_seen or candidate.flex_time > 0
            comparisons += 1
        match id:
            "w-wifi": check(seen.has("wifi_until"), "Wi-Fi never formed a zone")
            "big-chad": check(seen.has("big_chad_next") and float(candidate.passive_timers.big_chad_next) > Lab.START + 10, "Big Chad never became due")
            "homie-check", "so-back": check(float(candidate.run_metrics.healing) > 0.0, "No effective healing: " + id)
            "too-sigma": check(seen.has("too_sigma_ready"), "Too Sigma never crossed its shield threshold")
            "no-u": check(float(candidate.passive_timers.no_u_next) > Lab.START + 15, "No U never pulsed")
            "w-squad": check(seen.has("w_squad_until"), "W Squad never entered its window")
            "aura-viral": check(seen.has("viral_until"), "Viral never entered its window")
            "absolute-cinema": check(flex_seen, "Cinema never activated Flex")
            "let-him-cook": check(peak_cook >= 3, "Cook missed its mid-stack threshold")
            "no-cap-streak": check(candidate.directional_hits >= 5, "Streak missed its fifth activation")
            "six-to-seven": check(candidate.burst_count > 0 and baseline.records == candidate.records, "Six → Seven contacts differ")
    check(candidate.stage("six-to-seven", true, true, false, false, false), "Crowded build illegal")
    check(candidate.passives.size() == 5 and candidate.weapons.size() == 3, "Crowded equipment count")
    for frame in 180:
        candidate.tick()
    var trace := candidate.records.duplicate(true)
    check(not trace.is_empty(), "Dense fixture missed the burst")
    candidate.stage("six-to-seven", true, true, false, false, false)
    for frame in 180:
        candidate.tick()
    check(trace == candidate.records, "Dense replay diverged")
    candidate.stage("six-to-seven", false, false, false, false, false)
    _boundary(candidate)
    _weapon_triggers(candidate)
    print("Lab checks: ", comparisons, " paired frames across 23 passives, dense replay and blast truth. Failures: ", failures)
    baseline.free()
    candidate.free()
    quit(1 if failures else 0)

func _boundary(game: Lab) -> void:
    game.passive_timers.six_counter = 6
    var target: Dictionary = game.enemies[0]
    var center: Vector2 = target.pos
    game.enemies[1].pos = center + Vector2(90, 0)
    game.enemies[2].pos = center + Vector2(90.01, 0)
    game.enemies[3].pos = center + Vector2(30, 0)
    game.enemies[3].shield = 100.0
    game.enemies[3].shield_until = INF
    game._target(Vector2(150, 15), "npc")
    game.enemies[-1].born = 100.0
    var before: float = game.run_metrics.damage
    var hits := game.primary_hits
    var rng: int = game.rng.state
    game._primary_activation(center)
    check(game.burst_count == 1 and game.last_burst.radius == 90.0, "Radius or burst count changed")
    check(game.last_burst.center == [center.x, center.y], "Burst was not struck-target centered")
    check(game.passive_feedback.rings.is_empty(), "Candidate retained the legacy Six → Seven ring")
    var contacts: Array = game.last_burst.contacts
    check(contacts.size() == 2, "Only the center and exact boundary may lose HP")
    if contacts.size() == 2:
        check(contacts[0].id == target.id and contacts[1].id == game.enemies[1].id, "Wrong contacts at blast boundary")
        check(is_equal_approx(float(contacts[0].hp_lost), game._base_power() * 0.35), "Level-one coefficient changed")
        check(is_equal_approx(float(contacts[0].hp_lost + contacts[1].hp_lost), float(game.run_metrics.damage) - before), "Contact sum diverges from actual HP loss")
    check(game.primary_hits == hits + 1 and game.rng.state == rng, "Secondary blast recursed or drew RNG")
    var ready: float = game.passive_timers.six_ready
    check(is_equal_approx(ready, game.run_time + 2.0), "Lockout is not two active seconds")
    game._primary_activation(center)
    check(game.passive_timers.six_counter == 0 and game.burst_count == 1, "Lockout accumulated or emitted")
    game.mode = "paused"
    var at := game.run_time
    game.tick()
    check(game.run_time == at, "Paused run advanced the VFX clock")
    game.mode = "playing"
    game.run_time = ready
    game._primary_activation(center)
    check(game.passive_timers.six_counter == 1, "Counter did not resume at the deadline")
    game.stage("six-to-seven", false, false, false, false, false)
    check(game.records.is_empty() and game.burst_vfx.slots[0].at == -INF, "Replay leaked a burst")
    game.passive_timers.six_counter = 6
    game._spawn_enemy("boss", {"pos": game.enemies[0].pos})
    game.enemies[-1].hp = 1.0
    game._primary_activation(center)
    check(game.mode == "won" and game.burst_count == 1 and game.burst_vfx.slots[0].at == -INF,
        "Victory must record the outcome without leaving visible marks")

func _weapon_triggers(game: Lab) -> void:
    for slot in 3:
        game.stage("six-to-seven", false, false, false, false, false)
        game.passives[0].level = 2
        game.passive_timers.six_counter = 6
        for item in game.weapons:
            item.timer = INF
        game.weapons[slot].timer = 0.0
        for frame in 70:
            game.tick()
            if game.burst_count > 0:
                break
        check(game.burst_count == 1, "No real collision burst from " + str(game.weapons[slot].id))
        if game.burst_count > 0:
            check(is_equal_approx(float(game.last_burst.contacts[0].hp_lost), game._base_power() * 0.50),
                "Level-two coefficient changed for " + str(game.weapons[slot].id))
