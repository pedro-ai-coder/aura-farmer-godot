extends Node
## Bounded read-only presentation. No gameplay RNG or simulation timers.
const RATE:=22050
const VOICES:=8
const FIRE:={"no-cap":"swish","ratio-blaster":"zap","brainrot-feed":"heavy","keyboard-warrior":"key","ban-hammer":"heavy","touch-grass":"swish","cope-shield":"metal","chad-hands":"punch","personal-space":"pulse"}
const PROFILES:={"swish":[0.09,350.0,110.0,0.7],"zap":[0.11,930.0,180.0,0.1],"key":[0.045,1500.0,440.0,0.75],"heavy":[0.17,135.0,48.0,0.6],"metal":[0.095,1100.0,640.0,0.18],"punch":[0.07,240.0,65.0,0.65],"pulse":[0.13,340.0,100.0,0.15],"hurt":[0.15,290.0,105.0,0.4],"flex":[0.20,270.0,850.0,0.08],"warning":[0.12,780.0,1000.0,0.02],"pickup":[0.045,1250.0,1760.0,0.0]}
const BOSS_EFFECTS := {
    "boss_entrance": preload("res://assets/audio/big-hater-v1/entrance.wav"),
    "boss_impact": preload("res://assets/audio/big-hater-v1/attack-impact.wav"),
    "boss_hit": preload("res://assets/audio/big-hater-v1/contact.wav"),
}
const BOSS_GAIN := {"boss_entrance": -10.0, "boss_impact": -14.0, "boss_hit": -23.0}
const BOSS_LOOP = preload("res://assets/audio/big-hater-v1/boss-loop.wav")
const BOSS_VICTORY = preload("res://assets/audio/big-hater-v1/victory.wav")
const WaveMusic = preload("res://scripts/m0_wave_music.gd")
## Original wave score was mixed around -43 dBFS in Wave 1. Keep this music audible at default Master volume.
## Preserve SFX priorities and headroom; the authored PCM remains below clipping before the Master bus.
const WAVE_SCORE_DB := [-10.0, -10.0, -9.0, -9.0, -8.0]
const CROSSFADE_SECONDS := 0.85
const BOSS_HANDOFF_SECONDS := 0.55
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
var score: AudioStreamPlayer
var boss_loop: AudioStreamWAV
var score_at := INF
var victory_audio := false
var run_scores: Array[AudioStreamPlayer] = []
var run_tracks: Array[AudioStreamWAV] = []
var defeat_stream: AudioStreamWAV
var current_wave := 0
var active_run_score := 0
var previous_run_score := -1
var previous_gain_db := -22.0
var crossfade_at := 0.0
var boss_fade_at := INF
## Non-interactive contract tests do not need mixer voices. Dedicated audio
## tests explicitly enable the real mixer, and native/Web builds enable it.
var playback_enabled:=DisplayServer.get_name()!="headless"
func _ready() -> void:
    clip_users+=1
    if not playback_enabled:return
    if clips.is_empty():
        for kind in PROFILES:clips[kind]=make_clip(PROFILES[kind])
        clips.merge(BOSS_EFFECTS)
    boss_loop = BOSS_LOOP.duplicate()
    boss_loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
    boss_loop.loop_end = roundi(boss_loop.get_length() * boss_loop.mix_rate)
    score = AudioStreamPlayer.new()
    add_child(score)
    for i in range(2):
        var music := AudioStreamPlayer.new()
        music.volume_db = -60.0
        add_child(music)
        run_scores.append(music)
    for wave in range(1, 6):
        run_tracks.append(WaveMusic.render(wave))
    defeat_stream = WaveMusic.defeat_stinger()
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
    finish_boss(false)
    current_wave = 0
    previous_run_score = -1
    boss_fade_at = INF
    for music in run_scores:music.stop()
    last.clear();warnings.clear();accepted.clear();serial=0
func set_suspended(value: bool) -> void:
    suspended=value
    for voice in voices:voice.stream_paused=value
    if score != null:
        score.stream_paused = value and not victory_audio
    for music in run_scores:
        music.stream_paused = value

