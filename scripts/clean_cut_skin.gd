extends Control
## Production live-Control visual skin. Only immutable creator-approved runtime sources.
const Cache=preload("res://scripts/clean_cut_assets.gd")
const Type=preload("res://scripts/clean_cut_typography.gd")
const Style=preload("res://scripts/arcade_theme.gd")
const HeroBrand=preload("res://scripts/hero_clash_brand.gd")
const HeroFlexDial=preload("res://scripts/hero_clash_flex_dial.gd")
var game
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
var native_children: Dictionary={}
var hud_nodes: Array[Control]=[]
var player_plate: TextureRect
var portrait: TextureRect
var hp_fill: ColorRect
var xp_fill: ColorRect
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
    button.add_theme_stylebox_override("normal",box(key))
    for action in ["hover","pressed","disabled","focus"]:
        var alt: String=family+"-"+action
        button.add_theme_stylebox_override(action,box(alt if art.rows.has(alt) else key))
    Type.apply(button,"button_label",view.x<700)
    for color_key in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:button.add_theme_color_override(color_key,Style.INK)
    button.add_theme_color_override("font_disabled_color",Style.INK.lightened(0.3))
    for child in native_children.get(button,[]):
        if child is Control:child.hide()
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
        var parts: Dictionary={"category":label(button),"icon":image(button),"name":label(button,23),"meta":label(button,16),"body":label(button,18),"comparison":label(button,15),"state":label(button,14)}
        Type.apply(parts["name"],"card_title")
        Type.apply(parts["category"],"micro_label")
        parts["category"].add_theme_stylebox_override("normal",StyleBoxFlat.new())
        Type.apply(parts["meta"],"micro_label")
        Type.apply(parts["comparison"],"body_s")
        Type.apply(parts["state"],"micro_label")
        parts["body"].clip_text = true
        parts["body"].max_lines_visible = 5
        parts["body"].text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        offer_parts.append(parts)
    player_plate=image(self);player_plate.stretch_mode=TextureRect.STRETCH_SCALE
    hp_fill=ColorRect.new();hp_fill.color=Style.CORAL;hp_fill.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(hp_fill)
    portrait=image(self);hp=label(self,17)
    hero_name=label(self);shield_label=label(self)
    xp_frame=image(self);xp_frame.stretch_mode=TextureRect.STRETCH_SCALE
    xp_track=ColorRect.new();xp_track.color=Style.DEEP;xp_track.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(xp_track)
    xp_fill=ColorRect.new();xp_fill.color=Style.SKY;xp_fill.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(xp_fill)
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
    hud_nodes.assign([player_plate,hp_fill,portrait,hp,hero_name,shield_label,xp_frame,xp_track,xp_fill,xp,wave_frame,wave,warning,boss_plate,boss_text,flex_caption])
    for i in range(8):
        var parts: Dictionary={"frame":image(self),"icon":image(self),"level":label(self,12),"name":label(self,12,Style.PAPER)}
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
    watermark=label(self,13,Style.CORAL);watermark.text=""
    auxiliary=load("res://scripts/clean_cut_secondary.gd").new()
    add_child(auxiliary)
    auxiliary.install(self)
    refresh()
func _process(delta: float) -> void:
    refresh()
    if game == null or not offers_scroll.visible: return
    for i in range(offer_parts.size()):
        var icon: TextureRect = offer_parts[i]["icon"]
        var active: bool = game.selected_card_index == i or game.offer_buttons[i].has_focus() or game.offer_buttons[i].is_hovered()
        var target := Vector2.ONE * (1.08 if active else 1.0)
        icon.pivot_offset = icon.size * 0.5
        icon.scale = target if game.profile["settings"]["reducedMotion"] else icon.scale.lerp(target, 1.0-exp(-18.0*delta))
