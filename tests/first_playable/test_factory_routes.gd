extends SceneTree

const Maps = preload("res://scripts/solo_maps.gd")
const World = preload("res://scripts/solo_world_rules.gd")
const Navigation = preload("res://scripts/enemy_navigation.gd")

var failed := false

func check(valid: bool, message: String) -> void:
    if not valid:
        failed = true
        push_error(message)

func _initialize() -> void:
    var factory = Maps.FactoryGeometry
    check(not World.walkable(Vector2(138, 449), 16.0, factory), "West crate stack must block movement")
    check(World.walkable(Vector2(186, 478), 16.0, factory), "Pavement beside west stack must stay open")
    check(World.walkable(factory.EAST_TERMINAL, 19.0, factory), "East terminal event spawn")
    for cover: Dictionary in factory.COVERS:
        exercise_cover(cover, factory)
    print("Factory routes ", "FAILED" if failed else "PASS")
    quit(1 if failed else 0)

func exercise_cover(cover: Dictionary, factory) -> void:
    var center: Vector2 = cover.pos
    var axes: Vector2 = cover.axes
    var label := str(cover.sprite.resource_path.get_file())
    for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
        var edge := absf(direction.dot(axes))
        var point := center + direction * (edge + 39.0)
        check(World.walkable(point, 16.0, factory), label + " approach " + str(direction))
        for step in range(35):
            point = World.move(point, -direction * 2.0, 16.0, factory)
        check(absf(point.distance_to(center) - edge - 16.0) <= 2.01, label + " movement stop " + str(direction))
        var shoulder := center + direction * (edge - 6.0)
        check(not World.clear_line(shoulder, shoulder, factory), label + " LOS must cover the base")
    for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
        var reach := absf(direction.dot(axes)) + 50.0
        for radius: float in [16.0, 26.0]:
            var start := center + direction * reach
            var target := center - direction * reach
            var point := start
            var state := {}
            for step in range(480):
                if point.distance_to(target) < 3.0:
                    break
                point = Navigation.move(point, target, 2.5, radius, state, factory)
                if not World.walkable(point, radius, factory):
                    check(false, label + " steering entered a solid footprint")
                    break
            check(point.distance_to(target) < 3.0, "%s pursuit %s radius %s ended at %s, target %s" % [label, direction, radius, point, target])