func begin_run_score(clock: float) -> void:
    change_wave_score(1, clock)

func change_wave_score(number: int, clock: float) -> void:
    if run_scores.size() != 2 or number < 1 or number > 5 or current_wave == number or is_finite(boss_fade_at):
        return
    var incoming := 0 if current_wave == 0 else 1 - active_run_score
    if previous_run_score >= 0:
        run_scores[previous_run_score].stop()
    previous_run_score = active_run_score if current_wave > 0 else -1
    previous_gain_db = float(WAVE_SCORE_DB[current_wave - 1]) if current_wave > 0 else -60.0
    var from_position := run_scores[active_run_score].get_playback_position() if current_wave > 0 else 0.0
    run_scores[incoming].stop()
    run_scores[incoming].stream = run_tracks[number - 1]
    run_scores[incoming].volume_db = -60.0
    run_scores[incoming].stream_paused = suspended
    run_scores[incoming].play(from_position)
    crossfade_at = clock
    active_run_score = incoming
    current_wave = number

func update_run_score(clock: float) -> void:
    if run_scores.size() != 2 or suspended or current_wave == 0:
        return
    if is_finite(boss_fade_at):
        var fade := clampf((clock - boss_fade_at) / BOSS_HANDOFF_SECONDS, 0.0, 1.0)
        for music in run_scores:
            if music.playing:
                music.volume_db = lerpf(previous_gain_db, -60.0, fade)
                if fade >= 1.0:music.stop()
        return
    var t := clampf((clock - crossfade_at) / CROSSFADE_SECONDS, 0.0, 1.0)
    run_scores[active_run_score].volume_db = lerpf(-60.0, float(WAVE_SCORE_DB[current_wave - 1]), t)
    if previous_run_score >= 0:
        run_scores[previous_run_score].volume_db = lerpf(previous_gain_db, -60.0, t)
        if t >= 1.0:
            run_scores[previous_run_score].stop()
            previous_run_score = -1

func begin_boss(clock: float) -> void:
    if score == null:
        return
    boss_fade_at = clock
    previous_gain_db = float(WAVE_SCORE_DB[maxi(0, current_wave - 1)])
    play_event("boss_entrance", clock, 6)
    score_at = clock + 0.84
func update_boss(clock: float) -> void:
    if score == null or suspended or clock < score_at:
        return
    score_at = INF
    score.stream = boss_loop
    score.volume_db = -15.0
    score.play()
func finish_boss(victory: bool) -> void:
    score_at = INF
    victory_audio = victory
    for music in run_scores:
        music.stop()
    if score == null:
        return
    score.stop()
    if victory:
        score.stream = BOSS_VICTORY
        score.volume_db = -11.0
        score.stream_paused = false
        score.play()

func play_defeat() -> void:
    if score == null or defeat_stream == null:
        return
    # The result cue is allowed to finish after the gameplay mixer suspends.
    victory_audio = true
    score.stream = defeat_stream
    score.volume_db = -12.0
    score.stream_paused = false
    score.play()

func play_event(kind: String, clock: float, priority: int=1) -> bool:
    if not playback_enabled or suspended or AudioServer.is_bus_mute(0) or not clips.has(kind) or voices.is_empty():return false
    var interval:=0.12 if kind in ["warning","boss_hit"] else 0.035 if kind in ["punch","key","pickup"] else 0.055
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
    voices[chosen].stream=clips[kind];voices[chosen].volume_db=BOSS_GAIN.get(kind,-22.0)
    voices[chosen].stream_paused=false;voices[chosen].play()
    accepted[kind]=int(accepted.get(kind,0))+1
    return true
func fire(id: String, clock: float) -> void:
    play_event(str(FIRE.get(id,"punch")),clock)
func contact(blocked: bool, clock: float) -> void:
    play_event("metal" if blocked else "punch",clock,2)
func observe_enemies(enemies: Array, clock: float) -> void:
    if not playback_enabled:return
    update_run_score(clock)
    update_boss(clock)
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
