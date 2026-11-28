extends Node2D

signal finished

const Camera = preload("res://scripts/entrance_choreography.gd")
const Cast = preload("res://scripts/entrance_cast.gd")
const Stage = preload("res://scripts/entrance_stage.gd")
const Maps = preload("res://scripts/solo_maps.gd")
const Appearance = preload("res://scripts/hero_appearance.gd")
const Type = preload("res://scripts/clean_cut_typography.gd")
const Audio = preload("res://scripts/combat_audio.gd")
const PAPER := Color("fff9e9")
const INK := Color("14101c")

var game
var stage: Node2D
var skip: Button
var cue: AudioStreamPlayer
var cues: Array[AudioStreamWAV] = []
var spawn := Vector2.ZERO
var age := 0.0
var running := false
var reduced := false
var hero_name := ""
var safe := Rect2()
var last_count := 0
var last_shot := -1

func install(owner_game) -> void:
    game = owner_game
    var canvas := CanvasLayer.new()
    canvas.layer = game.layer.layer + 2
    game.add_child(canvas)
    canvas.add_child(self)
    stage = Stage.new()
    stage.z_index = -1
    stage.game = game
    add_child(stage)
    skip = Button.new()
    skip.text = "SKIP"
    skip.add_theme_font_override("font", Type.DISPLAY)
    skip.add_theme_font_size_override("font_size", 16)
    skip.pressed.connect(complete)
    add_child(skip)
    cue = AudioStreamPlayer.new()
    cue.volume_db = -17.0
    add_child(cue)
    if game.combat_audio.playback_enabled:
        cues.assign([Audio.make_clip([0.46, 98.0, 38.0, 0.35]),
            Audio.make_clip([0.27, 179.0, 57.0, 0.20]), Audio.make_clip([0.13, 535.0, 290.0, 0.06])])
    hide()
    set_process(false)

func begin(hero: Dictionary, appearance: String, arena: StringName, at: Vector2) -> void:
    stage.arena = arena
    stage.hero_id = hero.id
    stage.appearance = appearance
    hero_name = Appearance.display_name(hero.id, appearance, hero.name)
    reduced = bool(game.profile.settings.reducedMotion)
    stage.reduced = reduced
    spawn = at
    age = 0.0
    last_shot = -1
    last_count = 0
    running = true
    show()
    _sync()
    skip.grab_focus()
    set_process(true)

func _process(delta: float) -> void:
    age += minf(delta, 0.10)
    if age >= Camera.END:
        complete()
    else:
        _sync()

func _unhandled_key_input(event: InputEvent) -> void:
    if running and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
        get_viewport().set_input_as_handled()
        complete()

func complete() -> void:
    if not running:
        return
    running = false
    set_process(false)
    skip.release_focus()
    cue.stop()
    hide()
    finished.emit()

func _sync() -> void:
    var view := get_viewport_rect().size
    safe = game._touch_playfield().intersection(Rect2(Vector2.ZERO, view))
    if safe.size.x < 180.0 or safe.size.y < 140.0:
        safe = Rect2(Vector2.ZERO, view)
    skip.size = Vector2(104, 48)
    skip.position = safe.end - Vector2(116, safe.size.y - 12)
    var profile: Dictionary = Stage.ARENAS[stage.arena]
    var frame := Camera.sample(age, view, spawn, profile.lane, game.touch_device, reduced)
    stage.frame = frame
    stage.age = age
    stage.entrance_mix = 0.0 if reduced and frame.shot == 3 else 1.0 - smoothstep(Camera.HANDOFF, Camera.COUNTDOWN, age)
    stage.position = view * 0.5 - Vector2(frame.center) * float(frame.zoom)
    stage.scale = Vector2.ONE * float(frame.zoom)
    stage.queue_redraw()
    var count := _count()
    if count > 0 and count != last_count:
        _play(2)
    elif frame.shot != last_shot and frame.shot in [1, 2]:
        _play(frame.shot - 1)
    last_count = count
    last_shot = frame.shot
    queue_redraw()

func _play(index: int) -> void:
    if cues.is_empty() or not bool(game.profile.settings.sound):
        return
    cue.stream = cues[index]
    cue.play()

func _count() -> int:
    return clampi(ceili(Camera.END - age), 1, 3) if age >= Camera.COUNTDOWN else 0

func _draw() -> void:
    if not running:
        return
    var view := get_viewport_rect().size
    var profile: Dictionary = Stage.ARENAS[stage.arena]
    var count := _count()
    if count > 0:
        var center := safe.get_center() - Vector2(0, minf(86.0, safe.size.y * 0.19))
        var size := minf(60.0, safe.size.y * 0.16)
        draw_colored_polygon(PackedVector2Array([center + Vector2(0, -size), center + Vector2(size, 0),
            center + Vector2(0, size), center + Vector2(-size, 0)]), Color(INK, 0.90))
        _text(str(count), center + Vector2(0, size * 0.31), size * 0.96, size, profile.accent, true)
        return
    var bars := minf(42.0, view.y * 0.08) * float(stage.entrance_mix)
    draw_rect(Rect2(0, 0, view.x, bars), INK)
    draw_rect(Rect2(0, view.y - bars, view.x, bars), INK)
    if stage.frame.shot == 0 and not reduced:
        # Foreground occlusion follows a different screen-space path from the
        # world plate, giving the arrival a near doorway and a receding floor.
        var edge := view.x * lerpf(0.20, 0.035, smoothstep(0.0, Camera.REVEAL, age))
        draw_colored_polygon(PackedVector2Array([Vector2.ZERO, Vector2(edge * 1.65, 0),
            Vector2(edge * 0.54, view.y), Vector2(0, view.y)]), INK)
        draw_line(Vector2(edge * 1.61, 0), Vector2(edge * 0.52, view.y), Color(profile.trim, 0.8), 3.0, true)
    if stage.frame.shot == 1:
        _panel(str(Maps.NAMES[stage.arena]).to_upper(), "", profile.accent)
    elif stage.frame.shot == 2:
        _panel(hero_name, Cast.signature(stage.hero_id, stage.appearance)[0], profile.trim)

func _panel(title: String, line: String, accent: Color) -> void:
    var width := minf(440.0, safe.size.x - 32.0)
    var height := minf(100.0 if not line.is_empty() else 72.0, safe.size.y * 0.25)
    var at := Vector2(safe.position.x + 16.0, safe.end.y - height - 24.0)
    var points := PackedVector2Array([at + Vector2(15, 0), at + Vector2(width, 0),
        at + Vector2(width - 15, height), at + Vector2(0, height)])
    draw_colored_polygon(points, Color(INK, 0.96))
    draw_line(points[0], points[1], accent, 3.0, true)
    _text(title, at + Vector2(width * 0.5, height * (0.49 if not line.is_empty() else 0.68)),
        minf(33.0, height * 0.40), width - 34.0, PAPER, true)
    if not line.is_empty():
        _text(line, at + Vector2(width * 0.5, height * 0.80), minf(20.0, height * 0.25), width - 36.0, accent)

func _text(value: String, center_baseline: Vector2, pixels: float, available: float, color: Color, display := false) -> void:
    var font: Font = Type.DISPLAY if display else Type.BODY
    var font_size := maxi(1, roundi(pixels))
    var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
    if width > available:
        font_size = maxi(1, floori(font_size * available / width))
        width = font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
    draw_string(font, center_baseline - Vector2(width * 0.5, 0), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
