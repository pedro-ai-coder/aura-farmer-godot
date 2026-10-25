extends Control
## Production live-Control visual skin. Only immutable creator-approved runtime sources.
const Cache=preload("res://scripts/clean_cut_assets.gd")
const Style=preload("res://scripts/arcade_theme.gd")
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
    func _draw() -> void:
        draw_arc(size*0.5,minf(size.x,size.y)*0.43,-PI*0.5,-PI*0.5+TAU*clampf(progress,0,1),64,Color("f8c45f"),5,true)
var poster_surface: Control
var background: TextureRect
var wordmark: TextureRect
var poster_hero: TextureRect
var heading: Label
var heading_shadow: Label
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
var hp: Label
var xp_frame: TextureRect
var xp: Label
var wave_frame: TextureRect
var wave: Label
var warning: Label
var flex_image: TextureRect
var flex_caption: Label
var equipment: Array[Dictionary]=[]
var last_mode := ""
var signature := ""
var last_selected := -1
var view := Vector2.ZERO
var shift := Vector2.ZERO
var styles: Dictionary={}
var italic: FontVariation
var auxiliary
var layout_key := ""
var layout_count := 0
var empty_style := StyleBoxEmpty.new()
var caption_style := StyleBoxFlat.new()
func label(parent: Node, pixels: int=18, color: Color=Style.INK) -> Label:
    var node:=Label.new();parent.add_child(node)
    node.add_theme_font_override("font",Style.BODY)
    node.add_theme_font_size_override("font_size",pixels)
    node.add_theme_color_override("font_color",color)
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
    button.add_theme_font_override("font",Style.BLACK)
    button.add_theme_font_size_override("font_size",20)
    for color_key in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:button.add_theme_color_override(color_key,Style.INK)
    button.add_theme_color_override("font_disabled_color",Style.INK.lightened(0.3))
    for child in native_children.get(button,[]):
        if child is Control:child.hide()
func install(owner_game, source_root: String) -> void:
    game=owner_game;ui=game.presentation;art=Cache.new(source_root)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    game.layer.add_child(self)
    italic=FontVariation.new();italic.base_font=Style.BLACK
    italic.variation_transform=Transform2D(Vector2(1,0),Vector2(-0.17,1),Vector2.ZERO)
    background=image(self);background.stretch_mode=TextureRect.STRETCH_SCALE
    poster_surface=PosterSurface.new();poster_surface.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(poster_surface)
    wordmark=image(self);wordmark.texture=art.texture("support/wordmark")
    poster_hero=image(self);poster_hero.texture=game.art.texture("sigma")
    heading_shadow=label(self,34,Style.GOLD);heading=label(self,34,Style.PAPER)
    for node in [heading,heading_shadow]:node.add_theme_font_override("font",italic)
    home_caption=label(self,24,Style.PAPER)
    for button in [ui.play_button,ui.home.hero_destination,ui.options_button,ui.home.start_button,ui.home.return_button,game.confirm_button,game.defer_button,game.flex_button,game.pause_button,game.legendary_button]:adopt(button,self)
    hero_scroll=ScrollContainer.new();hero_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(hero_scroll)
    hero_content=Control.new();hero_scroll.add_child(hero_content)
    for i in range(3):
        var button: Button=game.menu_buttons[i];adopt(button,hero_content);button.text=""
        var parts: Dictionary={"portrait":image(button),"name":label(button,24),"role":label(button,15),"icon":image(button),"starter":label(button,17),"flex":label(button,18),"help":label(button,16)}
        parts["portrait"].texture=game.art.texture(game.HEROES[i]["id"])
        parts["name"].add_theme_font_override("font",Style.BLACK)
        hero_parts.append(parts)
    offers_scroll=ScrollContainer.new();offers_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(offers_scroll)
    offers_content=Control.new();offers_scroll.add_child(offers_content)
    for button: Button in game.offer_buttons:
        adopt(button,offers_content);button.text=""
        var parts: Dictionary={"icon":image(button),"name":label(button,23),"meta":label(button,16),"body":label(button,18),"comparison":label(button,15),"state":label(button,14)}
        parts["name"].add_theme_font_override("font",Style.BLACK)
        parts["body"].clip_text = true
        parts["body"].max_lines_visible = 5
        parts["body"].text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        offer_parts.append(parts)
    player_plate=image(self);player_plate.stretch_mode=TextureRect.STRETCH_SCALE
    hp_fill=ColorRect.new();hp_fill.color=Style.CORAL;hp_fill.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(hp_fill)
    portrait=image(self);hp=label(self,17)
    xp_frame=image(self);xp_frame.stretch_mode=TextureRect.STRETCH_SCALE
    xp_track=ColorRect.new();xp_track.color=Style.DEEP;xp_track.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(xp_track)
    xp_fill=ColorRect.new();xp_fill.color=Style.SKY;xp_fill.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(xp_fill)
    xp=label(self,15)
    boss_plate=image(self);boss_plate.stretch_mode=TextureRect.STRETCH_SCALE;boss_text=label(self,17)
    game.touch_joystick.self_modulate=Color(1,1,1,0)
    joystick_ring=image(game.touch_joystick);joystick_thumb=image(game.touch_joystick)
    wave_frame=image(self);wave=label(self,19)
    warning=label(self,16,Style.GOLD)
    flex_image=image(game.flex_button);aura_arc=AuraArc.new();aura_arc.mouse_filter=Control.MOUSE_FILTER_IGNORE;game.flex_button.add_child(aura_arc);flex_caption=label(self,14,Style.PAPER)
    flex_caption.add_theme_stylebox_override("normal",Style.box(Style.DEEP,Style.DEEP,0,0))
    hud_nodes.assign([player_plate,hp_fill,portrait,hp,xp_frame,xp_track,xp_fill,xp,wave_frame,wave,warning,flex_caption,boss_plate,boss_text])
    for i in range(8):
        var parts: Dictionary={"frame":image(self),"icon":image(self),"level":label(self,12),"name":label(self,12,Style.PAPER)}
        equipment.append(parts)
        for node in parts.values():hud_nodes.append(node)
    watermark=label(self,13,Style.CORAL);watermark.text=""
    caption_style.bg_color=Style.PAPER
    auxiliary=load("res://scripts/clean_cut_secondary.gd").new()
    add_child(auxiliary)
    auxiliary.install(self)
    refresh()
