extends RefCounted
## Opt-in development instrumentation. No gameplay state, RNG, timers or per-frame logs.
## Packed rolling samples; the ordinary Web export never installs this recorder.
const CAPACITY:=3600
const PHASES: Array[StringName]=[&"simulation",&"enemies",&"enemy_membership",&"navigation",&"weapons",&"projectiles",&"hazards",&"passives",&"player",&"camera",&"hud",&"text",&"presentation",&"platform",&"draw",&"actors"]
const COLUMNS: Array[String]=["delta_ms","substeps","process_us","enemies","player_projectiles","hostile_projectiles","areas","hazards","effects","pickups","travel_u","player_x","player_y","camera_x","camera_y","render_interval_ms","render_cpu_ms","render_gpu_ms","render_setup_ms","draw_calls","input_to_move_ms","input_to_render_ms","new_animation_textures","hud_layouts","frame_start_us","particle_nodes"]
var owner: WeakRef
var columns: Array[PackedFloat64Array]=[]
var phase_indices: Dictionary={}
var index:=0
var count:=0
var total:=0
var opened:=false
var frame_start:=0
var render_stamp:=0
var input_stamp:=0
var responded_stamp:=0
var requested_axis:=Vector2.ZERO
var rendered:=false
var detailed:=false
var was_playing:=false
var label: String="manual"
var input_events:=0
var engine_report_sent:=false
var metadata: Dictionary={}
func _init(game, tag: String="manual", per_actor_detail: bool=false) -> void:
    owner=weakref(game);label=tag;detailed=per_actor_detail
    rendered=DisplayServer.get_name()!="headless"
    for name in COLUMNS:
        var values:=PackedFloat64Array();values.resize(CAPACITY);columns.append(values)
    for name in PHASES:
        phase_indices[name]=columns.size()
        var values:=PackedFloat64Array();values.resize(CAPACITY);columns.append(values)
    if rendered:
        RenderingServer.viewport_set_measure_render_time(game.get_viewport().get_viewport_rid(),true)
        RenderingServer.frame_post_draw.connect(_post_draw)
    metadata={"reported_adapter":RenderingServer.call("get_video_adapter_name") if rendered and RenderingServer.has_method("get_video_adapter_name") else null,"software_renderer_requested":OS.get_environment("LIBGL_ALWAYS_SOFTWARE"),"engine":Engine.get_version_info()["string"],"display_server":DisplayServer.get_name(),"os":OS.get_name(),"cpu":OS.get_processor_name() if FileAccess.file_exists("/proc/cpuinfo") or OS.get_name()!="Linux" else "unavailable in executor sandbox","rendered_frames_observable":rendered,"label":label,"timing_source":"engine frame_post_draw completion; not physical display scanout" if rendered else "headless CPU only; no rendering FPS","input_timing_origin":"engine receipt of owner drag/release, not hardware/OS end-to-end latency","gpu_source":"RenderingServer viewport timer when nonzero; null otherwise"}
func close() -> void:
    if opened:_commit(false)
    if RenderingServer.frame_post_draw.is_connected(_post_draw):RenderingServer.frame_post_draw.disconnect(_post_draw)
func begin_frame(delta: float) -> void:
    var game=owner.get_ref()
    if game==null:return
    if opened and not rendered:_commit(false)
    if game.mode!="playing":
        opened=false;render_stamp=0;input_stamp=0;responded_stamp=0
        if was_playing and OS.has_feature("web"):_send_web_report()
        was_playing=false
        return
    if not was_playing:
        render_stamp=0
        if OS.has_feature("web"):JavaScriptBridge.eval("if(window.__auraPerformance)window.__auraPerformance.setMode('playing')",true)
    was_playing=true;opened=true;frame_start=Time.get_ticks_usec()
    for values in columns:values[index]=0.0
    columns[0][index]=delta*1000.0
    columns[24][index]=frame_start
    columns[20][index]=-1.0;columns[21][index]=-1.0
    engine_report_sent=false
func add(phase: StringName, microseconds: int) -> void:
    if opened:columns[int(phase_indices[phase])][index]+=microseconds
func substep() -> void:
    if opened:columns[1][index]+=1.0
func process_finished() -> void:
    if opened:columns[2][index]=Time.get_ticks_usec()-frame_start
func input_received(axis: Vector2) -> void:
    if not opened and not was_playing:return
    # Track the oldest unanswered owner event, rather than masking a stall with
    # a newer event. UI touches and unrelated pointers never call this method.
    if input_stamp==0:input_stamp=Time.get_ticks_usec()
    requested_axis=axis
    input_events+=1
func movement_applied(before: Vector2, after: Vector2) -> void:
    if not opened:return
    columns[10][index]+=before.distance_to(after)
    var answered: bool=(not requested_axis.is_zero_approx() and (after-before).dot(requested_axis)>0.0000001) or (requested_axis.is_zero_approx() and before.is_equal_approx(after))
    if input_stamp>0 and responded_stamp==0 and answered:
        responded_stamp=Time.get_ticks_usec()
        columns[20][index]=(responded_stamp-input_stamp)/1000.0
func _post_draw() -> void:
    if opened:_commit(true)
