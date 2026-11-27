extends RefCounted
## Original, deterministic tracker-like Wave 1–5 score. No gameplay RNG, samples or external music.
## Rendered once at Web/native start, then looped by AudioStreamPlayer.
const RATE := 24000
const BEAT := 0.6 # The existing Big Hater score is 100 BPM.
const BARS := 4
const SECONDS := BEAT * 4.0 * BARS
const ROOTS := [29, 29, 30, 27]
const BASS_STEPS := [0, -1, 0, 7, 0, 12, 7, -1]
const LEAD_STEPS := [12, -1, 15, -1, 17, 15, -1, 12]
const LAYERS := [
    # [bass, pad, drums, top line, glitch], staged by the five canonical waves.
    [0.26, 0.19, 0.12, 0.00, 0.00], # FIRST POST — establish a subdued pulse
    [0.31, 0.21, 0.17, 0.09, 0.00], # COMMENT SECTION — add rhythmic reply
    [0.32, 0.22, 0.20, 0.14, 0.06], # GOING VIRAL — more syncopation
    [0.35, 0.23, 0.25, 0.17, 0.10], # CANCEL STORM — sharper accents
    [0.38, 0.24, 0.30, 0.20, 0.13], # FINAL RATIO — forward drive into the boss
]

static func _frequency(note: int) -> float:
    return 440.0 * pow(2.0, (float(note) - 69.0) / 12.0)

static func render(wave: int) -> AudioStreamWAV:
    assert(wave >= 1 and wave <= 5)
    var layers: Array = LAYERS[wave - 1]
    var length := roundi(SECONDS * RATE)
    var pcm := PackedByteArray()
    pcm.resize(length * 2)
    for i in range(length):
        var t := float(i) / float(RATE)
        var beat_no := floori(t / BEAT)
        var bar := mini(BARS - 1, beat_no / 4)
        var beat_phase := fposmod(t, BEAT)
        var half_phase := fposmod(t, BEAT * 0.5)
        var root := int(ROOTS[bar])
        var bass_slot := mini(7, floori(fposmod(t, 4.0 * BEAT) / (BEAT * 0.5)))
        var bass_offset := int(BASS_STEPS[bass_slot])
        var bass: float = 0.0
        if bass_offset >= 0:
            var bass_frequency := _frequency(root + bass_offset)
            var bass_envelope := minf(1.0, half_phase * 85.0) * exp(-3.2 * half_phase)
            bass = (sin(TAU * bass_frequency * t) + 0.28 * sin(TAU * bass_frequency * 2.0 * t)) * bass_envelope
        var pad_frequency := _frequency(root + 24)
        var pad := (sin(TAU * pad_frequency * t) * 0.64 + sin(TAU * pad_frequency * 1.4983 * t) * 0.24
            + sin(TAU * pad_frequency * 1.9965 * t) * 0.18)
        var pad_envelope := 0.75 + 0.25 * sin(TAU * t / (BEAT * 4.0))
        var kick := 0.0
        if beat_no % 4 in [0, 2] or (wave >= 4 and beat_no % 4 == 3):
            kick = (sin(TAU * (53.0 * beat_phase + 18.0 * exp(-24.0 * beat_phase)))
                * exp(-18.0 * beat_phase))
        var noise := sin(float(i) * 1.7147) * sin(float(i) * 2.3993)
        var snare := noise * exp(-19.0 * beat_phase) if beat_no % 4 in [1, 3] else 0.0
        var hat := noise * exp(-44.0 * half_phase) if wave >= 2 else 0.0
        var lead := 0.0
        var lead_note := int(LEAD_STEPS[bass_slot])
        if lead_note >= 0 and wave >= 2:
            var lead_frequency := _frequency(root + 24 + lead_note)
            lead = (sin(TAU * lead_frequency * t + 0.32 * sin(TAU * lead_frequency * 2.0 * t))
                * exp(-4.5 * half_phase))
        var glitch := 0.0
        if wave >= 3 and bass_slot in [3, 7]:
            glitch = noise * exp(-39.0 * half_phase) * sin(TAU * 320.0 * t)
        var sample: float = (
            bass * float(layers[0]) +
            pad * pad_envelope * float(layers[1]) +
            (kick + 0.52 * snare + 0.16 * hat) * float(layers[2]) +
            lead * float(layers[3]) +
            glitch * float(layers[4])
        )
        # Seam guard: exact-zero first and final frames avoid loop discontinuity.
        sample *= minf(1.0, minf(t, SECONDS - t) * 38.0)
        pcm.encode_s16(i * 2, clampi(roundi(sample * 22000.0), -32767, 32767))
    var track := AudioStreamWAV.new()
    track.format = AudioStreamWAV.FORMAT_16_BITS
    track.mix_rate = RATE
    track.data = pcm
    track.loop_mode = AudioStreamWAV.LOOP_FORWARD
    track.loop_end = length
    return track

static func defeat_stinger() -> AudioStreamWAV:
    # Original sub-second falling minor-third resolved at the defeat screen.
    var length := roundi(RATE * 1.2)
    var pcm := PackedByteArray()
    pcm.resize(length * 2)
    for i in range(length):
        var t := float(i) / float(RATE)
        var n := 41 if t < 0.33 else 38
        var frequency := _frequency(n)
        var envelope := minf(t * 72.0, 1.0) * pow(1.0 - t / 1.2, 2.2)
        var sample := (0.68 * sin(TAU * frequency * t) + 0.28 * sin(TAU * frequency * 2.0 * t)) * envelope
        pcm.encode_s16(i * 2, clampi(roundi(sample * 19000.0), -32767, 32767))
    var track := AudioStreamWAV.new()
    track.format = AudioStreamWAV.FORMAT_16_BITS
    track.mix_rate = RATE
    track.data = pcm
    return track
