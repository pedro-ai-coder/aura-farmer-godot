extends Node
## Synthetic Web audio lifecycle. The ordinary game export excludes tests/.
const CombatAudio = preload("res://scripts/combat_audio.gd")
var audio: CombatAudio
var elapsed := 0.0
var stage := "waiting"
var wave := 1

func _ready() -> void:
    audio = CombatAudio.new()
    add_child(audio)
    mark("waiting")

func mark(value: String) -> void:
    stage = value
    JavaScriptBridge.eval("window.waveAudioStage = " + JSON.stringify(value))

func _input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_ENTER and stage == "waiting":
        audio.set_suspended(false)
        audio.begin_run_score(0.0)
        mark("wave-1")
    elif event.keycode == KEY_P and wave == 2:
        audio.set_suspended(not audio.suspended)
        mark("paused" if audio.suspended else "wave-2")
    elif event.keycode == KEY_M:
        AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
        mark("muted" if AudioServer.is_bus_mute(0) else "wave-%d" % wave)

func _process(delta: float) -> void:
    if stage == "waiting" or audio.suspended or stage == "done":
        return
    elapsed += delta
    audio.update_run_score(elapsed)
    audio.update_boss(elapsed)
    if stage.begins_with("wave-") and elapsed >= 12.0 * wave:
        if wave < 5:
            wave += 1
            audio.change_wave_score(wave, elapsed)
            mark("wave-%d" % wave)
        else:
            audio.begin_boss(elapsed)
            mark("boss")
    elif stage == "boss" and elapsed >= 72.0:
        audio.finish_boss(true)
        audio.set_suspended(true)
        mark("victory")
        get_tree().create_timer(3.0).timeout.connect(_retry)
    elif stage == "retry" and elapsed >= 2.0:
        audio.finish_boss(false)
        audio.set_suspended(true)
        audio.play_defeat()
        mark("defeat")
        get_tree().create_timer(2.0).timeout.connect(func(): mark("done"))

func _retry() -> void:
    audio.reset()
    elapsed = 0.0
    wave = 1
    audio.set_suspended(false)
    audio.begin_run_score(elapsed)
    mark("retry")
