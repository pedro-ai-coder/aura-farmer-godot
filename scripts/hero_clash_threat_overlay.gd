extends Control
## Presentation only: 20 Hz actor checks, live danger strokes, cached HUD geometry.
## No input ownership, camera adjustment, simulation writes or gameplay RNG.
## Re-expose only hostile boundary segments actually covered by passive HUD.
var hud
var game
var decoration: Array[Array]=[]
var essential: Array[Array]=[]
var dark_text: StyleBox
var light_text: StyleBox
var regions: Array[Rect2]=[]
var faded: Array[bool]=[]
var traces: Array[Dictionary]=[]
var cue: Label
var cue_direction:=Vector2.ZERO
var next_sample: int=0
var sampled_geometry: int=-1
var sampling_count: int=0
var actor_hits: int=0
var clipped_boss: bool=false

func install(owner_hud) -> void:
    hud=owner_hud;game=hud.game
    mouse_filter=Control.MOUSE_FILTER_IGNORE;z_index=1
    cue=hud.skin.label(self);hud.text_style(cue,"hud_secondary",18,hud.PAPER)
    cue.autowrap_mode=TextServer.AUTOWRAP_OFF;cue.clip_text=true
    cue.add_theme_stylebox_override("normal",hud.skin.Style.box(hud.INK,hud.GOLD,1,0))
    cue.add_theme_constant_override("margin_left",22)
    cue.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;cue.hide()
    decoration.assign([
        [hud.skin.player_plate,hud.shield_mark,hud.skin.shield_track,hud.skin.shield_fill.face,hud.skin.hp_fill.face],
        [hud.skin.wave_frame], [hud.skin.boss_plate,hud.boss_portrait,hud.boss_fill.face,hud.boss_phase_backdrop],
        [], [hud.skin.xp_frame,hud.skin.xp_track,hud.skin.xp_fill.face,hud.max_level_plate], [hud.strip], [hud.ability_plate]])
    essential.assign([[hud.skin.hp,hud.skin.shield_label],[hud.skin.wave,hud.wave_clock],[hud.skin.boss_text,hud.boss_hp,hud.skin.warning],[],[hud.skin.xp],[],[hud.skin.flex_title,hud.skin.flex_status,hud.skin.flex_caption]])
    dark_text=hud.skin.Style.box(Color(hud.INK,0.88),Color.TRANSPARENT,0,0)
    light_text=hud.skin.Style.box(Color(hud.PAPER,0.88),Color.TRANSPARENT,0,0)
    for parts in hud.skin.equipment:
        for id in ["frame","icon","tab","rarity"]:decoration[5].append(parts[id])
        essential[5].append(parts["level"])
    for i in range(decoration.size()):faded.append(false)

func sample(force: bool=false) -> void:
    if game.mode!="playing":
        if visible:
            hide();cue.hide();traces.clear();restore();queue_redraw()
        return
    show()
    var now: int=Time.get_ticks_msec()
    var transform: Transform2D=hud.skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
    if not force and now<next_sample and sampled_geometry==hud.geometry_count:
        update_traces(transform) # Live camera/tracking; never a 20 Hz danger boundary.
        return
    next_sample=now+50;sampling_count+=1
    if sampled_geometry!=hud.geometry_count:
        sampled_geometry=hud.geometry_count;regions.clear()
        for id in hud.modules:
            var region: Rect2=hud.modules[id].get_rect()
            if id=="BottomRightFlex":region=region.merge(Rect2(hud.modules[id].position+hud.ability_plate.position,hud.ability_plate.size))
            regions.append(region)
    var had_cue: bool=cue.visible
    faded.fill(false);actor_hits=0;clipped_boss=false;cue.hide()
    var safe:=Rect2(Vector2.ZERO,hud.skin.view)
    var cue_bounds:=Rect2();var cue_name: String=""
    for enemy: Dictionary in game.enemies:
        if game.run_time<float(enemy.get("born",0)) or float(enemy["hp"])<=0:continue
        var bounds:=enemy_bounds(enemy,transform)
        if not bounds.intersects(safe.grow(32)):continue
        var covered:=mark_regions(bounds)
        if covered:actor_hits+=1
        if game.SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"] and cue_name.is_empty() and (covered or not safe.encloses(bounds)):
            cue_bounds=bounds;cue_name=str(game.SoloEnemyRulesScript.DATA[enemy["kind"]]["name"]).to_upper()
            clipped_boss=not safe.encloses(bounds)
    update_traces(transform)
    if not cue_name.is_empty():place_cue(cue_bounds,cue_name+(" · EDGE" if clipped_boss else ""))
    for i in range(decoration.size()):
        for node: CanvasItem in decoration[i]:
            var alpha: float=0.18 if faded[i] else 1.0
            if not is_equal_approx(node.self_modulate.a,alpha):node.self_modulate.a=alpha
        for label: Label in essential[i]:
            var needs_contrast: bool=faded[i] and not label.text.is_empty()
            if needs_contrast and not label.has_theme_stylebox_override("normal"):label.add_theme_stylebox_override("normal",light_text if i in [1,4] else dark_text)
            elif not needs_contrast and label.has_theme_stylebox_override("normal"):label.remove_theme_stylebox_override("normal")
    # The portrait crop shader intentionally ignores vertex modulation. Hide
    # decorative identity here instead of editing its hash-pinned source.
    hud.skin.portrait.visible=not faded[0];hud.skin.hero_name.visible=not faded[0]
    hud.skin.aura_arc.set_occluded(faded[6])
    if had_cue or cue.visible:queue_redraw()

