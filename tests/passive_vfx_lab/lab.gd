extends Control

const Run := preload("res://tests/passive_vfx_lab/lab_run.gd")
const Offers := preload("res://scripts/solo_offer_rules.gd")
const INK := Color("#101523")
const PAPER := Color("#f6ebd9")
const MUTED := Color("#b7c2d7")
const GOLD := Color("#ffc171")

var games: Array[Run] = []
var views: Array[SubViewport] = []
var panes: Array[SubViewportContainer] = []
var passive: OptionButton
var density: OptionButton
var speed: OptionButton
var reduced: CheckButton
var hud: CheckButton
var pause: Button
var status: Label
var elapsed: Label
var controls: HFlowContainer
var layout: BoxContainer
var accumulator := 0.0
var paused := false
var automatic := false
var build_sha := "uncommitted"

func _ready() -> void:
    var canvas := ColorRect.new()
    canvas.color = INK
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(canvas)
    var pad := MarginContainer.new()
    pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left", "right", "top", "bottom"]:
        pad.add_theme_constant_override("margin_" + side, 12)
    add_child(pad)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 8)
    pad.add_child(column)
    var title := HBoxContainer.new()
    column.add_child(title)
    var name_plate := _label("CLUTCHPUNKS  /  PASSIVE VFX LAB", 20, PAPER)
    name_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title.add_child(name_plate)
    elapsed = _label("", 16, MUTED)
    title.add_child(elapsed)
    controls = HFlowContainer.new()
    controls.add_theme_constant_override("h_separation", 8)
    controls.add_theme_constant_override("v_separation", 4)
    column.add_child(controls)
    passive = _picker(controls, [], 186)
    for id: String in Offers.PASSIVE_DATA:
        passive.add_item(Offers.PASSIVE_DATA[id].name)
        passive.set_item_metadata(passive.item_count - 1, id)
        if id == "six-to-seven":
            passive.select(passive.item_count - 1)
    density = _picker(controls, ["Low density", "Dense combat", "Dense + overlap"])
    speed = _picker(controls, ["1×", "¼×"])
    speed.item_selected.connect(func(_index: int): accumulator = 0.0)
    reduced = _toggle(controls, "Reduced motion")
    hud = _toggle(controls, "Game HUD")
    pause = _button(controls, "Pause", _toggle_pause)
    _button(controls, "Replay", replay)
    _button(controls, "Screenshot", _screenshot)
    _button(controls, "Save traces", _save_traces)
    passive.item_selected.connect(func(_index: int): replay())
    density.item_selected.connect(func(_index: int): replay())
    reduced.toggled.connect(func(_value: bool): replay())
    hud.toggled.connect(func(value: bool):
        for game in games:
            game.show_hud(value))
    layout = BoxContainer.new()
    layout.add_theme_constant_override("separation", 9)
    layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(layout)
    _pane("BASELINE", MUTED, false)
    _pane("PROPOSED", GOLD, true)
    status = _label("", 14, MUTED)
    status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    column.add_child(status)
    resized.connect(_fit_layout)
    _fit_layout()
    get_window().title = "CLUTCHPUNKS | Passive VFX Lab"
    var args := OS.get_cmdline_user_args()
    for arg in args:
        if arg.begins_with("--sha="):
            build_sha = arg.trim_prefix("--sha=")
    replay()
    if args.has("--capture"):
        automatic = true
        _capture.call_deferred(args)

