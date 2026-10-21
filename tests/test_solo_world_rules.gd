extends SceneTree

## GDD Ruin Alley: geometry and spawn parity with pinned Phaser world.ts.
var failures: Array[String] = []

func _expect(ok: bool, description: String) -> void:
    if not ok:
        failures.append(description)

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var rules = load("res://scripts/solo_world_rules.gd")
    _expect(rules.FLOOR.size() == 12, "Approved floor consists of the twelve Phaser polygon vertices")
    _expect(rules.COVERS.size() == 2, "Exactly two approved Ruin Alley cover footprints")
    _expect(rules.walkable(Vector2(724, 540), 16.0), "Hero start is on accessible floor")
    _expect(not rules.walkable(Vector2(80, 80), 16.0), "Painted outer border is not walkable")
    _expect(not rules.walkable(Vector2(600, 550), 16.0), "First cover footprint blocks movement")
    _expect(not rules.walkable(Vector2(940, 680), 16.0), "Second cover footprint blocks movement")
    _expect(not rules.in_floor(Vector2(234, 448), 16.0), "Foot pivot cannot overlap a floor boundary")
    var sliding: Vector2 = rules.move(Vector2(550, 550), Vector2(25, 25), 16.0)
    _expect(is_equal_approx(sliding.x, 550.0) and is_equal_approx(sliding.y, 575.0), "X-first collision slides along cover")
    _expect(not rules.clear_line(Vector2(520, 550), Vector2(680, 550)), "Solid cover breaks line of sight")
    _expect(rules.clear_line(Vector2(450, 430), Vector2(520, 450)), "Unblocked sightline remains clear")

    var generator := RandomNumberGenerator.new()
    generator.seed = 451
    for i in range(16):
        var point = rules.spawn_point(Vector2(724, 540), generator)
        _expect(point != null, "Seeded spawn finds an unobstructed floor location")
        if point != null:
            _expect(rules.walkable(point, 24.0), "Spawn clearance matches Phaser")
            _expect(Vector2(point).distance_to(Vector2(724, 540)) >= 260.0, "Spawn stays off the hero")

    var game = load("res://scenes/main.tscn").instantiate()
    get_root().add_child(game)
    game.call("start_run", 0)
    for i in range(8):
        game.call("_spawn_enemy", "npc")
    var enemies: Array = game.get("enemies")
    _expect(enemies.size() == 8, "Ordinary spawning still works")
    for enemy: Dictionary in enemies:
        _expect(rules.walkable(enemy["pos"], 24.0), "Actual spawned enemies stay on approved floor")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Ruin Alley polygon, cover collision, line of sight and seeded floor spawns")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
