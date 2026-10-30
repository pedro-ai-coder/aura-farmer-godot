extends Control
## Live-Control skin. Approved sources stay immutable; HUD V2 candidates are separately inventoried.
const Cache=preload("res://scripts/clean_cut_assets.gd")
const Type=preload("res://scripts/clean_cut_typography.gd")
const Style=preload("res://scripts/arcade_theme.gd")
const HeroBrand=preload("res://scripts/hero_clash_brand.gd")
const GameplayHud=preload("res://scripts/hero_clash_hud.gd")
const HudMeter=preload("res://scripts/hero_clash_hud_meter.gd")
const HeroFlexDial=preload("res://scripts/hero_clash_flex_dial.gd")
const ButtonFeedback=preload("res://scripts/hero_clash_button_feedback.gd")
const SceneAccent=preload("res://scripts/hero_clash_scene_accent.gd")
var game
var gameplay_hud
var ui
var art
class PosterSurface extends Control:
    func _draw() -> void:
        draw_colored_polygon(PackedVector2Array([Vector2.ZERO,Vector2(size.x*890/1600,0),Vector2(size.x*805/1600,size.y),Vector2(0,size.y)]),Color(0.0745,0.1373,0.2275,0.83))
        draw_rect(Rect2(0,0,size.x*24/1600,size.y),Color("4ea3ff"))
        draw_rect(Rect2(size.x*24/1600,0,size.x*10/1600,size.y),Color("f8c45f"))
class AuraArc extends Control:
    var progress:=0.0
    var visual_state: String="charging"
    func _draw() -> void:
        var radius: float=minf(size.x,size.y)*0.43
        var accent:=Color("6eaab0") if visual_state=="active" else Color("f8c45f")
        draw_arc(size*0.5,radius,-PI*0.5,-PI*0.5+TAU*clampf(progress,0,1),64,accent,6,true)
        if visual_state=="ready" or visual_state=="active":
            draw_arc(size*0.5,radius+5,0.0,TAU,64,accent,3,true)
var poster_surface: Control
var background: TextureRect
var wordmark: TextureRect
var candidate_brand: Control
var poster_hero: TextureRect
var heading: Label
var heading_shadow: Label
var headline_accent: ColorRect
var watermark: Label
var home_caption: Label
var hero_scroll: ScrollContainer
var hero_content: Control
var hero_parts: Array[Dictionary]=[]
var offers_scroll: ScrollContainer
var offers_content: Control
var offer_parts: Array[Dictionary]=[]
var card_plate_styles: Dictionary={}
var native_children: Dictionary={}
var hud_nodes: Array[Control]=[]
var player_plate: TextureRect
var portrait: TextureRect
var hp_fill: Control
var shield_track: ColorRect
var shield_fill: Control
var xp_fill: Control
var xp_track: ColorRect
var aura_arc: Control
var boss_plate: TextureRect
var boss_text: Label
var joystick_ring: TextureRect
var joystick_thumb: TextureRect
var hero_name: Label
var shield_label: Label
var hp: Label
var xp_frame: TextureRect
var xp: Label
var wave_frame: TextureRect
var wave: Label
var warning: Label
var flex_image: TextureRect
var flex_badge: ColorRect
var flex_title: Label
var flex_status: Label
var flex_caption: Label
var flex_track: ColorRect
var flex_fill: ColorRect
var flex_styles: Dictionary={}
var equipment: Array[Dictionary]=[]
var last_mode := ""
var signature := ""
var last_selected := -1
var view := Vector2.ZERO
var shift := Vector2.ZERO
var styles: Dictionary={}
var auxiliary
var scene_accent
var layout_key := ""
var layout_count := 0
var empty_style := StyleBoxEmpty.new()
func label(parent: Node, pixels: int=18, color: Color=Style.INK) -> Label:
    var node:=Label.new();parent.add_child(node)
    Type.apply(node,"body_m" if pixels >= 18 else "body_s",false,color)
    node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    node.mouse_filter=Control.MOUSE_FILTER_IGNORE
    return node
func image(parent: Node) -> TextureRect:
    var node:=TextureRect.new();parent.add_child(node)
    node.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    node.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    node.mouse_filter=Control.MOUSE_FILTER_IGNORE
    return node
func place(node: Control, rect: Rect2) -> void:
    node.position=rect.position;node.size=rect.size
    if node is Label:node.set_deferred("size",rect.size)