func update_traces(transform: Transform2D) -> void:
    var had_traces: bool=not traces.is_empty()
    traces.clear()
    for enemy: Dictionary in game.enemies:
        if float(enemy["hp"])<=0 or game.run_time<float(enemy.get("born",0)):continue
        if enemy["phase"] in ["warning","charge-warning"]:
            var start: Vector2=enemy["pos"]
            add_path(PackedVector2Array([transform*start,transform*(start+Vector2(enemy["locked_direction"])*420)]),Color(1,0.58,0.24,0.9))
    for zone: Dictionary in game.hazard_zones:
        var points:=PackedVector2Array()
        var center: Vector2=zone["pos"];var heading: float=Vector2(zone["dir"]).angle()
        var warning: bool=game.run_time<float(zone["at"])
        var radius: float=zone["radius"]
        var start:=0.0;var end:=TAU;var steps:=48
        if zone["shape"] in ["line","tether"]:
            points.append(transform*center)
            points.append(transform*(game.player_pos if zone["shape"]=="tether" else center+Vector2(zone["dir"])*radius))
        else:
            if zone["shape"]=="ring":
                radius=80.0 if warning else 80.0+200.0*clampf((game.run_time-float(zone["at"]))/1.5,0,1)
                start=heading+deg_to_rad(35);end=heading+TAU-deg_to_rad(35)
            elif zone["shape"]=="cone":start=heading-PI/3;end=heading+PI/3;steps=32
            for i in range(steps+1):points.append(transform*(center+Vector2.from_angle(lerpf(start,end,float(i)/steps))*radius))
        add_path(points,Color(1,0.61,0.22,0.95) if warning else Color(0.98,0.29,0.31,0.95))
    if had_traces or not traces.is_empty():queue_redraw()

func restore() -> void:
    for group in decoration:
        for node: CanvasItem in group:node.self_modulate.a=1.0
    for group in essential:
        for label: Label in group:label.remove_theme_stylebox_override("normal")
    hud.skin.portrait.visible=game.mode=="playing";hud.skin.hero_name.visible=game.mode=="playing"
    hud.skin.aura_arc.set_occluded(false)