func _commit(actual_render: bool) -> void:
    var game=owner.get_ref()
    if game==null:opened=false;return
    var now:=Time.get_ticks_usec()
    columns[3][index]=game.enemies.size();columns[4][index]=game.player_shots.size();columns[5][index]=game.hostile_shots.size()
    columns[6][index]=game.weapon_areas.size();columns[7][index]=game.hazard_zones.size()
    columns[8][index]=game.attack_visuals.size()+game.combat_feedback.size()+game.defeated_visuals.size()+game.pickup_feedback.size()
    columns[9][index]=game.pickups.size()
    columns[11][index]=game.player_pos.x;columns[12][index]=game.player_pos.y
    columns[13][index]=game.camera.position.x;columns[14][index]=game.camera.position.y
    columns[23][index]=game.clean_cut_skin.layout_count
    # Current effects are immediate bounded draws; no particle nodes exist.
    columns[25][index]=0
    if actual_render:
        columns[15][index]=(now-render_stamp)/1000.0 if render_stamp>0 else 0.0;render_stamp=now
        var viewport: RID=game.get_viewport().get_viewport_rid()
        columns[16][index]=RenderingServer.viewport_get_measured_render_time_cpu(viewport)
        columns[17][index]=RenderingServer.viewport_get_measured_render_time_gpu(viewport)
        columns[18][index]=RenderingServer.get_frame_setup_time_cpu()
        columns[19][index]=game.get_viewport().get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE,Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)
        if input_stamp>0 and responded_stamp>0:
            columns[21][index]=(now-input_stamp)/1000.0;input_stamp=0;responded_stamp=0
    elif responded_stamp>0:input_stamp=0;responded_stamp=0
    count=mini(count+1,CAPACITY);total+=1;index=(index+1)%CAPACITY;opened=false
func animation_created(number: int) -> void:
    if opened:columns[22][index]+=number
static func distribution(values: PackedFloat64Array) -> Dictionary:
    if values.is_empty():return {"samples":0,"median":null,"p95":null,"p99":null,"max":null,"mean":null}
    var sorted:=values.duplicate();sorted.sort();var n:=sorted.size();var sum:=0.0
    for value in sorted:sum+=value
    return {"samples":n,"median":(sorted[(n-1)/2]+sorted[n/2])*0.5,"p95":sorted[ceili(n*0.95)-1],"p99":sorted[ceili(n*0.99)-1],"max":sorted[n-1],"mean":sum/n}
func series(column: int, positive: bool=false) -> PackedFloat64Array:
    var result:=PackedFloat64Array()
    for i in range(count):
        var value: float=columns[column][(index-count+i+CAPACITY)%CAPACITY]
        if not positive or value>0.0:result.append(value)
    return result
func report(include_samples: bool=true) -> Dictionary:
    var game=owner.get_ref();var summary: Dictionary={}
    for i in range(COLUMNS.size()):
        var values:=series(i,i in [15,16,17,18,19])
        if i in [20,21]:
            var observed:=PackedFloat64Array()
            for value in values:
                if value>=0.0:observed.append(value)
            values=observed
        summary[COLUMNS[i]]=distribution(values)
    for name in PHASES:summary[str(name)+"_us"]=distribution(series(phase_indices[name]))
    var frames:=series(15,true);var time:=0.0;var over25:=0;var over33:=0;var over50:=0
    for delta in frames:
        time+=delta
        if delta>25:over25+=1
        if delta>33.334:over33+=1
        if delta>50:over50+=1
    var environment: Dictionary=metadata.duplicate()
    environment["timing_detail"]="per-actor navigation/membership" if detailed else "phase totals; per-actor timers disabled"
    if not detailed:
        for name in ["navigation_us","enemy_membership_us"]:summary[name]=distribution(PackedFloat64Array())
    if game!=null:
        environment["window_pixels"]=[game.get_window().size.x,game.get_window().size.y]
        var extent: Vector2i=game.get_viewport().get_texture().get_size() if rendered else Vector2i.ZERO
        environment["viewport_texture_reported_pixels"]=[extent.x,extent.y] if rendered else null
        # One paused/end-of-scenario readback, never in the sampled hot path.
        # Window size, reported texture size and actual readback can differ.
        var image: Image=game.get_viewport().get_texture().get_image() if rendered else null
        environment["framebuffer_readback_pixels"]=[image.get_width(),image.get_height()] if image!=null else null
        environment["logical_view"]=[game.presentation.view.x,game.presentation.view.y]
        environment["browser_metrics"]=game.web_metrics.duplicate(true)
        environment["frame_cap"]=Engine.max_fps
        environment["seed"]=451+17*game.hero_index
        environment["mode_at_export"]=game.mode
    var result: Dictionary={"environment":environment,"rolling_capacity":CAPACITY,"sample_count":count,"total_frames_seen":total,"input_events":input_events,"delivered_render_fps":frames.size()*1000.0/time if rendered and time>0 else null,"long_frames":{"over_25ms":over25,"over_33_334ms":over33,"over_50ms":over50,"render_intervals":frames.size()},"metrics":summary}
    if include_samples:
        var raw: Dictionary={}
        for i in range(COLUMNS.size()):raw[COLUMNS[i]]=Array(series(i))
        for name in PHASES:raw[str(name)+"_us"]=Array(series(phase_indices[name]))
        result["samples"]=raw
    return result
func _send_web_report() -> void:
    if engine_report_sent:return
    engine_report_sent=true
    var payload:=JSON.stringify(report())
    JavaScriptBridge.eval("if(window.__auraPerformance){window.__auraPerformance.setMode('paused');window.__auraPerformance.engineReport("+payload+");}",true)
