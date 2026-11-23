extends SceneTree
## One-shot visual preview capture. It does not run or modify gameplay.

const NAMES := [
    "msg_factory", "ruin_valley", "moderation_zone",
    "echo_rails", "doomscroll_depths", "heart_of_the_feed"
]

func _initialize() -> void:
    call_deferred("_capture")


func _capture() -> void:
    var target := "res://evidence/feedverse/maps"
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target))
    for name in NAMES:
        var scene_path := "res://experiments/feedverse/maps/%s.tscn" % name
        var packed: PackedScene = load(scene_path)
        if packed == null:
            push_error("Cannot load " + scene_path)
            quit(1)
            return
        var scene: Node2D = packed.instantiate()
        root.add_child(scene)
        scene.set_physics_process(false)
        scene.camera.position = Vector2(724, 543)
        scene.camera.zoom = Vector2(0.66, 0.66)
        scene.queue_redraw()
        await RenderingServer.frame_post_draw
        await RenderingServer.frame_post_draw
        var image := root.get_texture().get_image()
        var result := image.save_png(ProjectSettings.globalize_path(
            "%s/%s.png" % [target, name]))
        if result != OK:
            push_error("Cannot save capture: " + name)
            quit(1)
            return
        print("CAPTURED ", name, " ", image.get_width(), "x", image.get_height())
        scene.queue_free()
        await process_frame
    quit(0)
