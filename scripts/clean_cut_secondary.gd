extends Control
## Secondary journeys use the same approved sources and existing signal-bound controls.
const MODES = ["paused","build","options","confirm_exit","profile_import","profile_export","won","lost"]
var skin
var game
var ui
var caption: Label
var result_portrait: TextureRect
var result_scroll: ScrollContainer
var result: Label
var result_rows: VBoxContainer
var result_values: Array[Label] = []
var result_hero: Label
var actions: Array[Button] = []
var build_frames: Array[TextureRect] = []
var pause_dim: ColorRect
var pause_panel: Panel
var pause_accent: ColorRect
var screen_panel: Panel
var build_parts: Array[Dictionary]=[]
var primary_stats: GridContainer
var secondary_stats: GridContainer
var stat_parts: Array[Dictionary]=[]
var fullscreen_button: Button
var fullscreen_status: Label
var fullscreen_bounds:=Rect2()
var web_fullscreen_key: String=""
var card_styles: Dictionary={}

func install(owner_skin) -> void:
    skin=owner_skin;game=skin.game;ui=skin.ui
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    pause_dim=ColorRect.new();pause_dim.color=Color(0.025,0.045,0.075,0.68)
    pause_dim.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(pause_dim)
    pause_panel=Panel.new();pause_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
    pause_panel.add_theme_stylebox_override("panel",skin.Style.box(skin.Style.PAPER,skin.Style.INK,4,3))
    add_child(pause_panel)
    pause_accent=ColorRect.new();pause_accent.color=skin.Style.GOLD;pause_accent.mouse_filter=Control.MOUSE_FILTER_IGNORE
    pause_panel.add_child(pause_accent)
    screen_panel=Panel.new();screen_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
    screen_panel.add_theme_stylebox_override("panel",skin.Style.box(skin.Style.PAPER,skin.Style.INK,3,3))
    add_child(screen_panel)
    caption=skin.label(self,18,skin.Style.INK)
    caption.add_theme_stylebox_override("normal",skin.Style.box(skin.Style.PAPER,skin.Style.PAPER,0,0))
    result_portrait=skin.image(self)
    result_scroll=ScrollContainer.new()
    result_scroll.add_theme_stylebox_override("panel",skin.Style.box(skin.Style.PAPER,skin.Style.PAPER,0,0))
    result_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    add_child(result_scroll)
    result_rows=VBoxContainer.new()
    result_rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    result_rows.add_theme_constant_override("separation",6)
    result_scroll.add_child(result_rows)
    result_hero=skin.label(result_rows)
    skin.Type.apply(result_hero,"card_title")
    result=skin.label(result_rows,20)
    result.hide()
    primary_stats=GridContainer.new();primary_stats.columns=2
    primary_stats.add_theme_constant_override("h_separation",12);primary_stats.add_theme_constant_override("v_separation",12)
    secondary_stats=GridContainer.new();secondary_stats.columns=2
    secondary_stats.add_theme_constant_override("h_separation",12);secondary_stats.add_theme_constant_override("v_separation",8)
    result_rows.add_child(primary_stats);result_rows.add_child(secondary_stats)
    for title in ["TIME","WAVE","LEVEL","KILLS","WEAPONS","PASSIVES","DAMAGE","HEALING","SHIELD ABSORBED","FLEX USES"]:
        var index: int=result_values.size()
        var primary: bool=index in [0,2,3,6]
        var row:=Panel.new();row.mouse_filter=Control.MOUSE_FILTER_IGNORE
        row.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        row.add_theme_stylebox_override("panel",panel_style("primary" if primary else "secondary"))
        (primary_stats if primary else secondary_stats).add_child(row)
        var label: Label=skin.label(row)
        label.text=title
        skin.Type.apply(label,"hud_secondary")
        var value: Label=skin.label(row)
        value.autowrap_mode=TextServer.AUTOWRAP_OFF
        value.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
        skin.Type.apply(value,"numeric_emphasis")
        result_values.append(value)
        stat_parts.append({"panel":row,"label":label,"value":value,"primary":primary})
    # Reading order: Time, Kills, Level, Total Damage. Stable value indices stay
    # compatible with the existing run-result bindings and regression checks.
    primary_stats.move_child(stat_parts[0]["panel"],0)
    primary_stats.move_child(stat_parts[3]["panel"],1)
    primary_stats.move_child(stat_parts[2]["panel"],2)
    primary_stats.move_child(stat_parts[6]["panel"],3)
    skin.Type.apply(game.profile_text,"body_s",false,skin.Style.PAPER)
    for state in ["normal","read_only"]:
        game.profile_text.add_theme_stylebox_override(state,skin.Style.box(skin.Style.DEEP,skin.Style.INK,0,0))
    game.profile_text.add_theme_color_override("font_readonly_color",skin.Style.PAPER)
    game.profile_text.add_theme_color_override("caret_color",skin.Style.PAPER)
    game.profile_text.add_theme_color_override("selection_color",skin.Style.BLUE)
    skin.Type.apply(ui.volume_label,"body_m")
    for button: Button in [ui.secondary.resume,ui.secondary.build,ui.secondary.settings,ui.secondary.quit_run,ui.back_button,game.retry_button]:
        skin.adopt(button,self)
        actions.append(button)
    for parts in ui.equipment_slots:
        var frame: TextureRect=skin.image(parts["panel"])
        parts["panel"].move_child(frame,0)
        build_frames.append(frame)
        var rim:=ColorRect.new();rim.mouse_filter=Control.MOUSE_FILTER_IGNORE;parts["panel"].add_child(rim)
        var details: Label=skin.label(parts["panel"],16,skin.Style.INK)
        var status: Label=skin.label(parts["panel"],13,skin.Style.BLUE)
        build_parts.append({"rim":rim,"details":details,"status":status})
    ui.body_scroll.reparent(self)
    game.profile_text.reparent(self)
    for button: Button in [game.sound_button,game.motion_button,game.import_button,game.export_button]:
        skin.native_children[button]=button.get_children()
    fullscreen_button=Button.new();fullscreen_button.text="FULLSCREEN";fullscreen_button.custom_minimum_size=Vector2.ZERO
    ui.body_content.add_child(fullscreen_button);skin.native_children[fullscreen_button]=[];fullscreen_button.pressed.connect(_native_fullscreen)
    fullscreen_status=skin.label(ui.body_content,16,skin.Style.INK)
    ui.body_scroll.get_v_scroll_bar().value_changed.connect(func(_value):_sync_fullscreen_bounds())

