extends RefCounted
## Reference-led HUD V2 presentation. No simulation, RNG, profile or input owner.
## Immutable SVG textures/styles are shared. Geometry and data invalidate separately.
const Type=preload("res://scripts/clean_cut_typography.gd")
const Meter=preload("res://scripts/hero_clash_hud_meter.gd")
const ART="res://assets/ui-hud-candidates/v2/"
const CROP=preload("res://assets/ui-hud-candidates/v2/portrait_crop.gdshader")
const INK=Color("0b2034")
const PAPER=Color("fff9e9")
const GOLD=Color("ffce30")
const SAFE_LABEL_OFFSETS=[Vector2(-48,35),Vector2(-48,-66),Vector2(-130,-10),Vector2(38,-10)]
static var textures: Dictionary={}
static var pause_styles: Dictionary={}
var skin
var game
var strip: TextureRect
var weapon_group: Label
var passive_group: Label
var ability_plate: TextureRect
var shield_mark: TextureRect
var boss_fill: Control
var portrait_material: ShaderMaterial
var geometry_key: String=""
var data_key: String=""
var has_boss: bool=false
var geometry_count: int=0
var data_count: int=0
var hp_rect:=Rect2()
var shield_rect:=Rect2()
var xp_rect:=Rect2()
var boss_rect:=Rect2()
var reserved: Array[Rect2]=[]
var compact: bool=false
var portrait: bool=false

static func texture(id: String) -> Texture2D:
    if not textures.has(id):textures[id]=load(ART+id+".svg")
    return textures[id]
static func pause_style(state: String) -> StyleBoxTexture:
    if not pause_styles.has(state):
        var style:=StyleBoxTexture.new();style.texture=texture("pause-"+state)
        pause_styles[state]=style
    return pause_styles[state]
func _init(owner_skin) -> void:
    skin=owner_skin;game=skin.game
    strip=skin.image(skin)
    # The strip belongs behind its eight independently bound approved icons.
    skin.move_child(strip,skin.player_plate.get_index())
    weapon_group=skin.label(skin);passive_group=skin.label(skin)
    ability_plate=skin.image(skin)
    skin.move_child(ability_plate,skin.flex_caption.get_index())
    shield_mark=skin.image(skin);shield_mark.texture=texture("shield-mark")
    boss_fill=Meter.new();skin.add_child(boss_fill);boss_fill.install(texture("hp-fill"))
    skin.move_child(boss_fill,skin.boss_text.get_index())
    skin.hud_nodes.append_array([strip,weapon_group,passive_group,ability_plate,shield_mark,boss_fill])
    portrait_material=ShaderMaterial.new();portrait_material.shader=CROP
    skin.portrait.material=portrait_material
    skin.portrait.stretch_mode=TextureRect.STRETCH_SCALE
    skin.flex_caption.remove_theme_stylebox_override("normal")
    for node in [skin.hero_name,skin.hp,skin.shield_label,skin.wave,skin.xp,skin.flex_title,skin.flex_status,skin.flex_caption,skin.boss_text,weapon_group,passive_group]:
        node.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
        node.autowrap_mode=TextServer.AUTOWRAP_OFF
        node.text_overrun_behavior=TextServer.OVERRUN_NO_TRIMMING
        node.add_theme_constant_override("outline_size",0)
        node.add_theme_color_override("font_shadow_color",Color.TRANSPARENT)
        node.add_theme_constant_override("shadow_offset_y",0)
    skin.hp.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
    skin.shield_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
    skin.wave.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    skin.flex_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    skin.flex_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    skin.flex_caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    skin.xp_frame.texture=texture("xp-frame")
    skin.player_plate.texture=texture("player-frame")
    skin.wave_frame.texture=texture("wave-frame")
    ability_plate.texture=texture("ability-nameplate")
    game.pause_button.tooltip_text="Pause [P / Esc]"
    game.flex_button.tooltip_text="Flex [Space] — 100 Aura required"

