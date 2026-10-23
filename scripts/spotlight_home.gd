class_name SpotlightHome
extends Control

## Authentic approved portraits and live navigation; no flattened screen UI.
const UI = preload("res://scripts/spotlight_components.gd")
const Style = preload("res://scripts/arcade_theme.gd")
var game
var presenter
var home_row: BoxContainer
var home_stack: VBoxContainer
var brand_labels: Array[Label] = []
var home_panel: PanelContainer
var hero_art: TextureRect
var hero_destination: Button
var selection: VBoxContainer
var grid: GridContainer
var hero_scroll: ScrollContainer
var start_button: Button
var return_button: Button
var summaries: Array[Label] = []
var selection_caption: Label

func install(owner_game, owner_presenter) -> void:
    game = owner_game
    presenter = owner_presenter
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    home_row = BoxContainer.new()
    add_child(home_row)
    home_row.add_theme_constant_override("separation",32)
    hero_art = TextureRect.new()
    hero_art.texture = game.art.texture("sigma")
    hero_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    hero_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    hero_art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    home_row.add_child(hero_art)
    home_panel = UI.ink_panel()
    home_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    home_row.add_child(home_panel)
    var margin := MarginContainer.new()
    for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,24)
    home_panel.add_child(margin)
    var stack := VBoxContainer.new()
    home_stack = stack
    stack.add_theme_constant_override("separation",16)
    margin.add_child(stack)
    var aura := UI.label("AURA","display",64,true)
    aura.add_theme_color_override("font_color",Style.GOLD)
    aura.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stack.add_child(aura)
    brand_labels.append(aura)
    var farmer := UI.label("FARMER","display",64,true)
    farmer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stack.add_child(farmer)
    brand_labels.append(farmer)
    var caption := UI.label("FARM AURA. BE LEGENDARY.","black",16,true)
    caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stack.add_child(caption)
    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    stack.add_child(spacer)
    presenter.play_button.reparent(stack)
    presenter.play_button.text = "PLAY"
    hero_destination = UI.action("HEROES")
    hero_destination.pressed.connect(presenter.open_heroes)
    stack.add_child(hero_destination)
    presenter.options_button.reparent(stack)
    presenter.options_button.text = "SETTINGS"
    var footer := UI.label("RUIN ALLEY  /  SOLO","numbers",14,true)
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    stack.add_child(footer)
    selection = VBoxContainer.new()
    selection.add_theme_constant_override("separation",16)
    add_child(selection)
    selection.add_child(UI.label("CHOOSE YOUR HERO","display",40,true))
    selection_caption = UI.label("Three starters. One signature Flex each.","body",18,true)
    selection.add_child(selection_caption)
    hero_scroll = ScrollContainer.new()
    hero_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    hero_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    selection.add_child(hero_scroll)
    grid = GridContainer.new()
    grid.add_theme_constant_override("h_separation",16)
    grid.add_theme_constant_override("v_separation",16)
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hero_scroll.add_child(grid)
    for i in range(3):
        var button: Button = game.menu_buttons[i]
        button.reparent(grid)
        button.custom_minimum_size = Vector2(0,420)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var margin_card := MarginContainer.new()
        margin_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
        button.add_child(margin_card)
        margin_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        for side in ["left","right","top","bottom"]: margin_card.add_theme_constant_override("margin_"+side,18)
        var card := VBoxContainer.new()
        card.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.add_theme_constant_override("separation",10)
        margin_card.add_child(card)
        var portrait: TextureRect = game.hero_portraits[i]
        portrait.reparent(card)
        portrait.custom_minimum_size = Vector2(0,180)
        portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        for part in ["name","role"]:
            var label: Label = presenter.hero_labels[i][part]
            label.reparent(card)
            label.add_theme_font_override("font",Style.BLACK if part == "name" else Style.NUMBERS)
            label.add_theme_font_size_override("font_size",26 if part == "name" else 18)
            label.text = str(game.HEROES[i]["name"] if part == "name" else game.HEROES[i]["role"]).to_upper()
        var summary := UI.label("","body",17)
        summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        summary.custom_minimum_size.y = 68
        card.add_child(summary)
        summaries.append(summary)
    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation",16)
    selection.add_child(actions)
    return_button = UI.action("BACK")
    return_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return_button.pressed.connect(game._return_to_menu)
    actions.add_child(return_button)
    start_button = UI.action("START RUN",true)
    start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    start_button.pressed.connect(func():game.start_run(game.hero_index))
    actions.add_child(start_button)

func refresh(view: Vector2) -> void:
    size = view
    visible = game.mode in ["menu","heroes"]
    home_row.visible = game.mode == "menu"
    selection.visible = game.mode == "heroes"
    if not visible: return
    var portrait := view.x < 700
    home_stack.add_theme_constant_override("separation",8 if view.y < 600 else 16)
    for label: Label in brand_labels: label.add_theme_font_size_override("font_size",40 if view.y < 600 else 64)
    grid.custom_minimum_size.x = 0
    home_panel.custom_minimum_size.x = 0
    home_row.vertical = portrait
    home_row.position = Vector2(32,24)
    home_row.size = view-Vector2(64,48)
    hero_art.visible = not portrait
    home_panel.custom_minimum_size = Vector2(0 if portrait else view.x*0.38,0)
    selection.position = Vector2(32,24)
    selection.size = view-Vector2(64,48)
    grid.columns = 1 if portrait else 3
    grid.custom_minimum_size.x = maxf(0,selection.size.x-16)
    for i in range(3):
        var button: Button = game.menu_buttons[i]
        button.text = ""
        button.visible = game.mode == "heroes"
        game.hero_portraits[i].visible = true
        Style.card(button,i == game.hero_index)
        var rim := Style.GOLD if i == game.hero_index else Style.SKY.darkened(0.35)
        var frame := Style.box(Style.BLUE,rim,19,5)
        frame.set_border_width_all(5 if i == game.hero_index else 3)
        button.add_theme_stylebox_override("normal",frame)
        button.add_theme_stylebox_override("hover",Style.box(Style.BLUE.lightened(0.08),Style.SKY,19,5))
        button.add_theme_stylebox_override("pressed",Style.box(Style.DEEP,Style.GOLD,19,0))
        for part in ["name","role"]: presenter.hero_labels[i][part].add_theme_color_override("font_color",Style.CARD)
        summaries[i].add_theme_color_override("font_color",Style.CARD)
        var definition: Dictionary = game.HEROES[i]
        summaries[i].text = "%s\n%s" % [game.WEAPONS[definition["starter"]]["name"],definition["flex"]]
    selection_caption.text = "%s SELECTED  /  %s" % [str(game.HEROES[game.hero_index]["name"]),str(game.HEROES[game.hero_index]["role"]).to_upper()]
    queue_redraw()

func _draw() -> void:
    if game == null or not visible: return
    var background: Texture2D = game.art.texture("ruin-alley")
    if background != null:
        var scale := maxf(size.x/background.get_width(),size.y/background.get_height())
        var extent := background.get_size()*scale
        draw_texture_rect(background,Rect2((size-extent)*0.5,extent),false)
    draw_rect(Rect2(Vector2.ZERO,size),Color(Style.DEEP,0.84))
