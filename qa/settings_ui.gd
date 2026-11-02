extends CanvasLayer
## Review-only QA scenario picker. Header and actions never scroll out of view.
const RULES = preload("res://qa/scenarios.gd")

var game
var input_events := 0
var close_count := 0
var last_close := ""
var previous_focus: Control
var shade: ColorRect
var card: PanelContainer
var scroll: ScrollContainer
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
var close_button: Button
var footer_close_button: Button

func _option(parent: VBoxContainer, label_text: String, options: Array) -> OptionButton:
    var label:=Label.new()
    label.text=label_text
    parent.add_child(label)
    var field:=OptionButton.new()
    field.custom_minimum_size.y=36
    field.size_flags_horizontal=Control.SIZE_EXPAND_FILL
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
    card.mouse_filter=Control.MOUSE_FILTER_STOP
    add_child(card)
    var margin:=MarginContainer.new()
    for side in ["left","right","top","bottom"]:
        margin.add_theme_constant_override("margin_"+side,12)
    card.add_child(margin)
    var outer:=VBoxContainer.new()
    outer.add_theme_constant_override("separation",8)
    margin.add_child(outer)

    # Fixed header: CLOSE is available even on short landscape viewports.
    var header:=HBoxContainer.new()
    outer.add_child(header)
    var headline:=Label.new()
    headline.text="CLUTCHPUNKS / QA SCENARIO MODE"
    headline.add_theme_font_size_override("font_size",20)
    headline.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    headline.clip_text=true
    header.add_child(headline)
    close_button=Button.new()
    close_button.text="CLOSE"
    close_button.custom_minimum_size=Vector2(90,42)
    close_button.pressed.connect(close.bind("header"))
    header.add_child(close_button)

    scroll=ScrollContainer.new()
    scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_AUTO
    scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    outer.add_child(scroll)
    var column:=VBoxContainer.new()
    column.add_theme_constant_override("separation",7)
    column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    scroll.add_child(column)

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

    # Fixed footer: action buttons never depend on the scroll position.
    var footer:=HBoxContainer.new()
    footer.add_theme_constant_override("separation",8)
    outer.add_child(footer)
    footer_close_button=Button.new()
    footer_close_button.text="CANCEL"
    footer_close_button.custom_minimum_size.y=46
    footer_close_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    footer_close_button.pressed.connect(close.bind("cancel"))
    footer.add_child(footer_close_button)
    launch_button=Button.new()
    launch_button.text="START SCENARIO"
    launch_button.custom_minimum_size.y=46
    launch_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    launch_button.pressed.connect(_launch)
    footer.add_child(launch_button)

    visible=false
    _changed(false)
    _layout()

func _input(event: InputEvent) -> void:
    if not visible:return
    input_events+=1
    if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
        close("escape")
        get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
    if visible and shade.size!=game.get_viewport_rect().size:_layout()

func _layout() -> void:
    if game==null:return
    var size: Vector2=game.get_viewport_rect().size
    shade.position=Vector2.ZERO
    shade.size=size
    var width:=maxf(0.0,minf(size.x-20.0,720.0))
    var height:=maxf(0.0,minf(size.y-16.0,650.0))
    card.position=Vector2((size.x-width)/2.0,(size.y-height)/2.0)
    card.size=Vector2(width,height)

func _changed(_value: bool) -> void:
    if launch_button!=null:launch_button.disabled=not enabled_box.button_pressed

func open() -> void:
    if game==null or not game.mode in ["menu","heroes","paused"]:return
    if game.recorder.enabled or not game.recorder.lines.is_empty():
        game.qa_ui.message="Export and clear the current recording before starting a scenario."
        game.qa_ui.refresh()
        return
    enabled_box.button_pressed=false
    _changed(false)
    message.text="QA must be explicitly enabled. Synthetic sessions never count as normal runs."
    previous_focus=get_viewport().gui_get_focus_owner()
    visible=true
    scroll.scroll_vertical=0
    _layout()
    close_button.grab_focus()

func close(reason: String="programmatic") -> void:
    if not visible:return
    close_count+=1
    last_close=reason
    # Release focus before hiding; no hidden LineEdit should retain keyboard input.
    var focused:=get_viewport().gui_get_focus_owner()
    if focused!=null and is_ancestor_of(focused):focused.release_focus()
    for selector in [scenario_select,hero_select,appearance_select,build_select]:
        selector.get_popup().hide()
    visible=false
    if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree():previous_focus.grab_focus()
    if game!=null:game.qa_ui.refresh()

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
    close("launch")