func panel_style(id: String) -> StyleBox:
    if not card_styles.has(id):
        var light: bool=id!="secondary"
        var edge: Color=skin.Style.INK if light else skin.Style.BLUE
        card_styles[id]=skin.Style.box(skin.Style.CARD if light else skin.Style.DEEP,edge,3,0)
    return card_styles[id]

func action(button: Button, rect: Rect2, primary: bool=false) -> void:
    if button.get_parent()!=self:skin.adopt(button,self)
    button.show()
    skin.place(button,rect)
    skin.button_skin(button,"menu/primary" if primary else "menu/secondary")

func layout() -> void:
    var view: Vector2=skin.view
    size=view
    skin.background.modulate=Color.WHITE
    skin.background.texture=skin.art.texture("support/upgrade-bg")
    skin.place(skin.background,Rect2(Vector2.ZERO,view))
    var mode: String=game.mode
    screen_panel.visible=mode=="options"
    fullscreen_button.visible=false;fullscreen_status.visible=false
    pause_dim.visible=mode in ["paused","build","options","won","lost"]
    pause_panel.visible=mode=="paused"
    pause_dim.color=Color(0.025,0.045,0.075,0.68) if mode=="paused" else Color(skin.Style.DEEP,0.94)
    if pause_dim.visible:
        skin.background.hide()
        skin.place(pause_dim,Rect2(-skin.shift,ui.full_view))
    var shown: Array=[]
    if mode=="paused":shown=[ui.secondary.resume,ui.secondary.build,ui.secondary.settings,ui.secondary.quit_run]
    elif mode in ["build","options"]:shown=[ui.back_button]
    elif mode in ["won","lost"]:shown=[game.restart_button,game.retry_button]
    else:shown=[game.restart_button,game.confirm_button]
    for button in actions+[game.restart_button,game.confirm_button]:button.visible=button in shown
    game.pause_button.hide()
    ui.body_scroll.visible=mode in ["options","build"]
    game.profile_text.visible=mode in ["profile_import","profile_export"]
    result_portrait.visible=mode in ["won","lost"]
    result_scroll.visible=result_portrait.visible
    caption.visible=true
    skin.Type.apply(caption,"body_m",false,skin.Style.INK)
    caption.text=ui.subtitle.text
    var titles := {"paused":"TAKE A BREATHER","build":"YOUR BUILD","options":"YOUR SETTINGS","confirm_exit":"LEAVE THIS RUN?","profile_import":"IMPORT YOUR SAVE","profile_export":"YOUR SAVE DATA","won":"VICTORY!","lost":"RUN OVER"}
    skin.headline(titles.get(mode,""))
    skin.place(caption,Rect2(28,94,view.x-56,68))
    var half: float=(view.x-64)/2
    var footer: float=view.y-78
    if mode=="paused":
        caption.text="Simulation paused. Take your time."
        var two_columns:=view.y<580 and view.x>=700
        var panel_size:=Vector2(minf(720 if two_columns else 600,view.x-32),304 if two_columns else 476)
        var panel:=Rect2((view-panel_size)*0.5,panel_size)
        skin.place(pause_panel,panel);skin.place(pause_accent,Rect2(24,3,112,4))
        skin.Type.apply(skin.heading,"display_l",view.x<700,skin.Style.INK)
        skin.place(skin.heading,Rect2(panel.position+Vector2(24,18),Vector2(panel_size.x-48,58)))
        skin.fit_line(skin.heading,24)
        skin.headline_accent.hide()
        skin.place(caption,Rect2(panel.position+Vector2(24,80),Vector2(panel_size.x-48,32)))
        var gap:=14.0
        var columns:=2 if two_columns else 1
        var cell_width: float=(panel_size.x-48-gap*(columns-1))/columns
        for i in range(4):
            var button: Button=[ui.secondary.resume,ui.secondary.build,ui.secondary.settings,ui.secondary.quit_run][i]
            action(button,Rect2(panel.position+Vector2(24+(i%columns)*(cell_width+gap),128+int(i/columns)*78),Vector2(cell_width,64)),i==0)
    elif mode=="build":
        build_layout()
    elif mode=="options":
        settings_layout()
    elif mode in ["profile_import","profile_export"]:
        skin.place(game.profile_text,Rect2(24,174,view.x-48,maxf(64,view.y-272)))
        action(game.restart_button,Rect2(24,footer,half,64))
        action(game.confirm_button,Rect2(40+half,footer,half,64),true)
    elif mode=="confirm_exit":
        caption.text="This unfinished run will not count towards your profile.\nYour settings and completed results remain saved."
        game.restart_button.text="STAY";game.confirm_button.text="CONFIRM QUIT"
        action(game.restart_button,Rect2(24,footer,half,64))
        action(game.confirm_button,Rect2(40+half,footer,half,64),true)
    elif mode in ["won","lost"]:
        caption.text=ui.secondary.result_caption.text
        result.text=ui.secondary.result_stats.text
        result_hero.text=game.HeroAppearanceScript.display_name(str(game.hero["id"]),game.hero_appearance,str(game.hero["name"]))
        var values: Array=["%02d:%02d" % [int(game.run_time)/60,int(game.run_time)%60],"%d / 5" % game.wave,str(game.level),str(game.kills),"%d / 3" % game.weapons.size(),"%d / 5" % game.passives.size(),"%.0f" % game.run_metrics["damage"],"%.0f" % game.run_metrics["healing"],"%.0f" % game.run_metrics["protection"],str(int(game.run_metrics["flexes"]))]
        for i in range(values.size()):result_values[i].text=values[i]
        result_portrait.texture=game.art.cosmetic_portrait(str(game.hero["id"]),game.hero_appearance)
        results_layout()

