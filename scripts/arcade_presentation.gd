class_name ArcadePresentation
extends Control

## Reusable responsive presentation. Never advances simulation or consumes gameplay RNG.
const OfferCard = preload("res://scripts/spotlight_offer_card.gd")
const Components = preload("res://scripts/spotlight_components.gd")
const ArcadeStyle = preload("res://scripts/arcade_theme.gd")
var game
var catalog: Dictionary = {}
var secondary
var settings_return := "menu"
var volume_slider: HSlider
var volume_label: Label
var preference_timer: Timer
var home
var spotlight_hud
var play_button: Button
var options_button: Button
var back_button: Button
var title: Label
var subtitle: Label
var detail: Label
var card_scroll: ScrollContainer
var card_content: Control
var body_scroll: ScrollContainer
var body_content: Control
var equipment_board: Control
var equipment_slots: Array[Dictionary] = []
var equipment_headings: Array[Label] = []
var full_view := Vector2.ZERO
var rotate_hint: Label
var card_parts: Array[Dictionary] = []
var hero_labels: Array[Dictionary] = []
var view := Vector2.ZERO
var menu_panel := Rect2()
var modal_panel := Rect2()
var content_rect := Rect2()
var last_window_size := Vector2i.ZERO
var last_card_signature := ""
var last_flex_ready := -1
var last_selected := -1
var last_mode := ""
var error_message := ""
var last_signature := ""

func _init(owner_game = null) -> void:
    game = owner_game
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func install() -> void:
    catalog = JSON.parse_string(FileAccess.get_file_as_string("res://assets/ui-catalog.json"))
    var original: Array[Node] = game.layer.get_children()
    game.layer.add_child(self)
    for node in original:
        if node != game.touch_joystick: node.reparent(self)
    title = _label(32)
    subtitle = _label(18)
    detail = _label(20)
    detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    play_button = _button("PLAY RUIN ALLEY",func(): game.start_run(game.hero_index))
    options_button = _button("OPTIONS & SAVE",func(): open_settings("menu"))
    back_button = _button("BACK",close_auxiliary)
    card_scroll = ScrollContainer.new()
    card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(card_scroll)
    card_content = Control.new()
    card_scroll.add_child(card_content)
    for i in range(game.offer_buttons.size()):
        var button: Button = game.offer_buttons[i]
        button.reparent(card_content)
        button.text = ""
        var parts := OfferCard.install(button)
        card_parts.append(parts)
    body_scroll = ScrollContainer.new()
    body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(body_scroll)
    body_content = Control.new()
    body_scroll.add_child(body_content)
    for control: Control in [game.build_details,game.sound_button,game.motion_button,game.import_button,game.export_button]: control.reparent(body_content)
    volume_label = _label(20)
    volume_label.reparent(body_content)
    volume_slider = HSlider.new()
    volume_slider.min_value = 0
    volume_slider.max_value = 100
    volume_slider.step = 1
    volume_slider.focus_mode = Control.FOCUS_ALL
    volume_slider.add_theme_stylebox_override("slider",ArcadeStyle.box(ArcadeStyle.BLUE,ArcadeStyle.INK,6,0))
    volume_slider.add_theme_stylebox_override("grabber_area",ArcadeStyle.box(ArcadeStyle.GOLD,ArcadeStyle.INK,6,0))
    volume_slider.add_theme_stylebox_override("grabber_area_highlight",ArcadeStyle.box(ArcadeStyle.GOLD,ArcadeStyle.SKY,6,0))
    body_content.add_child(volume_slider)
    preference_timer = Timer.new()
    preference_timer.one_shot = true
    preference_timer.wait_time = 0.25
    preference_timer.timeout.connect(game._save_profile)
    add_child(preference_timer)
    volume_slider.value_changed.connect(_volume_changed)
    equipment_board = Control.new()
    body_content.add_child(equipment_board)
    for caption in ["WEAPONS  /  3 SLOTS","PASSIVES  /  5 SLOTS"]:
        var heading := _inside_label(equipment_board,20)
        heading.text = caption
        equipment_headings.append(heading)
    for i in range(8):
        var panel := Panel.new()
        panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        equipment_board.add_child(panel)
        var label := _inside_label(panel,18)
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        equipment_slots.append({"panel":panel,"label":label})
    rotate_hint = _label(20)
    rotate_hint.text = "Rotate for a wider view"
    rotate_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    rotate_hint.add_theme_color_override("font_color",ArcadeStyle.CARD)
    rotate_hint.add_theme_color_override("font_outline_color",ArcadeStyle.INK)
    rotate_hint.add_theme_constant_override("outline_size",5)
    for i in range(3):
        var button: Button = game.menu_buttons[i]
        button.pressed.disconnect(game.start_run.bind(i))
        button.pressed.connect(select_hero.bind(i))
        game.hero_portraits[i].reparent(button)
        hero_labels.append({"name":_inside_label(button,20),"role":_inside_label(button,16)})
    home = load("res://scripts/spotlight_home.gd").new()
    add_child(home)
    home.install(game,self)
    spotlight_hud = load("res://scripts/spotlight_hud.gd").new()
    add_child(spotlight_hud)
    spotlight_hud.install(game)
    secondary = load("res://scripts/spotlight_secondary.gd").new()
    add_child(secondary)
    secondary.install(game,self)
    game.import_button.pressed.disconnect(game._open_profile_import)
    game.import_button.pressed.connect(func(): game.mode = "menu"; game._open_profile_import())
    game.export_button.pressed.disconnect(game._open_profile_export)
    game.export_button.pressed.connect(func(): game.mode = "menu"; game._open_profile_export())
    game.get_window().size_changed.connect(_window_changed)
    _window_changed()
    refresh()

