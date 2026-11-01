extends Control
## Existing HUD extension, not another CanvasLayer or input owner.
const Type=preload("res://scripts/clean_cut_typography.gd")
const INK=Color("0b2034")
const PAPER=Color("fff9e9")
const GOLD=Color("ffce30")
var skin
var game
var plate: Panel
var icon: TextureRect
var heading: Label
var detail: Label
var accent: ColorRect
var progress: Array[ColorRect]=[]
var regular_style: StyleBoxFlat
var legendary_style: StyleBoxFlat
var content_key: String=""
var slots_key: String=""
var content_updates: int=0

func install(owner_skin) -> void:
    name="PassiveFeedback";skin=owner_skin;game=skin.game
    mouse_filter=Control.MOUSE_FILTER_IGNORE;focus_mode=Control.FOCUS_NONE
    regular_style=StyleBoxFlat.new();regular_style.bg_color=Color("0b2034ee")
    regular_style.border_color=Color("427b9e");regular_style.border_width_left=3
    regular_style.corner_radius_top_right=10;regular_style.corner_radius_bottom_right=10
    legendary_style=regular_style.duplicate();legendary_style.border_color=GOLD;legendary_style.border_width_left=4
    plate=Panel.new();plate.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(plate)
    icon=TextureRect.new();icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    icon.mouse_filter=Control.MOUSE_FILTER_IGNORE;plate.add_child(icon)
    heading=Label.new();detail=Label.new()
    for node in [heading,detail]:
        node.mouse_filter=Control.MOUSE_FILTER_IGNORE;plate.add_child(node)
    Type.apply(heading,"card_title",false,PAPER);heading.add_theme_font_size_override("font_size",20)
    heading.autowrap_mode=TextServer.AUTOWRAP_OFF;heading.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
    Type.apply(detail,"body_s",false,PAPER);detail.add_theme_font_size_override("font_size",18)
    detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;detail.add_theme_constant_override("line_spacing",0)
    accent=ColorRect.new();accent.mouse_filter=Control.MOUSE_FILTER_IGNORE;plate.add_child(accent)
    for i in range(5):
        var bar:=ColorRect.new();bar.mouse_filter=Control.MOUSE_FILTER_IGNORE
        skin.gameplay_hud.modules["BottomCenterEquipment"].add_child(bar)
        progress.append(bar)
    # Share the already licensed/approved icon registry and warm it once.
    for id in game.PASSIVES:skin.ui.item_icons.texture("passive",id)
    hide()

func refresh() -> void:
    var observer=game.passive_feedback
    visible=game.mode=="playing" and observer!=null
    if not visible:
        for bar in progress:bar.hide()
        slots_key=""
        return
    var entry: Dictionary=observer.current
    plate.visible=not entry.is_empty()
    var status: Control=skin.gameplay_hud.modules["TopLeftHeroStatus"]
    var width: float=minf(420,skin.view.x-16)
    if not skin.gameplay_hud.portrait:
        width=minf(width,skin.gameplay_hud.modules["TopCenterBossStatus"].position.x-status.position.x-16)
    # Stay below HP, away from the central boss/wave lanes and touch controls.
    plate.position=status.position+Vector2(8,status.size.y+6)
    if skin.gameplay_hud.portrait:
        var wave: Control=skin.gameplay_hud.modules["TopCenterWaveTimer"]
        var boss: Control=skin.gameplay_hud.modules["TopCenterBossStatus"]
        plate.position.y=maxf(plate.position.y,maxf(wave.get_rect().end.y,boss.get_rect().end.y)+6)
    plate.size=Vector2(width,86)
    var reduced: bool=game.profile["settings"].get("reducedMotion",false)
    if not entry.is_empty():
        var key: String=str([entry,skin.view])
        if key!=content_key:
            content_key=key;content_updates+=1
            var legendary: bool=entry.kind=="legendary" or entry.id in ["absolute-cinema","w-squad","too-sigma","no-u"]
            plate.add_theme_stylebox_override("panel",legendary_style if legendary else regular_style)
            var id: String=entry.id
            icon.texture=skin.ui.item_icons.texture("weapon" if game.WEAPONS.has(id) else "passive",id) if not id.is_empty() else null
            icon.position=Vector2(12,16);icon.size=Vector2(48,48);icon.visible=icon.texture!=null
            var left:=72.0 if icon.visible else 16.0
            heading.position=Vector2(left,8);heading.size=Vector2(width-left-12,27)
            heading.text=("LEGENDARY · " if legendary else "")+str(entry.title)
            # The action is already explicit in detail. Keep full legendary identity.
            if legendary:heading.text=str(entry.title);heading.add_theme_color_override("font_color",GOLD)
            else:heading.add_theme_color_override("font_color",PAPER)
            detail.position=Vector2(left,36);detail.size=Vector2(width-left-12,43)
            detail.text=str(entry.detail)
            accent.position=Vector2(0,82);accent.size=Vector2(width,3)
            accent.color=GOLD if legendary else Color("6ff3df")
        var age: float=maxf(0,game.run_time-float(entry.get("started",game.run_time)))
        # A single tiny entrance; Reduced Motion is completely static.
        if not reduced:plate.position.x-=4.0*maxf(0,1.0-age/0.16)
        accent.scale.x=clampf((observer.current_until-game.run_time)/(3.0 if entry.kind=="legendary" else 2.0 if entry.kind=="upgrade" else 1.35),0,1)
    var next_slots_key: String=str([observer.revision,skin.gameplay_hud.data_count,skin.gameplay_hud.geometry_count])
    if next_slots_key==slots_key:return
    slots_key=next_slots_key
    for i in range(5):
        var parts: Dictionary=skin.equipment[i+3]
        var bar: ColorRect=progress[i];bar.visible=false
        var item: Dictionary=game.passives[i] if i<game.passives.size() else {}
        var active: Dictionary=observer.statuses.get(item.get("id",""),{})
        var label: Label=parts.level
        var text: String=str(active.short) if not active.is_empty() else "" if item.is_empty() else "LV%d" % int(item.level)
        var color: Color=active.color if not active.is_empty() else PAPER
        if label.text!=text:label.text=text
        if label.get_theme_color("font_color")!=color:label.add_theme_color_override("font_color",color)
        if active.is_empty():continue
        var frame: TextureRect=parts.frame
        bar.position=frame.position+Vector2(8,frame.size.y-8)
        bar.size=Vector2(maxf(0,frame.size.x-16)*float(active.fraction),3)
        bar.color=active.color;bar.show()