func fit_line(node: Label, minimum: int = 13) -> void:
    var font: Font=node.get_theme_font("font")
    var pixels: int=node.get_theme_font_size("font_size")
    while pixels > minimum and font.get_string_size(node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x > node.size.x:
        pixels -= 1
    node.add_theme_font_size_override("font_size",pixels)

func adopt(button: Button, parent: Node) -> void:
    if not native_children.has(button):native_children[button]=button.get_children()
    button.reparent(parent)
    button.custom_minimum_size=Vector2.ZERO
func state(button: Button, selected: bool=false) -> String:
    if button.disabled:return "disabled"
    if button.get_draw_mode()==BaseButton.DRAW_PRESSED or game.touch_ui_pointers.values().has(button):return "pressed"
    if selected:return "selected"
    if button.has_focus():return "focus"
    if button.is_hovered():return "hover"
    return "idle"
func box(key: String) -> StyleBoxTexture:
    if styles.has(key):return styles[key]
    var value:=StyleBoxTexture.new();value.texture=art.texture(key)
    styles[key]=value;return value
func button_skin(button: Button, family: String, selected: bool=false) -> void:
    button.custom_minimum_size=Vector2.ZERO
    var current:=state(button,selected)
    var key:=family+"-"+current
    if not art.rows.has(key):key=family+"-"+("selected" if selected and art.rows.has(family+"-selected") else "idle")
    if not art.rows.has(key):key=family+"-default"
    # Preserve approved idle card/hero art; the candidate's transparent selection
    # shell owns the state badge, avoiding a duplicate or obscured legacy tick.
    if not family.begins_with("menu/") and selected and art.rows.has(family+"-idle"):
        key=family+"-idle"
    button.add_theme_stylebox_override("normal",box(key))
    for action in ["hover","pressed","disabled","focus"]:
        var alt: String=family+"-"+action
        button.add_theme_stylebox_override(action,box(alt if art.rows.has(alt) else key))
    Type.apply(button,"button_label",view.x<700)
    for color_key in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:button.add_theme_color_override(color_key,Style.INK)
    button.add_theme_color_override("font_disabled_color",Style.INK.lightened(0.3))
    for child in native_children.get(button,[]):
        if child is Control:child.hide()
    # Feedback is attached to the already-signal-bound button and never
    # intercepts or replaces mouse, keyboard or touchscreen input.
    var feedback=button.get_node_or_null("ClashButtonFeedback")
    if feedback==null:
        var new_feedback:=ButtonFeedback.new()
        new_feedback.name="ClashButtonFeedback"
        button.add_child(new_feedback)
        new_feedback.install(button,game)
        feedback=new_feedback
    feedback.call("configure",family,selected)
func install(owner_game, source_root: String) -> void:
    game=owner_game;ui=game.presentation;art=Cache.new(source_root)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    game.layer.add_child(self)
    theme=Type.theme()
    background=image(self);background.stretch_mode=TextureRect.STRETCH_SCALE
    poster_surface=PosterSurface.new();poster_surface.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(poster_surface)
    wordmark=image(self);wordmark.texture=art.texture("support/wordmark")
    candidate_brand=HeroBrand.new()
    candidate_brand.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(candidate_brand)
    poster_hero=image(self);poster_hero.texture=game.art.texture("sigma")
    heading_shadow=label(self,34,Style.GOLD);heading=label(self,34,Style.PAPER)
    Type.apply(heading,"display_l",false,Style.PAPER)
    headline_accent=ColorRect.new()
    headline_accent.color=Style.GOLD
    headline_accent.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(headline_accent)
    home_caption=label(self,24,Style.PAPER)
    Type.apply(home_caption,"section_header",false,Style.PAPER)
    for button in [ui.play_button,ui.home.hero_destination,ui.options_button,ui.home.start_button,ui.home.return_button,game.confirm_button,game.defer_button,game.flex_button,game.pause_button,game.legendary_button]:adopt(button,self)
    hero_scroll=ScrollContainer.new();hero_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(hero_scroll)
    hero_content=Control.new();hero_scroll.add_child(hero_content)
    for i in range(3):
        var button: Button=game.menu_buttons[i];adopt(button,hero_content);button.text=""
        var parts: Dictionary={"portrait":image(button),"name":label(button,24),"role":label(button,15),"icon":image(button),"starter":label(button,17),"flex":label(button,18),"help":label(button,16)}
        parts["portrait"].texture=game.art.texture(game.HEROES[i]["id"])
        Type.apply(parts["name"],"card_title")
        for key in ["role","starter"]:Type.apply(parts[key],"hud_secondary")
        Type.apply(parts["flex"],"section_header")
        Type.apply(parts["help"],"body_s")
        hero_parts.append(parts)
    offers_scroll=ScrollContainer.new();offers_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(offers_scroll)
    offers_content=Control.new();offers_scroll.add_child(offers_content)
    for button: Button in game.offer_buttons:
        adopt(button,offers_content);button.text=""
        var rim:=ColorRect.new()
        rim.mouse_filter=Control.MOUSE_FILTER_IGNORE
        button.add_child(rim)
        var icon_plate:=Panel.new()
        icon_plate.mouse_filter=Control.MOUSE_FILTER_IGNORE
        button.add_child(icon_plate)
        var parts: Dictionary={"rim":rim,"icon_plate":icon_plate,"category":label(button),"icon":image(button),"name":label(button,23),"meta":label(button,16),"body":label(button,18),"comparison":label(button,15),"state":label(button,14)}
        Type.apply(parts["name"],"card_title")
        Type.apply(parts["category"],"micro_label")
        parts["category"].add_theme_stylebox_override("normal",StyleBoxFlat.new())
        Type.apply(parts["meta"],"micro_label")
        Type.apply(parts["comparison"],"hud_secondary")
        Type.apply(parts["state"],"micro_label")
        parts["body"].clip_text = false
        parts["body"].max_lines_visible = -1
        parts["body"].text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
        offer_parts.append(parts)
    player_plate=image(self);player_plate.stretch_mode=TextureRect.STRETCH_SCALE
    hp_fill=HudMeter.new();hp_fill.install(GameplayHud.texture("hp-fill"));add_child(hp_fill)
    shield_track=ColorRect.new()
    shield_track.color=Style.DEEP
    shield_track.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(shield_track)
    shield_fill=HudMeter.new()
    shield_fill.install(GameplayHud.texture("shield-fill"))
    shield_fill.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(shield_fill)
    portrait=image(self);hp=label(self,17)
    hero_name=label(self);shield_label=label(self)
    xp_frame=image(self);xp_frame.stretch_mode=TextureRect.STRETCH_SCALE
    xp_track=ColorRect.new();xp_track.color=Style.DEEP;xp_track.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(xp_track)
    xp_fill=HudMeter.new();xp_fill.install(GameplayHud.texture("shield-fill"));add_child(xp_fill)
    xp=label(self,15)
    boss_plate=image(self);boss_plate.stretch_mode=TextureRect.STRETCH_SCALE;boss_text=label(self,17)
    game.touch_joystick.self_modulate=Color(1,1,1,0)
    joystick_ring=image(game.touch_joystick);joystick_thumb=image(game.touch_joystick)
    wave_frame=image(self);wave=label(self,19)
    warning=label(self,16,Style.GOLD)
    # The previous crosshair and rectangle are rejected. The approved source
    # images remain unchanged, but this candidate renders a circular Flex dial.
    flex_image=image(game.flex_button)
    flex_image.hide()
    aura_arc=HeroFlexDial.new()
    aura_arc.mouse_filter=Control.MOUSE_FILTER_IGNORE
    game.flex_button.add_child(aura_arc)
    # Real Button signals change the drawn depth only; ability activation
    # remains exclusively owned by the existing _use_flex connection.
    game.flex_button.button_down.connect(func():aura_arc.set_pressed(true))
    game.flex_button.button_up.connect(func():aura_arc.set_pressed(false))
    aura_arc.show()
    flex_badge=ColorRect.new()
    flex_badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
    game.flex_button.add_child(flex_badge)
    flex_title=label(game.flex_button,36,Style.PAPER)
    flex_status=label(game.flex_button,16,Style.GOLD)
    flex_caption=label(self,18,Style.PAPER)
    Type.apply(flex_caption,"hud_secondary",true,Style.PAPER)
    flex_caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var caption_style:=StyleBoxFlat.new()
    caption_style.bg_color=Color(Style.DEEP,0.93)
    caption_style.border_color=Style.BLUE
    caption_style.set_border_width_all(2)
    caption_style.set_corner_radius_all(4)
    flex_caption.add_theme_stylebox_override("normal",caption_style)
    flex_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
    flex_track=ColorRect.new()
    flex_track.color=Style.BLUE
    flex_track.mouse_filter=Control.MOUSE_FILTER_IGNORE
    game.flex_button.add_child(flex_track)
    flex_fill=ColorRect.new()
    flex_fill.color=Style.GOLD
    flex_fill.mouse_filter=Control.MOUSE_FILTER_IGNORE
    game.flex_button.add_child(flex_fill)
    hud_nodes.assign([player_plate,hp_fill,shield_track,shield_fill,portrait,hp,hero_name,shield_label,xp_frame,xp_track,xp_fill,xp,wave_frame,wave,warning,boss_plate,boss_text,flex_caption])
    for i in range(8):
        var parts: Dictionary={"frame":image(self),"icon":image(self),"tab":image(self),"level":label(self,12),"name":label(self,12,Style.PAPER)}
        parts["tab"].texture=GameplayHud.texture("level-tab")
        var rarity:=ColorRect.new();rarity.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(rarity)
        parts["rarity"]=rarity
        Type.apply(parts["level"],"micro_label")
        Type.apply(parts["name"],"equipment_label",false,Style.PAPER)
        var name_plate:=StyleBoxFlat.new()
        name_plate.bg_color=Style.DEEP
        name_plate.content_margin_left=2;name_plate.content_margin_right=2
        parts["name"].add_theme_stylebox_override("normal",name_plate)
        parts["name"].uppercase=false
        parts["name"].mouse_filter=Control.MOUSE_FILTER_PASS
        equipment.append(parts)
        for node in parts.values():hud_nodes.append(node)
    gameplay_hud=GameplayHud.new(self)
    watermark=label(self,13,Style.CORAL);watermark.text=""
    auxiliary=load("res://scripts/clean_cut_secondary.gd").new()
    add_child(auxiliary)
    auxiliary.install(self)
    scene_accent=SceneAccent.new()
    scene_accent.name="HeroClashSceneAccent"
    add_child(scene_accent)
    refresh()
func _process(delta: float) -> void:
    refresh()
    gameplay_hud.tick_feedback()
    gameplay_hud.update_threat_readability()
    if game == null or not offers_scroll.visible: return
    for i in range(offer_parts.size()):
        var icon: TextureRect = offer_parts[i]["icon"]
        var active: bool = game.selected_card_index == i or game.offer_buttons[i].has_focus() or game.offer_buttons[i].is_hovered()
        var target := Vector2.ONE * (1.08 if active else 1.0)
        icon.pivot_offset = icon.size * 0.5
        icon.scale = target if game.profile["settings"]["reducedMotion"] else icon.scale.lerp(target, 1.0-exp(-18.0*delta))
func refresh() -> void:
    if game==null:return
    var perf_hud_start: int=Time.get_ticks_usec() if game.performance_probe!=null else 0
    update_joystick_visuals()
    visible=true;ui.visible=false
    view=ui.view;shift=ui.position;position=shift;size=view
    # Live pointer/focus states invalidate independently of simulation and presenter.
    var interactions := ""
    for button in native_children:
        interactions += str(button.get_instance_id())+state(button)+str(button.visible)
    var boss_hp := 0.0
    for enemy: Dictionary in game.enemies:
        if enemy["kind"]=="boss":boss_hp=float(enemy["hp"]);break
    var next_key := str([ui.revision,view,shift,game.mode,game.hero_index,game.selected_card_index,interactions,
        ceili(game.hp),game.max_hp,ceili(game.shield),game.xp,game.level,int(game.run_time),game.wave,
        int(game.aura),int(game.flex_time*10),int(game.flex_lock*10),bool(game.profile["settings"].get("reducedMotion",false)),game.legendary_spent,boss_hp])
    if next_key==layout_key:
        if game.performance_probe!=null:game.performance_probe.add(&"hud",Time.get_ticks_usec()-perf_hud_start)
        return
    layout_key=next_key;layout_count+=1
    # Exit/profile confirmation belongs to the active secondary shell. Never
    # reparent it away every frame: doing so can cancel a held pointer press.
    var confirmation_parent: Control=auxiliary if game.mode in auxiliary.MODES else self
    if game.confirm_button.get_parent()!=confirmation_parent:
        game.confirm_button.reparent(confirmation_parent)
    var pause_parent: Control=gameplay_hud.modules["TopRightPause"] if game.mode=="playing" else self
    if game.pause_button.get_parent()!=pause_parent:game.pause_button.reparent(pause_parent,false)
    view=ui.view;shift=ui.position;position=shift;size=view
    var mode: String=game.mode
    var mode_changed: bool=mode!=last_mode
    if mode_changed:
        hero_scroll.scroll_vertical=0;offers_scroll.scroll_vertical=0;last_mode=mode
        auxiliary.web_fullscreen_key=""
        if OS.has_feature("web"):
            JavaScriptBridge.eval("if(window.__auraPlatform)window.__auraPlatform.setMode("+JSON.stringify(mode)+")",true)
        # A hide/show cycle every frame cancels Godot BaseButton pointer presses
        # before mouse release. Only reset visibility when changing screens.
        for button in [ui.play_button,ui.home.hero_destination,ui.options_button,ui.home.start_button,ui.home.return_button,game.confirm_button,game.defer_button,game.flex_button,game.pause_button,game.restart_button,game.legendary_button,game.retry_button]:button.hide()
    background.visible=mode!="playing"
    # Approved artwork remains an immutable source; show only this isolated
    # candidate's original vector lockup on the review branch.
    wordmark.hide()
    candidate_brand.visible=mode=="menu"
    poster_hero.visible=mode=="menu"
    home_caption.visible=mode=="menu"
    poster_surface.visible=mode=="menu";place(poster_surface,Rect2(Vector2.ZERO,view));poster_surface.queue_redraw()
    hero_scroll.visible=mode=="heroes";offers_scroll.visible=mode in ["choice","legendary","replace"]
    heading.visible=mode!="playing";heading_shadow.hide();headline_accent.visible=heading.visible
    var heading_parent: Control=auxiliary if mode in auxiliary.MODES else self
    if heading.get_parent()!=heading_parent:heading.reparent(heading_parent,false)
    if headline_accent.get_parent()!=heading_parent:headline_accent.reparent(heading_parent,false)
    for node in hud_nodes:node.visible=mode=="playing"
    place(watermark,Rect2(12,3,view.x-24,20))
    if mode=="menu":home_layout()
    elif mode=="heroes":heroes_layout()
    elif mode=="playing":hud_layout()
    elif mode in ["choice","legendary","replace"]:cards_layout()
    else:auxiliary.layout()
    auxiliary.visible=mode in auxiliary.MODES
    if mode_changed:
        _animate_new_screen(mode)
    ui._focus_ring()
    if game.performance_probe!=null:game.performance_probe.add(&"hud",Time.get_ticks_usec()-perf_hud_start)

func _animate_new_screen(mode: String) -> void:
    var reduced: bool=bool(game.profile["settings"].get("reducedMotion",false))
    scene_accent.play(mode,view,reduced)
    if reduced or mode=="playing":
        return
    var reveal_buttons: Array[Button]=[]
    if mode=="menu":
        reveal_buttons=[ui.play_button,ui.home.hero_destination,ui.options_button]
    elif mode=="heroes":
        reveal_buttons=game.menu_buttons.duplicate()
        reveal_buttons.append(ui.home.start_button)
        reveal_buttons.append(ui.home.return_button)
    elif mode in ["choice","replace","legendary"]:
        reveal_buttons=game.offer_buttons.duplicate()
        reveal_buttons.append(game.confirm_button)
        if mode=="legendary":reveal_buttons.append(game.defer_button)
    else:
        reveal_buttons=auxiliary.actions.duplicate()
        reveal_buttons.append_array([game.confirm_button,game.restart_button,game.retry_button])
    var visible_index: int=0
    for button in reveal_buttons:
        if not button.is_visible_in_tree():
            continue
        var feedback=button.get_node_or_null("ClashButtonFeedback")
        if feedback!=null:
            feedback.call("reveal",minf(float(visible_index)*0.045,0.22))
            visible_index+=1
func headline(text: String) -> void:
    heading.text=text
    heading_shadow.hide()
    Type.apply(heading,"display_l",view.x<700,Style.PAPER)
    heading.autowrap_mode=TextServer.AUTOWRAP_OFF
    var heading_size: int=heading.get_theme_font_size("font_size")
    while heading_size>20 and heading.get_theme_font("font").get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,heading_size).x>view.x-64:
        heading_size-=1
    heading.add_theme_font_size_override("font_size",heading_size)
    place(heading,Rect2(28,25,view.x-56,64))
    headline_accent.show()
    place(headline_accent,Rect2(30,92,minf(116.0,view.x*0.25),5))
