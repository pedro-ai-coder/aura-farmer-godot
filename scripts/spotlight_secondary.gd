class_name SpotlightSecondary
extends Control

const UI = preload("res://scripts/spotlight_components.gd")
const Style = preload("res://scripts/arcade_theme.gd")
var game
var presenter
var pause_panel: PanelContainer
var resume: Button
var settings: Button
var build: Button
var quit_run: Button
var outcome: VBoxContainer
var outcome_body: BoxContainer
var result_title: Label
var result_caption: Label
var portrait: TextureRect
var result_stats: Label

func install(owner_game, owner_presenter) -> void:
    game = owner_game
    presenter = owner_presenter
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    pause_panel = UI.ink_panel()
    add_child(pause_panel)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation",12)
    pause_panel.add_child(stack)
    var heading := UI.label("PAUSED","display",32,true)
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stack.add_child(heading)
    for caption in ["RESUME","YOUR BUILD","SETTINGS","QUIT RUN"]:
        var action := UI.action(caption,caption == "RESUME")
        stack.add_child(action)
        if caption == "RESUME": resume = action; action.pressed.connect(game._toggle_pause)
        elif caption == "YOUR BUILD": build = action; action.pressed.connect(presenter.open_build)
        elif caption == "SETTINGS": settings = action; action.pressed.connect(func():presenter.open_settings("paused"))
        else: quit_run = action; action.pressed.connect(game._request_return_to_menu)
    outcome = VBoxContainer.new()
    outcome.add_theme_constant_override("separation",16)
    add_child(outcome)
    result_title = UI.label("","display",44,true)
    outcome.add_child(result_title)
    result_caption = UI.label("","body",18,true)
    result_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    outcome.add_child(result_caption)
    outcome_body = BoxContainer.new()
    outcome_body.add_theme_constant_override("separation",24)
    outcome_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outcome.add_child(outcome_body)
    portrait = TextureRect.new()
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outcome_body.add_child(portrait)
    var stats_panel := UI.ink_panel()
    stats_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stats_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    outcome_body.add_child(stats_panel)
    var scroll := ScrollContainer.new()
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    stats_panel.add_child(scroll)
    result_stats = UI.label("","numbers",20,true)
    result_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    result_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    result_stats.custom_minimum_size = Vector2(220,0)
    scroll.add_child(result_stats)

func refresh(view: Vector2) -> void:
    size = view
    visible = game.mode in ["paused","won","lost"]
    pause_panel.visible = game.mode == "paused"
    outcome.visible = game.mode in ["won","lost"]
    if not visible: return
    if game.mode == "paused":
        var width := minf(420,view.x-48)
        pause_panel.size = Vector2(width,0)
        pause_panel.reset_size()
        pause_panel.size.x = width
        pause_panel.position = (view-pause_panel.size)*0.5
        return
    var narrow := view.x < 700
    outcome_body.vertical = narrow
    outcome.position = Vector2(32,24)
    outcome.size = view-Vector2(64,128)
    portrait.custom_minimum_size.y = 180 if narrow else 0
    portrait.texture = game.art.texture(str(game.hero["id"]))
    result_title.text = "VICTORY!" if game.mode == "won" else "RUN OVER"
    result_title.add_theme_color_override("font_color",Style.GOLD if game.mode == "won" else Style.CORAL)
    result_caption.text = "BIG HATER DEFEATED" if game.mode == "won" else "THE STREETS WON THIS ROUND"
    result_stats.text = "%s\n\nTIME  %02d:%02d\nWAVE  %d / 5     LEVEL  %d\nKILLS  %d\nWEAPONS  %d / 3\nPASSIVES  %d / 5\n\nDAMAGE  %.0f\nHEALING  %.0f\nSHIELD ABSORBED  %.0f\nFLEX USES  %d" % [game.hero["name"],int(game.run_time)/60,int(game.run_time)%60,game.wave,game.level,game.kills,game.weapons.size(),game.passives.size(),game.run_metrics["damage"],game.run_metrics["healing"],game.run_metrics["protection"],int(game.run_metrics["flexes"])]
    presenter._place(game.restart_button,Rect2(32,view.y-88,(view.x-80)/2,64))
    presenter._place(game.retry_button,Rect2(48+(view.x-80)/2,view.y-88,(view.x-80)/2,64))
    game.restart_button.text = "MAIN MENU"
