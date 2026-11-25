# Six to Seven gameplay review — V3 Neon Impact

Status **PROPOSED**. This branch stacks on [draft PR #157](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/157) at bf96d3868b15e241dcaa9f0c21e11676f2147f72 and [draft PR #156](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/156) at 701944183a624f967ac3a6d1aab41c6cb7df8fa1. The gameplay control is main at 34767716e1c9b5ecb6e7361e6aced6d13d052817. The [passive audit](../../docs/PASSIVE_VFX_AUDIT_V1.md) preserves the existing primary-hit semantics and No U weaken discrepancy as separate rules work.

The exported feature `six_to_seven_review` enables both renderers in the original Garage, map picker and Solo run. V2 remains the byte-identical default. V3 inherits its sixth-hit cue and consumes the same resolved burst payload. Its ignition, irregular pressure front, seven short streaks and contact marks use fixed geometry. Reduced Motion holds the center, perimeter and contacts in place and fades them once. The ordinary pack excludes both renderers. The review uses a separate profile directory.

## Local review

Use Godot 4.7.2 Compatibility and the official Windows templates. Keep the executable and adjacent PCK together.

~~~sh
python tests/six_to_seven/review_export.py --stage /absolute/fresh/review
godot --headless --path /absolute/fresh/review --import
godot --headless --path /absolute/fresh/review --export-release "Six to Seven Review" "/absolute/fresh/review/build/CLUTCHPUNKS Six to Seven Review.exe"
~~~

Use --target web to stage an equivalent local Web review. Run the existing Web preset inside that staging directory. The ordinary project presets continue to export the production entry point with the review feature off.

## Creator acceptance

In the protected Vercel preview, pick a hero in the Garage and choose Solo.
Select Ruin Alley or MSG Factory, turn on **QA: SIX → SEVEN**, and select
**VFX: V2 BASELINE** or **VFX: V3 NEON IMPACT**, then select
**Start Run**. The hero determines the seed for either treatment. The run starts with the legal Epic Level 1 passive equipped.
Keep enemies in your starter weapon's range. Watch for the cue on hit six,
then the burst and contact marks on hit seven. **Try Again** repeats the
QA loadout. Return to the Garage and leave the toggle off for standard
progression. QA run results are never recorded in the profile.

- [ ] Identify 6/7 from the player cue and decide whether V3's seventh hit feels stronger than a standard attack and V2.
- [ ] Follow the seventh strike to the burst center. Identify which enemies lost HP and where the 90 U boundary sits.
- [ ] Check that hostile projectiles and warning geometry remain readable in a crowd in Ruin Alley and MSG Factory.
- [ ] Pause during an effect, resume and verify it expires naturally. Retry or return to the Garage and start again.
- [ ] Check that the burst clears quickly and that Reduced Motion identifies the source, extent, and confirmed contacts.
- [ ] Approve the visual treatment explicitly before production integration.

## Reproduce paired evidence

Run `godot --headless --path . --script res://tests/six_to_seven/test_integration.gd -- v3` for V2/V3 parity and lifecycle checks.
For native evidence, set `CPK_VFX_VARIANT=v2` or `v3` and run
`godot --path . --resolution 1280x720 --script res://tests/six_to_seven/gameplay_review.gd -- <map> 451 <capture|measure> <frame> <output-directory>`.
Use Ruin Alley frame 27111 for normal combat or 30830 for dense combat. Use
MSG Factory frame 1197 with `CPK_VFX_QA_LOADOUT=1`. Set
`CPK_VFX_REDUCED=1` for Reduced Motion. The replays use 60 Hz simulation
and report the seed, focused tick, resolved events and terminal state.
Capture mode writes native 30 fps footage frames and 60 Hz source frames
around impact for quarter-speed playback. Measure mode omits readback.