func _label(value: String, font_size: int, tint: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", tint)
    return label

func _picker(parent: Control, options: Array, width: int = 0) -> OptionButton:
    var control := OptionButton.new()
    control.custom_minimum_size = Vector2(width, 36)
    control.fit_to_longest_item = false
    for item: String in options:
        control.add_item(item)
    parent.add_child(control)
    return control

func _button(parent: Control, value: String, action: Callable) -> Button:
    var control := Button.new()
    control.text = value
    control.custom_minimum_size.y = 36
    control.pressed.connect(action)
    parent.add_child(control)
    return control

func _toggle(parent: Control, value: String) -> CheckButton:
    var control := CheckButton.new()
    control.text = value
    parent.add_child(control)
    return control

func _pane(label: String, tint: Color, candidate: bool) -> void:
    var stack := VBoxContainer.new()
    stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(stack)
    stack.add_child(_label(label, 15, tint))
    var pane := SubViewportContainer.new()
    pane.stretch = true
    pane.mouse_filter = Control.MOUSE_FILTER_IGNORE
    pane.size_flags_vertical = Control.SIZE_EXPAND_FILL
    stack.add_child(pane)
    panes.append(pane)
    var viewport := SubViewport.new()
    viewport.size = Vector2i(550, 450)
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    viewport.gui_disable_input = true
    pane.add_child(viewport)
    views.append(viewport)
    var game := Run.new()
    game.candidate = candidate
    game.pause_requested.connect(_pause_comparison)
    viewport.add_child(game)
    games.append(game)

func _fit_layout() -> void:
    layout.vertical = size.x < 700.0
    var target_height := 56.0 if size.x <= 1160.0 else 36.0
    for control: Control in controls.get_children():
        control.custom_minimum_size.y = target_height

func replay() -> void:
    accumulator = 0.0
    paused = false
    pause.text = "Pause"
    var id: String = passive.get_selected_metadata()
    for game in games:
        game.build_sha = build_sha
        if not game.stage(id, density.selected > 0, density.selected == 2, reduced.button_pressed, hud.button_pressed):
            push_error("Illegal lab fixture: " + id)
            paused = true
    status.text = "Synthetic QA · WASD / arrows to move · Replay restores the same starting state"

func _toggle_pause() -> void:
    paused = not paused
    pause.text = "Resume" if paused else "Pause"

func _pause_comparison() -> void:
    if not automatic:
        paused = true
        pause.text = "Resume"

func _process(delta: float) -> void:
    if automatic or games.is_empty():
        return
    if not paused:
        accumulator += minf(delta, 0.1) * (0.25 if speed.selected == 1 else 1.0)
        while accumulator >= Run.STEP:
            _tick()
            accumulator -= Run.STEP
    _update_clock()

func _tick() -> void:
    for game in games:
        game.tick()

func _update_clock() -> void:
    elapsed.text = "%.2fs / 10s%s" % [games[0].run_time - Run.START, "  PAUSED" if paused else ""]

func _screenshot() -> void:
    await RenderingServer.frame_post_draw
    var path := "user://passive-vfx-%d.png" % Time.get_ticks_msec()
    var error := get_viewport().get_texture().get_image().save_png(path)
    status.text = ProjectSettings.globalize_path(path) if error == OK else error_string(error)

func _save_traces() -> void:
    var stem := "user://passive-vfx-%d" % Time.get_ticks_msec()
    var errors := _export(stem)
    status.text = ("Saved both traces in " + ProjectSettings.globalize_path("user://")) if not errors else "Trace error: " + error_string(errors)

func _export(stem: String) -> Error:
    for game in games:
        var error := game.recorder.export_zip(stem + ("-candidate.zip" if game.candidate else "-baseline.zip"),
            "Synthetic passive fixture. Each trace includes confirmed burst HP loss and the build configuration.")
        if error != OK:
            return error
    return OK

func _capture(args: PackedStringArray) -> void:
    if DisplayServer.get_name() == "headless" or args.size() < args.find("--capture") + 3:
        get_tree().quit(2)
        return
    var out := args[args.find("--capture") + 1]
    var suite := args[args.find("--capture") + 2]
    DirAccess.make_dir_recursive_absolute(out)
    var dense := suite in ["dense", "reduced", "mobile"]
    density.select(2 if dense else 0)
    reduced.set_pressed_no_signal(suite == "reduced")
    hud.set_pressed_no_signal(args.has("--hud"))
    speed.select(1 if suite in ["slow", "dense", "reduced", "mobile"] else 0)
    replay()
    await get_tree().process_frame
    await get_tree().process_frame
    var previous_frame := 0
    var shots := {}
    var movie := suite in ["normal", "slow", "dense"]
    var count := 135 if speed.selected == 0 else 265
    for sample in count:
        var next_frame := (sample + 1) * 2 if speed.selected == 0 else (sample + 1) / 2
        while previous_frame < next_frame:
            _tick()
            previous_frame += 1
        _update_clock()
        var still := ""
        var burst: Dictionary = games[1].last_burst
        if int(games[1].passive_timers.get("six_counter", 0)) == 6 and not shots.has("armed"):
            still = "armed"
        if not burst.is_empty() and not shots.has("impact") and previous_frame >= int(burst.frame) + 4:
            still = "impact"
        if not burst.is_empty() and not shots.has("recovery") and previous_frame >= int(burst.frame) + 34:
            still = "recovery"
        if not burst.is_empty() and not shots.has("ready") and previous_frame >= int(burst.frame) + 122:
            still = "ready"
        if movie or not still.is_empty():
            await RenderingServer.frame_post_draw
            var image := get_viewport().get_texture().get_image()
            if movie and image.save_png(out.path_join("frame-%04d.png" % sample)) != OK:
                get_tree().quit(2)
                return
            if not still.is_empty():
                shots[still] = previous_frame
                if image.save_png(out.path_join(still + ".png")) != OK:
                    get_tree().quit(2)
                    return
    var report := FileAccess.open(out.path_join("capture.json"), FileAccess.WRITE)
    report.store_string(JSON.stringify({"suite": suite, "viewport": str(size), "shots": shots,
        "seed": Run.SEED, "engine": Engine.get_version_info().string,
        "adapter": RenderingServer.get_video_adapter_name(), "baseline": games[0].records,
        "candidate": games[1].records, "synthetic": true, "rendered_movie_fps": 30}, "  "))
    report.close()
    for game in games:
        game.recorder.stop(game, "fixture_complete")
    var exported := _export(out.path_join("trace"))
    get_tree().quit(0 if shots.has("impact") and exported == OK else 1)
