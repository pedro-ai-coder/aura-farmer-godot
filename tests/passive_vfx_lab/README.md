# Passive VFX Lab V1 / Six → Seven Demo V2

Open the dedicated scene with Godot 4.7.2 Compatibility from the game project.

```sh
godot --headless --path . --import
godot --path . res://tests/passive_vfx_lab/main.tscn
```

Baseline and proposed presentation share the same synthetic arena and loadout. Use **Replay** from a neutral input state to repeat the scenario. WASD/arrows move both heroes while the window has input focus. **¼×** slows playback without changing simulation steps. **Pause** holds the frame. **Dense + overlap** stages three weapons, five legal passives and a concurrent hostile warning. **Game HUD** reveals the existing passive slot and recovery timer. **Reduced motion** replays the fixture with a static candidate treatment.

Select any of the 23 playable passives. Event fixtures exercise production collision/timer/Flex/damage handling. Permanent stats use ordinary weapon or movement behavior or an actual equipment commitment. Only Six → Seven has alternate art. The lab stages prior counters, enemy durability, starting HP and encounter layout. It is synthetic QA evidence. The current input state is shared for both panels. Recorded fixtures use neutral input and fixed stepping.

**Screenshot** saves both panels to the local Godot user directory. **Save traces** snapshots bounded QA Recorder ZIPs for both panels. The steps below capture genuine runtime PNGs and video frames, with no screen grab or video overlay software needed.

```sh
godot --headless --path . --script res://tests/passive_vfx_lab/test_lab.gd
godot --path . --resolution 1200x740 res://tests/passive_vfx_lab/main.tscn -- --capture /absolute/output/directory normal --sha=COMMIT_SHA
ffmpeg -framerate 30 -i /absolute/output/directory/frame-%04d.png -vf 'pad=ceil(iw/2)*2:ceil(ih/2)*2' -c:v libx264 -pix_fmt yuv420p /absolute/output/directory/comparison.mp4
godot --path . --script res://tests/passive_vfx_lab/measure.gd -- /absolute/output/performance.json
```

Capture suites `normal`, `slow`, and `dense` write image sequences at 30 movie frames per second. `reduced` and `mobile` save stills. Set `--resolution 844x390` for the landscape mobile-sized test. The Godot screenshots are window-rendered evidence. Encoding pads an odd-sized renderer output by one pixel when required.

For a standalone Windows x64 build with the installed Godot Windows template, stage a separate project and export locally. Keep the executable and its adjacent PCK together.

```sh
python tests/passive_vfx_lab/prepare_review_export.py /absolute/fresh/staging
godot --headless --path /absolute/fresh/staging --import
godot --headless --path /absolute/fresh/staging --export-release "Passive VFX Lab Windows" "/absolute/fresh/staging/build/CLUTCHPUNKS Passive VFX Lab.exe"
```

See the [audit](../../docs/PASSIVE_VFX_AUDIT_V1.md), [architecture](../../docs/PASSIVE_VFX_ARCHITECTURE_V1.md), [proposed style](../../docs/PASSIVE_VFX_STYLE_GUIDE_V1.md) and [validation record](evidence/README.md).