func screen_header(title: String, subtitle: String) -> void:
    skin.headline(title)
    skin.Type.apply(skin.heading,"display_l",skin.view.x<700,skin.Style.PAPER)
    skin.place(skin.heading,Rect2(28,22,skin.view.x-224,58));skin.fit_line(skin.heading,30)
    skin.place(skin.headline_accent,Rect2(30,82,116,3))
    caption.remove_theme_stylebox_override("normal")
    caption.text=subtitle
    skin.Type.apply(caption,"body_m",false,skin.Style.PAPER)
    skin.place(caption,Rect2(30,88,skin.view.x-60,30))
    action(ui.back_button,Rect2(skin.view.x-176,22,148,64));ui.back_button.text="BACK"

func build_layout() -> void:
    var view: Vector2=skin.view
    screen_header("YOUR BUILD","Three weapons. Five passives. Your current run.")
    var width: float=minf(1120,view.x-48)
    skin.place(ui.body_scroll,Rect2((view.x-width)*0.5,130,width,view.y-150))
    var content_width: float=width-16
    # Reuse the existing canonical formatter/icons; only presentation changes.
    ui._equipment(content_width)
    var columns: int=3 if content_width>=960 else 2 if content_width>=640 else 1
    var gap:=12.0
    var tile_width: float=(content_width-gap*(columns-1))/columns
    var row_height:=156.0 if view.y>=580 else 168.0
    var weapon_rows: int=ceili(3.0/columns)
    var passive_y: float=36+weapon_rows*row_height+(weapon_rows-1)*gap+18
    for i in range(2):
        skin.Type.apply(ui.equipment_headings[i],"section_header",false,skin.Style.PAPER)
        ui.equipment_headings[i].text="WEAPONS — 3 SLOTS" if i==0 else "PASSIVES — 5 SLOTS"
        skin.place(ui.equipment_headings[i],Rect2(0,0 if i==0 else passive_y,content_width,30))
    for i in range(8):
        var weapon: bool=i<3
        var index: int=i if weapon else i-3
        var items: Array=game.weapons if weapon else game.passives
        var item: Dictionary=items[index] if index<items.size() else {}
        var parts: Dictionary=ui.equipment_slots[i]
        var extra: Dictionary=build_parts[i]
        var top: float=36 if weapon else passive_y+36
        skin.place(parts["panel"],Rect2((index%columns)*(tile_width+gap),top+int(index/columns)*(row_height+gap),tile_width,row_height))
        parts["panel"].add_theme_stylebox_override("panel",panel_style("equipment"))
        parts["panel"].mouse_filter=Control.MOUSE_FILTER_PASS
        build_frames[i].texture=skin.art.texture("equipment/"+("weapon" if weapon else "passive")+("-filled" if not item.is_empty() else "-empty"))
        skin.place(build_frames[i],Rect2(10,26,62,62));skin.place(parts["image"],Rect2(20,36,42,42))
        skin.Type.apply(parts["label"],"card_title",false,skin.Style.INK)
        parts["label"].add_theme_font_size_override("font_size",20)
        skin.place(parts["label"],Rect2(100,9,tile_width-114,52))
        skin.Type.apply(parts["meta"],"hud_secondary",false,skin.Style.BLUE)
        parts["meta"].add_theme_font_size_override("font_size",16)
        parts["meta"].show();skin.place(parts["meta"],Rect2(100,64,tile_width-114,24))
        var description: String="Available weapon position." if weapon else "Available passive position."
        if item.is_empty():
            parts["label"].text="EMPTY WEAPON SLOT" if weapon else "EMPTY PASSIVE SLOT"
            parts["meta"].text="%d / %d" % [index+1,3 if weapon else 5]
        else:description=str(ui.catalog[item["id"]].get("description",""))
        extra["details"].text=description
        extra["details"].add_theme_font_size_override("font_size",15 if view.y>=580 else 16)
        skin.place(extra["details"],Rect2(12,90,tile_width-24,row_height-96))
        parts["panel"].tooltip_text=description
        extra["status"].text="EQUIPPED" if not item.is_empty() else "OPEN SLOT"
        skin.Type.apply(extra["status"],"micro_label",false,skin.Style.BLUE)
        extra["status"].add_theme_font_size_override("font_size",14)
        extra["status"].autowrap_mode=TextServer.AUTOWRAP_OFF
        # Status shares the icon column; rarity and actual level stay explicit.
        skin.place(extra["status"],Rect2(12,4,72,18))
        extra["rim"].color=skin.Style.RARITY.get(item.get("rarity",""),skin.Style.BLUE)
        skin.place(extra["rim"],Rect2(0,8,4,row_height-16))
    var rows: int=ceili(5.0/columns)
    var height: float=passive_y+36+rows*row_height+(rows-1)*gap
    skin.place(ui.equipment_board,Rect2(0,0,content_width,height))
    ui.body_content.custom_minimum_size=Vector2(content_width,height);ui.body_content.size=ui.body_content.custom_minimum_size