func _process(_delta: float) -> void:refresh()
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
    background.visible=mode!="playing";wordmark.visible=mode=="menu";poster_hero.visible=mode=="menu";home_caption.visible=mode=="menu"
    poster_surface.visible=mode=="menu";place(poster_surface,Rect2(Vector2.ZERO,view));poster_surface.queue_redraw()
    hero_scroll.visible=mode=="heroes";offers_scroll.visible=mode in ["choice","legendary","replace"]
    heading.visible=mode!="playing";heading_shadow.visible=heading.visible
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
    heading.text=text;heading_shadow.text=text
    for node in [heading,heading_shadow]:node.add_theme_font_size_override("font_size",24 if view.x<700 else 36)
    place(heading_shadow,Rect2(28,39,view.x-56,50));place(heading,Rect2(25,36,view.x-56,50))
func home_layout() -> void:
    background.modulate=Color.WHITE
    background.texture=art.texture("support/poster");place(background,Rect2(Vector2.ZERO,view))
    var narrow:=view.x<700
    place(wordmark,Rect2(35,45,view.x*(0.78 if narrow else 0.38),125))
    place(poster_hero,Rect2(view.x*0.49,view.y*0.18,view.x*0.48,view.y*0.66))
    poster_hero.visible=not narrow
    heading.hide();heading_shadow.hide()
    home_caption.text="THE STREETS ARE YOURS.\nFARM AURA. BE LEGENDARY."
    place(home_caption,Rect2(40,180,view.x-80 if narrow else view.x*0.5,90))
    var compact_landscape: bool=view.y<515
    var width:=minf(360,view.x-80)
    var top:=maxf(280,view.y*0.53)
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
    var items: Array=game.legendary_offers if legendary else game.replace_options if game.mode=="replace" else game.selection
    var columns:=1 if view.x<700 else 3
    var gap:=16.0;var width: float=(view.x-64-gap*(columns-1))/columns
    var height: float=minf(440,view.y-190) if not legendary else minf(230,(view.y-200)/2) if view.y>=650 and columns==3 else 270.0
    height=maxf(height,220 if legendary and view.y>=650 and columns==3 else 250 if legendary else 360)
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
        parts["icon"].texture=ui.item_icons.texture(category,id)
        parts["name"].text=native["name"].text;parts["body"].text=native["body"].text;parts["comparison"].text=native["comparison"].text
        parts["body"].tooltip_text = parts["body"].text
        parts["meta"].text=str(item.get("rarity",native["meta"].text)).to_upper()+" / "+native["category"].text
        parts["state"].text="SELECTED / CONFIRM BELOW" if selected else "SELECT THIS ITEM"
        if legendary:
            place(parts["icon"],Rect2(18,48,62,62));place(parts["name"],Rect2(92,48,width-112,55))
            parts["meta"].hide();place(parts["body"],Rect2(18,122,width-36,height-158));parts["comparison"].hide()
            parts["body"].add_theme_font_size_override("font_size",16)
        else:
            parts["meta"].show();parts["body"].add_theme_font_size_override("font_size",18)
            place(parts["icon"],Rect2((width-80)/2,74,80,80));place(parts["name"],Rect2(20,168,width-40,54))
            place(parts["meta"],Rect2(20,226,width-40,34));place(parts["body"],Rect2(20,265,width-40,height-375));parts["comparison"].show()
            place(parts["comparison"],Rect2(20,height-102,width-40,55))
        if not legendary and height<420:
            place(parts["icon"],Rect2(18,78,60,60));place(parts["name"],Rect2(90,78,width-108,60))
            place(parts["meta"],Rect2(18,150,width-36,32));place(parts["body"],Rect2(18,188,width-36,height-280))
            parts["body"].add_theme_font_size_override("font_size",16)
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
    hp.text="%s\nHP %d / %d  / SHIELD %d" % [game.hero["name"],ceili(game.hp),int(game.max_hp),ceili(game.shield)]
    place(hp,Rect2(82,38,minf(280,view.x-244),60))
    var xp_y: float=view.y-226 if narrow else view.y-132
    var xp_width: float=minf(350,view.x-200)
    xp_frame.texture=art.texture("support/xp");place(xp_frame,Rect2(18,xp_y,xp_width,38))
    # Approved SVG contains an illustrative blue segment (x28..330,y24..41).
    # Mask it completely before drawing the actual XP; never show sample progress.
    var track:=Rect2(18+27*xp_width/540,xp_y+23*38.0/120,467*xp_width/540,19*38.0/120)
    place(xp_track,track)
    place(xp_fill,Rect2(track.position,Vector2(track.size.x*clampf(game.xp/(30+8*game.level+game.level*game.level),0,1),track.size.y)))
    xp.add_theme_color_override("font_color",Style.PAPER)
    xp.add_theme_color_override("font_outline_color",Style.DEEP)
    xp.add_theme_constant_override("outline_size",5)
    xp.text="XP %d / LEVEL %d" % [int(game.xp),game.level]
    place(xp,Rect2(24,xp_y-25,minf(300,view.x-210),24))
    wave_frame.texture=art.texture("support/wave");place(wave_frame,Rect2((view.x-190)/2,128 if narrow else 28,190,70))
    wave.text="%s\n%02d:%02d" % ["BIG HATER" if game.boss_spawned else "WAVE %d / 5" % game.wave,int(game.run_time)/60,int(game.run_time)%60]
    wave.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;place(wave,Rect2((view.x-178)/2,138 if narrow else 38,170,55))
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
        var thumb_at: Vector2=game.touch_joystick.center+game.touch_direction*game.touch_joystick.THUMB_OFFSET*scale
        place(joystick_thumb,Rect2(thumb_at-Vector2.ONE*44*scale,Vector2.ONE*88*scale))
    var extent:=128.0
    game.flex_button.show();game.flex_button.text="";place(game.flex_button,Rect2(view.x-extent-26,view.y-extent-68,extent,extent))
    var current: String="active" if game.flex_time>0 else "recovery" if game.flex_lock>0 else "ready" if game.aura>=100 else "charging"
    if game.mode!="playing":current="disabled"
    elif state(game.flex_button)=="pressed":current="pressed"
    elif game.flex_button.has_focus():current="focused"
    var empty:=empty_style
    for key in ["normal","hover","pressed","focus","disabled"]:game.flex_button.add_theme_stylebox_override(key,empty)
    flex_image.texture=art.texture("flex/"+game.hero["id"]+"-"+current);place(flex_image,Rect2(Vector2.ZERO,Vector2.ONE*extent))
    aura_arc.progress=game.aura/100.0;place(aura_arc,Rect2(Vector2.ZERO,Vector2.ONE*extent));aura_arc.queue_redraw()
    flex_caption.text=game.hero["flex"]+"\n"+(game.flex_status() if game.flex_time>0 else "RECOVERY %.1fs" % game.flex_lock if game.flex_lock>0 else "READY" if game.aura>=100 else "AURA %d%%" % int(game.aura))
    flex_caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;place(flex_caption,Rect2(view.x-240,view.y-62,230,58))
    var slot_width:=48.0;var start_y:=view.y-174 if narrow else view.y-90
    for i in range(8):
        var weapon:=i<3;var index:=i if weapon else i-3
        var items: Array=game.weapons if weapon else game.passives
        var item: Dictionary=items[index] if index<items.size() else {}
        var parts: Dictionary=equipment[i]
        var at:=Vector2(18+(index if narrow else i)*(slot_width+10)+(14 if not narrow and not weapon else 0),start_y+(82 if narrow and not weapon else 0))
        var kind: String="weapon" if weapon else "passive"
        parts["frame"].texture=art.texture("equipment/"+kind+("-empty" if item.is_empty() else "-filled"));place(parts["frame"],Rect2(at,Vector2.ONE*slot_width))
        parts["icon"].texture=ui.item_icons.texture(kind,item["id"]) if not item.is_empty() else null;place(parts["icon"],Rect2(at+Vector2(5,5),Vector2.ONE*32))
        parts["level"].text="" if item.is_empty() else str(item["level"]);place(parts["level"],Rect2(at+Vector2(32,30),Vector2(16,18)))
        parts["name"].add_theme_color_override("font_color",Style.INK)
        parts["name"].add_theme_stylebox_override("normal",caption_style)
        parts["name"].visible=not item.is_empty()
        parts["name"].text="" if item.is_empty() else ui.catalog[item["id"]]["name"]
        place(parts["name"],Rect2(at+Vector2(0,50),Vector2(slot_width+8,30)))

func reveal_selected(index: int, expected_signature: String) -> void:
    # Scroll ranges settle after container sorting, not when card positions are assigned.
    await get_tree().process_frame
    await get_tree().process_frame
    if signature==expected_signature and game.selected_card_index==index and offers_scroll.visible:
        offers_scroll.ensure_control_visible(game.offer_buttons[index])