func _label(font_size: int) -> Label:
    var label := Label.new()
    label.add_theme_font_size_override("font_size",font_size)
    label.add_theme_color_override("font_color",ArcadeStyle.INK)
    label.add_theme_font_override("font",ArcadeStyle.font("display" if font_size >= 30 else "body"))
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(label)
    return label

func _inside_label(parent: Control, font_size: int) -> Label:
    var label := _label(font_size)
    label.reparent(parent)
    return label

func _button(text: String, action: Callable) -> Button:
    var button := Components.action(text)
    button.pressed.connect(action)
    add_child(button)
    ArcadeStyle.button(button)
    return button

func _window_changed(force: bool = false) -> void:
    var window: Window = game.get_window()
    if window.size == last_window_size and not force: return
    last_window_size = window.size
    var physical := Vector2(window.size)
    var scale := clampf(minf(physical.x/1280.0,physical.y/720.0),0.75,1.5)
    window.content_scale_size = Vector2i(physical / scale)
    full_view = Vector2(window.content_scale_size)
    var insets := Vector4.ZERO
    var safe: Array = game.web_metrics.get("safe",[])
    if safe.size() == 4:
        var factor := full_view / Vector2(maxf(1,float(game.web_metrics.get("width",physical.x))),maxf(1,float(game.web_metrics.get("height",physical.y))))
        insets = Vector4(float(safe[0])*factor.x,float(safe[1])*factor.y,float(safe[2])*factor.x,float(safe[3])*factor.y)
    elif OS.has_feature("mobile"):
        var native_safe: Rect2i = DisplayServer.get_display_safe_area()
        var window_rect := Rect2i(window.position,window.size)
        if native_safe.has_area():
            var useful := window_rect.intersection(native_safe)
            var factor := full_view / physical
            var near := Vector2(useful.position-window_rect.position)*factor
            var far := Vector2(window_rect.end-useful.end)*factor
            insets = Vector4(near.x,near.y,far.x,far.y)
    position = Vector2(insets.x,insets.y)
    view = full_view-Vector2(insets.x+insets.z,insets.y+insets.w)
    size = view
    game.touch_joystick.size = full_view
    game._clear_touch()
    last_signature = ""
    refresh()

func select_hero(index: int) -> void:
    if game.mode not in ["menu","heroes"]: return
    game.hero_index = index
    refresh()

