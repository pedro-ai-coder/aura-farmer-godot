extends SceneTree

const Maps = preload("res://scripts/solo_maps.gd")
const World = preload("res://scripts/solo_world_rules.gd")
class CaptureRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:
        profile = ProfileStoreScript.defaults()
    func _save_profile() -> void:
        pass
class CaptureGarage extends "res://scripts/signal_breaker_garage.gd":
    func _create_run() -> Node:
        return CaptureRun.new()

var out: String
var game
var garage
var failed := false

func _initialize() -> void:
    call_deferred("run")

func check(valid: bool, message: String) -> void:
    if not valid:
        failed = true
        push_error(message)

func click(button: Button) -> void:
    check(button.is_visible_in_tree() and not button.disabled, "Unavailable button: " + button.text)
    var pointer := button.get_global_transform_with_canvas() * (button.size * 0.5)
    var motion := InputEventMouseMotion.new()
    motion.position = pointer
    root.push_input(motion, true)
    for down in [true, false]:
        var event := InputEventMouseButton.new()
        event.button_index = MOUSE_BUTTON_LEFT
        event.position = pointer
        event.pressed = down
        root.push_input(event, true)
    await process_frame

func capture(filename: String) -> void:
    if out.is_empty() or DisplayServer.get_name() == "headless":
        return
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    check(root.get_texture().get_image().save_png(out.path_join(filename)) == OK, filename)

func run() -> void:
    var args := OS.get_cmdline_user_args()
    if not args.is_empty():
        out = args[0]
        DirAccess.make_dir_recursive_absolute(out)
    root.size = Vector2i(1440, 900)
    garage = CaptureGarage.new()
    root.add_child(garage)
    await process_frame
    game = garage.game
    await click(garage.play_button)
    check(game.mode == "maps" and game.map_select.start.disabled, "Map select did not require an explicit choice")
    await click(game.map_select.back)
    await process_frame
    check(garage.active, "Back did not return to the garage")
    await click(garage.play_button)
    await click(game.map_select.choices[Maps.RUIN_ALLEY])
    await click(game.map_select.start)
    check(game.mode == "playing" and game.map_id == Maps.RUIN_ALLEY and game.map_geometry == null, "Ruin Alley did not launch")
    game.set_process(false)
    game._advance(2.0)
    check(not game.enemies.is_empty(), "Ruin Alley spawned no enemies")
    await capture("ruin-alley.png")
    game._return_to_menu()
    await process_frame
    await process_frame
    await click(garage.play_button)
    await click(game.map_select.choices[Maps.MSG_FACTORY])
    check(game.map_select.selected == Maps.MSG_FACTORY, "Factory selection was lost")
    await capture("map-select.png")
    await click(game.map_select.start)
    check(game.mode == "playing" and game.map_id == Maps.MSG_FACTORY and game.map_geometry != null, "MSG Factory did not launch")
    game.set_process(false)
    game._advance(2.0)
    check(not game.enemies.is_empty(), "MSG Factory spawned no enemies")
    check(World.walkable(game.player_pos, 16, game.map_geometry), "Factory spawn overlaps a collider")
    check(World.walkable(Vector2(1100,565), 16, game.map_geometry), "Safe Spot unreachable")
    check(World.walkable(Vector2(724,445), 48, game.map_geometry), "Big Hater spawn invalid")
    check(World.walkable(game.map_geometry.EAST_TERMINAL, 19, game.map_geometry), "Factory terminal overlaps a collider")
    for cover: Dictionary in game.map_geometry.COVERS:
        check(not World.walkable(cover.pos, 16, game.map_geometry), "Factory prop failed to collide")
        check(not World.clear_line(cover.pos - Vector2(100,0), cover.pos + Vector2(100,0), game.map_geometry), "Factory prop failed to block combat")
    game.queue_redraw()
    await capture("msg-factory.png")
    game.player_pos = Vector2(535, 355)
    game._update_camera(0.0, true)
    game.queue_redraw()
    game.layer.hide()
    await capture("msg-factory-door-and-cover.png")
    game.layer.show()
    game.mode = "lost"
    game._show_ui()
    await click(game.retry_button)
    check(game.mode == "playing" and game.map_id == Maps.MSG_FACTORY, "Retry changed maps")
    print("First playable flow ", "FAILED" if failed else "PASS")
    quit(1 if failed else 0)