func home_layout() -> void:
    background.modulate=Color.WHITE
    background.texture=art.texture("support/poster");place(background,Rect2(Vector2.ZERO,view))
    var narrow:=view.x<700
    # The wordmark is visually dominant but stays inside the illustration's
    # poster half. It scales down rather than cropping on narrow/mobile views.
    var logo_width: float=minf(590.0,view.x*0.47) if not narrow else view.x-38.0
    var logo_height: float=154.0 if narrow or view.y<540.0 else 190.0
    place(candidate_brand,Rect2(28,24,logo_width,logo_height))
    # Selected hero must be the visible hero on the menu, not a fixed Sigma.
    poster_hero.texture=game.art.texture(str(game.HEROES[game.hero_index]["id"]))
    var mobile_portrait: bool=narrow and view.y>=780.0
    place(poster_hero,Rect2(view.x-188.0,view.y*0.30,164,176) if mobile_portrait else Rect2(view.x*0.49,view.y*0.18,view.x*0.48,view.y*0.66))
    poster_hero.visible=not narrow or mobile_portrait
    heading.hide();heading_shadow.hide();headline_accent.hide()
    Type.apply(home_caption,"hud_secondary",narrow,Style.PAPER)
    home_caption.text="THE STREETS ARE YOURS.\nFARM AURA. BE LEGENDARY."
    place(home_caption,Rect2(40,183 if narrow or view.y<540.0 else 224,view.x-80 if narrow else view.x*0.45,64))
    var compact_landscape: bool=view.y<515
    var width:=minf(360,view.x-80)
    var top:=maxf(300.0,view.y*0.51)
    for i in range(3):
        var button: Button=[ui.play_button,ui.home.hero_destination,ui.options_button][i]
        button.show();button.text=["PLAY","HERO SELECTION","SETTINGS"][i]
        if compact_landscape:
            var gap:=12.0
            var compact_width: float=(view.x-48-2*gap)/3
            place(button,Rect2(24+i*(compact_width+gap),view.y-76,compact_width,64))
        else:
            place(button,Rect2(40,top+i*76,width,64))
        button_skin(button,"menu/primary" if i==0 else "menu/secondary")
