extends Control
## Presentation only: stable contextual boss cues; live hostile boundaries.
## No gameplay, camera, HUD opacity, input ownership or profile writes.
enum Visibility { CLEAR, OCCLUDED, OFFSCREEN }
const ENTER_VISIBLE: float=0.60
const EXIT_VISIBLE: float=0.78
const OFFSCREEN_ENTER: float=0.12
const OFFSCREEN_EXIT: float=0.32
const ENTER_MS: int=180
const EXIT_MS: int=300
const SWITCH_MS: int=200
const HANDOFF_MS: int=160
const CUE_SIZE:=Vector2(210,30)

class BossVisibility:
    var id: int
    var kind: String
    var name: String
    var rank: int
    var phase: int=Visibility.CLEAR
    var pending: int=Visibility.CLEAR
    var pending_since: int=0
    var seen: int=0
    var bounds:=Rect2()
    var viewport_fraction: float=1.0
    var readable_fraction: float=1.0
    var transitions: int=0
    func observe(viewport: float,readable: float,now_ms: int) -> void:
        viewport_fraction=clampf(viewport,0,1);readable_fraction=clampf(readable,0,1)
        var wanted: int=Visibility.CLEAR
        if viewport_fraction<=(OFFSCREEN_EXIT if phase==Visibility.OFFSCREEN else OFFSCREEN_ENTER):wanted=Visibility.OFFSCREEN
        elif readable_fraction<(EXIT_VISIBLE if phase!=Visibility.CLEAR else ENTER_VISIBLE):wanted=Visibility.OCCLUDED
        if wanted==phase:
            pending=phase;pending_since=now_ms;return
        if pending!=wanted:
            pending=wanted;pending_since=now_ms;return
        var wait_ms: int=EXIT_MS if wanted==Visibility.CLEAR else ENTER_MS if phase==Visibility.CLEAR else SWITCH_MS
        if now_ms-pending_since>=wait_ms:
            phase=wanted;transitions+=1

var hud
var game
var regions: Array[Rect2]=[]
var traces: Array[Dictionary]=[]
var cue: Label
var cue_direction:=Vector2.ZERO
var next_sample: int=0
var sampled_geometry: int=-1
var sampling_count: int=0
var actor_hits: int=0
var clipped_boss: bool=false # Diagnostic only, never player copy.
var states: Dictionary={}
var current_id: int=-1
var current_phase: int=Visibility.CLEAR
var layout_updates: int=0
var _last_clock: int=-1
var _last_run_time: float=-1.0
var _anchor:=Rect2()
var _anchor_target:=Vector2.INF
var _retired: Array[int]=[]
var _handoff_until: int=0

func install(owner_hud) -> void:
    hud=owner_hud;game=hud.game
    mouse_filter=Control.MOUSE_FILTER_IGNORE;z_index=1
    cue=hud.skin.label(self);hud.text_style(cue,"hud_secondary",18,hud.PAPER)
    cue.autowrap_mode=TextServer.AUTOWRAP_OFF;cue.clip_text=true
    var cue_box: StyleBoxFlat=hud.skin.Style.box(hud.INK,hud.GOLD,1,0)
    cue_box.set_content_margin_all(0);cue_box.set_border_width_all(1)
    cue.add_theme_stylebox_override("normal",cue_box)
    cue.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;cue.hide()

func reset() -> void:
    states.clear();current_id=-1;current_phase=Visibility.CLEAR
    _anchor=Rect2();_anchor_target=Vector2.INF;next_sample=0;_last_clock=-1;_last_run_time=-1
    actor_hits=0;clipped_boss=false;_handoff_until=0;cue.hide();traces.clear();hide();queue_redraw()

func sample(force: bool=false) -> void:
    _sample(Time.get_ticks_msec(),force)

func sample_at(now_ms: int) -> void:
    # Deterministic fixture clock; production always uses sample().
    _sample(now_ms,true)