func refresh() -> void:
    if game==null:return
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
        int(game.aura),int(game.flex_time*10),int(game.flex_lock*10),game.touch_direction,game.touch_joystick.active,
        game.touch_joystick.center,game.legendary_spent,boss_hp])
    if next_key==layout_key:return
    layout_key=next_key;layout_count+=1
    if game.confirm_button.get_parent()!=self:game.confirm_button.reparent(self)
    if game.pause_button.get_parent()!=self:game.pause_button.reparent(self)
    view=ui.view;shift=ui.position;position=shift;size=view
    var mode: String=game.mode
    if mode!=last_mode:
        hero_scroll.scroll_vertical=0;offers_scroll.scroll_vertical=0;last_mode=mode
        # A hide/show cycle every frame cancels Godot BaseButton pointer presses
        # before mouse release. Only reset visibility when changing screens.
        for button in [ui.play_button,ui.home.hero_destination,ui.options_button,ui.home.start_button,ui.home.return_button,game.confirm_button,game.defer_button,game.flex_button,game.pause_button,game.restart_button,game.legendary_button,game.retry_button]:button.hide()
    background.visible=mode!="playing"
    # Approved artwork remains an immutable source; show only this isolated
    # candidate's original vector lockup on the review branch.
    wordmark.hide()
    candidate_brand.visible=mode=="menu"
    poster_hero.visible=mode=="menu";home_caption.visible=mode=="menu"
    poster_surface.visible=mode=="menu";place(poster_surface,Rect2(Vector2.ZERO,view));poster_surface.queue_redraw()
    hero_scroll.visible=mode=="heroes";offers_scroll.visible=mode in ["choice","legendary","replace"]
    heading.visible=mode!="playing";heading_shadow.hide();headline_accent.visible=heading.visible
    for node in hud_nodes:node.visible=mode=="playing"
    place(watermark,Rect2(12,3,view.x-24,20))
    if mode=="menu":home_layout()
    elif mode=="heroes":heroes_layout()
    elif mode=="playing":hud_layout()
    elif mode in ["choice","legendary","replace"]:cards_layout()
    else:auxiliary.layout()
    auxiliary.visible=mode in auxiliary.MODES
    ui._focus_ring()
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
    var logo_height: float=154.0 if view.y<540.0 else 190.0
    place(candidate_brand,Rect2(28,24,logo_width,logo_height))
    place(poster_hero,Rect2(view.x*0.49,view.y*0.18,view.x*0.48,view.y*0.66))
    poster_hero.visible=not narrow
    heading.hide();heading_shadow.hide();headline_accent.hide()
    Type.apply(home_caption,"hud_secondary",narrow,Style.PAPER)
    home_caption.text="THE STREETS ARE YOURS.\nFARM AURA. BE LEGENDARY."
    place(home_caption,Rect2(40,183 if view.y<540.0 else 224,view.x-80 if narrow else view.x*0.45,64))
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
    place(hero_scroll,Rect2(24,100,view.x-48,view.y-190))
    hero_content.custom_minimum_size=Vector2(view.x-64,ceili(3.0/columns)*(height+gap));hero_content.size=hero_content.custom_minimum_size
    for i in range(3):
        var button: Button=game.menu_buttons[i];button.show()
        var selected: bool=game.hero_index==i
        button.text=""
        button_skin(button,"hero-select/card",selected)
        place(button,Rect2((i%columns)*(width+gap),int(i/columns)*(height+gap),width,height))
        var data: Dictionary=game.HEROES[i];var parts: Dictionary=hero_parts[i]
        parts["name"].text=data["name"];parts["role"].text=data["role"].to_upper()
        place(parts["name"],Rect2(24,44,width-48,40));place(parts["role"],Rect2(24,85,width-48,24))
        place(parts["portrait"],Rect2(40,118,width-80,160))
        parts["icon"].texture=ui.item_icons.texture("weapon",data["starter"]);place(parts["icon"],Rect2(24,282,45,45))
        parts["starter"].text="STARTER / "+game.WEAPONS[data["starter"]]["name"];place(parts["starter"],Rect2(80,282,width-100,55))
        parts["flex"].text=data["flex"];place(parts["flex"],Rect2(24,350,width-48,48))
        parts["help"].text=ui.catalog[data["id"]]["flex_help"];place(parts["help"],Rect2(24,400,width-48,height-420))
    ui.home.return_button.show();ui.home.start_button.show()
    place(ui.home.return_button,Rect2(24,view.y-78,150,64));place(ui.home.start_button,Rect2(view.x-300,view.y-78,276,64))
    ui.home.start_button.text="START RUN"
    button_skin(ui.home.return_button,"menu/secondary");button_skin(ui.home.start_button,"menu/primary")