func heroes_layout() -> void:
    background.texture=game.art.texture("ruin-alley");place(background,Rect2(Vector2.ZERO,view))
    background.modulate=Color(0.32,0.35,0.39)
    headline("PICK YOUR FARMER.")
    var columns:=1 if view.x<700 else 3
    var gap:=20.0;var width: float=(view.x-64-gap*(columns-1))/columns
    var height:=maxf(460,view.y-188) if columns==3 else 520.0
    # Reserve the full approved Flex help text, including the longest hero.
    # A fixed 460 U mobile card let the Label minimum escape its lower edge.
    for i in range(3):
        var help: Label=hero_parts[i]["help"]
        help.text=ui.catalog[game.HEROES[i]["id"]]["flex_help"]
        var flex_name: Label=hero_parts[i]["flex"]
        flex_name.text=game.HEROES[i]["flex"]
        var help_top: float=350.0+maxf(48.0,text_height(flex_name,width-48.0))+12.0
        height=maxf(height,help_top+text_height(help,width-48.0)+20.0)
    place(hero_scroll,Rect2(24,100,view.x-48,view.y-190))
    hero_content.custom_minimum_size=Vector2(view.x-64,ceili(3.0/columns)*(height+gap));hero_content.size=hero_content.custom_minimum_size
    for i in range(3):
        var button: Button=game.menu_buttons[i];button.show()
        var selected: bool=game.hero_index==i
        button.text=""
        button_skin(button,"hero-select/card",selected)
        place(button,Rect2((i%columns)*(width+gap),int(i/columns)*(height+gap),width,height))
        var data: Dictionary=game.HEROES[i];var parts: Dictionary=hero_parts[i]
        parts["portrait"].texture=game.art.texture(str(data["id"]))
        parts["portrait"].show()
        parts["name"].text=data["name"]
        parts["role"].text=data["role"].to_upper()+(" · SELECTED" if selected else "")
        place(parts["name"],Rect2(24,44,width-48,40));place(parts["role"],Rect2(24,85,width-48,24))
        place(parts["portrait"],Rect2(40,118,width-80,160))
        parts["icon"].texture=ui.item_icons.texture("weapon",data["starter"]);place(parts["icon"],Rect2(24,282,45,45))
        parts["starter"].text="STARTER / "+game.WEAPONS[data["starter"]]["name"];place(parts["starter"],Rect2(80,282,width-100,55))
        parts["flex"].text=data["flex"]
        var flex_height: float=maxf(48.0,text_height(parts["flex"],width-48.0))
        var help_top: float=350.0+flex_height+12.0
        place(parts["flex"],Rect2(24,350,width-48,flex_height))
        parts["help"].text=ui.catalog[data["id"]]["flex_help"]
        place(parts["help"],Rect2(24,help_top,width-48,height-help_top-20.0))
    ui.home.return_button.show();ui.home.start_button.show()
    place(ui.home.return_button,Rect2(24,view.y-78,150,64));place(ui.home.start_button,Rect2(view.x-300,view.y-78,276,64))
    ui.home.start_button.text="START RUN"
    button_skin(ui.home.return_button,"menu/secondary");button_skin(ui.home.start_button,"menu/primary")