func open_heroes() -> void:
    game.mode = "heroes"
    game._clear_touch()
    game._show_ui()

func _volume_changed(percent: float) -> void:
    game.profile["settings"]["masterVolume"] = clampf(percent/100.0,0.0,1.0)
    game._apply_preferences()
    volume_label.text = "MASTER VOLUME  %d%%" % int(percent)
    preference_timer.start()

func open_settings(origin: String = "menu") -> void:
    settings_return = origin
    game.mode = "options"
    game._clear_touch()
    game._show_ui()

func open_build() -> void:
    game.mode = "build"
    game._clear_touch()
    game._show_ui()

func close_auxiliary() -> void:
    game.mode = "paused" if game.mode == "build" else settings_return
    game._clear_touch()
    game._show_ui()

func pump() -> void:
    spotlight_hud.sync(view)
    if game.get_window().size != last_window_size: _window_changed()
    queue_redraw()

func _place(control: Control, rect: Rect2) -> void:
    control.position = rect.position
    control.size = rect.size
    if control is Button and not game.offer_buttons.has(control) and not game.menu_buttons.has(control): control.size.y = maxf(64,rect.size.y)
    if control is Label: control.set_deferred("size",rect.size)

func refresh(force: bool = false) -> void:
    if game == null or play_button == null: return
    if view.x <= 0.0: view = game.get_viewport_rect().size
    var equipment := ""
    for item: Dictionary in game.weapons + game.passives: equipment += "%s:%s:%s;" % [item["id"],item["rarity"],item["level"]]
    var signature: String = str(game.mode) + str(game.hero_index) + str(game.selected_card_index) + str(game.level) + equipment + JSON.stringify(game.selection) + JSON.stringify(game.legendary_offers) + str(game.profile["settings"]) + error_message + str(game.touch_device)
    var ready := int(game.aura >= 100.0 and game.flex_lock <= 0.0)
    if ready != last_flex_ready:
        ArcadeStyle.button(game.flex_button,ready == 1)
        last_flex_ready = ready
    game.flex_button.text = game.flex_status()
    game.flex_button.disabled = game.aura < 100.0 or game.flex_lock > 0.0
    if not force and signature == last_signature:
        queue_redraw()
        return
    last_signature = signature
    if game.mode != last_mode:
        error_message = ""
        last_mode = game.mode
    var width := view.x
    var height := view.y
    var compact := height < 600.0
    var portrait := width < 700.0
    var menu: bool = game.mode == "menu"
    var options: bool = game.mode == "options"
    var cards: bool = game.mode in ["choice","replace","legendary"]
    var settings: bool = options or game.mode == "build"
    game.headline.hide()
    game.metrics.hide()
    game.notice.hide()
    game.hud_top.hide()
    game.hud_bottom.hide()
    game.modal_dim.hide()
    menu_panel = Rect2(width*0.52,36,width*0.45,height-72) if not portrait else Rect2(18,height*0.25,width-36,height*0.75-18)
    if compact: menu_panel = Rect2(width*0.47,18,width*0.51,height-36)
    modal_panel = Rect2(Vector2(maxf(18,(width-1160)/2),18),Vector2(minf(width-36,1160),height-36))
    if game.mode == "confirm_exit":
        modal_panel = Rect2((view-Vector2(minf(width-36,680),300))*0.5,Vector2(minf(width-36,680),300))
    title.visible = not menu
    subtitle.visible = true
    detail.visible = menu or settings or game.mode in ["won","lost","confirm_exit","profile_import","profile_export"]
    play_button.visible = menu
    options_button.visible = menu
    back_button.visible = options or game.mode == "build"
    volume_slider.visible = options
    volume_label.visible = options
    volume_slider.set_value_no_signal(float(game.profile["settings"].get("masterVolume",1.0))*100)
    volume_label.text = "MASTER VOLUME  %d%%" % int(volume_slider.value)
    game.sound_button.visible = options
    game.motion_button.visible = options
    game.import_button.visible = options and settings_return == "menu"
    game.export_button.visible = options and settings_return == "menu"
    game.profile_text.visible = game.mode in ["profile_import","profile_export"]
    game.build_details.hide()
    equipment_board.visible = game.mode == "build"
    game.pause_button.visible = game.mode == "playing" or game.mode == "paused"
    game.retry_button.visible = game.mode in ["won","lost"]
    game.restart_button.visible = game.mode in ["paused","won","lost","replace","confirm_exit","profile_import","profile_export"]
    game.confirm_button.visible = cards or game.mode in ["confirm_exit","profile_import","profile_export"]
    game.defer_button.visible = game.mode == "legendary"
    card_scroll.visible = cards
    body_scroll.visible = settings
    rotate_hint.visible = game.mode == "playing" and game.touch_device and portrait
    _place(rotate_hint,Rect2(20,162,width-40,40))
    for control: Button in [game.pause_button,game.confirm_button,game.restart_button,game.defer_button,game.retry_button,game.sound_button,game.motion_button,game.import_button,game.export_button,game.legendary_button,play_button,options_button,back_button]:
        ArcadeStyle.button(control,control == play_button or control == game.confirm_button or control == game.retry_button or (control == game.flex_button and game.aura >= 100.0 and game.flex_lock <= 0.0))
    secondary.refresh(view)
    spotlight_hud.sync(view)
    home.refresh(view)
    if game.mode == "paused":
        title.hide()
        subtitle.hide()
        detail.hide()
        game.pause_button.hide()
        game.restart_button.hide()
        _focus_ring()
        queue_redraw()
        return
    if game.mode in ["menu","heroes"]:
        title.hide()
        subtitle.hide()
        detail.hide()
        play_button.visible = menu
        options_button.visible = menu
        _focus_ring()
        queue_redraw()
        return
    else:
        for i in range(3): game.menu_buttons[i].hide(); game.hero_portraits[i].hide()
        var headings := {"choice":"LEVEL UP!","legendary":"GO LEGENDARY","replace":"MAKE ROOM","build":"YOUR BUILD","paused":"TAKE A BREATHER","options":"YOUR SETTINGS","confirm_exit":"LEAVE THIS RUN?","profile_import":"IMPORT YOUR SAVE","profile_export":"YOUR SAVE DATA","won":"BIG HATER DOWN!","lost":"ONE MORE RUN?"}
        title.text = "LEVEL UP!  /  %d" % game.level if game.mode == "choice" else headings.get(game.mode,"")
        if portrait and game.mode == "paused": title.text = "PAUSED"
        _place(title,Rect2(modal_panel.position+Vector2(24,18),Vector2(modal_panel.size.x-48,48)))
        subtitle.text = {"choice":"Choose one. Confirm to keep farming.","legendary":"ONE PER RUN  /  Three weapons. Three buffs.","replace":"The old item is removed. Its effects do not carry over.","build":"THREE WEAPONS / FIVE PASSIVES. Your actual equipped items.","paused":"Simulation paused.","options":"Make it yours. Everything is saved on this device.","confirm_exit":"This unfinished run will not count towards your profile.","profile_import":"Paste a Phaser v1 or v2 profile. Your current profile is backed up.","profile_export":"Copy this JSON to transfer your progress to another browser.","won":"Victory recorded. Your next run starts fresh.","lost":"Progress recorded. Take what you learned into the next run."}.get(game.mode,"")
        if game.mode == "replace":
            var incoming: Dictionary = catalog.get(game.replace_card.get("id",""),{})
            subtitle.text = "%s · %s replaces one equipped item. Removed effects do not carry over." % [incoming.get("name","New item"),str(game.replace_card.get("rarity","")).to_upper()]
        if game.mode == "profile_import" and not error_message.is_empty(): subtitle.text = error_message
        subtitle.add_theme_color_override("font_color",ArcadeStyle.CORAL if game.mode == "profile_import" and not error_message.is_empty() else ArcadeStyle.INK)
        subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        _place(subtitle,Rect2(modal_panel.position+Vector2(24,72),Vector2(modal_panel.size.x-48,48)))
        var footer_y := modal_panel.end.y-74
        var action_width := minf(300,(modal_panel.size.x-72)/2)
        _place(game.confirm_button,Rect2(modal_panel.end.x-24-action_width,footer_y,action_width,60))
        _place(game.restart_button,Rect2(modal_panel.position.x+24,footer_y,action_width,60))
        _place(game.defer_button,Rect2(modal_panel.position.x+24,footer_y,action_width,60))
        _place(game.retry_button,Rect2(modal_panel.end.x-24-action_width,footer_y,action_width,60))
        _place(back_button,Rect2(modal_panel.position.x+24,footer_y,action_width,60))
        var header_height := 150.0 if portrait else 132.0
        content_rect = Rect2(modal_panel.position+Vector2(24,header_height),Vector2(modal_panel.size.x-48,maxf(60,footer_y-modal_panel.position.y-header_height-16)))
        if cards:
            _cards(content_rect)
            var offers: Array = game.selection if game.mode == "choice" else (game.legendary_offers if game.mode == "legendary" else game.replace_options)
            if game.selected_card_index >= 0 and game.selected_card_index < offers.size():
                var selected: Dictionary = catalog.get(offers[game.selected_card_index].get("id",""),{"name":"Recovery"})
                subtitle.text = "SELECTED: %s / Confirm below" % selected["name"]
        elif settings:
            _place(body_scroll,content_rect)
            var stacked: bool = content_rect.size.x < 800 or compact or game.mode == "build"
            var body_width := content_rect.size.x-14
            var settings_width := body_width if stacked else 340.0
            var settings_x := 0.0 if stacked else body_width-settings_width
            var settings_y := 0.0
            detail.visible = options and not stacked
            detail.text = "MAKE YOUR OWN AURA\n\nWASD / arrows — move\nSpace / E — Flex\nM — switch aim\nP / Escape — pause\n\nTouch: drag on the left to move."
            _place(detail,Rect2(content_rect.position,Vector2(maxf(0,content_rect.size.x-settings_width-24),content_rect.size.y)))
            var build_height := 0.0
            if game.mode == "build":
                build_height = _equipment(body_width if stacked else body_width-settings_width-24)
            if game.mode == "build" and stacked: settings_y = build_height+20
            _place(volume_label,Rect2(settings_x,settings_y,settings_width,28))
            _place(volume_slider,Rect2(settings_x,settings_y+32,settings_width,64))
            settings_y += 108 if options else 0
            _place(game.sound_button,Rect2(settings_x,settings_y,settings_width,60))
            _place(game.motion_button,Rect2(settings_x,settings_y+72,settings_width,64))
            _place(game.import_button,Rect2(settings_x,settings_y+148,settings_width,60))
            _place(game.export_button,Rect2(settings_x,settings_y+220,settings_width,60))
            var content_height := maxf(maxf(content_rect.size.y,build_height),settings_y+(280 if options else 144))
            body_content.custom_minimum_size = Vector2(body_width,content_height)
            body_content.size = body_content.custom_minimum_size
        elif game.mode in ["profile_import","profile_export"]:
            _place(game.profile_text,content_rect)
            game.profile_text.add_theme_stylebox_override("normal",ArcadeStyle.box(ArcadeStyle.CARD,ArcadeStyle.INK,8,0))
            game.profile_text.add_theme_color_override("font_color",ArcadeStyle.INK)
            detail.hide()
        elif game.mode in ["won","lost"]:
            detail.text = "%s\n\nWAVE %d    /    LEVEL %d    /    %d KILLS\n\nDamage  %s\nHealing  %s    /    Shield absorbed  %s\nFlexes  %d    /    Safe Spot visits  %d" % [game.hero["name"],game.wave,game.level,game.kills,_number(game.run_metrics["damage"]),_number(game.run_metrics["healing"]),_number(game.run_metrics["protection"]),int(game.run_metrics["flexes"]),game.safe_spot_uses]
            _place(detail,content_rect)
        elif game.mode == "confirm_exit":
            detail.text = "Your settings and earlier completed results remain saved."
            _place(detail,content_rect)
    if game.mode in ["won","lost"]:
        title.hide()
        subtitle.hide()
        detail.hide()
        secondary.refresh(view)
    if game.mode == "confirm_exit":
        title.add_theme_color_override("font_color",ArcadeStyle.CARD)
        subtitle.add_theme_color_override("font_color",ArcadeStyle.CARD)
        detail.add_theme_color_override("font_color",ArcadeStyle.CARD)
        game.restart_button.text = "STAY"
        game.confirm_button.text = "QUIT RUN"
    else:
        title.add_theme_color_override("font_color",ArcadeStyle.INK)
        detail.add_theme_color_override("font_color",ArcadeStyle.INK)
    if portrait and game.mode in ["paused","won","lost"]: game.restart_button.text = "MAIN MENU"
    _place(game.pause_button,Rect2(width-176,14,158,60))
    if game.mode == "paused": _place(game.pause_button,Rect2(modal_panel.end.x-190,modal_panel.position.y+18,166,60))
    _place(game.flex_button,Rect2(width-246,height-78,226,60))
    _place(game.legendary_button,Rect2(20 if width < 1000 else width-500,height-78,minf(238,width-286) if width < 1000 else 238,60))
    game.flex_button.text = game.flex_status()
    game.flex_button.disabled = game.aura < 100.0 or game.flex_lock > 0.0
    if not cards:
        for button: Button in game.offer_buttons: button.hide()
    if not menu and not options and game.mode == "playing":
        title.hide(); subtitle.hide(); detail.hide()
    _focus_ring()
    queue_redraw()

