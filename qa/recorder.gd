extends RefCounted
## Bounded, local-only observer. Never receives profile data or consumes RNG.
const MAX_BYTES := 8 * 1024 * 1024
const MAX_RECORDS := 32768
const SAMPLE_SECONDS := 0.5
const FRAME_BOUNDS := [8.33,16.67,25.0,33.33,50.0,100.0,250.0,1000.0]
var enabled := false
var full := false
var lines := PackedStringArray()
var bytes_used := 0
var origin_us := 0
var last_frame_us := 0
var next_sample_us := 0
var last_mode := ""
var mode_since_us := 0
var run_number := 0
var marker := 0
var metadata: Dictionary = {}
var modes: Dictionary = {}
var waves: Dictionary = {}
var spawn_counts: Dictionary = {}
var frames := 0
var frame_sum_ms := 0.0
var frame_max_ms := 0.0
var histogram: Array[int] = []
var stopped_ms := 0.0
var last_wave := -1
var last_boss := false
var last_event := -1
var damage_by_type: Dictionary = {}
var taken_by_source: Dictionary = {}
var observer_us := 0
var simulation_us := 0
var frame_modes: Dictionary = {}
func now_ms() -> float: return (Time.get_ticks_usec()-origin_us)/1000.0
func start(game, build: Dictionary) -> void:
    enabled=true;full=false;lines.clear();bytes_used=0;run_number=0;marker=0
    modes.clear();waves.clear();spawn_counts.clear();damage_by_type.clear();taken_by_source.clear();frame_modes.clear()
    frames=0;frame_sum_ms=0;frame_max_ms=0;observer_us=0;simulation_us=0;stopped_ms=0
    histogram.assign([0,0,0,0,0,0,0,0,0])
    origin_us=Time.get_ticks_usec();last_frame_us=0;next_sample_us=origin_us
    last_mode=game.mode;mode_since_us=origin_us;last_wave=-1;last_event=-1;last_boss=false
    metadata={"schema":1,"build_sha":str(build.get("commit","unknown")),"engine":Engine.get_version_info().string,"sample_hz":2,"max_trace_bytes":MAX_BYTES,"max_records":MAX_RECORDS,"platform":"web" if OS.has_feature("web") else "native","display":DisplayServer.get_name(),"time_origin":"monotonic recorder start; no wall-clock identity","started_mid_run":game.mode not in ["menu","heroes"],"viewport":[game.get_viewport_rect().size.x,game.get_viewport_rect().size.y]}
    metadata.merge(game.qa_context())
    event(game,"recording_started")
    if not game.hero.is_empty() and game.mode not in ["menu","heroes"]: run_started(game)
func event(game, kind: String, data: Dictionary = {}) -> void:
    if not enabled:return
    var row := {"event":kind,"wall_ms":now_ms(),"active_s":game.run_time,"run":run_number,"wave":game.wave,"data":data,"session_type":metadata.get("session_type","normal_run"),"scenario_id":metadata.get("scenario_id","")}
    var line := JSON.stringify(row)
    var size := line.to_utf8_buffer().size()+1
    if lines.size()>=MAX_RECORDS or bytes_used+size>MAX_BYTES:
        full=true;stop(game,"capacity");return
    lines.append(line);bytes_used+=size
func observe_mode(game) -> void:
    if not enabled or last_mode==game.mode:return
    var now := Time.get_ticks_usec()
    modes[last_mode]=float(modes.get(last_mode,0))+(now-mode_since_us)/1000.0
    event(game,"mode",{"from":last_mode,"to":game.mode,"duration_ms":(now-mode_since_us)/1000.0})
    last_mode=game.mode;mode_since_us=now
func run_started(game) -> void:
    if not enabled:return
    observe_mode(game);run_number+=1;last_wave=-1;last_event=-1;last_boss=false
    metadata["hero_id"]=game.hero.id;metadata["appearance"]=game.hero_appearance;metadata["rng_seed"]=game.rng.seed
    event(game,"run_started",{"hero":game.hero.id,"appearance":game.hero_appearance,"seed":game.rng.seed,"rng_state":game.rng.state,"weapons":equipment(game.weapons),"passives":equipment(game.passives)})
func stop(game, reason: String="creator") -> void:
    if not enabled:return
    var now := Time.get_ticks_usec()
    modes[last_mode]=float(modes.get(last_mode,0))+(now-mode_since_us)/1000.0
    stopped_ms=now_ms();enabled=false
    metadata["stop_reason"]=reason
func mark(game) -> void:
    if not enabled:return
    marker+=1;event(game,"video_marker",{"number":marker})
static func equipment(items: Array) -> Array:
    var result: Array=[]
    for item: Dictionary in items:result.append({"id":item.id,"level":item.level,"rarity":item.rarity})
    return result