func place(node: Control, rect: Rect2) -> void:skin.place(node,rect)
func text_style(node: Control, role: String, pixels: int, color: Color) -> void:
    Type.apply(node,role,false,color)
    node.add_theme_font_size_override("font_size",pixels)
    node.add_theme_constant_override("outline_size",0)
    node.add_theme_color_override("font_shadow_color",Color.TRANSPARENT)
func rect_in(rect: Rect2, x: float,y: float,w: float,h: float) -> Rect2:
    return Rect2(rect.position+Vector2(x/620.0,y/170.0)*rect.size,Vector2(w/620.0,h/170.0)*rect.size)
func layout() -> void:
    # Clear legacy text before measuring real Button minimum sizes.
    game.pause_button.show();game.pause_button.text=""
    for state in ["normal","hover","focus","pressed","disabled"]:
        game.pause_button.add_theme_stylebox_override(state,pause_style(state))
    game.flex_button.show();game.flex_button.text=""
    for state in ["normal","hover","focus","pressed","disabled"]:
        game.flex_button.add_theme_stylebox_override(state,skin.empty_style)
    var next_geometry: String=str([skin.view,skin.shift,skin.ui.revision,game.boss_spawned])
    if geometry_key!=next_geometry:
        geometry_key=next_geometry;geometry_count+=1
        layout_geometry()
        data_key=""
    sync_data()
    skin.boss_plate.visible=has_boss;skin.boss_text.visible=has_boss;boss_fill.visible=has_boss
    for parts in skin.equipment:
        parts["name"].hide()
        parts["tab"].visible=not parts["level"].text.is_empty()
        parts["rarity"].visible=parts["tab"].visible

