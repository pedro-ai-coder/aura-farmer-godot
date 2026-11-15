extends Node
## Bounded read-only presentation. No gameplay RNG, timers or external assets.
const RATE:=22050
const VOICES:=8
const FIRE:={"no-cap":"swish","ratio-blaster":"zap","brainrot-feed":"heavy","keyboard-warrior":"key","ban-hammer":"heavy","touch-grass":"swish","cope-shield":"metal","chad-hands":"punch","personal-space":"pulse"}
const PROFILES:={"swish":[0.09,350.0,110.0,0.7],"zap":[0.11,930.0,180.0,0.1],"key":[0.045,1500.0,440.0,0.75],"heavy":[0.17,135.0,48.0,0.6],"metal":[0.095,1100.0,640.0,0.18],"punch":[0.07,240.0,65.0,0.65],"pulse":[0.13,340.0,100.0,0.15],"hurt":[0.15,290.0,105.0,0.4],"flex":[0.20,270.0,850.0,0.08],"warning":[0.12,780.0,1000.0,0.02],"pickup":[0.045,1250.0,1760.0,0.0]}
static var clips: Dictionary={}
static var clip_users:=0
var voices: Array[AudioStreamPlayer]=[]
var priorities: Array[int]=[]
var stamps: Array[int]=[]
var last: Dictionary={}
var warnings: Dictionary={}
var suspended:=true
var serial:=0
var accepted: Dictionary={}
## Non-interactive contract tests do not need mixer voices. Dedicated audio
## tests explicitly enable the real mixer, and native/Web builds enable it.
var playback_enabled:=DisplayServer.get_name()!="headless"
func _ready() -> void:
    clip_users+=1
    if not playback_enabled:return
    if clips.is_empty():
        for kind in PROFILES:clips[kind]=make_clip(PROFILES[kind])
    for i in range(VOICES):
        var voice:=AudioStreamPlayer.new();voice.volume_db=-22.0;add_child(voice)
        voices.append(voice);priorities.append(0);stamps.append(0)
func _exit_tree() -> void:
    for voice in voices:
        if is_instance_valid(voice):voice.stop()
    clip_users=maxi(0,clip_users-1)
    if clip_users==0:clips.clear()
static func make_clip(profile: Array) -> AudioStreamWAV:
    var count:=int(float(profile[0])*RATE)
    var pcm:=PackedByteArray();pcm.resize(count*2)
    var phase:=0.0
    for i in range(count):
        var t:=float(i)/maxi(1,count-1)
        phase+=TAU*lerpf(float(profile[1]),float(profile[2]),t)/RATE
        var noise:=fmod(sin(float(i)*12.9898+78.233)*43758.5453,1.0)
        var envelope:=minf(t*40.0,1.0)*pow(1.0-t,2.4)
        var sample:=lerpf(sin(phase),noise,float(profile[3]))*envelope*0.75
        pcm.encode_s16(i*2,clampi(roundi(sample*32767),-32767,32767))
    var clip:=AudioStreamWAV.new();clip.format=AudioStreamWAV.FORMAT_16_BITS
    clip.mix_rate=RATE;clip.data=pcm
    return clip
func reset() -> void:
    for voice in voices:voice.stop()
    last.clear();warnings.clear();accepted.clear();serial=0
func set_suspended(value: bool) -> void:
    suspended=value
    for voice in voices:voice.stream_paused=value
func play_event(kind: String, clock: float, priority: int=1) -> bool:
    if not playback_enabled or suspended or not clips.has(kind) or voices.is_empty():return false
    var interval:=0.12 if kind=="warning" else 0.035 if kind in ["punch","key","pickup"] else 0.055
    if clock-float(last.get(kind,-INF))<interval:return false
    var chosen:=-1
    for i in range(voices.size()):
        if not voices[i].playing:chosen=i;break
    if chosen<0:
        for i in range(voices.size()):
            if priorities[i]>priority:continue
            if chosen<0 or priorities[i]<priorities[chosen] or (priorities[i]==priorities[chosen] and stamps[i]<stamps[chosen]):chosen=i
    if chosen<0:return false
    last[kind]=clock;serial+=1;stamps[chosen]=serial;priorities[chosen]=priority
    voices[chosen].stream=clips[kind];voices[chosen].stream_paused=false;voices[chosen].play()
    accepted[kind]=int(accepted.get(kind,0))+1
    return true
func fire(id: String, clock: float) -> void:
    play_event(str(FIRE.get(id,"punch")),clock)
func contact(blocked: bool, clock: float) -> void:
    play_event("metal" if blocked else "punch",clock,2)
func observe_enemies(enemies: Array, clock: float) -> void:
    if not playback_enabled:return
    var present: Dictionary={}
    for enemy: Dictionary in enemies:
        var id: int=enemy["id"];var phase: String=enemy.get("phase","")
        present[id]=true
        var previous: Dictionary=warnings.get(id,{})
        var pose: Dictionary=enemy.get("attack_pose",{})
        var start: float=pose.get("start",-INF)
        var phase_warning:=phase in ["warning","charge-warning"] and str(previous.get("phase",""))!=phase
        var pose_warning:=clock<float(pose.get("impact",-INF)) and start!=float(previous.get("attack_start",-INF))
        if phase_warning or pose_warning:play_event("warning",clock,5)
        warnings[id]={"phase":phase,"attack_start":start}
    for id in warnings.keys():
        if not present.has(id):warnings.erase(id)