func frame(game, cost_us: int) -> void:
    if not enabled:return
    var entered := Time.get_ticks_usec()
    observe_mode(game)
    simulation_us+=cost_us
    if last_frame_us>0:
        var ms := (entered-last_frame_us)/1000.0
        frames+=1;frame_sum_ms+=ms;frame_max_ms=maxf(frame_max_ms,ms)
        var bucket := 0
        while bucket<FRAME_BOUNDS.size() and ms>FRAME_BOUNDS[bucket]:bucket+=1
        histogram[bucket]+=1
        if not frame_modes.has(game.mode):
            frame_modes[game.mode]={"count":0,"sum_ms":0.0,"max_ms":0.0,"histogram":[0,0,0,0,0,0,0,0,0]}
        var mode_frames: Dictionary=frame_modes[game.mode]
        mode_frames.count+=1;mode_frames.sum_ms+=ms;mode_frames.max_ms=maxf(mode_frames.max_ms,ms)
        mode_frames.histogram[bucket]+=1;frame_modes[game.mode]=mode_frames
    last_frame_us=entered
    if game.wave!=last_wave:
        event(game,"wave",{"from":last_wave,"to":game.wave});last_wave=game.wave
    if game.event_index!=last_event:
        event(game,"event_schedule",{"index":game.event_index});last_event=game.event_index
    if game.boss_spawned!=last_boss:
        event(game,"boss_phase",{"entered":game.boss_spawned});last_boss=game.boss_spawned
    if entered>=next_sample_us:
        sample(game);next_sample_us=entered+int(SAMPLE_SECONDS*1000000)
    observer_us+=Time.get_ticks_usec()-entered
func sample(game) -> void:
    if not enabled:return
    var types: Dictionary={}
    var nearby := 0
    var active := 0
    var portals := 0
    var normal := 0
    for enemy: Dictionary in game.enemies:
        types[enemy.kind]=int(types.get(enemy.kind,0))+1
        if game.run_time<float(enemy.born):portals+=1;continue
        active+=1
        if not game.SoloEnemyRulesScript.DATA[enemy.kind].boss and enemy.kind!="terminal":normal+=1
        if game.player_pos.distance_squared_to(enemy.pos)<=260.0*260.0:nearby+=1
    var data := {"mode":game.mode,"active_enemies":active,"normal_enemies":normal,"portals":portals,"enemy_types":types,"nearby_260u":nearby,"spawn_counts":spawn_counts.duplicate(),"kills":game.kills,"damage_dealt":game.run_metrics.get("damage",0),"hp":game.hp,"max_hp":game.max_hp,"shield":game.shield,"healing":game.run_metrics.get("healing",0),"xp":game.xp,"total_xp":game.total_xp,"level":game.level,"aura":game.aura,"flex_s":game.flex_time,"shots":game.hostile_shots.size(),"hazards":game.hazard_zones.size(),"player":[game.player_pos.x,game.player_pos.y]}
    event(game,"sample",data)
    if run_number==0 or game.mode not in ["playing","won","lost"]:return
    var key := "%d:%d" % [run_number,game.wave]
    var summary: Dictionary=waves.get(key,{"run":run_number,"wave":game.wave,"samples":0,"sum_enemies":0,"max_enemies":0,"zero_nearby_samples":0,"first_active_s":game.run_time})
    summary.samples+=1;summary.sum_enemies+=active;summary.max_enemies=maxi(summary.max_enemies,active)
    if nearby==0:summary.zero_nearby_samples+=1
    summary["last_active_s"]=game.run_time;summary["last_state"]=data
    waves[key]=summary
func summary() -> Dictionary:
    var durations := modes.duplicate()
    if enabled:durations[last_mode]=float(durations.get(last_mode,0))+(Time.get_ticks_usec()-mode_since_us)/1000.0
    return {"session_type":metadata.get("session_type","normal_run"),"scenario_id":metadata.get("scenario_id",""),"sim_start_time":metadata.get("sim_start_time",0.0),"scenario_config":metadata.get("scenario_config",{}),"elapsed_ms":now_ms() if enabled else stopped_ms,"recording":enabled,"truncated":full,"records":lines.size(),"trace_bytes":bytes_used,"runs":run_number,"mode_wall_ms":durations,"waves":waves.values(),"damage_dealt_by_enemy_type":damage_by_type,"damage_taken_by_source":taken_by_source,"frame_intervals":{"meaning":"monotonic process-callback intervals, includes observer and rendering/scheduling; not GPU render time or physical-device certification","count":frames,"mean_ms":frame_sum_ms/maxi(1,frames),"max_ms":frame_max_ms,"bucket_upper_ms":FRAME_BOUNDS,"counts":histogram},"frame_intervals_by_mode":frame_modes,"observer_frame_us":observer_us,"game_process_us":simulation_us}
func export_zip(path: String, guide: String) -> Error:
    if lines.is_empty():return ERR_UNAVAILABLE
    var zip := ZIPPacker.new()
    var error := zip.open(path)
    if error!=OK:return error
    var files := {"session.json":JSON.stringify(metadata,"  "),"session-trace.jsonl":"\n".join(lines)+"\n","session-summary.json":JSON.stringify(summary(),"  "),"README.md":guide}
    for name: String in files:
        error=zip.start_file(name)
        if error==OK:error=zip.write_file(str(files[name]).to_utf8_buffer())
        if error!=OK:zip.close();return error
        error=zip.close_file()
        if error!=OK:zip.close();return error
    return zip.close()