func _cards(rect: Rect2) -> void:
    _place(card_scroll,rect)
    var items: Array = game.selection if game.mode == "choice" else (game.legendary_offers if game.mode == "legendary" else game.replace_options)
    var columns := 3 if rect.size.x >= 850 else (2 if rect.size.x >= 580 else 1)
    var gap := 14.0
    var width := (rect.size.x-12.0-gap*(columns-1))/columns
    var desktop_grid := columns == 3 and rect.size.y >= 440.0
    var height := minf(224,(rect.size.y-gap)/2.0) if game.mode == "legendary" and desktop_grid else (280.0 if game.mode == "legendary" else 416.0)
    if game.mode != "legendary" and columns >= 2 and rect.size.y >= 280: height = minf(height,rect.size.y)
    var rows := ceili(float(items.size())/columns)
    card_content.custom_minimum_size = Vector2(rect.size.x-12,rows*height+maxi(0,rows-1)*gap)
    card_content.size = card_content.custom_minimum_size
    var signature: String = str(game.mode) + JSON.stringify(items)
    if signature != last_card_signature:
        card_scroll.scroll_vertical = 0
        last_card_signature = signature
        last_selected = -1
    for i in range(game.offer_buttons.size()):
        var button: Button = game.offer_buttons[i]
        button.visible = i < items.size()
        if i >= items.size(): continue
        button.text = ""
        button.custom_minimum_size = Vector2.ZERO
        _place(button,Rect2((i%columns)*(width+gap),int(i/columns)*(height+gap),width,height))
        var item: Dictionary = items[i]
        var id: String = str(item.get("id",""))
        var data: Dictionary = catalog.get(id,{"name":"Recovery","icon":"+","description":"Restore 8% of maximum HP."})
        var rarity: String = item.get("rarity","")
        var level_value: int = int(item.get("level",1))
        var old: Dictionary = {}
        for equipped: Dictionary in game.weapons + game.passives:
            if equipped["id"] == id: old = equipped
        if rarity.is_empty():
            for equipped: Dictionary in game.weapons + game.passives:
                if equipped["id"] == id:
                    rarity = equipped["rarity"]
                    level_value = int(equipped["level"])
        var color: Color = ArcadeStyle.RARITY.get(rarity,ArcadeStyle.INK)
        ArcadeStyle.card(button,i==game.selected_card_index,color)
        var parts: Dictionary = card_parts[i]
        parts["icon"].text = data.get("icon","+")
        parts["name"].text = data.get("name",id)
        parts["body"].text = data.get("legendary_description",data.get("description","")) if rarity == "legendary" else data.get("description","")
        var category := "WEAPON" if game.WEAPONS.has(id) else ("PASSIVE" if catalog.has(id) else "RECOVERY")
        var level_caption := "LV %d/%d" % [level_value,int(game.CAP_LEVELS.get(rarity,1))]
        OfferCard.layout(parts,Vector2(width,height),game.mode == "legendary",rarity,category,level_caption)
        var comparison := "No equipment slot used"
        if game.mode == "replace": comparison = "Remove this item and its effects"
        elif not old.is_empty(): comparison = "LV %d %s → LV %d %s" % [int(old["level"]),old["rarity"],level_value,rarity]
        elif catalog.has(id): comparison = "Uses one %s slot" % ("weapon" if game.WEAPONS.has(id) else "passive")
        if game.WEAPONS.has(id) and game.mode != "replace":
            var new_stats := _weapon_summary(id,rarity,level_value)
            comparison += "\n" + (_weapon_summary(id,old["rarity"],int(old["level"])) + " → " if not old.is_empty() else "") + new_stats
        parts["comparison"].text = comparison
        parts["state"].text = "SELECTED / CONFIRM BELOW" if i==game.selected_card_index else "%d  /  %s" % [i+1,"REPLACE THIS ITEM" if game.mode == "replace" else str(item.get("type","equip")).replace("_"," ").to_upper()]
        button.tooltip_text = "%s / %s\n%s\n%s\n%s" % [data.get("name",id),rarity.to_upper(),category,parts["body"].text,comparison]
    if game.selected_card_index != last_selected and game.selected_card_index >= 0:
        # Top-align oversized cards so focus never scrolls their name/rarity out of view.
        card_scroll.set_deferred("scroll_vertical",int(game.offer_buttons[game.selected_card_index].position.y))
    last_selected = game.selected_card_index

