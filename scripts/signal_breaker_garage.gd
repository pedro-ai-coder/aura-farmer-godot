extends Control
## Real entry coordinator. The existing Solo scene retains all rules and saves.
## This candidate environment is explicitly separated from approved hero/brand pixels.
const Design=preload("res://scripts/neon_arcade.gd")
const Graphics=preload("res://scripts/neon_garage_graphics.gd")
const Run=preload("res://scenes/main.tscn")
const GarageEnvironment=preload("res://scripts/neon_garage_environment.gd")
const Showcase=preload("res://scripts/neon_hero_showcase.gd")
const Feedback=preload("res://scripts/neon_button_feedback.gd")
const BACKDROP=preload("res://assets/production/garage-candidate-v1/garage-backdrop.png")
const WORDMARK=preload("res://assets/production/cpk-brand-2026-11-13-v1/cpk-wordmark-color-1024.png")
const IDENTITIES=[
    [0,"original","THE SIGMA"],[1,"original","COOL KID"],[2,"original","ALPHA CHAD"],
    [0,"female","PIXEL VIXEN"],[1,"female","BYTE BADDIE"],[2,"female","BLOCK QUEEN"]]
var game
var garage_layer: CanvasLayer
var ui: Control
var backdrop: TextureRect
var environment: Control
var graphics: Control
var footer: Label
var sign: TextureRect
var hero_art: TextureRect
var showcase: Node
var info: PanelContainer
var info_stack: VBoxContainer
var hero_name: Label
var kit_label: Label
var starter_label: Label
var flex_label: Label
var help_label: Label
var title: Label
var select_button: Button
var play_button: Button
var settings_button: Button
var hero_grid: GridContainer
var hero_cards: Array[Button]=[]
var hero_card_names: Array[Label]=[]
var selection_open:=false
var active:=true
var view:=Vector2.ZERO
var selected_slot: int=-1
var touch_targets: Dictionary={}
var touch_armed: Dictionary={}
var swallow_emulated:=false

func _ready() -> void:
    get_window().title="CLUTCHPUNKS"
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    game=_create_run();add_child(game)
    game.set_process(false);game.process_mode=Node.PROCESS_MODE_DISABLED
    game.hide();game.layer.hide()
    garage_layer=CanvasLayer.new();garage_layer.layer=10;add_child(garage_layer)
    ui=Control.new();ui.theme=Design.theme();ui.mouse_filter=Control.MOUSE_FILTER_IGNORE;garage_layer.add_child(ui)
    backdrop=_image(ui);backdrop.name="CandidateBackdrop";backdrop.texture=BACKDROP;backdrop.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    environment=GarageEnvironment.new();environment.name="SeparateLightPlatformForeground";ui.add_child(environment)
    graphics=Graphics.new();ui.add_child(graphics)
    sign=_image(ui);sign.name="ApprovedCpkWordmark";sign.texture=WORDMARK
    hero_art=_image(ui);hero_art.name="ApprovedSelectedHero"
    showcase=Showcase.new();add_child(showcase)
    title=_label(ui,"SIGNAL BREAKER GARAGE","small")
    info=PanelContainer.new();Design.panel(info);ui.add_child(info)
    info_stack=VBoxContainer.new();info.add_child(info_stack)
    hero_name=_label(info_stack,"","title")
    kit_label=_label(info_stack,"","micro")
    starter_label=_label(info_stack,"","body")
    flex_label=_label(info_stack,"","body")
    help_label=_label(info_stack,"","small");help_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    hero_grid=GridContainer.new();hero_grid.name="SixHeroIdentities";ui.add_child(hero_grid)
    for i in range(IDENTITIES.size()):
        var card:=Button.new();card.name="Identity"+str(i+1);Design.card(card);hero_grid.add_child(card)
        card.pressed.connect(select_identity.bind(i));card.tooltip_text=IDENTITIES[i][2]
        var portrait:=_image(card);portrait.texture=game.art.cosmetic_portrait(game.HEROES[IDENTITIES[i][0]]["id"],IDENTITIES[i][1]);portrait.set_meta("hero_card_portrait",true)
        var label:=_label(card,IDENTITIES[i][2],"micro");label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
        hero_cards.append(card);hero_card_names.append(label)
        _feedback(card)
    select_button=_button("HERO SELECT",func():set_selection(not selection_open))
    play_button=_button("PLAY",start_selected,true)
    settings_button=_button("SETTINGS",open_settings)
    footer=_label(ui,"01  /  GARAGE     •     CLUTCHPUNKS","micro")
    get_viewport().size_changed.connect(_layout)
    _refresh_identity();_layout()

