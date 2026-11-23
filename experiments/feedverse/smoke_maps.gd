extends SceneTree
## Minimal scene/integration check for the six opt-in previews.

const NAMES := [
    "msg_factory", "ruin_valley", "moderation_zone",
    "echo_rails", "doomscroll_depths", "heart_of_the_feed"
]

func _initialize() -> void:
    call_deferred("_check")


func _check() -> void:
    for name in NAMES:
        var path := "res://experiments/feedverse/maps/%s_combat.tscn" % name
        var scene: Node2D = load(path).instantiate()
        root.add_child(scene)
        await process_frame
        await process_frame
        if scene.mode != "playing":
            push_error(name + ": Solo preview did not start")
            quit(1)
            return
        var rules = scene.world_rules
        if not rules.walkable(scene.player_pos, 16.0):
            push_error(name + ": player spawn invalid")
            quit(1)
            return
        var before: Vector2 = scene.player_pos
        var after: Vector2 = rules.move(before, Vector2(8, 0), 16.0)
        if after.x <= before.x or not rules.walkable(after, 16.0):
            push_error(name + ": movement invalid")
            quit(1)
            return
        scene._spawn_enemy("npc")
        if scene.enemies.is_empty() or not rules.walkable(scene.enemies[0].pos,
                float(scene.enemies[0].radius)):
            push_error(name + ": enemy spawn invalid")
            quit(1)
            return
        print("PASS ", name)
        scene.queue_free()
        await process_frame
    quit(0)
