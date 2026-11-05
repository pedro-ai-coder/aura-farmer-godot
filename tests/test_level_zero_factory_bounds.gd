extends SceneTree
## EXPERIMENTAL floor regression: candidate factory world vs V3 Ruin Alley parity.
const Factory = preload("res://scripts/level_zero/world_rules_v1.gd")
const Normal = preload("res://scripts/solo_world_rules.gd")
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("verify")

func check(condition: bool, reason: String) -> void:
    if not condition: failures.append(reason)

func verify() -> void:
    var wall := Vector2(724.0, 445.0)
    var entrance := Factory.PLAYER_SPAWN
    check(Normal.walkable(wall, 16.0), "Baseline Ruin Alley permits the old top area")
    check(not Factory.walkable(wall, 16.0), "Factory machinery is not walkable")
    check(Factory.walkable(entrance, 16.0), "Level Zero start lies on open ground")
    check(Factory.walkable(Factory.IMITATION_SPAWN, 36.0), "Prototype boss spawn clears the floor")
    check(Factory.walkable(Vector2(1100, 565), 16.0), "Existing recovery spot remains accessible")
    check(not Factory.walkable(Vector2(1400, 600), 16.0), "Outside right boundary is blocked")
    check(not Factory.walkable(Vector2(724, 330), 16.0), "Print-press wall is blocked")
    check(not Factory.walkable(Vector2(720, 480), 16.0), "Front of central paper stack is blocked")
    check(not Factory.walkable(Vector2(335, 440), 16.0), "Front of left machinery is blocked")
    check(not Factory.walkable(Vector2(1310, 485), 16.0), "Front of right paper pile is blocked")
    check(Factory.walkable(Vector2(724, 670), 16.0), "Player has room below central stack")
    var pushed := Factory.move(Factory.IMITATION_SPAWN, Vector2(0.0, -300.0), 16.0)
    check(Factory.walkable(pushed, 16.0) and pushed.y > 570.0, "Swept movement stops short of the press/paper stack")
    var crossing := Factory.move(Vector2(500,700), Vector2(600,0), 16.0)
    check(Factory.walkable(crossing, 16.0) and crossing.x < 925.0, "Long horizontal step does not tunnel through a cover")
    var normal = load("res://scenes/main.tscn").instantiate()
    root.add_child(normal)
    normal.set_process(false)
    check(normal._world_walkable(wall), "Normal world keeps old polygon")
    normal.queue_free()
    var level = load("res://scenes/level_zero.tscn").instantiate()
    root.add_child(level)
    level.set_process(false)
    check(not level._world_walkable(wall), "Level Zero uses factory polygon")
    level.start_run(0)
    check(level.player_pos == Factory.PLAYER_SPAWN, "Factory start is deterministic")
    level._begin_encounter()
    var heading_to_press: Vector2 = level._navigate_enemy(Factory.IMITATION_SPAWN, Vector2(724,330), 300.0, 36.0, {})
    check(Factory.walkable(heading_to_press, 36.0), "Enemy steering cannot escape the factory floor")
    level._spawn_enemy(level.Candidate.BOSS_ID, {"pos": wall})
    check(level.enemies.back()["pos"] == Factory.IMITATION_SPAWN, "Boss spawn is stage-specific")
    level.queue_free()
    if failures.is_empty():
        print("LEVEL_ZERO_FACTORY_BOUNDS: PASS (experimental polygon)")
    else:
        for issue in failures: push_error(issue)
    quit(0 if failures.is_empty() else 1)