func _create_run() -> Node:
    return Run.instantiate()

func _image(parent: Node) -> TextureRect:
    var node:=TextureRect.new();node.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;node.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    node.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(node);return node
func _label(parent: Node,text: String,role: String) -> Label:
    var node:=Label.new();Design.label(node,role);node.text=text;parent.add_child(node);return node
func _button(text: String,callback: Callable,primary: bool=false) -> Button:
    var node:=Button.new();node.text=text;Design.button(node,primary);node.pressed.connect(callback);ui.add_child(node);_feedback(node);return node
func _feedback(button: Button) -> void:
    var feedback:=Feedback.new();button.add_child(feedback);feedback.install(button,game)

func _place(node: Control,rect: Rect2) -> void:
    node.position=rect.position;node.size=rect.size

func _refresh_identity() -> void:
    var data: Dictionary=game.HEROES[game.hero_index]
    for i in range(IDENTITIES.size()):
        var selected: bool=IDENTITIES[i][0]==game.hero_index and IDENTITIES[i][1]==game.hero_appearance
        Design.card(hero_cards[i],selected)
        if selected:selected_slot=i
        hero_card_names[i].text=IDENTITIES[i][2]+(" ✓" if selected else "")
    hero_art.texture=game.art.cosmetic_portrait(data["id"],game.hero_appearance)
    hero_name.text=game.HeroAppearanceScript.display_name(data["id"],game.hero_appearance,data["name"])
    kit_label.text=str(data["role"]).to_upper()
    starter_label.text="STARTER  /  "+str(game.WEAPONS[data["starter"]]["name"])
    flex_label.text="FLEX  /  "+str(data["flex"])
    help_label.text=str(game.presentation.catalog[data["id"]]["flex_help"])
    info.tooltip_text=help_label.text
    play_button.disabled=not game.HeroAppearanceScript.can_start(game.hero_appearance,data["id"])
    environment.reduced_motion=bool(game.profile["settings"]["reducedMotion"])
    showcase.configure(hero_art,data["id"],game.hero_appearance,environment.reduced_motion)

func select_identity(slot: int) -> void:
    if slot<0 or slot>=IDENTITIES.size() or not active:return
    game.hero_index=IDENTITIES[slot][0]
    game.select_appearance(IDENTITIES[slot][1])
    _refresh_identity();_layout()

func set_selection(value: bool) -> void:
    selection_open=value;_layout()
    if selection_open:hero_cards[maxi(0,selected_slot)].grab_focus()
    else:select_button.grab_focus()