func settings_layout() -> void:
    var view: Vector2=skin.view
    var panel_width: float=minf(720,view.x-32)
    var width: float=panel_width-64
    var columns: int=2 if width>=560 else 1
    var fullscreen_y: float=108+ceili(2.0/columns)*76+8
    var save_y: float=fullscreen_y+110
    var has_save_actions: bool=game.import_button.visible or game.export_button.visible
    var height: float=save_y+ceili(2.0/columns)*76-12 if has_save_actions else fullscreen_y+98
    var panel_size:=Vector2(panel_width,minf(height+140,view.y-32))
    var panel:=Rect2((view-panel_size)*0.5,panel_size)
    screen_header("YOUR SETTINGS","Preferences are saved on this device.")
    skin.place(screen_panel,panel)
    # Reuse the actual heading and Back action inside the bounded panel.
    skin.Type.apply(skin.heading,"display_l",false,skin.Style.INK)
    skin.place(skin.heading,Rect2(panel.position+Vector2(24,18),Vector2(panel_size.x-194,54)));skin.fit_line(skin.heading,26)
    skin.headline_accent.hide()
    skin.Type.apply(caption,"body_s",false,skin.Style.INK)
    skin.place(caption,Rect2(panel.position+Vector2(24,86),Vector2(panel_size.x-48,26)))
    action(ui.back_button,Rect2(panel.position+Vector2(panel_size.x-156,18),Vector2(132,64)))
    skin.place(ui.body_scroll,Rect2(panel.position+Vector2(24,122),panel_size-Vector2(48,140)))
    skin.place(ui.volume_label,Rect2(0,0,width,30))
    skin.place(ui.volume_slider,Rect2(0,32,width,64))
    var cell: float=(width-14*(columns-1))/columns
    for i in range(2):
        var button: Button=game.sound_button if i==0 else game.motion_button
        skin.place(button,Rect2((i%columns)*(cell+14),108+int(i/columns)*76,cell,64))
        skin.button_skin(button,"menu/secondary")
    fullscreen_bounds=Rect2((width-minf(400,width))*0.5,fullscreen_y,minf(400,width),64)
    skin.place(fullscreen_button,fullscreen_bounds);skin.button_skin(fullscreen_button,"menu/secondary")
    fullscreen_button.visible=not OS.has_feature("web")
    fullscreen_button.disabled=DisplayServer.get_name()=="headless"
    var state: String=str(game.web_metrics.get("fullscreen","idle"))
    var active: bool=state in ["active","standalone"] if OS.has_feature("web") else DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN
    fullscreen_button.text="EXIT FULLSCREEN" if active else "FULLSCREEN"
    fullscreen_status.text="FULLSCREEN ACTIVE" if active else "Enter fullscreen for a wider view."
    fullscreen_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    fullscreen_status.visible=not OS.has_feature("web") or active
    skin.place(fullscreen_status,Rect2(4,fullscreen_y+68,width-8,30))
    for i in range(2):
        var button: Button=game.import_button if i==0 else game.export_button
        if button.visible:
            skin.place(button,Rect2((i%columns)*(cell+14),save_y+int(i/columns)*76,cell,64))
            skin.button_skin(button,"menu/secondary")
    ui.body_content.custom_minimum_size=Vector2(width,height);ui.body_content.size=ui.body_content.custom_minimum_size
    _sync_fullscreen_bounds()

