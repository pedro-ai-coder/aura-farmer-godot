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
var actions: Array[Button] = []
var build_frames: Array[TextureRect] = []

func install(owner_skin) -> void:
    skin=owner_skin;game=skin.game;ui=skin.ui
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    caption=skin.label(self,18,skin.Style.PAPER)
    result_portrait=skin.image(self)
    result_scroll=ScrollContainer.new()
    result_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    add_child(result_scroll)
    result=skin.label(result_scroll,20)
    result.size_flags_horizontal=Control.SIZE_EXPAND_FILL
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
            var height: float=ui._equipment(width)
            ui.body_content.custom_minimum_size=Vector2(width,height)
            for i in range(ui.equipment_slots.size()):
                var parts: Dictionary=ui.equipment_slots[i]
                var kind: String="weapon" if i<3 else "passive"
                var items: Array=game.weapons if i<3 else game.passives
                var occupied: bool=(i if i<3 else i-3)<items.size()
                parts["panel"].add_theme_stylebox_override("panel",skin.empty_style)
                build_frames[i].texture=skin.art.texture("equipment/"+kind+("-filled" if occupied else "-empty"))
                skin.place(build_frames[i],Rect2(0,4,96,96))
                skin.place(parts["image"],Rect2(20,24,56,56))
                skin.place(parts["label"],Rect2(104,12,parts["panel"].size.x-116,66))
                skin.place(parts["meta"],Rect2(104,82,parts["panel"].size.x-116,34))
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
        game.restart_button.text="STAY";game.confirm_button.text="QUIT RUN"
        action(game.restart_button,Rect2(24,footer,half,64),true)
        action(game.confirm_button,Rect2(40+half,footer,half,64))
    elif mode in ["won","lost"]:
        caption.text=ui.secondary.result_caption.text
        result.text=ui.secondary.result_stats.text
        result_portrait.texture=game.art.texture(game.hero["id"])
        var narrow:=view.x<700
        result_portrait.visible=not narrow
        skin.place(result_portrait,Rect2(28,166,view.x*0.42,maxf(80,view.y-270)))
        skin.place(result_scroll,Rect2(28 if narrow else view.x*0.48,166,view.x-56 if narrow else view.x*0.48-24,maxf(80,view.y-270)))
        game.restart_button.text="MAIN MENU";game.retry_button.text="TRY AGAIN"
        action(game.restart_button,Rect2(24,footer,half,64))
        action(game.retry_button,Rect2(40+half,footer,half,64),true)
