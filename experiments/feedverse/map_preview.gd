extends Node2D
## Isolated map-layout experiment. No production gameplay code or RNG is used.
@export_range(0, 5) var map_index := 0
const WORLD := Vector2(1448, 1086)
const DATA_PATH := "res://experiments/feedverse/maps.json"
const PLAYER_RADIUS := 16.0
var maps: Array = []
var data: Dictionary
var floor_polygon := PackedVector2Array()
var player := Vector2.ZERO
var camera: Camera2D
var label: Label

func _ready() -> void:
    maps = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
    camera = Camera2D.new()
    add_child(camera)
    label = Label.new()
    var overlay := CanvasLayer.new()
    add_child(overlay)
    overlay.add_child(label)
    label.position = Vector2(18, 15)
    label.add_theme_font_size_override("font_size", 18)
    _load_map(map_index)

func _load_map(index: int) -> void:
    map_index = posmod(index, maps.size())
    data = maps[map_index]
    floor_polygon = PackedVector2Array()
    for p in data.floor:
        floor_polygon.append(Vector2(p[0], p[1]))
    player = Vector2(data.spawn[0], data.spawn[1])
    label.text = "%s  |  EXPERIMENTAL GRAYBOX  |  WASD / arrows: move  |  [ / ]: switch" % data.name
    queue_redraw()

func _physics_process(delta: float) -> void:
    var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if Input.is_key_pressed(KEY_A): input.x -= 1.0
    if Input.is_key_pressed(KEY_D): input.x += 1.0
    if Input.is_key_pressed(KEY_W): input.y -= 1.0
    if Input.is_key_pressed(KEY_S): input.y += 1.0
    var step := input.limit_length() * 220.0 * minf(delta, 0.05)
    var x := player + Vector2(step.x, 0)
    if _walkable(x): player = x
    var y := player + Vector2(0, step.y)
    if _walkable(y): player = y
    var view := get_viewport_rect().size
    var z := maxf(maxf(view.x / WORLD.x, view.y / WORLD.y), minf(view.x / 1040.0, view.y / 585.0))
    camera.zoom = Vector2(z, z)
    var half := view / z * 0.5
    camera.position = Vector2(clampf(player.x, half.x, WORLD.x - half.x), clampf(player.y, half.y, WORLD.y - half.y))
    queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_BRACKETLEFT: _load_map(map_index - 1)
        if event.keycode == KEY_BRACKETRIGHT: _load_map(map_index + 1)

func _walkable(p: Vector2) -> bool:
    if not Geometry2D.is_point_in_polygon(p, floor_polygon): return false
    for i in range(floor_polygon.size()):
        var nearest := Geometry2D.get_closest_point_to_segment(p, floor_polygon[i], floor_polygon[(i + 1) % floor_polygon.size()])
        if p.distance_to(nearest) < PLAYER_RADIUS: return false
    for c in data.covers:
        if p.distance_to(Vector2(c[0], c[1])) <= float(c[2]) + PLAYER_RADIUS: return false
    return true

func _draw() -> void:
    if data.is_empty(): return
    var base := Color(data.color)
    var accent := Color(data.accent)
    draw_rect(Rect2(Vector2.ZERO, WORLD), Color("18171d"))
    draw_colored_polygon(floor_polygon, base)
    # All linework is decorative and deliberately separate from collision data.
    for i in range(floor_polygon.size()):
        draw_line(floor_polygon[i], floor_polygon[(i + 1) % floor_polygon.size()], Color("211e25"), 12.0)
    match int(data.style):
        0:
            for x in [280, 1120]:
                draw_rect(Rect2(x, 220, 100, 560), Color(accent, 0.14), true)
                for y in range(240, 760, 70): draw_line(Vector2(x, y), Vector2(x + 100, y), Color(accent, 0.25), 5.0)
        1:
            draw_line(Vector2(230, 500), Vector2(1200, 500), Color("aaa09a", 0.25), 65.0)
            draw_line(Vector2(230, 500), Vector2(1200, 500), Color("f3e9db", 0.4), 3.0)
        2:
            for x in [250, 1190]: draw_line(Vector2(x, 250), Vector2(x, 800), Color(accent, 0.32), 9.0)
        3:
            for y in [300, 340, 790, 830]: draw_line(Vector2(240, y), Vector2(1200, y), Color(accent, 0.28), 8.0)
        4:
            for x in range(300, 1200, 110): draw_rect(Rect2(x, 190, 65, 30), Color(accent, 0.3))
        5:
            draw_arc(Vector2(720, 520), 310, 0, TAU, 64, Color(accent, 0.35), 12.0)
            draw_arc(Vector2(720, 520), 360, 0, TAU, 64, Color("9b00ff", 0.24), 6.0)
    for c in data.covers:
        var p := Vector2(c[0], c[1])
        var radius := float(c[2])
        draw_circle(p + Vector2(7, 10), radius + 4.0, Color("25212b"))
        draw_circle(p, radius, Color("302d35"))
        draw_arc(p, radius - 8.0, 0, TAU, 32, accent.darkened(0.2), 6.0)
        draw_line(p + Vector2(-radius * 0.45, 0), p + Vector2(radius * 0.45, 0), Color("f3e9db", 0.65), 4.0)
    draw_circle(player + Vector2(0, 7), 18.0, Color(0, 0, 0, 0.45))
    draw_circle(player, PLAYER_RADIUS, Color("f3e9db"))
    draw_circle(player, 7.0, Color("ff6a00"))
