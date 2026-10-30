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
const STATUS_TINTS={"damage":Color("ff9b8b"),"healing":Color("9dffd2"),"shield-gained":Color("88dfff"),"shield-depleted":Color("b6c5df"),"critical":Color("ffc1b6")}
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
var boss_portrait: TextureRect
var boss_hp: Label
var wave_clock: Label
var modules: Dictionary={}
var stacked_bottom: bool=false
var feedback_state: String="normal"
var feedback_until: float=0.0
var level_feedback_until: float=0.0
var previous_hp: float=-1.0
var previous_shield: float=0.0
var previous_level: int=1
var previous_time: float=-1.0
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
var desktop: bool=false

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
    boss_portrait=skin.image(skin);boss_portrait.texture=game.art.texture("big-hater")
    boss_hp=skin.label(skin);wave_clock=skin.label(skin)
    skin.hud_nodes.append_array([boss_portrait,boss_hp,wave_clock])
    # Each module is a live, non-intercepting Control anchored inside the
    # presenter's existing safe area. Buttons keep their original signals.
    for id in ["TopLeftHeroStatus","TopCenterWaveTimer","TopRightBossStatus","TopRightPause","BottomLeftXP","BottomCenterEquipment","BottomRightFlex"]:
        var module:=Control.new();module.name=id;module.mouse_filter=Control.MOUSE_FILTER_IGNORE
        skin.add_child(module);modules[id]=module;skin.hud_nodes.append(module)
    move_into("TopLeftHeroStatus",[skin.player_plate,skin.hp_fill,skin.shield_track,skin.shield_fill,skin.portrait,skin.hero_name,skin.hp,shield_mark,skin.shield_label])
    move_into("TopCenterWaveTimer",[skin.wave_frame,skin.wave,wave_clock])
    move_into("TopRightBossStatus",[skin.boss_plate,boss_fill,boss_portrait,skin.boss_text,boss_hp,skin.warning])
    move_into("TopRightPause",[game.pause_button])
    move_into("BottomLeftXP",[skin.xp_frame,skin.xp_track,skin.xp_fill,skin.xp])
    move_into("BottomCenterEquipment",[strip,weapon_group,passive_group])
    for parts in skin.equipment:move_into("BottomCenterEquipment",parts.values())
    move_into("BottomRightFlex",[game.flex_button,ability_plate,skin.flex_caption])
    portrait_material=ShaderMaterial.new();portrait_material.shader=CROP
    skin.portrait.material=portrait_material
    skin.portrait.stretch_mode=TextureRect.STRETCH_SCALE
    skin.flex_caption.remove_theme_stylebox_override("normal")
    for node in [skin.hero_name,skin.hp,skin.shield_label,skin.wave,wave_clock,skin.xp,skin.flex_title,skin.flex_status,skin.flex_caption,skin.boss_text,boss_hp,weapon_group,passive_group]:
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

func move_into(id: String, nodes: Array) -> void:
    for node in nodes:node.reparent(modules[id],false)

func anchor(id: String, alignment: Vector2, extent: Vector2, inset: Vector2=Vector2.ZERO) -> Control:
    var module: Control=modules[id]
    module.anchor_left=alignment.x;module.anchor_right=alignment.x
    module.anchor_top=alignment.y;module.anchor_bottom=alignment.y
    module.offset_left=inset.x-extent.x*alignment.x
    module.offset_right=module.offset_left+extent.x
    module.offset_top=inset.y-extent.y*alignment.y
    module.offset_bottom=module.offset_top+extent.y
    return module

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
    var next_geometry: String=str([skin.view,skin.shift,skin.ui.revision,game.boss_spawned,game.touch_device,not game.SoloClock.warning(game.run_time).is_empty()])
    if geometry_key!=next_geometry:
        geometry_key=next_geometry;geometry_count+=1
        layout_geometry()
        data_key=""
    sync_data()
    modules["TopRightBossStatus"].visible=has_boss or not skin.warning.text.is_empty()
    for node in [skin.boss_plate,skin.boss_text,boss_hp,boss_fill,boss_portrait]:node.visible=has_boss
    for parts in skin.equipment:
        parts["name"].hide()
        parts["tab"].visible=not parts["level"].text.is_empty()
        parts["rarity"].visible=parts["tab"].visible