func text_height(node: Label, width: float) -> float:
    var font: Font=node.get_theme_font("font")
    var pixels: int=node.get_theme_font_size("font_size")
    var measured: Vector2=font.get_multiline_string_size(node.text.to_upper() if node.uppercase else node.text,HORIZONTAL_ALIGNMENT_LEFT,width,pixels,-1,TextServer.BREAK_MANDATORY|TextServer.BREAK_WORD_BOUND|TextServer.BREAK_ADAPTIVE)
    var lines: float=maxf(1.0,ceilf(measured.y/font.get_height(pixels)))
    return ceilf(measured.y+(lines-1.0)*node.get_theme_constant("line_spacing"))+4.0

func cards_layout() -> void:
    var legendary: bool=game.mode=="legendary"
    background.modulate=Color.WHITE;background.texture=art.texture("support/legendary-bg" if legendary else "support/upgrade-bg")
    place(background,Rect2(Vector2.ZERO,view));headline("THE LEGENDARY DROP" if legendary else "MAKE ROOM" if game.mode=="replace" else "CHOOSE YOUR NEXT MOVE")
    if legendary:heading.add_theme_color_override("font_color",Style.INK)
    var items: Array=game.legendary_offers if legendary else game.replace_options if game.mode=="replace" else game.selection
    var columns:=1 if view.x<700 else 3
    var compact_cards: bool=view.y<=560.0 and columns==3
    var gap:=12.0 if compact_cards else 16.0
    var available_width: float=view.x-48.0 if compact_cards else view.x-64.0
    var width: float=(available_width-gap*(columns-1))/columns
    var height: float=view.y-138.0 if compact_cards else 250.0 if legendary else 440.0
    var metrics: Array=[]
    # Measure live strings first, then reserve independent rows. No negative
    # body heights, overlapping comparison row, or hidden/truncated description.
    for i in range(items.size()):
        var item: Dictionary=items[i]
        var parts: Dictionary=offer_parts[i];var native: Dictionary=ui.card_parts[i]
        parts["name"].text=native["name"].text
        parts["body"].text=native["body"].text
        parts["body"].tooltip_text=parts["body"].text
        parts["comparison"].text=native["comparison"].text
        parts["meta"].text=str(item.get("rarity",native["meta"].text)).to_upper()+" / "+native["category"].text
        Type.apply(parts["name"],"card_title",compact_cards or view.x<700)
        Type.apply(parts["body"],"body_m",compact_cards)
        Type.apply(parts["meta"],"hud_secondary",view.x<700)
        Type.apply(parts["comparison"],"hud_secondary",compact_cards)
        var title_height: float=maxf(84.0,text_height(parts["name"],width-132.0))
        var meta_y: float=68.0+title_height+10.0
        var body_y: float=meta_y if legendary else meta_y+38.0
        var body_height: float=maxf(80.0,text_height(parts["body"],width-32.0))
        var comparison_y: float=body_y+body_height+12.0
        var comparison_height: float=0.0 if legendary else text_height(parts["comparison"],width-32.0)
        height=maxf(height,comparison_y+comparison_height+46.0)
        metrics.append({"title":title_height,"meta":meta_y,"body":body_y,"body_height":body_height,"comparison":comparison_y,"comparison_height":comparison_height})
    if compact_cards:
        Type.apply(heading,"display_l",true,Style.INK if legendary else Style.PAPER)
        place(heading,Rect2(18,5,view.x-36,49));fit_line(heading,19)
        place(headline_accent,Rect2(22,55,94,5))
    var scroll_y: float=68.0 if compact_cards else 106.0
    var scroll_height: float=view.y-136.0 if compact_cards else view.y-196.0
    place(offers_scroll,Rect2(16 if compact_cards else 24,scroll_y,view.x-32 if compact_cards else view.x-48,scroll_height))
    offers_content.custom_minimum_size=Vector2(available_width,ceili(float(items.size())/columns)*(height+gap));offers_content.size=offers_content.custom_minimum_size
    var current_signature: String=game.run_id+game.mode+JSON.stringify(items)
    if current_signature!=signature:signature=current_signature;offers_scroll.scroll_vertical=0;last_selected=-1
    for i in range(6):
        var button: Button=game.offer_buttons[i];button.visible=i<items.size()
        if i>=items.size():continue
        var item: Dictionary=items[i];var id: String=item["id"]
        var category: String="weapon" if game.WEAPONS.has(id) else "passive"
        var selected: bool=game.selected_card_index==i
        button.text="";button_skin(button,"cards/"+("legendary-" if legendary else "")+category,selected)
        place(button,Rect2((i%columns)*(width+gap),int(i/columns)*(height+gap),width,height))
        var parts: Dictionary=offer_parts[i];var measured: Dictionary=metrics[i]
        var rarity_name: String=str(item.get("rarity","legendary" if legendary else "common")).to_lower()
        var rarity_color: Color=Style.RARITY.get(rarity_name,Style.SKY)
        parts["rim"].color=Style.SKY if selected else rarity_color;place(parts["rim"],Rect2(9,10,7,height-20))
        parts["category"].text=("LEGENDARY · " if legendary else "")+category.to_upper()
        Type.apply(parts["category"],"micro_label",view.x<700,Style.INK)
        var category_plate: StyleBoxFlat=parts["category"].get_theme_stylebox("normal")
        category_plate.bg_color=Style.SKY if category=="weapon" else Style.GOLD
        category_plate.content_margin_left=10;category_plate.content_margin_right=10
        place(parts["category"],Rect2(16,12,width-32,44))
        var style_key: String=rarity_name+("/selected" if selected else "")
        if not card_plate_styles.has(style_key):
            var plate_style:=StyleBoxFlat.new();plate_style.bg_color=Style.CARD;plate_style.border_color=Style.SKY if selected else rarity_color
            plate_style.set_border_width_all(4 if selected else 3);plate_style.set_corner_radius_all(5);card_plate_styles[style_key]=plate_style
        parts["icon_plate"].add_theme_stylebox_override("panel",card_plate_styles[style_key])
        parts["icon"].texture=ui.item_icons.texture(category,id)
        place(parts["icon_plate"],Rect2(16,68,84,84));place(parts["icon"],Rect2(24,76,68,68))
        place(parts["name"],Rect2(112,68,width-132,measured["title"]))
        parts["meta"].visible=not legendary
        place(parts["meta"],Rect2(16,measured["meta"],width-32,28))
        place(parts["body"],Rect2(16,measured["body"],width-32,measured["body_height"]))
        parts["comparison"].visible=not legendary
        place(parts["comparison"],Rect2(16,measured["comparison"],width-32,measured["comparison_height"]))
        parts["state"].text="SELECTED · CONFIRM BELOW" if selected else "TAP TO SELECT"
        Type.apply(parts["state"],"micro_label",view.x<700,Style.SKY if selected else Style.INK)
        place(parts["state"],Rect2(16,height-30,width-32,24))
        parts["state"].horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
    game.confirm_button.show();game.confirm_button.text="CONFIRM LEGENDARY" if legendary else "CONFIRM"
    game.confirm_button.disabled=game.selected_card_index<0
    place(game.confirm_button,Rect2(view.x-350,view.y-78,326,64));button_skin(game.confirm_button,"menu/primary")
    if legendary:
        game.defer_button.show();place(game.defer_button,Rect2(24,view.y-78,270,64));button_skin(game.defer_button,"menu/secondary")
    if view.x<700:
        var half: float=(view.x-64)/2
        if legendary:
            place(game.defer_button,Rect2(24,view.y-78,half,64));place(game.confirm_button,Rect2(40+half,view.y-78,half,64))
            game.confirm_button.text="CONFIRM"
        else:place(game.confirm_button,Rect2(24,view.y-78,view.x-48,64))
    if game.mode=="replace":
        if game.restart_button.get_parent()!=self:adopt(game.restart_button,self)
        game.restart_button.show();game.restart_button.text="BACK"
        var half: float=(view.x-64)/2
        place(game.restart_button,Rect2(24,view.y-78,half if view.x<700 else 180,64))
        if view.x<700:place(game.confirm_button,Rect2(40+half,view.y-78,half,64))
        button_skin(game.restart_button,"menu/secondary")
    if compact_cards:
        # Preserve the GDD physical touch target despite the shorter cards.
        var confirm_width: float=250.0
        place(game.confirm_button,Rect2(view.x-confirm_width-16.0,view.y-66.0,confirm_width,64.0))
        if legendary:
            place(game.defer_button,Rect2(16,view.y-66.0,200,64.0))
        elif game.mode=="replace":
            place(game.restart_button,Rect2(16,view.y-66.0,180,64.0))
    if game.selected_card_index>=0 and game.selected_card_index!=last_selected:
        call_deferred("reveal_selected",game.selected_card_index,signature)
    last_selected=game.selected_card_index
