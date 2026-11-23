extends Node2D
## Isolated map-layout experiment. No production gameplay code or RNG is used.
@export_range(0, 5) var map_index := 0
const WORLD := Vector2(1448, 1086)
const DATA_PATH := "res://experiments/feedverse/maps.json"
const PLAYER_RADIUS := 16.0
const EnvironmentArt = preload("res://experiments/feedverse/environment_art.gd")
const CpkEmblem = preload("res://assets/production/cpk-brand-2026-11-13-v1/cpk-emblem-color-96.png")
const DisplayFont = preload("res://assets/fonts/Inter-Black.ttf")
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
    var banner := ColorRect.new()
    banner.color = Color("13233a", 0.86)
    banner.position = Vector2.ZERO
    banner.size = Vector2(1280, 52)
    banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay.add_child(banner)
    overlay.add_child(label)
    label.position = Vector2(18, 15)
    label.add_theme_font_size_override("font_size", 18)
    label.add_theme_font_override("font", DisplayFont)
    var emblem := Sprite2D.new()
    emblem.texture = CpkEmblem
    emblem.position = Vector2(1232, 26)
    emblem.scale = Vector2(0.44, 0.44)
    overlay.add_child(emblem)
    _load_map(map_index)

func _load_map(index: int) -> void:
    map_index = posmod(index, maps.size())
    data = maps[map_index]
    floor_polygon = PackedVector2Array()
    for p in data.floor:
        floor_polygon.append(Vector2(p[0], p[1]))
    player = Vector2(data.spawn[0], data.spawn[1])
    label.text = "%s  |  ENVIRONMENT CANDIDATE  |  WASD / arrows: move  |  [ / ]: switch" % data.name
    label.add_theme_color_override("font_color", Color("f3e9db"))
    label.add_theme_color_override("font_shadow_color", Color("13233a"))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
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
    EnvironmentArt.draw_map(self, data, floor_polygon, WORLD)
    draw_circle(player + Vector2(3, 9), 20.0, Color("13233a", 0.55))
    draw_circle(player, PLAYER_RADIUS, Color("13233a"))
    draw_arc(player, PLAYER_RADIUS - 2.0, 0.0, TAU, 32, Color("f3e9db"), 3.0)
    draw_circle(player, 8.0, Color("ff6a00"))