func layout_geometry() -> void:
    var view: Vector2=skin.view
    compact=view.y<580.0 or view.x<700.0
    portrait=view.x<700.0 and view.y>view.x
    var status:=Rect2(22,30,530,144)
    if compact:status=Rect2(14,14,390 if not portrait else minf(395,view.x-110),112 if not portrait else 118)
    place(skin.player_plate,status)
    place(skin.portrait,rect_in(status,26,22,154,118))
    place(skin.hero_name,rect_in(status,207,30,342,41))
    text_style(skin.hero_name,"section_header",25 if compact else 32,INK)
    hp_rect=rect_in(status,197,79,373,34)
    place(skin.hp,Rect2(hp_rect.position+Vector2(15,0),hp_rect.size-Vector2(24,0)))
    text_style(skin.hp,"hud_stat",20 if compact else 24,PAPER)
    shield_rect=rect_in(status,186,121,369,25)
    place(skin.shield_track,shield_rect);skin.shield_track.color=Color("082b4b")
    place(shield_mark,Rect2(shield_rect.position+Vector2(8,2),Vector2(18,shield_rect.size.y-4)))
    place(skin.shield_label,Rect2(shield_rect.position+Vector2(34,0),shield_rect.size-Vector2(42,0)))
    text_style(skin.shield_label,"hud_secondary",18 if compact else 20,PAPER)
    var wave_width: float=300.0 if compact else 390.0
    var wave_height: float=60.0 if compact else 70.0
    var wave_left: float=view.x*0.62-wave_width*0.5
    var wave_top: float=22.0 if compact else 46.0
    if portrait:wave_left=(view.x-wave_width)*0.5;wave_top=status.end.y+14.0
    place(skin.wave_frame,Rect2(wave_left,wave_top,wave_width,wave_height))
    place(skin.wave,Rect2(wave_left+25,wave_top+5,wave_width-50,wave_height-13))
    text_style(skin.wave,"section_header",23 if compact else 30,INK)
    var pause_size:=Vector2(72,68) if compact else Vector2(88,84)
    place(game.pause_button,Rect2(Vector2(view.x-pause_size.x-16,status.position.y),pause_size))
    var strip_height: float=214.0 if portrait else 98.0 if compact else 114.0
    var strip_width: float=view.x-28.0 if portrait else 640.0 if compact else 760.0
    var strip_rect:=Rect2(14 if compact else 22,view.y-strip_height-14,strip_width,strip_height)
    place(strip,strip_rect);strip.texture=texture("equipment-portrait" if portrait else "equipment-strip")
    var slot: float=76.0 if portrait else 68.0 if compact else 82.0
    var pitch: float=86.0 if portrait else 76.0 if compact else 91.0
    for i in range(8):
        var weapon: bool=i<3
        var index: int=i if weapon else i-3
        var at: Vector2=strip_rect.position+Vector2(12+(index if portrait else i)*pitch+(12 if not portrait and not weapon else 0),112 if portrait and not weapon else 8)
        var parts: Dictionary=skin.equipment[i]
        place(parts["frame"],Rect2(at,Vector2.ONE*slot))
        place(parts["icon"],Rect2(at+Vector2(8,6),Vector2(slot-16,slot-18)))
        place(parts["tab"],Rect2(at+Vector2(12,slot-23),Vector2(slot-17,22)))
        place(parts["level"],Rect2(at+Vector2(10,slot-24),Vector2(slot-14,24)))
        text_style(parts["level"],"hud_secondary",18 if compact else 19,PAPER)
        parts["level"].horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
        place(parts["rarity"],Rect2(at+Vector2(13,slot-6),Vector2(slot-25,3)))
        parts["name"].hide()
    weapon_group.text="WEAPONS";passive_group.text="PASSIVES"
    text_style(weapon_group,"micro_label",15 if compact else 16,PAPER)
    text_style(passive_group,"micro_label",15 if compact else 16,PAPER)
    if portrait:
        place(weapon_group,Rect2(strip_rect.position+Vector2(282,30),Vector2(strip_width-300,30)))
        place(passive_group,Rect2(strip_rect.position+Vector2(14,89),Vector2(strip_width-28,24)))
    else:
        place(weapon_group,Rect2(strip_rect.position+Vector2(18,strip_height-23),Vector2(3*pitch-18,22)))
        place(passive_group,Rect2(strip_rect.position+Vector2(3*pitch+30,strip_height-23),Vector2(strip_width-3*pitch-42,22)))
        weapon_group.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
        passive_group.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var xp_width: float=minf(350,view.x-30) if compact else 390.0
    var xp_height: float=58.0 if compact else 66.0
    var xp_top: float=strip_rect.position.y-xp_height-5
    place(skin.xp_frame,Rect2(strip_rect.position.x,xp_top,xp_width,xp_height))
    xp_rect=Rect2(strip_rect.position.x+xp_width*0.115,xp_top+xp_height*0.585,xp_width*0.785,xp_height*0.19)
    place(skin.xp_track,xp_rect);skin.xp_track.color=Color("073052")
    place(skin.xp,Rect2(strip_rect.position.x+xp_width*0.12,xp_top+1,xp_width*0.72,xp_height*0.55))
    text_style(skin.xp,"hud_stat",21 if compact else 24,INK)
    var diameter: float=164.0 if compact else 208.0
    var flex_rect:=Rect2(view.x-diameter-16,view.y-diameter-(strip_height+104 if portrait else 14),diameter,diameter)
    place(game.flex_button,flex_rect)
    place(skin.aura_arc,Rect2(Vector2.ZERO,Vector2.ONE*diameter));skin.aura_arc.show()
    place(skin.flex_title,Rect2(diameter*0.13,diameter*0.32,diameter*0.74,diameter*0.25))
    text_style(skin.flex_title,"section_header",32 if compact else 43,PAPER)
    skin.flex_title.text="FLEX"
    place(skin.flex_status,Rect2(diameter*0.11,diameter*0.60,diameter*0.78,diameter*0.18))
    text_style(skin.flex_status,"hud_stat",19 if compact else 22,PAPER)
    var caption_width: float=230.0 if compact else 250.0
    var caption_left: float=maxf(8.0,minf(view.x-caption_width-10.0,flex_rect.get_center().x-caption_width*0.5))
    var caption_rect:=Rect2(caption_left,flex_rect.position.y-39,caption_width,35)
    place(ability_plate,caption_rect)
    place(skin.flex_caption,Rect2(caption_rect.position+Vector2(20,0),caption_rect.size-Vector2(34,0)))
    text_style(skin.flex_caption,"section_header",18 if compact else 20,PAPER)
    for node in [skin.flex_image,skin.flex_track,skin.flex_fill,skin.flex_badge]:node.hide()
    boss_rect=Rect2((view.x-minf(440,view.x-40))*0.5,maxf(status.end.y,skin.wave_frame.get_rect().end.y)+12,minf(440,view.x-40),44)
    place(skin.boss_plate,boss_rect);skin.boss_plate.texture=texture("boss-frame")
    place(skin.boss_text,Rect2(boss_rect.position+Vector2(24,1),boss_rect.size-Vector2(48,15)))
    text_style(skin.boss_text,"hud_secondary",18 if compact else 20,INK)
    var warning_top: float=(boss_rect.end.y if game.boss_spawned else maxf(status.end.y,skin.wave_frame.get_rect().end.y))+6
    place(skin.warning,Rect2((view.x-minf(420,view.x-32))*0.5,warning_top,minf(420,view.x-32),28))
    text_style(skin.warning,"hud_secondary",18,Color("ffdc70"))
    skin.warning.add_theme_constant_override("outline_size",2)
    skin.warning.add_theme_color_override("font_outline_color",INK)
    skin.warning.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    place(game.legendary_button,Rect2(16,skin.xp_frame.position.y-72,minf(250,view.x-32),64))
    reserved.assign([status,skin.wave_frame.get_rect(),game.pause_button.get_rect(),strip_rect,skin.xp_frame.get_rect(),flex_rect,caption_rect])
    if game.boss_spawned:reserved.append(boss_rect)