func update_joystick_visuals() -> void:
    # Touch motion changes two sprites, never the entire HUD layout/theme.
    var shown: bool=game.mode=="playing" and game.touch_joystick.active
    joystick_ring.visible=shown;joystick_thumb.visible=shown
    if not shown:return
    var scale: float=game.touch_joystick.geometry_scale
    var held: String="pressed" if game.touch_direction.length()>0.05 else "idle"
    joystick_ring.texture=art.texture("joystick/ring-"+held);joystick_thumb.texture=art.texture("joystick/thumb-"+held)
    place(joystick_ring,Rect2(game.touch_joystick.center-Vector2.ONE*100*scale,Vector2.ONE*200*scale))
    var thumb_at: Vector2=game.touch_joystick.center+game.touch_joystick.axis*game.touch_joystick.THUMB_OFFSET*scale
    place(joystick_thumb,Rect2(thumb_at-Vector2.ONE*44*scale,Vector2.ONE*88*scale))

func hud_layout() -> void:
    background.modulate=Color.WHITE
    gameplay_hud.layout()


func reveal_selected(index: int, expected_signature: String) -> void:
    # Scroll ranges settle after container sorting, not when card positions are assigned.
    await get_tree().process_frame
    await get_tree().process_frame
    if signature==expected_signature and game.selected_card_index==index and offers_scroll.visible:
        offers_scroll.ensure_control_visible(game.offer_buttons[index])
