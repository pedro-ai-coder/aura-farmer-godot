extends CanvasLayer
## Creator-facing scenario controls. Available only in isolated QA review exports.
var game
var shade: ColorRect
var card: PanelContainer
var scenario_select: OptionButton
var hero_select: OptionButton
var appearance_select: OptionButton
var build_select: OptionButton
var seed_input: SpinBox
var enabled_box: CheckBox
var record_box: CheckBox
var threats_box: CheckBox
var hitboxes_box: CheckBox
var buffs_box: CheckBox
var performance_box: CheckBox
var message: Label
var launch_button: Button
const RULES = preload("res://qa/scenarios.gd")

func _option(parent: VBoxContainer, label_text: String, options: Array) -> OptionButton:
    var label:=Label.new()
    label.text=label_text
    parent.add_child(label)
    var field:=OptionButton.new()
    field.custom_minimum_size.y=36
    for value in options:field.add_item(str(value))
    parent.add_child(field)
    return field

func _check(parent: VBoxContainer, label_text: String) -> CheckBox:
    var field:=CheckBox.new()
    field.text=label_text
    field.button_pressed=false
    parent.add_child(field)
    return field

func install(owner_game) -> void:
    game=owner_game
    layer=110
    shade=ColorRect.new()
    shade.color=Color(0.04,0.08,0.13,0.94)
    shade.mouse_filter=Control.MOUSE_FILTER_STOP
    add_child(shade)
    card=PanelContainer.new()
    add_child(card)
    var scroll:=ScrollContainer.new()
    scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    card.add_child(scroll)
    var column:=VBoxContainer.new()
    column.add_theme_constant_override("separation",7)
    column.custom_minimum_size=Vector2(560,670)
    scroll.add_child(column)
    var headline:=Label.new()
    headline.text="CLUTCHPUNKS / QA SCENARIO MODE"
    headline.add_theme_font_size_override("font_size",22)
    column.add_child(headline)
    enabled_box=_check(column,"QA Mode Enabled (review build only)")
    enabled_box.toggled.connect(_changed)
    var names: Array[String]=[]
    for entry: Dictionary in RULES.PRESETS:names.append(str(entry["name"]))
    scenario_select=_option(column,"Starting wave / encounter",names)
    hero_select=_option(column,"Canonical hero kit",["Sigma","Cool Kid","Alpha Chad"])
    appearance_select=_option(column,"Cosmetic appearance",["Original","Female"])
    build_select=_option(column,"Equipment preset",RULES.BUILD_NAMES)
    var seed_label:=Label.new()
    seed_label.text="Deterministic RNG seed"
    column.add_child(seed_label)
    seed_input=SpinBox.new()
    seed_input.min_value=0
    seed_input.max_value=2147483647
    seed_input.step=1
    seed_input.value=451
    column.add_child(seed_input)
    record_box=_check(column,"Record telemetry for this synthetic session")
    var overlay_header:=Label.new()
    overlay_header.text="Diagnostic overlays (all OFF by default)"
    column.add_child(overlay_header)
    threats_box=_check(column,"Nearby threats and enemy counts")
    hitboxes_box=_check(column,"Actual hitboxes and solid covers")
    buffs_box=_check(column,"Active buffs, HP, shield and XP")
    performance_box=_check(column,"Engine FPS and render object counters")
    message=Label.new()
    message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    message.text="Only canonical QA fixtures; synthetic state never counts as normal gameplay."
    column.add_child(message)
    launch_button=Button.new()
    launch_button.text="START SYNTHETIC SCENARIO"
    launch_button.custom_minimum_size.y=48
    launch_button.pressed.connect(_launch)
    column.add_child(launch_button)
    var cancel:=Button.new()
    cancel.text="CLOSE"
    cancel.custom_minimum_size.y=44
    cancel.pressed.connect(close)
    column.add_child(cancel)
    visible=false
    _layout()

func _process(_delta: float) -> void:
    if visible:_layout()

func _layout() -> void:
    if game==null:return
    var size:=game.get_viewport_rect().size
    shade.position=Vector2.ZERO
    shade.size=size
    var width:=minf(size.x-22,680.0)
    var height:=minf(size.y-16,580.0)
    card.position=Vector2((size.x-width)/2.0,(size.y-height)/2.0)
    card.size=Vector2(width,height)

func _changed(_value: bool) -> void:
    launch_button.disabled=not enabled_box.button_pressed

func open() -> void:
    if game==null or not game.mode in ["menu","heroes","paused"]:return
    if game.recorder.enabled or not game.recorder.lines.is_empty():
        game.qa_ui.message="Export and clear the current recording before starting a scenario."
        game.qa_ui.refresh()
        return
    enabled_box.button_pressed=false
    _changed(false)
    message.text="QA must be explicitly enabled. Synthetic sessions never count as normal runs."
    visible=true
    _layout()

func close() -> void:
    visible=false

func _launch() -> void:
    if not enabled_box.button_pressed:return
    var ids: Array[String]=["sigma","cool-kid","alpha"]
    var index:=clampi(hero_select.selected,0,2)
    var selected: Dictionary=RULES.PRESETS[clampi(scenario_select.selected,0,RULES.PRESETS.size()-1)]
    var flags: Dictionary={
        "threats":threats_box.button_pressed,
        "hitboxes":hitboxes_box.button_pressed,
        "buffs":buffs_box.button_pressed,
        "performance":performance_box.button_pressed
    }
    var successful: bool=game.start_qa_scenario(str(selected["id"]),ids[index],
        "female" if appearance_select.selected==1 else "original",
        RULES.BUILD_NAMES[clampi(build_select.selected,0,RULES.BUILD_NAMES.size()-1)],
        int(seed_input.value),flags,record_box.button_pressed)
    if not successful:
        message.text="Scenario refused: invalid configuration, recording state or asset."
        return
    close()
