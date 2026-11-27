"""Render the original Big Hater V1 candidate from oscillator and drum patterns."""
from array import array
from math import exp, pi, sin, tanh
from pathlib import Path
from random import Random
import sys
import wave

RATE = 24000
BEAT = 0.6
OUT = Path(__file__).resolve().parents[1] / "assets/audio/big-hater-v1"


def tone(track, start, length, note, level, voice="bass"):
    offset = round(start * RATE)
    count = min(round(length * RATE), len(track) - offset)
    freq = 440 * 2 ** ((note - 69) / 12)
    for i in range(count):
        t = i / RATE
        phase = 2 * pi * freq * t
        envelope = min(t / 0.011, 1) * min((count - i - 1) / (RATE * 0.035), 1)
        if voice == "bass":
            value = tanh(1.5 * sin(phase) + 0.62 * sin(2 * phase) + 0.26 * sin(3 * phase))
        elif voice == "brass":
            value = sin(phase + 0.7 * sin(phase * 2)) + 0.35 * sin(phase * 1.005)
        else:
            value = (sin(phase) + 0.35 * sin(phase * 2.01)) * exp(-3 * t)
        track[offset + i] += level * envelope * value


def drum(track, start, length, level, color, seed):
    offset = round(start * RATE)
    count = min(round(length * RATE), len(track) - offset)
    rng = Random(seed)
    phase = previous = 0.0
    for i in range(count):
        t = i / RATE
        noise = rng.uniform(-1, 1)
        if color == "kick":
            phase += 2 * pi * (43 + 110 * exp(-31 * t)) / RATE
            value = sin(phase) * exp(-12 * t) + noise * 0.22 * exp(-104 * t)
        elif color == "snare":
            value = noise * 0.68 * exp(-17 * t) + sin(2 * pi * 174 * t) * 0.46 * exp(-29 * t)
        elif color == "hat":
            value = (noise - previous) * 0.68 * exp(-46 * t)
        else:
            value = (noise * 0.35 + 0.48 * sin(2 * pi * 231 * t)
                     + 0.28 * sin(2 * pi * 587 * t)) * exp(-20 * t)
        previous = noise
        envelope = min(t / 0.003, 1) * min((count - i - 1) / (RATE * 0.012), 1)
        track[offset + i] += value * level * envelope


def write(name, track):
    # Keep headroom for the live weapon and warning mixer.
    samples = array("h", (round(29000 * tanh(sample)) for sample in track))
    if sys.byteorder != "little":
        samples.byteswap()
    with wave.open(str(OUT / (name + ".wav")), "wb") as stream:
        stream.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        stream.writeframes(samples.tobytes())


def render():
    OUT.mkdir(parents=True, exist_ok=True)
    music = [0.0] * round(16 * BEAT * RATE)
    # Four bars, 100 BPM. F minor with a G-flat scrape and syncopated half-time drums.
    for bar, (root, pickup) in enumerate([(29, 41), (29, 36), (30, 42), (27, 36)]):
        at = bar * 4 * BEAT
        for step, note, length in [(0, root, 0.64), (3, root, 0.26), (5, pickup, 0.20), (6, root, 0.36)]:
            tone(music, at + step * BEAT / 2, length, note, 0.32)
        for step in [0, 3, 6]:
            drum(music, at + step * BEAT / 2, 0.23, 0.56, "kick", bar * 8 + step)
        drum(music, at + 2 * BEAT, 0.21, 0.54, "snare", 32 + bar)
        for step in range(1, 8):
            drum(music, at + step * BEAT / 2, 0.09, 0.23 if step % 2 else 0.12, "hat", 40 + bar * 8 + step)
        for note in [root + 24, root + 31]:
            tone(music, at + 0.5 * BEAT, 0.34, note, 0.086, "brass")
    write("boss-loop", music)

    entrance = [0.0] * round(0.84 * RATE)
    for start, length, note, level in [(0.0, 0.42, 41, 0.24), (0.12, 0.35, 42, 0.18), (0.44, 0.38, 29, 0.39)]:
        tone(entrance, start, length, note, level, "brass")
    drum(entrance, 0.02, 0.17, 0.32, "metal", 57)
    drum(entrance, 0.44, 0.38, 0.82, "kick", 58)
    drum(entrance, 0.44, 0.24, 0.49, "metal", 59)
    write("entrance", entrance)

    impact = [0.0] * round(0.30 * RATE)
    drum(impact, 0.0, 0.30, 0.88, "kick", 60)
    drum(impact, 0.005, 0.23, 0.57, "metal", 61)
    write("attack-impact", impact)

    hit = [0.0] * round(0.13 * RATE)
    drum(hit, 0.0, 0.13, 0.68, "metal", 62)
    tone(hit, 0.0, 0.10, 43, 0.35)
    write("contact", hit)

    victory = [0.0] * round(2.05 * RATE)
    drum(victory, 0.0, 0.43, 0.86, "kick", 63)
    drum(victory, 0.0, 0.26, 0.42, "metal", 64)
    # Recover the entrance's F root and resolve the tension into F major.
    for at, note in [(0.33, 65), (0.52, 69), (0.72, 72), (0.94, 77)]:
        tone(victory, at, 0.60, note, 0.23, "chime")
    for note in [41, 53, 65, 69, 72]:
        tone(victory, 0.94, 1.11, note, 0.11, "brass")
    write("victory", victory)


if __name__ == "__main__":
    render()
