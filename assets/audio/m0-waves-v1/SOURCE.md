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

## Creator's full-playback acceptance checklist

Listen in the real ordinary Web game from Garage → Run Start to victory and at least one defeat. The soundtrack must be audible from Wave 1 (00:00), develop distinctly at each actual two-minute wave transition, remain below combat warnings and player SFX, then hand off musically to the creator-approved Big Hater V1 entrance and boss score at 10:00. The original approved boss victory cue must remain unchanged.

Test Sound OFF, non-default Master volume, pause/upgrade offer suspension, retry and returning to menu. Confirm that music does not replay over itself, hang after leaving the run, trigger during a sound-disabled menu or alter the existing deterministic gameplay state.

This list is an acceptance target, **not a claim of successful browser/audio end-to-end listening or creator approval**.

## Wave 2 Web regression

An ordinary Godot 4.7.2 Web export at creator-tested commit `e3716941eb7d9d1b6fe69346fee5f64dc593d6b0` reproduced the failure in Chromium. The second score reached `AudioBufferSourceNode.start()` with offset **118.579 s** in a **9.600 s** buffer. After the existing fade retired Wave 1, 27 recorded Wave 2 samples had **0 RMS** on the music path. The final mix still reached **0.01765 RMS** from combat SFX and the context stayed running.

Godot's Web Sample playback position counts rendered samples across loop restarts. The engine sends a `clear` message at restart, while the position processor resets through its `reset` parameter. Passing that cumulative position to the next player's `play()` put the Web Audio start past the end of the new buffer. The sample restarts with the same initial offset, so the track stays silent. See the Godot 4.7.2 [sample implementation](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/web/js/libs/library_godot_audio.js) and [position processor](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/web/js/libs/godot.audio.position.worklet.js).

Each incoming Web wave now starts at the beginning of its authored four-bar loop. This keeps Web Sample playback, the original loop content, the existing 0.85 s fade and gains, and the approved boss audio. Native playback keeps its position-based handoff.

The browser test samples real Web Audio waveforms after each player gain and at the final output and records the final mix. Per-track measurements keep weapons from masking a silent score. The synthetic export spends longer than one 9.6 s loop on each wave, so it exercises the position failure a fast state or PCM test misses. Use the ordinary export for continuous run evidence. The synthetic result covers the audio lifecycle it drives.

### Reproduction commands

Use Godot 4.7.2 with Web export templates, Python 3, Node.js 22+ and a Chromium executable. Set `CHROME_BIN` to the Chrome path. Run the ordinary export with `node tests/test_web_wave_audio.mjs WEB_URL FULL_COMMIT EVIDENCE_DIR`. Set `WAVE_AUDIO_REPRO=1` for a check that stops after recording Wave 2. It should fail on the original build.

For the synthetic run, generate the separate export with `python tests/build_wave_audio_fixture.py GODOT SYNTHETIC_EXPORT_DIR`, serve it over HTTP, and run the same Node command with `WAVE_AUDIO_FIXTURE=1`. Its metadata and capture filename identify it as synthetic. The ordinary browser run writes a single audio/video WebM and a JSON timeline. The synthetic run writes an audio WebM and a JSON timeline.