func sync_data() -> void:
    var inventory: String=""
    for item: Dictionary in game.weapons+game.passives:inventory+=str([item["id"],item["level"],item["rarity"]])
    var boss: Dictionary={}
    for enemy: Dictionary in game.enemies:
        if enemy["kind"]=="boss":boss=enemy;break
    var key: String=str([skin.ui.revision,game.hero.get("id"),game.hp,game.max_hp,game.shield,game.level,int(game.xp),int(game.run_time),game.wave,int(game.aura),int(game.flex_time*10),int(game.flex_lock*10),game.flex_button.disabled,skin.state(game.flex_button),game.profile["settings"].get("reducedMotion",false),game.legendary_spent,boss.get("hp",0),inventory])
    if data_key==key:return
    data_key=key;data_count+=1
    skin.hero_name.text=str(game.hero["name"]).to_upper();skin.fit_line(skin.hero_name,22 if compact else 26)
    skin.portrait.texture=game.art.texture(game.hero["id"])
    var regions: Dictionary={"sigma":Vector4(0.18,0.07,0.49,0.54),"cool-kid":Vector4(0.12,0.02,0.65,0.63),"alpha":Vector4(0.14,0.00,0.65,0.62)}
    portrait_material.set_shader_parameter("source_region",regions[game.hero["id"]])
    skin.hp.text="HP %d / %d" % [ceili(game.hp),ceili(game.max_hp)]
    skin.fit_line(skin.hp,18 if compact else 22)
    skin.hp_fill.update_meter(hp_rect,game.hp/maxf(1.0,game.max_hp))
    # Shield remains a percentage of real max HP, as before; no artificial max.
    skin.shield_fill.update_meter(Rect2(shield_rect.position+Vector2(3,3),shield_rect.size-Vector2(6,6)),game.shield/maxf(1.0,game.max_hp))
    skin.shield_label.text="SHIELD %d" % ceili(game.shield)
    skin.xp.text="LEVEL %d  ·  XP %d" % [game.level,int(game.xp)];skin.fit_line(skin.xp,18)
    skin.xp_fill.update_meter(xp_rect,game.xp/(30+8*game.level+game.level*game.level))
    skin.wave.text="%s / %02d:%02d" % ["BIG HATER" if game.boss_spawned else "WAVE %d" % game.wave,int(game.run_time)/60,int(game.run_time)%60]
    skin.fit_line(skin.wave,20 if compact else 26)
    skin.warning.text=game.SoloClock.warning(game.run_time)
    has_boss=not boss.is_empty()
    skin.boss_plate.visible=not boss.is_empty();skin.boss_text.visible=not boss.is_empty();boss_fill.visible=not boss.is_empty()
    if not boss.is_empty():
        skin.boss_text.text="BIG HATER / %d HP" % ceili(boss["hp"])
        boss_fill.update_meter(Rect2(boss_rect.position+Vector2(25,30),boss_rect.size-Vector2(50,35)),float(boss["hp"])/maxf(1.0,float(boss["max"])))
    var active_flex: bool=game.flex_time>0.0
    var ready: bool=game.aura>=100 and game.flex_lock<=0 and not active_flex
    var recovering: bool=game.flex_lock>0 and not active_flex
    var current: String="active" if active_flex else "ready" if ready else "recovery" if recovering else "charging" if game.aura>=0 else "disabled"
    if game.hp<=0.0:current="disabled"
    var progress: float=1.0 if active_flex or ready else 0.0 if recovering or current=="disabled" else game.aura/100.0
    skin.aura_arc.show_state(progress,current,skin.state(game.flex_button) in ["pressed","focus","hover"],bool(game.profile["settings"].get("reducedMotion",false)))
    skin.flex_title.add_theme_color_override("font_color",GOLD if ready else PAPER)
    skin.flex_status.text="READY" if ready else "ACTIVE %.1fs" % game.flex_time if active_flex else "LOCK %.0fs" % game.flex_lock if recovering else "AURA %d%%" % int(game.aura)
    skin.flex_status.add_theme_color_override("font_color",GOLD if ready else Color("6ff3df") if active_flex else PAPER)
    skin.fit_line(skin.flex_status,17)
    skin.flex_caption.text=str(game.hero["flex"]).to_upper();skin.fit_line(skin.flex_caption,16 if compact else 18)
    game.legendary_button.visible=game.run_time>=game.SoloClock.LEGENDARY_FIRST and game.run_time<game.SoloClock.LEGENDARY_DEADLINE and not game.legendary_spent and not game.legendary_offers.is_empty()
    if game.legendary_button.visible:game.legendary_button.text="LEGENDARY [L]";skin.button_skin(game.legendary_button,"menu/primary")
    for i in range(8):
        var index: int=i if i<3 else i-3
        var items: Array=game.weapons if i<3 else game.passives
        var item: Dictionary=items[index] if index<items.size() else {}
        var parts: Dictionary=skin.equipment[i]
        parts["frame"].texture=texture("slot-empty" if item.is_empty() else "slot-equipped")
        parts["icon"].texture=null if item.is_empty() else skin.ui.item_icons.texture("weapon" if i<3 else "passive",item["id"])
        parts["level"].text="" if item.is_empty() else "LV%d" % int(item["level"])
        parts["tab"].visible=not item.is_empty();parts["rarity"].visible=not item.is_empty()
        if not item.is_empty():parts["rarity"].color={"common":Color("adb6bd"),"rare":Color("54bcff"),"epic":Color("ba84ff"),"legendary":GOLD}.get(item["rarity"],GOLD)
        parts["name"].hide()
        parts["name"].tooltip_text="" if item.is_empty() else str(skin.ui.catalog[item["id"]]["name"])

func safe_label_origin(world: Vector2, label_size: Vector2) -> Vector2:
    # Try presentation offsets only. The station/radius/activation never move.
    var transform: Transform2D=skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
    for offset in SAFE_LABEL_OFFSETS:
        var at: Vector2=world+offset
        var candidate: Rect2=transform*Rect2(at,label_size)
        var blocked: bool=(not skin.warning.text.is_empty() and candidate.intersects(skin.warning.get_rect().grow(4))) or (game.legendary_button.visible and candidate.intersects(game.legendary_button.get_rect().grow(4)))
        for region in reserved:
            if candidate.intersects(region.grow(4)):blocked=true;break
        if not blocked and Rect2(Vector2.ZERO,skin.view).encloses(candidate):return at
    return Vector2.INF