func cards_layout() -> void:
    var legendary: bool=game.mode=="legendary"
    background.modulate=Color.WHITE;background.texture=art.texture("support/legendary-bg" if legendary else "support/upgrade-bg")
    place(background,Rect2(Vector2.ZERO,view));headline("THE LEGENDARY DROP" if legendary else "MAKE ROOM" if game.mode=="replace" else "CHOOSE YOUR NEXT MOVE")
    if legendary:
        heading.add_theme_color_override("font_color",Style.INK)
        heading_shadow.hide()
    var items: Array=game.legendary_offers if legendary else game.replace_options if game.mode=="replace" else game.selection
    var columns:=1 if view.x<700 else 3
    var gap:=16.0;var width: float=(view.x-64-gap*(columns-1))/columns
    var height: float=minf(520,view.y-212) if not legendary else minf(250,(view.y-212)/2) if view.y>=650 and columns==3 else 270.0
    height=maxf(height,220 if legendary and view.y>=650 and columns==3 else 250 if legendary else 414)
    place(offers_scroll,Rect2(24,106,view.x-48,view.y-196))
    offers_content.custom_minimum_size=Vector2(view.x-64,ceili(float(items.size())/columns)*(height+gap));offers_content.size=offers_content.custom_minimum_size
    var current_signature: String=game.run_id+game.mode+JSON.stringify(items)
    if current_signature!=signature:signature=current_signature;offers_scroll.scroll_vertical=0;last_selected=-1
    for i in range(6):
        var button: Button=game.offer_buttons[i];button.visible=i<items.size()
        if i>=items.size():continue
        var item: Dictionary=items[i];var id: String=item["id"]
        var category: String="weapon" if game.WEAPONS.has(id) else "passive"
        var selected: bool=game.selected_card_index==i
        var family: String="cards/"+("legendary-" if legendary else "")+category
        button.text=""
        button_skin(button,family,selected)
        place(button,Rect2((i%columns)*(width+gap),int(i/columns)*(height+gap),width,height))
        var native: Dictionary=ui.card_parts[i];var parts: Dictionary=offer_parts[i]
        parts["category"].text=("LEGENDARY · " if legendary else "")+category
        var category_plate: StyleBoxFlat=parts["category"].get_theme_stylebox("normal")
        category_plate.bg_color=(Style.SKY if category=="weapon" else Style.GOLD) if legendary else Style.PAPER
        if legendary:
            place(parts["category"],Rect2(width*68/438,height*10/304,width*338/438,height*42/304))
        else:
            place(parts["category"],Rect2(20,height*34/486,width-40,height*28/486))
        parts["icon"].texture=ui.item_icons.texture(category,id)
        parts["name"].text=native["name"].text;parts["body"].text=native["body"].text;parts["comparison"].text=native["comparison"].text
        parts["body"].tooltip_text = parts["body"].text
        parts["meta"].text=str(item.get("rarity",native["meta"].text)).to_upper()+" / "+native["category"].text
        Type.apply(parts["meta"],"hud_secondary",view.x<700,Style.INK)
        parts["state"].text="SELECTED · CONFIRM BELOW" if selected else "SELECT ITEM"
        if legendary:
            place(parts["icon"],Rect2(18,48,86,86));place(parts["name"],Rect2(116,48,width-136,80))
            parts["meta"].hide();place(parts["body"],Rect2(18,144,width-36,height-180));parts["comparison"].hide()
            Type.apply(parts["body"],"body_s")
        else:
            parts["meta"].show();Type.apply(parts["body"],"body_m")
            place(parts["icon"],Rect2((width-136)/2,68,136,136));place(parts["name"],Rect2(20,210,width-40,70))
            place(parts["meta"],Rect2(20,278,width-40,26));place(parts["body"],Rect2(20,310,width-40,height-414));parts["comparison"].show()
            place(parts["comparison"],Rect2(20,height-126,width-40,62))
        if not legendary and height<490:
            place(parts["icon"],Rect2(18,78,60,60));place(parts["name"],Rect2(90,70,width-108,76))
            place(parts["meta"],Rect2(18,150,width-36,32));place(parts["body"],Rect2(18,188,width-36,height-280))
            Type.apply(parts["body"],"body_s")
            place(parts["comparison"],Rect2(18,height-86,width-36,48))
        place(parts["state"],Rect2(18,height-28,width-36,22))
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
    if game.selected_card_index>=0 and game.selected_card_index!=last_selected:
        call_deferred("reveal_selected",game.selected_card_index,signature)
    last_selected=game.selected_card_index
