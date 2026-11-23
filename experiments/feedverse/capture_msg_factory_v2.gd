extends SceneTree
## Actual Godot renders for the MSG Factory V2 art review.

const OUTPUT := "res://evidence/feedverse/msg-factory-v2"

func _initialize() -> void:
    call_deferred("_capture")


func _save(name: String) -> bool:
    await RenderingServer.frame_post_draw
    await RenderingServer.frame_post_draw
    var image := root.get_texture().get_image()
    var path := ProjectSettings.globalize_path("%s/%s.png" % [OUTPUT, name])
    var result := image.save_png(path)
    if result != OK:
        push_error("Could not save " + path)
        return false
    print("CAPTURED ", name, " ", image.get_width(), "x", image.get_height())
    return true


func _capture() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
    var preview: Node2D = load("res://experiments/feedverse/maps/msg_factory.tscn").instantiate()
    root.add_child(preview)
    preview.set_physics_process(false)
    preview.player = Vector2(-1000, -1000)
    for child in preview.get_children():
        if child is CanvasLayer:
            child.visible = false
    preview.camera.position = Vector2(724, 543)
    preview.camera.zoom = Vector2(0.66, 0.66)
    preview.queue_redraw()
    if not await _save("after-overview"):
        quit(1)
        return
    preview.camera.position = Vector2(460, 305)
    preview.camera.zoom = Vector2(1.42, 1.42)
    preview.queue_redraw()
    if not await _save("after-detail"):
        quit(1)
        return
    preview.queue_free()
    await process_frame

    var combat: Node2D = load(
        "res://experiments/feedverse/maps/msg_factory_combat.tscn").instantiate()
    root.add_child(combat)
    await process_frame
    await process_frame
    if combat.mode != "playing":
        push_error("MSG Factory combat preview did not start")
        quit(1)
        return
    for i in range(5):
        combat._spawn_enemy("npc")
    await create_timer(1.5).timeout
    combat.queue_redraw()
    if not await _save("after-combat"):
        quit(1)
        return
    combat.queue_free()
    quit(0)