func layout_geometry() -> void:
    var view: Vector2=skin.view
    compact=view.y<580.0 or view.x<700.0
    portrait=view.x<700.0 and view.y>view.x
    desktop=not compact and not game.touch_device
    # Logical dimensions, anchored against the actual safe viewport. The
    # presenter's CSS/DPR scaling and touch-coordinate transform stay intact.
    var wave_size:=Vector2(270 if compact else 300,72)
    var status_width: float=minf(450.0 if desktop else 350.0,view.x*0.5-wave_size.x*0.5-12.0)
    if portrait:status_width=minf(340,view.x-90)
    var status_size:=Vector2(status_width,112 if compact else 132)
    var status:=anchor("TopLeftHeroStatus",Vector2.ZERO,status_size,Vector2(4,4))
    var local_status:=Rect2(Vector2.ZERO,status_size)
    place(skin.player_plate,local_status)
    place(skin.portrait,rect_in(local_status,26,22,154,118))
    place(skin.hero_name,rect_in(local_status,207,23,342,48))
    text_style(skin.hero_name,"section_header",24 if compact else 30,INK)
    hp_rect=rect_in(local_status,197,81,373,36)
    place(skin.hp,Rect2(hp_rect.position+Vector2(10,0),hp_rect.size-Vector2(16,0)))
    text_style(skin.hp,"hud_stat",20 if compact else 24,PAPER)
    shield_rect=rect_in(local_status,186,124,369,29)
    place(skin.shield_track,shield_rect);skin.shield_track.color=Color("082b4b")
    place(shield_mark,Rect2(shield_rect.position+Vector2(6,2),Vector2(16,shield_rect.size.y-4)))
    place(skin.shield_label,Rect2(shield_rect.position+Vector2(28,0),shield_rect.size-Vector2(34,0)))
    text_style(skin.shield_label,"hud_secondary",18,PAPER)
    var wave_top: float=status_size.y+8 if portrait else 4.0
    var wave_module:=anchor("TopCenterWaveTimer",Vector2(0.5,0),wave_size,Vector2(0,wave_top))
    skin.wave_frame.stretch_mode=TextureRect.STRETCH_SCALE
    place(skin.wave_frame,Rect2(Vector2.ZERO,wave_size))
    place(skin.wave,Rect2(24,3,wave_size.x-48,32))
    text_style(skin.wave,"section_header",23 if compact else 25,INK)
    place(wave_clock,Rect2(24,34,wave_size.x-48,28))
    text_style(wave_clock,"hud_stat",24,INK);wave_clock.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    var pause_size:=Vector2(72,68) if compact else Vector2(80,76)
    var pause_module:=anchor("TopRightPause",Vector2(1,0),pause_size,Vector2(-4,4))
    place(game.pause_button,Rect2(Vector2.ZERO,pause_size))
    var boss_size:=Vector2(300 if compact else 320,84)
    var boss_top:=4.0
    var boss_right: float=-pause_size.x-8.0
    # A second row belongs to the right edge, never the center of combat.
    if view.x+boss_right-boss_size.x<wave_module.get_rect().end.x+8:
        boss_right=-4
        boss_top=maxf(status.get_rect().end.y,wave_module.get_rect().end.y)+8
    var boss_module:=anchor("TopRightBossStatus",Vector2(1,0),boss_size,Vector2(boss_right,boss_top))
    boss_rect=boss_module.get_rect()
    place(skin.boss_plate,Rect2(Vector2.ZERO,boss_size));skin.boss_plate.texture=texture("boss-frame")
    place(boss_portrait,Rect2(15,8,43,47))
    place(skin.boss_text,Rect2(64,5,boss_size.x-92,25))
    text_style(skin.boss_text,"section_header",18,INK)
    place(boss_hp,Rect2(64,29,boss_size.x-92,23))
    text_style(boss_hp,"hud_secondary",18,INK)
    place(skin.warning,Rect2(24,64,boss_size.x-48,20))
    text_style(skin.warning,"hud_secondary",16,PAPER)
    skin.warning.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    # The 3+5 rail is centered independently from the XP and Flex end modules.
    # Portrait/constrained fallback puts a full-width rail on the bottom edge.
    var diameter: float=164.0 if compact else 184.0
    var xp_width: float=200.0 if compact else 260.0
    var strip_width: float=minf(660,view.x-2.0*(xp_width+14.0))
    stacked_bottom=portrait or strip_width<480
    if stacked_bottom:strip_width=minf(660,view.x-8)
    var slot: float=minf(72,floorf((strip_width-66.0)/8.0))
    var pitch: float=slot+6
    var strip_height: float=slot+28
    var strip_module:=anchor("BottomCenterEquipment",Vector2(0.5,1),Vector2(strip_width,strip_height),Vector2(0,-4))
    strip.stretch_mode=TextureRect.STRETCH_SCALE
    place(strip,Rect2(Vector2.ZERO,strip_module.size));strip.texture=texture("equipment-strip")
    for i in range(8):
        var at:=Vector2(9+i*pitch+(12 if i>=3 else 0),4)
        var parts: Dictionary=skin.equipment[i]
        place(parts["frame"],Rect2(at,Vector2.ONE*slot))
        place(parts["icon"],Rect2(at+Vector2(6,4),Vector2(slot-12,slot-16)))
        place(parts["tab"],Rect2(at+Vector2(8,slot-25),Vector2(slot-12,20)))
        place(parts["level"],Rect2(at+Vector2(7,slot-30),Vector2(slot-11,24)))
        text_style(parts["level"],"hud_secondary",18,PAPER)
        parts["level"].horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
        place(parts["rarity"],Rect2(at+Vector2(10,slot-5),Vector2(slot-20,3)))
        parts["name"].hide()
    weapon_group.text="WEAPONS";passive_group.text="PASSIVES"
    for node in [weapon_group,passive_group]:
        text_style(node,"micro_label",14,Color(PAPER,0.88))
        node.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    place(weapon_group,Rect2(9,slot+5,3*pitch-6,20))
    place(passive_group,Rect2(9+3*pitch+12,slot+5,5*pitch-6,20))
    var lower_offset: float=strip_height+10 if stacked_bottom else 4.0
    if stacked_bottom:xp_width=minf(250,view.x-diameter-24)
    var xp_module:=anchor("BottomLeftXP",Vector2(0,1),Vector2(xp_width,58),Vector2(4,-lower_offset))
    place(skin.xp_frame,Rect2(Vector2.ZERO,xp_module.size))
    xp_rect=Rect2(xp_width*0.115,58*0.585,xp_width*0.785,58*0.19)
    place(skin.xp_track,xp_rect);skin.xp_track.color=Color("073c64")
    place(skin.xp,Rect2(xp_width*0.09,1,xp_width*0.82,31))
    text_style(skin.xp,"hud_stat",20 if compact else 22,INK)
    var flex_module:=anchor("BottomRightFlex",Vector2(1,1),Vector2(diameter,diameter+34),Vector2(-6,-maxf(6,lower_offset)))
    place(game.flex_button,Rect2(0,34,diameter,diameter))
    place(skin.aura_arc,Rect2(Vector2.ZERO,Vector2.ONE*diameter));skin.aura_arc.show()
    place(skin.flex_title,Rect2(diameter*0.13,diameter*0.39,diameter*0.74,diameter*0.25))
    text_style(skin.flex_title,"section_header",32 if compact else 38,PAPER)
    skin.flex_title.text="FLEX"
    place(skin.flex_status,Rect2(diameter*0.08,diameter*0.66,diameter*0.84,diameter*0.18))
    text_style(skin.flex_status,"hud_stat",18 if compact else 20,PAPER)
    # The ability's name is attached to the circular end cap, not a READY banner.
    var caption_width: float=230
    var caption_left: float=diameter-caption_width
    place(ability_plate,Rect2(caption_left,0,caption_width,34))
    place(skin.flex_caption,Rect2(caption_left+19,0,caption_width-32,32))
    text_style(skin.flex_caption,"section_header",18,PAPER)
    for node in [skin.flex_image,skin.flex_track,skin.flex_fill,skin.flex_badge]:node.hide()
    place(game.legendary_button,Rect2(4,xp_module.position.y-68,minf(250,view.x-8),60))
    reserved.assign([status.get_rect(),wave_module.get_rect(),pause_module.get_rect(),strip_module.get_rect(),xp_module.get_rect(),Rect2(flex_module.position+game.flex_button.position,game.flex_button.size)])
    # The nameplate extends left of the circular target but never intercepts input.
    reserved.append(Rect2(flex_module.position+Vector2(caption_left,0),Vector2(caption_width,34)))
    if game.boss_spawned or not game.SoloClock.warning(game.run_time).is_empty():reserved.append(boss_rect)

