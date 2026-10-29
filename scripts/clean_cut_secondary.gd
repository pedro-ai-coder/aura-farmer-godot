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

func install(owner_skin) -> void:
    skin=owner_skin;game=skin.game;ui=skin.ui
    mouse_filter=Control.MOUSE_FILTER_IGNORE
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
    for title in ["TIME","WAVE","LEVEL","KILLS","WEAPONS","PASSIVES","DAMAGE","HEALING","SHIELD ABSORBED","FLEX USES"]:
        var row:=HBoxContainer.new()
        row.add_theme_constant_override("separation",16)
        result_rows.add_child(row)
        var label: Label=skin.label(row)
        label.text=title
        label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
        skin.Type.apply(label,"hud_secondary")
        var value: Label=skin.label(row)
        value.autowrap_mode=TextServer.AUTOWRAP_OFF
        value.custom_minimum_size.x=112
        value.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
        skin.Type.apply(value,"numeric_emphasis")
        result_values.append(value)
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
    ui.body_scroll.reparent(self)
    game.profile_text.reparent(self)
    for button: Button in [game.sound_button,game.motion_button,game.import_button,game.export_button]:
        skin.native_children[button]=button.get_children()

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
    caption.text=ui.subtitle.text
    var titles := {"paused":"TAKE A BREATHER","build":"YOUR BUILD","options":"YOUR SETTINGS","confirm_exit":"LEAVE THIS RUN?","profile_import":"IMPORT YOUR SAVE","profile_export":"YOUR SAVE DATA","won":"VICTORY!","lost":"RUN OVER"}
    skin.headline(titles.get(mode,""))
    skin.place(caption,Rect2(28,94,view.x-56,68))
    var half: float=(view.x-64)/2
    var footer: float=view.y-78
    if mode=="paused":
        caption.text="Simulation paused. Take your time."
        var width:=minf(440,view.x-48)
        var two_columns:=view.y<620
        for i in range(4):
            var button: Button=[ui.secondary.resume,ui.secondary.build,ui.secondary.settings,ui.secondary.quit_run][i]
            var columns:=2 if two_columns else 1
            var cell_width: float=half if two_columns else width
            action(button,Rect2(24+(i%columns)*(half+16) if two_columns else (view.x-width)/2,170+int(i/columns)*78,cell_width,64),i==0)
    elif mode in ["build","options"]:
        action(ui.back_button,Rect2(24,footer,minf(240,view.x-48),64))
        ui.back_button.text="BACK"
        # Native data/layout remains authoritative inside a scrollable body.
        skin.place(ui.body_scroll,Rect2(24,170,view.x-48,maxf(60,view.y-270)))
        var width: float=view.x-64
        if mode=="build":
            ui._equipment(width) # Populate canonical labels, metadata and icons.
            var columns: int=2 if width>=760.0 else 1
            var gap: float=16.0
            var tile_width: float=(width-gap*(columns-1))/columns
            var row_height: float=142.0
            var weapon_rows: int=ceili(3.0/columns)
            var passive_y: float=44.0+weapon_rows*(row_height+gap)+16.0
            skin.place(ui.equipment_headings[0],Rect2(0,0,width,30))
            skin.place(ui.equipment_headings[1],Rect2(0,passive_y,width,30))
            for i in range(ui.equipment_slots.size()):
                var parts: Dictionary=ui.equipment_slots[i]
                var weapon: bool=i<3
                var index: int=i if weapon else i-3
                var items: Array=game.weapons if weapon else game.passives
                var occupied: bool=index<items.size()
                var top: float=44.0 if weapon else passive_y+44.0
                skin.place(parts["panel"],Rect2((index%columns)*(tile_width+gap),top+int(index/columns)*(row_height+gap),tile_width,row_height))
                parts["panel"].add_theme_stylebox_override("panel",skin.empty_style)
                build_frames[i].texture=skin.art.texture("equipment/"+("weapon" if weapon else "passive")+("-filled" if occupied else "-empty"))
                skin.place(build_frames[i],Rect2(0,4,88,88));skin.place(parts["image"],Rect2(18,22,52,52))
                skin.Type.apply(parts["label"],"card_title",view.x<700)
                skin.Type.apply(parts["meta"],"hud_secondary")
                # Empty capacity is still explicit, but its counter belongs in
                # metadata so the title cannot grow through the following row.
                if not occupied:
                    parts["label"].text="EMPTY WEAPON SLOT" if weapon else "EMPTY PASSIVE SLOT"
                    parts["meta"].text="%d / %d" % [index+1,3 if weapon else 5]
                parts["meta"].show()
                skin.place(parts["label"],Rect2(104,8,tile_width-116,82))
                skin.place(parts["meta"],Rect2(104,100,tile_width-116,28))
            var height: float=passive_y+44.0+ceili(5.0/columns)*(row_height+gap)
            skin.place(ui.equipment_board,Rect2(0,0,width,height))
            ui.body_content.custom_minimum_size=Vector2(width,height)
        else:
            caption.text="Preferences are saved on this device.\nTouch: drag anywhere on clear terrain to move."
            skin.place(ui.volume_label,Rect2(8,0,width-16,32))
            skin.place(ui.volume_slider,Rect2(8,38,width-16,64))
            for i in range(4):
                var button: Button=[game.sound_button,game.motion_button,game.import_button,game.export_button][i]
                skin.place(button,Rect2(0,118+i*78,width,64))
                skin.button_skin(button,"menu/secondary")
            ui.body_content.custom_minimum_size=Vector2(width,430 if ui.settings_return=="menu" else 274)
        ui.body_content.size=ui.body_content.custom_minimum_size
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
        result_hero.text=game.hero["name"]
        var values: Array=["%02d:%02d" % [int(game.run_time)/60,int(game.run_time)%60],"%d / 5" % game.wave,str(game.level),str(game.kills),"%d / 3" % game.weapons.size(),"%d / 5" % game.passives.size(),"%.0f" % game.run_metrics["damage"],"%.0f" % game.run_metrics["healing"],"%.0f" % game.run_metrics["protection"],str(int(game.run_metrics["flexes"]))]
        for i in range(values.size()):result_values[i].text=values[i]
        result_portrait.texture=game.art.texture(game.hero["id"])
        var narrow:=view.x<700
        result_portrait.visible=not narrow
        skin.place(result_portrait,Rect2(28,166,view.x*0.42,maxf(80,view.y-270)))
        skin.place(result_scroll,Rect2(28 if narrow else view.x*0.48,166,view.x-56 if narrow else view.x*0.48-24,maxf(80,view.y-270)))
        game.restart_button.text="MAIN MENU";game.retry_button.text="TRY AGAIN"
        action(game.restart_button,Rect2(24,footer,half,64))
        action(game.retry_button,Rect2(40+half,footer,half,64),true)
