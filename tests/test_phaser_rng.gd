extends SceneTree

const SeededRng = preload("res://scripts/phaser_rng.gd")
const Offers = preload("res://scripts/solo_offer_rules.gd")
const Enemies = preload("res://scripts/solo_enemy_rules.gd")
const RunScript = preload("res://scripts/solo_run.gd")
var failures: Array[String] = []

func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _initialize() -> void:
    var rng := SeededRng.new()
    rng.seed = 451
    # Generated independently with Phaser's JavaScript Mulberry32 and floor.
    for expected in [517581,930193,475277,893140,470349,107972,678600,614024]:
        var before := rng.state
        check(rng.randi_range(0,1000000) == expected,"Integer draws match the JavaScript reference")
        check(rng.state != before,"Integer draw advances the seeded stream")
    var floats := SeededRng.new()
    var integers := SeededRng.new()
    floats.seed = 987654321
    integers.seed = 987654321
    for i in range(1000):
        var expected := -7+int(floor(floats.randf()*23))
        check(integers.randi_range(-7,15) == expected,"Integer/float interleaving shares one stream")
        check(integers.randf() == floats.randf(),"Subsequent float consumes the next shared draw")
    for role in ["ranged","melee","tank"]:
        var first := SeededRng.new()
        var second := SeededRng.new()
        first.seed = 451
        second.seed = 451
        for wave in range(1,6):
            var a := Offers.choices(role,wave,[],[],RunScript.WEAPONS,first)
            # Changing global RNG must not alter seeded offers or enemy kinds.
            seed(937+wave)
            var b := Offers.choices(role,wave,[],[],RunScript.WEAPONS,second)
            check(a == b and first.state == second.state,"Fresh equal seeds produce equal legal offers")
            for i in range(20):
                check(Enemies.spawn_kind(wave,200.0,first) == Enemies.spawn_kind(wave,200.0,second),"Spawn selection shares deterministic integer draws")
    if failures.is_empty():
        print("PASS: Seeded integer JavaScript parity, shared draw state, offers and enemy selection")
        quit()
    else:
        for failure in failures: push_error(failure)
        quit(1)