func _sample(now_ms: int,force: bool) -> void:
    if game.mode!="playing":
        if visible or not states.is_empty():reset()
        return
    if game.run_time<_last_run_time:reset()
    show();_last_run_time=game.run_time
    now_ms=maxi(now_ms,_last_clock);_last_clock=now_ms
    var transform: Transform2D=hud.skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
    if not force and now_ms<next_sample and sampled_geometry==hud.geometry_count:
        update_traces(transform);return
    next_sample=now_ms+50;sampling_count+=1
    var geometry_changed: bool=sampled_geometry!=hud.geometry_count
    if geometry_changed:
        sampled_geometry=hud.geometry_count;regions.clear()
        for id in hud.modules:
            var region: Rect2=hud.modules[id].get_rect()
            if id=="BottomRightFlex":region=region.merge(Rect2(hud.modules[id].position+hud.ability_plate.position,hud.ability_plate.size))
            regions.append(region)
    actor_hits=0;clipped_boss=false
    var safe:=Rect2(Vector2.ZERO,hud.skin.view)
    for enemy: Dictionary in game.enemies:
        # Ordinary actors do not need contextual nameplates. Their live attack
        # boundaries still use update_traces(), including while cues are hidden.
        if not game.SoloEnemyRulesScript.DATA[enemy["kind"]]["boss"]:continue
        if game.run_time<float(enemy.get("born",0)) or float(enemy["hp"])<=0:continue
        var id: int=int(enemy["id"])
        if not states.has(id) or states[id].kind!=enemy["kind"]:
            var created:=BossVisibility.new();created.id=id;created.kind=enemy["kind"]
            created.name=str(game.SoloEnemyRulesScript.DATA[enemy["kind"]]["name"]).to_upper()
            created.rank=0 if enemy["kind"]=="boss" else 1;states[id]=created
        var state: BossVisibility=states[id];state.seen=sampling_count
        state.bounds=enemy_bounds(enemy,transform)
        var area: float=maxf(1,state.bounds.get_area())
        var visible_bounds: Rect2=state.bounds.intersection(safe)
        var covered: float=hud_covered_area(visible_bounds)
        if covered>0:actor_hits+=1
        state.observe(visible_bounds.get_area()/area,maxf(0,visible_bounds.get_area()-covered)/area,now_ms)
    _retired.clear()
    for id in states:
        if states[id].seen!=sampling_count:_retired.append(id)
    for id in _retired:states.erase(id)
    update_traces(transform)
    var selected: BossVisibility=choose_threat()
    if current_id>=0 and (selected==null or selected.id!=current_id):
        if selected==null or selected.kind!="boss":_handoff_until=now_ms+HANDOFF_MS
    # When several actors return on slightly different frames, do not flash a
    # lower-priority name for a few milliseconds. Final-boss escalation is direct.
    if selected!=null and selected.kind!="boss" and now_ms<_handoff_until:selected=null
    if selected==null:
        if cue.visible:cue.hide();queue_redraw()
        current_id=-1;current_phase=Visibility.CLEAR;return
    var selection_changed: bool=current_id!=selected.id or current_phase!=selected.phase
    current_id=selected.id;current_phase=selected.phase;clipped_boss=selected.viewport_fraction<0.999
    var target: Vector2=selected.bounds.get_center()
    # Keep one anchor through small boundary movements. Only real obstruction,
    # changed viewport/state/owner or substantial travel needs placement again.
    if selection_changed or geometry_changed or _anchor.size==Vector2.ZERO or not is_free(_anchor) or target.distance_squared_to(_anchor_target)>64.0*64.0:
        place_cue(selected.bounds,selected.name,selected.phase==Visibility.OFFSCREEN)
        _anchor_target=target
    if _anchor.size!=Vector2.ZERO:
        cue_direction=(target-(hud.skin.view*0.5 if selected.phase==Visibility.OFFSCREEN else _anchor.get_center())).normalized()
        cue.show();queue_redraw()