func _layout() -> void:
    if ui==null:return
    var full: Vector2=get_viewport_rect().size
    # Reuse the existing browser safe-area resolution; no second input coordinate system.
    var safe: Vector2=game.presentation.position
    view=game.presentation.view
    if view.x<=0:view=full
    ui.position=safe;ui.size=view
    _place(backdrop,Rect2(Vector2.ZERO,view));environment.size=view
    graphics.size=view;graphics.queue_redraw()
    var portrait: bool=view.x<700
    var compact: bool=not portrait and view.y<600
    select_button.text="BACK" if selection_open else "HERO SELECT"
    play_button.text="PLAY" if portrait or selection_open else "PLAY  /  START RUN"
    for button in [play_button,select_button,settings_button]:
        button.add_theme_font_size_override("font_size",16 if portrait else 20 if compact else 24)
    settings_button.add_theme_font_size_override("font_size",16 if portrait else 20)
    footer.visible=not compact
    var grid_bounds:=Rect2()
    info.visible=not selection_open or not portrait
    hero_grid.columns=2
    _place(footer,Rect2(40,view.y-36,view.x-80,24))
    if portrait:
        _place(sign,Rect2(24,24,view.x-48,74))
        _place(title,Rect2(24,100,view.x-48,26))
        _place(settings_button,Rect2(view.x-154,137,130,48))
        _place(hero_art,Rect2(30,174,view.x-60,view.y-424))
        _place(info,Rect2(24,view.y-242,view.x-48,126))
        grid_bounds=Rect2(24,410,view.x-48,view.y-540)
        if selection_open:_place(hero_art,Rect2(60,184,view.x-120,210))
        _place(select_button,Rect2(24,view.y-104,(view.x-60)*.5,52))
        _place(play_button,Rect2(view.x*.5+6,view.y-104,view.x*.5-30,52))
        footer.text="CLUTCHPUNKS  /  GARAGE"
    elif compact:
        _place(sign,Rect2(32,16,280,62))
        _place(title,Rect2(38,78,330,26))
        _place(play_button,Rect2(38,122,270,56))
        _place(select_button,Rect2(38,190,270,52))
        _place(settings_button,Rect2(38,254,270,48))
        _place(hero_art,Rect2(view.x*.51,36,view.x*.45,view.y-164))
        _place(info,Rect2(view.x*.53,view.y-129,view.x*.43,100))
        hero_grid.columns=3
        grid_bounds=Rect2(38,108,view.x*.55,view.y-190)
        if selection_open:
            _place(hero_art,Rect2(view.x*.65,82,view.x*.31,view.y-120))
            _place(select_button,Rect2(38,view.y-76,130,48))
            _place(play_button,Rect2(188,view.y-76,180,48))
            _place(settings_button,Rect2(view.x-190,24,152,48))
        info.visible=not selection_open
    else:
        var nav_width: float=minf(380,view.x*.32)
        _place(sign,Rect2(48,40,minf(490,view.x*.40),108))
        _place(title,Rect2(60,154,view.x*.40,30))
        var nav_y: float=view.y*.34
        _place(play_button,Rect2(60,nav_y,nav_width,76))
        _place(select_button,Rect2(60,nav_y+92,nav_width-18,60))
        _place(settings_button,Rect2(60,nav_y+168,nav_width-36,56))
        _place(hero_art,Rect2(view.x*.50,52,view.x*.47,view.y-80))
        _place(info,Rect2(60,view.y-190,view.x*.39,142))
        grid_bounds=Rect2(60,190,view.x*.38,view.y-460)
        if selection_open:
            _place(select_button,Rect2(60,view.y-104,170,52))
            _place(play_button,Rect2(248,view.y-104,view.x*.38-188,52))
            _place(settings_button,Rect2(view.x-220,28,180,48))
            _place(info,Rect2(60,view.y-240,view.x*.38,124))
            info.visible=true
    hero_grid.visible=selection_open
    hero_art.visible=true
    starter_label.visible=not selection_open
    flex_label.visible=not selection_open
    help_label.visible=selection_open and not compact and not portrait
    help_label.add_theme_font_size_override("font_size",13)
    footer.text=("02  /  HERO SELECT     •     1–6 / TAB / ENTER" if selection_open else "01  /  GARAGE     •     CLUTCHPUNKS") if not portrait else "CLUTCHPUNKS  /  "+("HERO SELECT" if selection_open else "GARAGE")
    hero_name.add_theme_font_size_override("font_size",22 if portrait or compact or selection_open else 30)
    kit_label.add_theme_color_override("font_color",Design.LIME)
    info_stack.add_theme_constant_override("separation",4)
    for label in [starter_label,flex_label]:
        label.add_theme_font_size_override("font_size",13 if compact else 15)
        label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    hero_name.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    # Grid dimensions use fixed, non-overlapping hitboxes; thumbnail pixels never own input.
    var columns: int=hero_grid.columns
    var card_width: float=(grid_bounds.size.x-12*(columns-1))/columns
    var rows: int=ceili(6.0/columns)
    var card_height: float=maxf(82.0,(grid_bounds.size.y-12*(rows-1))/rows)
    for i in range(hero_cards.size()):
        var card: Button=hero_cards[i];card.custom_minimum_size=Vector2(card_width,card_height)
        var image: TextureRect=card.get_child(0)
        _place(image,Rect2(8,4,card_width-16,card_height-30))
        _place(hero_card_names[i],Rect2(4,card_height-26,card_width-8,22))
        hero_card_names[i].add_theme_font_size_override("font_size",13 if card_width<150 else 14)
    _place(hero_grid,grid_bounds)
    showcase.set_home(Rect2(hero_art.position,hero_art.size))
    # KEEP_ASPECT_CENTERED can letterbox; ground the platform to the actual image.
    var pixels: Vector2=hero_art.texture.get_size()
    var image_scale: float=minf(hero_art.size.x/pixels.x,hero_art.size.y/pixels.y)
    environment.hero_feet=showcase.home.position+Vector2(hero_art.size.x*.5,(hero_art.size.y+pixels.y*image_scale)*.5-4)
    environment.queue_redraw()
    _focus_chain()