func _native_fullscreen() -> void:
    if OS.has_feature("web"):return # Browser action owns its trusted DOM gesture.
    var active: bool=DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if active else DisplayServer.WINDOW_MODE_FULLSCREEN)
    ui._window_changed(true)

func _sync_fullscreen_bounds() -> void:
    if not OS.has_feature("web") or game.mode!="options":return
    var rect:=Rect2(ui.body_content.get_global_transform_with_canvas()*fullscreen_bounds.position,fullscreen_bounds.size)
    var payload: Variant=null
    if ui.body_scroll.get_global_rect().grow(0.5).encloses(rect):
        var factor: Vector2=Vector2(float(game.web_metrics.get("width",0)),float(game.web_metrics.get("height",0)))/ui.full_view
        payload=[rect.position.x*factor.x,rect.position.y*factor.y,rect.size.x*factor.x,rect.size.y*factor.y]
    var key: String=JSON.stringify(payload)
    if key==web_fullscreen_key:return
    web_fullscreen_key=key
    JavaScriptBridge.eval("if(window.__auraPlatform)window.__auraPlatform.setFullscreenBounds("+key+")",true)

func results_layout() -> void:
    var view: Vector2=skin.view
    var narrow: bool=view.x<700
    skin.heading.add_theme_color_override("font_color",skin.Style.GOLD if game.mode=="won" else skin.Style.CORAL)
    caption.remove_theme_stylebox_override("normal")
    skin.Type.apply(caption,"section_header",false,skin.Style.PAPER)
    if game.mode=="won":
        var living_boss:=false
        for enemy in game.enemies:
            if enemy["kind"]=="boss" and enemy["hp"]>0:living_boss=true
        caption.text="BIG HATER DEFEATED" if game.boss_spawned and not living_boss else "RUN COMPLETE"
    skin.place(caption,Rect2(30,94,view.x-60,36))
    var body_top:=142.0
    result_portrait.show()
    if narrow:
        skin.place(result_portrait,Rect2(28,body_top,view.x-56,180));body_top+=190
    else:skin.place(result_portrait,Rect2(28,body_top,view.x*0.38,view.y-body_top-24))
    var area:=Rect2(28 if narrow else view.x*0.43,body_top,view.x-56 if narrow else view.x*0.54,view.y-body_top-100)
    skin.place(result_scroll,area)
    result_scroll.add_theme_stylebox_override("panel",skin.empty_style)
    var width: float=area.size.x-16
    result_rows.custom_minimum_size=Vector2(width,0)
    result_rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    skin.Type.apply(result_hero,"card_title",false,skin.Style.PAPER)
    for part in stat_parts:
        var primary: bool=part["primary"]
        var panel: Panel=part["panel"]
        var cell: float=(width-12)*0.5
        panel.custom_minimum_size=Vector2(cell,96 if primary else 52)
        skin.Type.apply(part["label"],"micro_label",false,skin.Style.BLUE if primary else skin.Style.PAPER)
        part["label"].add_theme_font_size_override("font_size",14)
        skin.place(part["label"],Rect2(14,8 if primary else 3,cell-28,22))
        skin.Type.apply(part["value"],"numeric_emphasis",false,skin.Style.INK if primary else skin.Style.PAPER)
        part["value"].add_theme_font_size_override("font_size",36 if primary else 22)
        skin.place(part["value"],Rect2(14,32 if primary else 24,cell-28,52 if primary else 25));skin.fit_line(part["value"],20)
    var gap:=14.0
    var button_width: float=(area.size.x-gap)*0.5
    game.restart_button.text="MAIN MENU";game.retry_button.text="TRY AGAIN"
    action(game.restart_button,Rect2(area.position.x,view.y-80,button_width,64))
    action(game.retry_button,Rect2(area.position.x+button_width+gap,view.y-80,button_width,64),true)
