# Six to Seven gameplay review

Status **PROPOSED**. This branch depends on [draft PR #156](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/156) at 701944183a624f967ac3a6d1aab41c6cb7df8fa1. The gameplay control is main at 34767716e1c9b5ecb6e7361e6aced6d13d052817. The [passive audit](../../docs/PASSIVE_VFX_AUDIT_V1.md) preserves the existing primary-hit semantics and No U weaken discrepancy as separate rules work.

The renderer from Demo V2 now lives in scripts/vfx. The game uses it only when the exported feature six_to_seven_review is present. The ordinary pack excludes the renderer. The review package boots into the same Garage, map picker and Solo run as the current game. A separate application data directory isolates its profile and save progression. The normal offer pool and starter loadouts remain intact.

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
**Start Run**. The run starts with the legal Epic Level 1 passive equipped.
Keep enemies in your starter weapon's range. Watch for the cue on hit six,
then the burst and contact marks on hit seven. **Try Again** repeats the
QA loadout. Return to the Garage and leave the toggle off for standard
progression. QA run results are never recorded in the profile.

- [ ] Acquire Six → Seven through the normal upgrade flow and identify 6/7 from the player cue.
- [ ] Follow the seventh strike to the burst center. Identify which enemies lost HP and where the 90 U boundary sits.
- [ ] Check that hostile projectiles and warning geometry remain readable in a crowd in Ruin Alley and MSG Factory.
- [ ] Pause during an effect, resume and verify it expires naturally. Retry or return to the Garage and start again.
- [ ] Check Reduced Motion and the existing recovery indicator.
- [ ] Approve the visual treatment explicitly before production integration.