func enemy_bounds(enemy: Dictionary, transform: Transform2D) -> Rect2:
    # Same trimmed frame, pivot, pose flip and hurt stretch as draw_enemy().
    var kind: String=game.art.enemy_visual_kind(enemy,game.run_time)
    if kind=="terminal":
        var extent: float=float(enemy["radius"])*3.1
        return transform*Rect2(Vector2(enemy["pos"])-Vector2(extent*0.5,extent),Vector2.ONE*extent)
    var frame: int=game.art.enemy_pose_frame(enemy,game.run_time,-1)
    var image: Texture2D=game.art.enemy_frame(kind,frame)
    if image==null:return Rect2()
    var data: Dictionary=game.art.enemy_frame_cache[kind+":"+str(frame)]
    var scale: float=float(enemy["radius"])*(2.6 if game.SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"] else 3.1)/maxf(1,float(data["height"]))
    var left: bool=cos(float(enemy.get("angle",0)))< -0.05
    if enemy["phase"] in ["warning","charge-warning","charging"]:left=Vector2(enemy["locked_direction"]).x< -0.05
    var attack: Dictionary=enemy.get("attack_pose",{})
    if not attack.is_empty() and game.run_time<float(attack["end"]):left=cos(float(attack["angle"]))< -0.05
    var flash: float=0 if game.profile["settings"]["reducedMotion"] else clampf(1-(game.run_time-float(enemy.get("hurt_at",-100)))/0.12,0,1)
    return transform*Transform2D(0,Vector2(-1 if left else 1,1)*Vector2(1+flash*0.05,1-flash*0.05)*scale,0,enemy["pos"])*Rect2(-Vector2(data["pivot"]),image.get_size())

func mark_regions(bounds: Rect2) -> bool:
    var hit:=false;var index:=0
    for id in hud.modules:
        if hud.modules[id].visible and bounds.intersects(regions[index]):faded[index]=true;hit=true
        index+=1
    return hit

func add_path(points: PackedVector2Array, color: Color) -> void:
    # Clip real boundary segments to reserved HUD rectangles, not their AABBs.
    if points.size()<2:return
    var bounds:=Rect2(points[0],Vector2.ZERO)
    for point in points:bounds=bounds.expand(point)
    var index:=0
    for id in hud.modules:
        if hud.modules[id].visible and bounds.grow(4).intersects(regions[index]):
            for i in range(points.size()-1):
                var segment:=clip_segment(points[i],points[i+1],regions[index])
                if not segment.is_empty():
                    traces.append({"points":segment,"color":color});faded[index]=true
        index+=1

static func clip_segment(a: Vector2,b: Vector2,rect: Rect2) -> PackedVector2Array:
    var delta:=b-a;var low:=0.0;var high:=1.0
    for axis in range(2):
        if absf(delta[axis])<0.0001:
            if a[axis]<rect.position[axis] or a[axis]>rect.end[axis]:return PackedVector2Array()
        else:
            var first: float=(rect.position[axis]-a[axis])/delta[axis]
            var last: float=(rect.end[axis]-a[axis])/delta[axis]
            low=maxf(low,minf(first,last));high=minf(high,maxf(first,last))
            if low>high:return PackedVector2Array()
    return PackedVector2Array([a+delta*low,a+delta*high])

func place_cue(bounds: Rect2, text: String) -> void:
    var extent:=Vector2(210,30);var safe:=Rect2(Vector2(8,8),hud.skin.view-Vector2(16,16))
    var hero: Vector2=(hud.skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas())*game.player_pos
    for at in [bounds.position+Vector2(bounds.size.x+12,0),bounds.position+Vector2(0,bounds.size.y+12),bounds.position-Vector2(222,0),Vector2(8,hud.modules["TopLeftHeroStatus"].get_rect().end.y+12),Vector2(hud.skin.view.x*0.5-105,hud.boss_rect.end.y+12)]:
        var candidate:=Rect2(Vector2(clampf(at.x,safe.position.x,safe.end.x-extent.x),clampf(at.y,safe.position.y,safe.end.y-extent.y)),extent)
        var blocked: bool=candidate.intersects(Rect2(hero-Vector2(40,65),Vector2(80,85)))
        for region in hud.reserved:
            if candidate.intersects(region.grow(4)):blocked=true;break
        if not blocked:
            hud.place(cue,Rect2(candidate.position+Vector2(22,0),candidate.size-Vector2(22,0)));cue.text=text
            cue.add_theme_font_size_override("font_size",18);hud.skin.fit_line(cue,16);cue.show()
            cue_direction=(bounds.get_center()-candidate.get_center()).normalized();return

func _draw() -> void:
    for trace in traces:
        draw_polyline(trace["points"],hud.INK,7,true)
        draw_polyline(trace["points"],trace["color"],3,true)
    if cue!=null and cue.visible:
        var center: Vector2=cue.position+Vector2(-10,15)
        var normal:=cue_direction.orthogonal()
        draw_colored_polygon(PackedVector2Array([center+cue_direction*7,center-cue_direction*5+normal*5,center-cue_direction*5-normal*5]),hud.GOLD)
