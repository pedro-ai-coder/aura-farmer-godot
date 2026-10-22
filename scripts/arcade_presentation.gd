class_name ArcadePresentation
extends Control

## Reusable responsive presentation. Never advances simulation or consumes gameplay RNG.
const ArcadeStyle = preload("res://scripts/arcade_theme.gd")
var game
var catalog: Dictionary = {}
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
    options_button = _button("OPTIONS & SAVE",func(): game.mode = "options"; game._clear_touch(); game._show_ui())
    back_button = _button("BACK",func(): game._return_to_menu())
    card_scroll = ScrollContainer.new()
    card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(card_scroll)
    card_content = Control.new()
    card_scroll.add_child(card_content)
    for i in range(game.offer_buttons.size()):
        var button: Button = game.offer_buttons[i]
        button.reparent(card_content)
        button.text = ""
        var parts := {"icon":_inside_label(button,34),"name":_inside_label(button,22),"meta":_inside_label(button,16),"body":_inside_label(button,18),"state":_inside_label(button,15),"comparison":_inside_label(button,16)}
        parts["name"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        parts["body"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        card_parts.append(parts)
    body_scroll = ScrollContainer.new()
    body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(body_scroll)
    body_content = Control.new()
    body_scroll.add_child(body_content)
    for control: Control in [game.build_details,game.sound_button,game.motion_button,game.import_button,game.export_button]: control.reparent(body_content)
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
    if font_size >= 30:
        var bold := FontVariation.new()
        bold.base_font = ThemeDB.fallback_font
        bold.variation_embolden = 1.0
        label.add_theme_font_override("font",bold)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(label)
    return label

func _inside_label(parent: Control, font_size: int) -> Label:
    var label := _label(font_size)
    label.reparent(parent)
    return label

func _button(text: String, action: Callable) -> Button:
    var button := Button.new()
    button.text = text
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
    if game.mode != "menu": return
    game.hero_index = index
    refresh()

func pump() -> void:
    if game.get_window().size != last_window_size: _window_changed()
    queue_redraw()

func _place(control: Control, rect: Rect2) -> void:
    control.position = rect.position
    control.size = rect.size
    if control is Label: control.set_deferred("size",rect.size)

func refresh(force: bool = false) -> void:
    if game == null or play_button == null: return
    if view.x <= 0.0: view = game.get_viewport_rect().size
    var equipment := ""
    for item: Dictionary in game.weapons + game.passives: equipment += "%s:%s:%s;" % [item["id"],item["rarity"],item["level"]]
    var signature: String = str(game.mode) + str(game.hero_index) + str(game.selected_card_index) + str(game.level) + equipment + JSON.stringify(game.selection) + JSON.stringify(game.legendary_offers) + str(game.profile["settings"]) + error_message + str(game.touch_device)
    game.flex_button.text = "FLEX READY  [E]" if game.aura >= 100.0 and game.flex_lock <= 0.0 else "FLEX  %d%%" % int(game.aura)
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
    var settings: bool = options or game.mode == "paused"
    game.headline.hide()
    game.metrics.hide()
    game.notice.hide()
    game.hud_top.hide()
    game.hud_bottom.hide()
    game.modal_dim.hide()
    menu_panel = Rect2(width*0.52,36,width*0.45,height-72) if not portrait else Rect2(18,height*0.25,width-36,height*0.75-18)
    if compact: menu_panel = Rect2(width*0.47,18,width*0.51,height-36)
    modal_panel = Rect2(Vector2(maxf(18,(width-1160)/2),18),Vector2(minf(width-36,1160),height-36))
    title.visible = not menu
    subtitle.visible = true
    detail.visible = menu or settings or game.mode in ["won","lost","confirm_exit","profile_import","profile_export"]
    play_button.visible = menu
    options_button.visible = menu
    back_button.visible = options
    game.sound_button.visible = settings
    game.motion_button.visible = settings
    game.import_button.visible = options
    game.export_button.visible = options
    game.profile_text.visible = game.mode in ["profile_import","profile_export"]
    game.build_details.visible = game.mode == "paused"
    game.pause_button.visible = game.mode == "playing" or game.mode == "paused"
    game.retry_button.visible = game.mode in ["won","lost"]
    game.restart_button.visible = game.mode in ["paused","won","lost","replace","confirm_exit","profile_import","profile_export"]
    game.confirm_button.visible = cards or game.mode in ["confirm_exit","profile_import","profile_export"]
    game.defer_button.visible = game.mode == "legendary"
    card_scroll.visible = cards
    body_scroll.visible = settings
    rotate_hint.visible = game.mode == "playing" and game.touch_device and portrait
    _place(rotate_hint,Rect2(20,162,width-40,40))
    for control: Button in [game.pause_button,game.flex_button,game.confirm_button,game.restart_button,game.defer_button,game.retry_button,game.sound_button,game.motion_button,game.import_button,game.export_button,game.legendary_button,play_button,options_button,back_button]:
        ArcadeStyle.button(control,control == play_button)
    if menu:
        subtitle.text = "RUIN ALLEY  /  SOLO"
        _place(subtitle,Rect2(menu_panel.position+Vector2(22,16),Vector2(menu_panel.size.x-44,28)))
        var card_y := menu_panel.position.y + (56.0 if compact else 68.0)
        var card_height := minf(235.0,menu_panel.size.y-(326.0 if compact else 250.0))
        card_height = maxf(166,card_height)
        if portrait: card_height = minf(260,menu_panel.size.y-270)
        var gap := 10.0
        var card_width := (menu_panel.size.x-44.0-gap*2.0)/3.0
        for i in range(3):
            var button: Button = game.menu_buttons[i]
            button.visible = true
            button.text = ""
            _place(button,Rect2(menu_panel.position.x+22+i*(card_width+gap),card_y,card_width,card_height))
            ArcadeStyle.button(button,i==game.hero_index)
            var portrait_image: TextureRect = game.hero_portraits[i]
            portrait_image.visible = true
            _place(portrait_image,Rect2(7,10,card_width-14,maxf(70,card_height-75)))
            var labels: Dictionary = hero_labels[i]
            labels["name"].text = ["SIGMA","COOL KID","ALPHA"][i]
            labels["name"].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            labels["name"].add_theme_font_size_override("font_size",22)
            _place(labels["name"],Rect2(3,card_height-70,card_width-6,32))
            labels["role"].text = str(game.HEROES[i]["role"]).to_upper()
            labels["role"].add_theme_font_size_override("font_size",22)
            labels["role"].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            _place(labels["role"],Rect2(3,card_height-36,card_width-6,32))
        var hero: Dictionary = game.HEROES[game.hero_index]
        detail.text = "%s  ·  %s\n%s" % [hero["name"],hero["flex"],["Lock onto a rival. Throw No Cap through the crowd.","Keep moving. Unleash Giga Chad Rampage.","Hold the line. Shield up and slam with Alpha Hold."][game.hero_index]]
        if compact: detail.text = "%s  ·  %s" % [hero["name"],hero["flex"]]
        detail.add_theme_font_size_override("font_size",22 if compact else 20)
        _place(detail,Rect2(menu_panel.position.x+24,card_y+card_height+14,menu_panel.size.x-48,64 if compact else 90))
        var footer_y := menu_panel.end.y-144
        _place(play_button,Rect2(menu_panel.position.x+22,footer_y,menu_panel.size.x-44,60))
        _place(options_button,Rect2(menu_panel.position.x+22,footer_y+72,menu_panel.size.x-44,60))
    else:
        for i in range(3): game.menu_buttons[i].hide(); game.hero_portraits[i].hide()
        var headings := {"choice":"LEVEL UP!","legendary":"GO LEGENDARY","replace":"MAKE ROOM","paused":"TAKE A BREATHER","options":"YOUR SETTINGS","confirm_exit":"LEAVE THIS RUN?","profile_import":"IMPORT YOUR SAVE","profile_export":"YOUR SAVE DATA","won":"BIG HATER DOWN!","lost":"ONE MORE RUN?"}
        title.text = "LEVEL UP!  /  %d" % game.level if game.mode == "choice" else headings.get(game.mode,"")
        if portrait and game.mode == "paused": title.text = "PAUSED"
        _place(title,Rect2(modal_panel.position+Vector2(24,18),Vector2(modal_panel.size.x-48,48)))
        subtitle.text = {"choice":"Choose one. Confirm to keep farming.","legendary":"ONE PER RUN  /  Three weapons. Three buffs.","replace":"The old item is removed. Its effects do not carry over.","paused":"Simulation paused. Your build and settings are below.","options":"Make it yours. Everything is saved on this device.","confirm_exit":"This unfinished run will not count towards your profile.","profile_import":"Paste a Phaser v1 or v2 profile. Your current profile is backed up.","profile_export":"Copy this JSON to transfer your progress to another browser.","won":"Victory recorded. Your next run starts fresh.","lost":"Progress recorded. Take what you learned into the next run."}.get(game.mode,"")
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
        if cards: _cards(content_rect)
        elif settings:
            _place(body_scroll,content_rect)
            var stacked := content_rect.size.x < 800 or compact
            var body_width := content_rect.size.x-14
            var settings_width := body_width if stacked else 340.0
            var settings_x := 0.0 if stacked else body_width-settings_width
            var settings_y := 0.0
            detail.visible = options and not stacked
            detail.text = "MAKE YOUR OWN AURA\n\nWASD / arrows — move\nSpace / E — Flex\nM — switch aim\nP / Escape — pause\n\nTouch: drag on the left to move."
            _place(detail,Rect2(content_rect.position,Vector2(maxf(0,content_rect.size.x-settings_width-24),content_rect.size.y)))
            var build_height := maxf(160,(game.weapons.size()+game.passives.size()+4)*(34.0 if stacked else 28.0))
            _place(game.build_details,Rect2(0,0,body_width if stacked else body_width-settings_width-24,build_height))
            game.build_details.add_theme_font_size_override("font_size",22 if stacked else 18)
            game.build_details.add_theme_color_override("font_color",ArcadeStyle.INK)
            if game.mode == "paused" and stacked: settings_y = build_height+20
            _place(game.sound_button,Rect2(settings_x,settings_y,settings_width,60))
            _place(game.motion_button,Rect2(settings_x,settings_y+72,settings_width,64))
            _place(game.import_button,Rect2(settings_x,settings_y+148,settings_width,60))
            _place(game.export_button,Rect2(settings_x,settings_y+220,settings_width,60))
            var content_height := maxf(content_rect.size.y,settings_y+(280 if options else 144))
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
    if portrait and game.mode in ["paused","won","lost"]: game.restart_button.text = "MAIN MENU"
    _place(game.pause_button,Rect2(width-176,14,158,60))
    if game.mode == "paused": _place(game.pause_button,Rect2(modal_panel.end.x-190,modal_panel.position.y+18,166,60))
    _place(game.flex_button,Rect2(width-246,height-78,226,60))
    _place(game.legendary_button,Rect2(20 if width < 1000 else width-500,height-78,minf(238,width-286) if width < 1000 else 238,60))
    game.flex_button.text = "FLEX READY  [E]" if game.aura >= 100.0 and game.flex_lock <= 0.0 else "FLEX  %d%%" % int(game.aura)
    game.flex_button.disabled = game.aura < 100.0 or game.flex_lock > 0.0
    if not cards:
        for button: Button in game.offer_buttons: button.hide()
    if not menu and not options and game.mode == "playing":
        title.hide(); subtitle.hide(); detail.hide()
    queue_redraw()

func _cards(rect: Rect2) -> void:
    _place(card_scroll,rect)
    var items: Array = game.selection if game.mode == "choice" else (game.legendary_offers if game.mode == "legendary" else game.replace_options)
    var columns := 3 if rect.size.x >= 850 and view.y >= 650 else (2 if rect.size.x >= 580 else 1)
    var gap := 14.0
    var width := (rect.size.x-12.0-gap*(columns-1))/columns
    var desktop_grid := columns == 3 and rect.size.y >= 440.0
    var height := minf(224,(rect.size.y-gap)/2.0) if game.mode == "legendary" and desktop_grid else (280.0 if game.mode == "legendary" else (330.0 if columns >= 2 else 360.0))
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
        ArcadeStyle.button(button,i==game.selected_card_index,color)
        var parts: Dictionary = card_parts[i]
        parts["icon"].text = data.get("icon","+")
        _place(parts["icon"],Rect2(18,10,50,42))
        parts["meta"].text = "%s  ·  LV %d/%d" % [rarity.to_upper(),level_value,int(game.CAP_LEVELS.get(rarity,1))]
        _place(parts["meta"],Rect2(72,19,width-90,26))
        parts["name"].text = data.get("name",id)
        _place(parts["name"],Rect2(18,53,width-36,40))
        parts["body"].text = data.get("legendary_description",data.get("description","")) if rarity == "legendary" else data.get("description","")
        parts["body"].add_theme_font_size_override("font_size",(16 if game.mode == "legendary" else 18) if desktop_grid else 22)
        _place(parts["body"],Rect2(18,96,width-36,height-(130 if game.mode == "legendary" else 190)))
        parts["body"].clip_text = false
        parts["comparison"].visible = game.mode != "legendary"
        parts["comparison"].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        var comparison := "No equipment slot used"
        if game.mode == "replace": comparison = "Remove this item and its effects"
        elif not old.is_empty(): comparison = "LV %d %s → LV %d %s" % [int(old["level"]),old["rarity"],level_value,rarity]
        elif catalog.has(id): comparison = "Uses one %s slot" % ("weapon" if game.WEAPONS.has(id) else "passive")
        if game.WEAPONS.has(id) and game.mode != "replace":
            var new_stats := _weapon_summary(id,rarity,level_value)
            comparison += "\n" + (_weapon_summary(id,old["rarity"],int(old["level"])) + " → " if not old.is_empty() else "") + new_stats
        parts["comparison"].text = comparison
        _place(parts["comparison"],Rect2(18,height-86,width-36,48))
        parts["state"].text = "✓ SELECTED — CONFIRM BELOW" if i==game.selected_card_index else "%d  /  %s" % [i+1,"REPLACE THIS ITEM" if game.mode == "replace" else str(item.get("type","equip")).replace("_"," ").to_upper()]
        _place(parts["state"],Rect2(18,height-33,width-36,25))
        button.tooltip_text = str(data.get("description",""))
    if game.selected_card_index != last_selected and game.selected_card_index >= 0:
        card_scroll.call_deferred("ensure_control_visible",game.offer_buttons[game.selected_card_index])
    last_selected = game.selected_card_index

func _number(value: float) -> String:
    return "%.1fk" % (value/1000.0) if value >= 1000.0 else "%.0f" % value

func _panel(rect: Rect2, fill: Color = ArcadeStyle.PAPER) -> void:
    draw_style_box(ArcadeStyle.box(fill),rect)

func _text(at: Vector2, text: String, font_size: int = 18, color: Color = ArcadeStyle.INK) -> void:
    draw_string(ThemeDB.fallback_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)

func _bar(rect: Rect2, value: float, maximum: float, color: Color, caption: String) -> void:
    draw_style_box(ArcadeStyle.box(ArcadeStyle.INK,ArcadeStyle.INK,7,0),rect)
    var fill := Rect2(rect.position+Vector2(3,3),Vector2((rect.size.x-6)*clampf(value/maxf(maximum,1),0,1),rect.size.y-6))
    if fill.size.x > 0: draw_style_box(ArcadeStyle.box(color,color,4,0),fill)
    draw_string_outline(ThemeDB.fallback_font,rect.position+Vector2(9,rect.size.y-7),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,17,3,ArcadeStyle.INK)
    _text(rect.position+Vector2(9,rect.size.y-7),caption,17,ArcadeStyle.CARD)

func _draw() -> void:
    if game == null or view.x <= 0: return
    if game.mode == "menu":
        var texture: Texture2D = game.art.texture("main-menu")
        if texture != null:
            var source := texture.get_size()
            var scale := maxf(view.x/source.x,view.y/source.y)
            var extent := source*scale
            if view.x < 700.0:
                draw_rect(Rect2(Vector2.ZERO,view),ArcadeStyle.INK)
                var header_height := menu_panel.position.y+4
                var crop_width := source.x*0.55
                draw_texture_rect_region(texture,Rect2(0,0,view.x,header_height),Rect2(0,0,crop_width,crop_width*header_height/view.x))
            else: draw_texture_rect(texture,Rect2(Vector2.ZERO,extent),false)
        _panel(menu_panel)
        return
    if game.mode != "playing":
        draw_rect(Rect2(Vector2.ZERO,view),Color(0.09,0.13,0.19,0.72))
        _panel(modal_panel)
        return
    var bars: Array[Rect2] = hud_rectangles()
    if view.x < 700.0:
        _panel(Rect2(14,10,view.x-28,146),ArcadeStyle.PAPER)
        _bar(bars[0],game.hp,game.max_hp,ArcadeStyle.CORAL,"HP %d / %d" % [ceili(game.hp),int(game.max_hp)])
        _bar(bars[1],game.xp,30+8*game.level+game.level*game.level,ArcadeStyle.TEAL,"XP / LV %d" % game.level)
        _bar(bars[2],game.aura,100,ArcadeStyle.GOLD,"AURA %d%%" % int(game.aura))
        _text(Vector2(26,139),"SHIELD %d  /  WAVE %d  /  %02d:%02d" % [ceili(game.shield),game.wave,int(game.run_time)/60,int(game.run_time)%60],18)
    else:
        var hud_width := minf(view.x-210,860)
        _panel(Rect2(14,10,hud_width,74),ArcadeStyle.PAPER)
        _bar(bars[0],game.hp,game.max_hp,ArcadeStyle.CORAL,"HP %d / %d" % [ceili(game.hp),int(game.max_hp)])
        _bar(bars[1],game.xp,30+8*game.level+game.level*game.level,ArcadeStyle.TEAL,"XP / LV %d" % game.level)
        _bar(bars[2],game.aura,100,ArcadeStyle.GOLD,"AURA %d%%" % int(game.aura))
        _text(Vector2(26,72),"SHIELD %d   /   %s   /   %02d:%02d" % [ceili(game.shield),"BIG HATER" if game.boss_spawned else "WAVE %d" % game.wave,int(game.run_time)/60,int(game.run_time)%60],18)
    var slot_x := 20.0
    for item: Dictionary in game.weapons + game.passives:
        var data: Dictionary = catalog.get(item["id"],{})
        var rect := Rect2(slot_x,view.y-(138 if view.x < 1000 else 62),46,44)
        draw_style_box(ArcadeStyle.box(ArcadeStyle.PAPER,ArcadeStyle.RARITY.get(item["rarity"],ArcadeStyle.INK),8,2),rect)
        _text(rect.position+Vector2(7,26),data.get("icon","?"),22)
        _text(rect.position+Vector2(30,37),str(item["level"]),13)
        slot_x += 54
    for enemy: Dictionary in game.enemies:
        if enemy["kind"] == "boss":
            var boss_width := minf(620,view.x-80)
            var rect := Rect2((view.x-boss_width)/2,202 if view.x < 700 else 102,boss_width,26)
            _bar(rect,enemy["hp"],enemy["max"],ArcadeStyle.CORAL,"BIG HATER  /  %s HP" % _number(enemy["hp"]))
            _text(rect.position+Vector2(0,52),"FULL HATER MODE" if game.run_time >= 1080.0 else "BERSERK IN %ds" % ceili(1080-game.run_time),18,ArcadeStyle.CARD)
            break

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
    if view.x < 700:
        var width := (view.x-64)/2
        return [Rect2(25,20,view.x-210,28),Rect2(25,84,width,28),Rect2(39+width,84,width,28)]
    var width := maxf(70,(minf(view.x-210,860)-58)/3)
    return [Rect2(25,20,width,28),Rect2(39+width,20,width,28),Rect2(53+width*2,20,width,28)]
