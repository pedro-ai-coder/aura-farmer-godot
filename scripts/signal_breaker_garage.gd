extends Control
## Real entry coordinator. The existing Solo scene retains all rules and saves.
## This candidate environment is explicitly separated from approved hero/brand pixels.
const Design=preload("res://scripts/cpk_design_system.gd")
const Run=preload("res://scenes/main.tscn")
const GarageEnvironment=preload("res://scripts/garage_environment.gd")
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
var sign: TextureRect
var hero_art: TextureRect
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
var browser_poll:=0.0

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
    sign=_image(ui);sign.name="ApprovedCpkWordmark";sign.texture=WORDMARK
    hero_art=_image(ui);hero_art.name="ApprovedSelectedHero"
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
    select_button=_button("HERO SELECT",func():set_selection(not selection_open))
    play_button=_button("PLAY",start_selected,true)
    settings_button=_button("SETTINGS",open_settings)
    get_viewport().size_changed.connect(_layout)
    _refresh_identity();_layout();_sync_browser()

func _create_run() -> Node:
    return Run.instantiate()

func _image(parent: Node) -> TextureRect:
    var node:=TextureRect.new();node.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;node.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    node.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(node);return node
func _label(parent: Node,text: String,role: String) -> Label:
    var node:=Label.new();Design.label(node,role);node.text=text;parent.add_child(node);return node
func _button(text: String,callback: Callable,primary: bool=false) -> Button:
    var node:=Button.new();node.text=text;Design.button(node,primary);node.pressed.connect(callback);ui.add_child(node);return node
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
    var portrait: bool=view.x<700
    var compact: bool=not portrait and view.y<600
    var grid_bounds:=Rect2()
    var logo_width: float=minf(620.0,view.x*.55) if not portrait else view.x-48
    _place(sign,Rect2((view.x-logo_width)*.5,62 if not compact and not portrait else 18,logo_width,100 if not compact else 70))
    _place(title,Rect2(24,18,view.x*.28,36));title.visible=not portrait
    _place(settings_button,Rect2(view.x-154,22,130,48))
    if portrait:
        _place(settings_button,Rect2(view.x-174,126,154,48))
        _place(hero_art,Rect2(30,view.y*.47,view.x-60,view.y*.34))
        _place(info,Rect2(20,190,view.x-40,190));info.visible=not selection_open
        hero_grid.columns=2
        grid_bounds=Rect2(20,200,view.x-40,minf(480,view.y-365))
        _place(select_button,Rect2(20,view.y-132,view.x-40,48));_place(play_button,Rect2(20,view.y-72,view.x-40,52))
    elif compact:
        _place(hero_art,Rect2(24,100,view.x*.35,view.y-175))
        _place(info,Rect2(view.x*.42,104,view.x*.55,view.y-190));info.visible=not selection_open
        hero_grid.columns=3
        grid_bounds=Rect2(view.x*.42,104,view.x*.55,view.y-190)
        _place(select_button,Rect2(24,view.y-72,210,52));_place(play_button,Rect2(view.x-254,view.y-72,230,52))
    else:
        _place(hero_art,Rect2(view.x*.28 if selection_open else view.x*.37,230,view.x*.35,view.y-280))
        _place(info,Rect2(36,240,view.x*.28,300));info.visible=true
        hero_grid.columns=2
        grid_bounds=Rect2(view.x*.64,230,view.x*.33,view.y-350)
        _place(select_button,Rect2(36,view.y-92,260,60));_place(play_button,Rect2(view.x-316,view.y-92,280,60))
    hero_grid.visible=selection_open
    select_button.text="BACK" if selection_open else "HERO SELECT"
    hero_art.visible=not(portrait and selection_open)
    help_label.visible=not compact and not portrait
    hero_name.add_theme_font_size_override("font_size",23 if portrait or compact else 28)
    hero_name.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    for label in [starter_label,flex_label]:label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
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
    environment.hero_feet=hero_art.position+Vector2(hero_art.size.x*.5,hero_art.size.y-4) if hero_art.visible else Vector2(-1000,-1000)
    environment.queue_redraw()
    _focus_chain()

func _focus_chain() -> void:
    var buttons: Array[Button]=[]
    if selection_open:buttons.assign(hero_cards)
    buttons.append(select_button);buttons.append(play_button);buttons.append(settings_button)
    for i in range(buttons.size()):
        buttons[i].focus_next=buttons[(i+1)%buttons.size()].get_path()
        buttons[i].focus_previous=buttons[(i+buttons.size()-1)%buttons.size()].get_path()
    var owner=get_viewport().gui_get_focus_owner()
    if active and (owner==null or not owner.is_visible_in_tree()):select_button.grab_focus.call_deferred()

func _leave_garage() -> void:
    active=false;touch_targets.clear();touch_armed.clear()
    garage_layer.hide();game.show();game.layer.show()
    game.process_mode=Node.PROCESS_MODE_INHERIT;game.set_process(true)

func start_selected() -> void:
    if not active or play_button.disabled:return
    _leave_garage();game.start_run(game.hero_index)
    game.touch_swallow_emulated_mouse=swallow_emulated

func open_settings() -> void:
    if not active:return
    _leave_garage();game.presentation.open_settings("menu")

func _sync_browser() -> void:
    if not OS.has_feature("web"):return
    var before: String=JSON.stringify(game.web_metrics)
    game.web_metrics=game.WebPlatformScript.metrics("garage")
    game.touch_device=game.touch_device or bool(game.web_metrics.get("touch",false))
    if JSON.stringify(game.web_metrics)!=before:
        game.presentation._window_changed(true);_layout()

func _process(delta: float) -> void:
    if not active and game!=null and game.mode=="menu":
        game._clear_touch();game.set_process(false);game.process_mode=Node.PROCESS_MODE_DISABLED
        game.hide();game.layer.hide();garage_layer.show();active=true;selection_open=false
        _refresh_identity();_layout();_sync_browser();select_button.grab_focus.call_deferred()
    elif active and ui!=null and (view!=game.presentation.view or ui.position!=game.presentation.position):_layout()
    if active:
        browser_poll-=delta
        if browser_poll<=0:browser_poll=.5;_sync_browser()

func _input(event: InputEvent) -> void:
    if (event is InputEventMouseButton or event is InputEventMouseMotion) and event.device==InputEvent.DEVICE_ID_EMULATION and swallow_emulated:
        get_viewport().set_input_as_handled();return
    if not active:return
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