func _equipment(width: float) -> float:
    # Fixed empty slots communicate capacity without inventing equipment or effects.
    var columns := 3 if width >= 540 else 2
    var gap := 12.0
    var tile_width := (width-gap*(columns-1))/columns
    var tile_height := 118.0
    var weapon_rows := ceili(3.0/columns)
    var passive_y := 36.0+weapon_rows*(tile_height+gap)+12.0
    _place(equipment_headings[0],Rect2(0,0,width,28))
    _place(equipment_headings[1],Rect2(0,passive_y,width,28))
    for i in range(8):
        var is_weapon := i < 3
        var index := i if is_weapon else i-3
        var items: Array = game.weapons if is_weapon else game.passives
        var item: Dictionary = items[index] if index < items.size() else {}
        var slot: Dictionary = equipment_slots[i]
        var y := 36.0 if is_weapon else passive_y+36.0
        _place(slot["panel"],Rect2((index%columns)*(tile_width+gap),y+int(index/columns)*(tile_height+gap),tile_width,tile_height))
        var color: Color = ArcadeStyle.RARITY.get(item.get("rarity",""),ArcadeStyle.INK)
        slot["panel"].add_theme_stylebox_override("panel",ArcadeStyle.box(ArcadeStyle.CARD,color,8,0))
        var label: Label = slot["label"]
        if item.is_empty():
            label.text = "EMPTY %s SLOT\n%d / %d" % ["WEAPON" if is_weapon else "PASSIVE",index+1,3 if is_weapon else 5]
        else:
            var data: Dictionary = catalog.get(item["id"],{})
            label.text = "%s  %s\n%s  /  LV %d" % [data.get("icon","?"),data.get("name",item["id"]),str(item["rarity"]).to_upper(),int(item["level"])]
        _place(label,Rect2(12,10,tile_width-24,tile_height-20))
    var height := passive_y+36.0+ceili(5.0/columns)*(tile_height+gap)
    _place(equipment_board,Rect2(0,0,width,height))
    return height