func sync_data() -> void:
    var inventory: String=""
    for item: Dictionary in game.weapons+game.passives:inventory+=str([item["id"],item["level"],item["rarity"]])
    var boss: Dictionary={}
    for enemy: Dictionary in game.enemies:
        if enemy["kind"]=="boss":boss=enemy;break
    var key: String=str([skin.ui.revision,game.hero.get("id"),game.hp,game.max_hp,game.shield,game.level,int(game.xp),int(game.run_time),game.wave,int(game.aura),int(game.flex_time*10),int(game.flex_lock*10),game.flex_button.disabled,skin.state(game.flex_button),game.profile["settings"].get("reducedMotion",false),game.legendary_spent,boss.get("hp",0),boss.get("max",0),inventory])
    if data_key==key:return
    data_key=key;data_count+=1
    update_status_feedback()
    skin.hero_name.text=str(game.hero["name"]).to_upper();skin.fit_line(skin.hero_name,20 if compact else 22)
    skin.portrait.texture=game.art.texture(game.hero["id"])
    var regions: Dictionary={"sigma":Vector4(0.18,0.07,0.49,0.54),"cool-kid":Vector4(0.12,0.02,0.65,0.63),"alpha":Vector4(0.14,0.00,0.65,0.62)}
    portrait_material.set_shader_parameter("source_region",regions[game.hero["id"]])
    skin.hp.text="HP %d / %d" % [ceili(game.hp),ceili(game.max_hp)]
    skin.fit_line(skin.hp,18 if compact else 22)
    skin.hp_fill.update_meter(hp_rect,game.hp/maxf(1.0,game.max_hp))
    # Shield remains a percentage of real max HP, as before; no artificial max.
    skin.shield_fill.update_meter(Rect2(shield_rect.position+Vector2(3,3),shield_rect.size-Vector2(6,6)),game.shield/maxf(1.0,game.max_hp))
    skin.shield_label.text="SHIELD %d" % ceili(game.shield)
    skin.xp.text="LV %d  ·  XP %d" % [game.level,int(game.xp)];skin.fit_line(skin.xp,18)
    skin.xp_fill.update_meter(xp_rect,game.xp/(30+8*game.level+game.level*game.level))
    skin.wave.text="WAVE %d / %d" % [game.wave,int(game.SoloClock.BOSS_AT/game.SoloClock.WAVE_SECONDS)]
    wave_clock.text="%02d:%02d" % [int(game.run_time)/60,int(game.run_time)%60]
    skin.warning.text=game.SoloClock.warning(game.run_time)
    has_boss=not boss.is_empty()
    for node in [skin.boss_plate,skin.boss_text,boss_hp,boss_fill,boss_portrait]:node.visible=has_boss
    skin.warning.visible=not skin.warning.text.is_empty()
    if not has_boss:
        place(skin.warning,Rect2(12,0,modules["TopRightBossStatus"].size.x-24,25))
        text_style(skin.warning,"hud_secondary",18,GOLD)
        skin.warning.add_theme_constant_override("outline_size",2)
        skin.warning.add_theme_color_override("font_outline_color",INK)
    if not boss.is_empty():
        skin.warning.add_theme_color_override("font_color",GOLD if game.run_time>=game.SoloClock.BERSERK_AT else PAPER)
        skin.boss_text.text="BIG HATER"
        boss_hp.text="%d / %d HP" % [ceili(boss["hp"]),ceili(boss["max"])]
        boss_fill.update_meter(Rect2(60,57,boss_rect.size.x-88,9),float(boss["hp"])/maxf(1.0,float(boss["max"])))
    var active_flex: bool=game.flex_time>0.0
    var ready: bool=game.aura>=100 and game.flex_lock<=0 and not active_flex
    var recovering: bool=game.flex_lock>0 and not active_flex
    var current: String="active" if active_flex else "ready" if ready else "recovery" if recovering else "charging" if game.aura>=0 else "disabled"
    if game.hp<=0.0:current="disabled"
    var progress: float=1.0 if active_flex or ready else 0.0 if recovering or current=="disabled" else game.aura/100.0
    skin.aura_arc.show_state(progress,current,skin.state(game.flex_button) in ["pressed","focus","hover"],bool(game.profile["settings"].get("reducedMotion",false)))
    skin.aura_arc.set_identity(str(game.hero["id"]))
    skin.flex_title.add_theme_color_override("font_color",GOLD if ready else PAPER)
    skin.flex_status.text="READY" if ready else "ACTIVE %.1fs" % game.flex_time if active_flex else "LOCK %.0fs" % game.flex_lock if recovering else "AURA %d%%" % int(game.aura)
    skin.flex_status.add_theme_color_override("font_color",GOLD if ready else Color("6ff3df") if active_flex else PAPER)
    skin.fit_line(skin.flex_status,17)
    skin.flex_caption.text=str(game.hero["flex"]).to_upper();skin.fit_line(skin.flex_caption,16 if compact or desktop else 18)
    var caption_alpha: float=0.72 if desktop and current=="charging" else 1.0
    ability_plate.modulate=Color(1,1,1,caption_alpha);skin.flex_caption.modulate=ability_plate.modulate
    game.flex_button.tooltip_text=str(game.hero["flex"])+" [Space] — 100 Aura required"
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