func choose_threat() -> BossVisibility:
    var chosen: BossVisibility=states.get(current_id)
    if chosen!=null and chosen.phase==Visibility.CLEAR:chosen=null
    var retain: bool=chosen!=null
    for id in states:
        var candidate: BossVisibility=states[id]
        if candidate.phase==Visibility.CLEAR:continue
        # Preserve an owned cue's exit hysteresis, but never acquire a new
        # identity which is already recovering sufficient visibility.
        if candidate.id!=current_id and candidate.pending==Visibility.CLEAR:continue
        if chosen==null or candidate.rank<chosen.rank or (not retain and candidate.rank==chosen.rank and candidate.id<chosen.id):chosen=candidate
    return chosen

func hud_covered_area(bounds: Rect2) -> float:
    if not bounds.has_area():return 0.0
    # Permanent HUD modules are non-overlapping (covered by the layout suite).
    # Area thresholds ignore incidental corner/AABB intersections.
    var covered:=0.0;var index:=0
    for id in hud.modules:
        if hud.modules[id].visible:covered+=bounds.intersection(regions[index]).get_area()
        index+=1
    return minf(bounds.get_area(),covered)

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
                    traces.append({"points":segment,"color":color})
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

func is_free(rect: Rect2) -> bool:
    if not Rect2(Vector2(8,8),hud.skin.view-Vector2(16,16)).encloses(rect):return false
    var hero: Vector2=(hud.skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas())*game.player_pos
    if rect.intersects(Rect2(hero-Vector2(40,65),Vector2(80,85))):return false
    for region in hud.reserved:
        if rect.intersects(region.grow(4)):return false
    if game.legendary_button.visible and rect.intersects(Rect2(game.legendary_button.get_global_rect().position-hud.skin.shift,game.legendary_button.size).grow(4)):return false
    if hud.skin.joystick_ring.visible and rect.intersects(Rect2(hud.skin.joystick_ring.get_global_rect().position-hud.skin.shift,hud.skin.joystick_ring.size).grow(4)):return false
    return true

func place_cue(bounds: Rect2,text: String,offscreen: bool=false) -> void:
    var extent: Vector2=CUE_SIZE
    var safe:=Rect2(Vector2(8,8),hud.skin.view-Vector2(16,16))
    var target: Vector2=bounds.get_center();var center: Vector2=hud.skin.view*0.5
    var direction: Vector2=(target-center).normalized()
    var reach: Vector2=(safe.size-extent)*0.5
    var along: float=minf(reach.x/maxf(0.001,absf(direction.x)),reach.y/maxf(0.001,absf(direction.y)))
    var edge: Vector2=center+direction*along-extent*0.5
    var options: Array[Vector2]=[]
    if offscreen:options.append(edge)
    options.append_array([bounds.position+Vector2(bounds.size.x+12,0),bounds.position+Vector2(0,bounds.size.y+12),bounds.position-Vector2(222,0),Vector2(8,hud.modules["TopLeftHeroStatus"].get_rect().end.y+12),Vector2(hud.skin.view.x*0.5-105,hud.boss_rect.end.y+12),Vector2(safe.end.x-extent.x,hud.skin.view.y*0.5),Vector2(8,hud.skin.view.y*0.5)])
    _anchor=Rect2()
    for at in options:
        var candidate:=Rect2(Vector2(clampf(at.x,safe.position.x,safe.end.x-extent.x),clampf(at.y,safe.position.y,safe.end.y-extent.y)),extent)
        if not is_free(candidate):continue
        _anchor=candidate;layout_updates+=1
        hud.place(cue,Rect2(candidate.position+Vector2(22,0),candidate.size-Vector2(22,0)))
        if cue.text!=text:
            cue.text=text;cue.add_theme_font_size_override("font_size",18);hud.skin.fit_line(cue,16)
        return
    cue.hide()

func _draw() -> void:
    for trace in traces:
        draw_polyline(trace["points"],hud.INK,7,true)
        draw_polyline(trace["points"],trace["color"],3,true)
    if cue!=null and cue.visible:
        var center: Vector2=cue.position+Vector2(-10,15)
        var normal:=cue_direction.orthogonal()
        draw_colored_polygon(PackedVector2Array([center+cue_direction*7,center-cue_direction*5+normal*5,center-cue_direction*5-normal*5]),hud.GOLD)