func _number(value: float) -> String:
    return "%.1fk" % (value/1000.0) if value >= 1000.0 else "%.0f" % value

func _panel(rect: Rect2, fill: Color = ArcadeStyle.PAPER) -> void:
    draw_style_box(ArcadeStyle.box(fill),rect)

func _text(at: Vector2, text: String, font_size: int = 18, color: Color = ArcadeStyle.INK) -> void:
    draw_string(ArcadeStyle.NUMBERS,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)

func _bar(rect: Rect2, value: float, maximum: float, color: Color, caption: String) -> void:
    draw_style_box(ArcadeStyle.box(ArcadeStyle.INK,ArcadeStyle.INK,7,0),rect)
    var fill := Rect2(rect.position+Vector2(3,3),Vector2((rect.size.x-6)*clampf(value/maxf(maximum,1),0,1),rect.size.y-6))
    if fill.size.x > 0: draw_style_box(ArcadeStyle.box(color,color,4,0),fill)
    draw_string_outline(ArcadeStyle.NUMBERS,rect.position+Vector2(9,rect.size.y-7),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,17,3,ArcadeStyle.INK)
    _text(rect.position+Vector2(9,rect.size.y-7),caption,17,ArcadeStyle.CARD)

func _draw() -> void:
    if game == null or view.x <= 0: return
    if game.mode in ["menu","heroes"]: return
    if game.mode != "playing":
        draw_rect(Rect2(Vector2.ZERO,view),Color(0.09,0.13,0.19,0.72))
        if game.mode in ["choice","legendary","replace"]:
            draw_style_box(ArcadeStyle.box(ArcadeStyle.PAPER,ArcadeStyle.GOLD,16,6),modal_panel)
        elif game.mode not in ["paused","won","lost"]: _panel(modal_panel,ArcadeStyle.DEEP if game.mode == "confirm_exit" else ArcadeStyle.PAPER)
        return
    var slot_x := 20.0
    for item: Dictionary in game.weapons + game.passives:
        var data: Dictionary = catalog.get(item["id"],{})
        var rect := Rect2(slot_x,view.y-(138 if view.x < 1000 else 62),46,44)
        draw_style_box(ArcadeStyle.box(ArcadeStyle.PAPER,ArcadeStyle.RARITY.get(item["rarity"],ArcadeStyle.INK),8,2),rect)
        _text(rect.position+Vector2(7,26),data.get("icon","?"),22)
        _text(rect.position+Vector2(30,37),str(item["level"]),13)
        slot_x += 54