func _focus_chain() -> void:
    var buttons: Array[Button]=[]
    if selection_open:buttons.assign(hero_cards)
    if selection_open:
        buttons.append(select_button);buttons.append(play_button);buttons.append(settings_button)
    else:
        buttons.append(play_button);buttons.append(select_button);buttons.append(settings_button)
    for i in range(buttons.size()):
        buttons[i].focus_next=buttons[(i+1)%buttons.size()].get_path()
        buttons[i].focus_previous=buttons[(i+buttons.size()-1)%buttons.size()].get_path()
        buttons[i].focus_neighbor_top=buttons[(i+buttons.size()-1)%buttons.size()].get_path()
        buttons[i].focus_neighbor_bottom=buttons[(i+1)%buttons.size()].get_path()
    if selection_open:
        for i in range(hero_cards.size()):
            var card: Button=hero_cards[i]
            card.focus_neighbor_left=hero_cards[maxi(i-i%hero_grid.columns,i-1)].get_path()
            card.focus_neighbor_right=hero_cards[mini(i-i%hero_grid.columns+hero_grid.columns-1,i+1)].get_path()
            card.focus_neighbor_top=hero_cards[i-hero_grid.columns].get_path() if i>=hero_grid.columns else settings_button.get_path()
            card.focus_neighbor_bottom=hero_cards[i+hero_grid.columns].get_path() if i+hero_grid.columns<6 else select_button.get_path()
    var owner=get_viewport().gui_get_focus_owner()
    if active and (owner==null or not owner.is_visible_in_tree()):select_button.grab_focus.call_deferred()

func _leave_garage() -> void:
    active=false;showcase.enabled=false
    if showcase.transition!=null:showcase.transition.kill()
    touch_targets.clear();touch_armed.clear()
    garage_layer.hide();game.show();game.layer.show()
    game.process_mode=Node.PROCESS_MODE_INHERIT;game.set_process(true)

func start_selected() -> void:
    if not active or play_button.disabled:return
    _leave_garage();game.start_run(game.hero_index)
    game.touch_swallow_emulated_mouse=swallow_emulated

func open_settings() -> void:
    if not active:return
    _leave_garage();game.presentation.open_settings("menu")

func _process(_delta: float) -> void:
    if not active and game!=null and game.mode=="menu":
        game._clear_touch();game.set_process(false);game.process_mode=Node.PROCESS_MODE_DISABLED
        game.hide();game.layer.hide();garage_layer.show();active=true;showcase.enabled=true;selection_open=false
        _refresh_identity();_layout();select_button.grab_focus.call_deferred()
    elif active and ui!=null and (view!=game.presentation.view or ui.position!=game.presentation.position):_layout()

func _input(event: InputEvent) -> void:
    if (event is InputEventMouseButton or event is InputEventMouseMotion) and event.device==InputEvent.DEVICE_ID_EMULATION and swallow_emulated:
        get_viewport().set_input_as_handled();return
    if not active:return
    # This project maps ui_accept to keys only. Keep controller acceptance local
    # to the Garage rather than changing gameplay InputMap bindings.
    if event is InputEventJoypadButton and event.button_index in [JOY_BUTTON_A,JOY_BUTTON_B]:
        if event.pressed:
            if event.button_index==JOY_BUTTON_B and selection_open:set_selection(false)
            elif event.button_index==JOY_BUTTON_A:
                var focused=get_viewport().gui_get_focus_owner()
                if focused is Button and ui.is_ancestor_of(focused) and focused.is_visible_in_tree() and not focused.disabled:
                    focused.pressed.emit()
        get_viewport().set_input_as_handled();return
    if event is InputEventScreenTouch:
        swallow_emulated=true
        if event.pressed and not event.canceled:
            var target=game._touch_ui_at(ui,event.position)
            if target is Button:
                touch_targets[event.index]=target;touch_armed[event.index]=not target.disabled
                get_viewport().set_input_as_handled()
        elif touch_targets.has(event.index):
            var target: Button=touch_targets[event.index];var armed: bool=touch_armed.get(event.index,false)
            touch_targets.erase(event.index);touch_armed.erase(event.index)
            if armed and not event.canceled and target.is_visible_in_tree() and not target.disabled and game._touch_control_contains(target,event.position):
                target.grab_focus();target.pressed.emit()
            get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag and touch_targets.has(event.index):
        if not game._touch_control_contains(touch_targets[event.index],event.position):touch_armed[event.index]=false
        get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
    if not active or not event.pressed or event.echo:return
    if event.keycode>=KEY_1 and event.keycode<=KEY_6:
        select_identity(event.keycode-KEY_1);get_viewport().set_input_as_handled()
    elif event.keycode==KEY_ESCAPE and selection_open:
        set_selection(false);get_viewport().set_input_as_handled()