func update_status_feedback() -> void:
    # Observe actual state only. No damage/healing callbacks, RNG or tweens.
    if previous_hp<0 or game.run_time<previous_time:
        feedback_until=0;level_feedback_until=0;feedback_state="normal"
    elif game.hp<previous_hp:feedback_state="damage";feedback_until=game.run_time+0.30
    elif game.hp>previous_hp:feedback_state="healing";feedback_until=game.run_time+0.30
    elif game.shield>previous_shield:feedback_state="shield-gained";feedback_until=game.run_time+0.30
    elif previous_shield>0 and game.shield<=0:feedback_state="shield-depleted";feedback_until=game.run_time+0.30
    if game.level>previous_level:level_feedback_until=game.run_time+0.4
    previous_hp=game.hp;previous_shield=game.shield;previous_level=game.level;previous_time=game.run_time
    tick_feedback()

func tick_feedback() -> void:
    if game.mode!="playing":return
    var remaining: float=maxf(0,feedback_until-game.run_time)
    if remaining<=0:feedback_state="critical" if game.hp<=game.max_hp*0.25 else "normal"
    var tint: Color=STATUS_TINTS.get(feedback_state,Color.WHITE)
    var strength: float=0.35 if feedback_state=="critical" else minf(0.5,remaining/0.6)
    if game.profile["settings"].get("reducedMotion",false):strength=0.25 if feedback_state!="normal" else 0.0
    var color:=Color.WHITE.lerp(tint,strength)
    if skin.player_plate.modulate!=color:skin.player_plate.modulate=color
    var hp_color: Color=Color("ffe58a") if game.hp<=game.max_hp*0.25 else PAPER
    if skin.hp.get_theme_color("font_color")!=hp_color:skin.hp.add_theme_color_override("font_color",hp_color)
    var xp_color:=Color.WHITE.lerp(Color(1,0.91,0.62),clampf((level_feedback_until-game.run_time)/0.4,0,1))
    if skin.xp_frame.modulate!=xp_color:skin.xp_frame.modulate=xp_color

func safe_label_origin(world: Vector2, label_size: Vector2) -> Vector2:
    # Try presentation offsets only. The station/radius/activation never move.
    var transform: Transform2D=skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
    for i in range(SAFE_LABEL_OFFSETS.size()):
        var offset: Vector2=SAFE_LABEL_OFFSETS[i]
        if i<2:offset.x=-label_size.x*0.5
        elif i==2:offset.x=-label_size.x-34.0
        var at: Vector2=world+offset
        var candidate: Rect2=transform*Rect2(at,label_size)
        var blocked: bool=game.legendary_button.visible and candidate.intersects(game.legendary_button.get_rect().grow(4))
        for region in reserved:
            if candidate.intersects(region.grow(4)):blocked=true;break
        if not blocked and Rect2(Vector2.ZERO,skin.view).encloses(candidate):return at
    return Vector2.INF