func show_error(message: String) -> void:
    error_message = message
    refresh()

func _weapon_summary(id: String, rarity: String, level_value: int) -> String:
    var definition: Dictionary = game.WEAPONS[id]
    var damage: float = game._base_power() * float(definition["power"]) * float(game.RARITY_POWER[rarity]) * (1.0+0.15*(level_value-1))
    var frequency: float = game.SoloPassiveRulesScript.weapon_frequency(game.passives,game.passive_timers,game.run_time,game.player_pos)
    var interval: float = maxf(0.2,float(definition["interval"])*pow(0.95,level_value-1)/(1.0+frequency))
    return "%.0f dmg · %.2fs" % [damage,interval]

func hud_rectangles() -> Array[Rect2]:
    return load("res://scripts/spotlight_hud.gd").rectangles(view)

func _focus_ring() -> void:
    var buttons: Array[Control] = []
    _visible_buttons(self,buttons)
    for i in range(buttons.size()):
        buttons[i].focus_next = buttons[(i+1)%buttons.size()].get_path()
        buttons[i].focus_previous = buttons[(i+buttons.size()-1)%buttons.size()].get_path()
    var focused := get_viewport().gui_get_focus_owner()
    if not buttons.is_empty() and (focused == null or not buttons.has(focused)):
        buttons[0].grab_focus.call_deferred()

func _visible_buttons(node: Node, buttons: Array[Control]) -> void:
    for child in node.get_children():
        if child is Control and child.focus_mode == Control.FOCUS_ALL and child.is_visible_in_tree() and not (child is BaseButton and child.disabled): buttons.append(child)
        _visible_buttons(child,buttons)