func hud_layout() -> void:
    background.modulate=Color.WHITE
    var narrow:=view.x<700
    player_plate.texture=art.texture("support/hp");place(player_plate,Rect2(18,28,minf(350,view.x-160),86))
    var hp_width: float=minf(350,view.x-160)
    place(hp_fill,Rect2(18+33*hp_width/463,28+47*86.0/92,(381*hp_width/463)*clampf(game.hp/maxf(1,game.max_hp),0,1),30*86.0/92))
    portrait.texture=game.art.texture(game.hero["id"]);place(portrait,Rect2(25,30,50,55))
    Type.apply(hero_name,"section_header",true,Style.INK)
    hero_name.text=game.hero["name"]
    hero_name.autowrap_mode=TextServer.AUTOWRAP_OFF
    place(hero_name,Rect2(82,28,hp_width-70,32))
    fit_line(hero_name,15)
    Type.apply(shield_label,"micro_label",narrow,Style.INK)
    shield_label.text="SHIELD %d" % ceili(game.shield)
    shield_label.autowrap_mode=TextServer.AUTOWRAP_OFF
    place(shield_label,Rect2(82,57,hp_width-70,20))
    Type.apply(hp,"hud_stat",narrow,Style.PAPER,true)
    hp.text="HP %d / %d" % [ceili(game.hp),ceili(game.max_hp)]
    hp.autowrap_mode=TextServer.AUTOWRAP_OFF
    place(hp,Rect2(82,79,hp_width-70,27))
    fit_line(hp,14)
    var xp_y: float=view.y-248 if narrow else view.y-150
    var xp_width: float=minf(350,view.x-200)
    xp_frame.texture=art.texture("support/xp");place(xp_frame,Rect2(18,xp_y,xp_width,38))
    # Approved SVG contains an illustrative blue segment (x28..330,y24..41).
    # Mask it completely before drawing the actual XP; never show sample progress.
    var track:=Rect2(18+27*xp_width/540,xp_y+23*38.0/120,467*xp_width/540,19*38.0/120)
    place(xp_track,track)
    place(xp_fill,Rect2(track.position,Vector2(track.size.x*clampf(game.xp/(30+8*game.level+game.level*game.level),0,1),track.size.y)))
    Type.apply(xp,"hud_stat",narrow,Style.PAPER,true)
    xp.text="LEVEL %d   ·   XP %d" % [game.level,int(game.xp)]
    place(xp,Rect2(24,xp_y-25,minf(300,view.x-210),24))
    fit_line(xp,14)
    wave_frame.texture=art.texture("support/wave");place(wave_frame,Rect2((view.x-240)/2,128 if narrow else 28,240,64))
    wave.text="%s  /  %02d:%02d" % ["BIG HATER" if game.boss_spawned else "WAVE %d" % game.wave,int(game.run_time)/60,int(game.run_time)%60]
    Type.apply(wave,"hud_stat",narrow,Style.INK)
    wave.autowrap_mode=TextServer.AUTOWRAP_OFF
    wave.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;place(wave,Rect2((view.x-220)/2,145 if narrow else 45,220,28))
    fit_line(wave,14)
    Type.apply(warning,"hud_secondary",narrow,Style.GOLD,true)
    warning.text=game.SoloClock.warning(game.run_time);place(warning,Rect2((view.x-360)/2,210 if narrow else 108,360,40))
    game.pause_button.show();game.pause_button.text="II";place(game.pause_button,Rect2(view.x-90,28,64,64));button_skin(game.pause_button,"menu/secondary")
    # The legacy presentation is hidden while this skin owns gameplay. Keep
    # its original action reachable after Defer without changing offers or RNG.
    game.legendary_button.visible = game.run_time >= game.SoloClock.LEGENDARY_FIRST and game.run_time < game.SoloClock.LEGENDARY_DEADLINE and not game.legendary_spent and not game.legendary_offers.is_empty()
    if game.legendary_button.visible:
        game.legendary_button.text = "LEGENDARY [L]"
        place(game.legendary_button,Rect2(18,view.y-302,minf(238,view.x-36),64))
        button_skin(game.legendary_button,"menu/primary")
    boss_plate.hide();boss_text.hide()
    for enemy: Dictionary in game.enemies:
        if enemy["kind"]!="boss":continue
        var rect: Rect2=ui.spotlight_hud.boss_rectangle(enemy)
        rect.size.y=60
        boss_plate.show();boss_text.show();boss_plate.texture=art.texture("support/hp")
        place(boss_plate,rect);boss_text.text="BIG HATER / %d HP" % ceili(enemy["hp"]);place(boss_text,Rect2(rect.position+Vector2(28,8),rect.size-Vector2(56,12)))
        break
    if game.touch_joystick.active:
        var scale: float=game.touch_joystick.geometry_scale
        var held: String="pressed" if game.touch_direction.length()>0.05 else "idle"
        joystick_ring.texture=art.texture("joystick/ring-"+held);joystick_thumb.texture=art.texture("joystick/thumb-"+held)
        place(joystick_ring,Rect2(game.touch_joystick.center-Vector2.ONE*100*scale,Vector2.ONE*200*scale))
        var thumb_at: Vector2=game.touch_joystick.center+game.touch_joystick.axis*game.touch_joystick.THUMB_OFFSET*scale
        place(joystick_thumb,Rect2(thumb_at-Vector2.ONE*44*scale,Vector2.ONE*88*scale))
    # Circular special action with live Aura, an unmistakable gold READY ring,
    # and the actual existing Flex Button handling all pointer activation.
    var compact_flex: bool = view.y < 540.0 or view.x < 700.0
    var portrait_flex: bool = view.x < 700.0 and view.y >= view.x
    var diameter: float = 116.0 if compact_flex else 144.0
    var button_x: float = view.x - diameter - (12.0 if compact_flex else 22.0)
    var button_y: float = view.y-diameter-(186.0 if portrait_flex else 12.0 if compact_flex else 22.0)
    game.flex_button.show()
    game.flex_button.text=""
    place(game.flex_button,Rect2(button_x,button_y,diameter,diameter))
    var active_flex: bool = game.flex_time > 0.0
    var ready_flex: bool = game.aura >= 100.0 and game.flex_lock <= 0.0 and not active_flex
    var recovering: bool = game.flex_lock > 0.0 and not active_flex
    var current: String = "active" if active_flex else "ready" if ready_flex else "recovery" if recovering else "charging"
    var aura_progress: float = 1.0 if ready_flex or active_flex else 0.0 if recovering else clampf(game.aura/100.0,0.0,1.0)
    var action_state: String = state(game.flex_button)
    var emphasised: bool = action_state in ["pressed","hover","focus"]
    for key in ["normal","hover","pressed","disabled","focus"]:
        game.flex_button.add_theme_stylebox_override(key,empty_style)
    flex_image.hide()
    flex_track.hide()
    flex_fill.hide()
    flex_badge.hide()
    aura_arc.show()
    place(aura_arc,Rect2(Vector2.ZERO,Vector2.ONE*diameter))
    aura_arc.show_state(aura_progress,current,emphasised)
    var foreground: Color=Style.GOLD if ready_flex else Style.PAPER
    Type.apply(flex_title,"section_header",compact_flex,foreground)
    flex_title.text="FLEX"
    flex_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    flex_title.autowrap_mode=TextServer.AUTOWRAP_OFF
    place(flex_title,Rect2(8,diameter*0.32,diameter-16,42))
    Type.apply(flex_status,"micro_label",compact_flex,Style.GOLD if ready_flex else Style.TEAL if active_flex else Style.PAPER)
    flex_status.text="READY" if ready_flex else "%.1fs" % game.flex_time if active_flex else "LOCK %.0fs" % game.flex_lock if recovering else "AURA %d%%" % int(game.aura)
    flex_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    flex_status.autowrap_mode=TextServer.AUTOWRAP_OFF
    place(flex_status,Rect2(8,diameter*0.61,diameter-16,25))
    Type.apply(flex_caption,"hud_secondary",compact_flex,Style.PAPER)
    flex_caption.text=str(game.hero["flex"]).to_upper()
    flex_caption.autowrap_mode=TextServer.AUTOWRAP_OFF
    var caption_width: float=diameter+54.0
    place(flex_caption,Rect2(button_x-(caption_width-diameter)*0.5,button_y-32.0,caption_width,27.0))
    fit_line(flex_caption,13)
    var slot_width:=56.0;var slot_pitch:=76.0;var start_y:=view.y-196 if narrow else view.y-104
    for i in range(8):
        var weapon:=i<3;var index:=i if weapon else i-3
        var items: Array=game.weapons if weapon else game.passives
        var item: Dictionary=items[index] if index<items.size() else {}
        var parts: Dictionary=equipment[i]
        var at:=Vector2(18+(index if narrow else i)*slot_pitch+(14 if not narrow and not weapon else 0),start_y+(94 if narrow and not weapon else 0))
        var kind: String="weapon" if weapon else "passive"
        parts["frame"].texture=art.texture("equipment/"+kind+("-empty" if item.is_empty() else "-filled"));place(parts["frame"],Rect2(at,Vector2.ONE*slot_width))
        parts["icon"].texture=ui.item_icons.texture(kind,item["id"]) if not item.is_empty() else null;place(parts["icon"],Rect2(at+Vector2(5,5),Vector2.ONE*44))
        parts["level"].text="" if item.is_empty() else "LV%d" % int(item["level"])
        Type.apply(parts["level"],"micro_label",true,Style.PAPER,true)
        place(parts["level"],Rect2(at+Vector2(18,38),Vector2(43,21)))
        # Keep gameplay clean: the 8 approved icons plus clear level marks
        # are visible; full names remain accessible in Build inspection.
        parts["name"].hide()
        parts["name"].text="" if item.is_empty() else Type.equipment_name(item["id"],ui.catalog[item["id"]]["name"])
        parts["name"].tooltip_text="" if item.is_empty() else ui.catalog[item["id"]]["name"]


func reveal_selected(index: int, expected_signature: String) -> void:
    # Scroll ranges settle after container sorting, not when card positions are assigned.
    await get_tree().process_frame
    await get_tree().process_frame
    if signature==expected_signature and game.selected_card_index==index and offers_scroll.visible:
        offers_scroll.ensure_control_visible(game.offer_buttons[index])
