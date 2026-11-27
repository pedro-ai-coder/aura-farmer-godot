# M0 Waves 1–5 music V1 — original audio candidate

**Status:** CANDIDATE — creator listening and exact-master approval pending.

The original five-wave score is authored as deterministic, project-owned PCM synthesis in `scripts/m0_wave_music.gd`. It renders five independent 100 BPM, four-bar mono 24 kHz / 16-bit loop streams and one short defeat cue using original oscillator, rhythm and melody patterns; no external samples, stock music, voice sources or third-party compositions are imported.

The five treatments are arranged for the already approved wave sequence:

1. FIRST POST — light beat and subtle synthetic bed.
2. COMMENT SECTION — low bass and reply motif.
3. GOING VIRAL — brighter counter-rhythm.
4. CANCEL STORM — more insistent stabs and percussion.
5. FINAL RATIO — intensified drive into the existing creator-approved Big Hater V1 boss entrance, score and victory.

The existing `scripts/combat_audio.gd` mixer owns two bounded run-score players for 0.85-second crossfades and the unchanged boss score channel. New PCM synthesis does **not** consume the gameplay RNG. The score follows the existing Master mute/volume and pause controls, including choices and web audio unlock. A normal loss plays a short original defeat cue through the result channel.

**Non-goals:** No gameplay clock, wave timing, enemy, boss, weapon, RNG, save, HUD, animation, or canonical changes. Existing Big Hater V1 audio and its exact WAV sources are preserved.

**Validation gate:** Run Godot 4.7.2 import/contract tests, ordinary Web export, a real-browser listening session from Wave 1 to victory and defeat, both maps and the sound/mute/retry flow. A synthetic fast-forward fixture is not proof of uninterrupted real-browser audio. Do not merge, treat this candidate as approved, or release to production before creator listening acceptance.

**Reproduction:** Source alone produces the exact PCM streams via `WaveMusic.render(1..5)` on ordinary audio mixer initialization. `WaveMusic.defeat_stinger()` produces the loss cue. No generated audio binary is required in Git.
