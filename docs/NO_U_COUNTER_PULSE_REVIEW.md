# No U Counter-Pulse V1

**PROPOSED.** Godot 4.7.2 Compatibility, Solo only. This treatment needs explicit creator approval.

## Play the comparison

In the Garage choose a hero and either Ruin Alley or MSG Factory. Click **NO U QA OFF** once for **NORMAL** and twice for **DENSE**. Select **VFX BASELINE** or **COUNTER-PULSE**, then **Start Run**. Stand near the opening enemies for the first pulse at about 1.25 active seconds. Retry keeps the fixture and visual treatment. Return to Garage to change the comparison. Use **Reduced Motion** in the game's Settings to see the stationary version.

The normal fixture starts with a mix of standard enemies, a shielded elite, and a boss. Dense adds a deterministic crowd using the same enemies, map collision and combat runtime. The fixture uses the real equipment grant for the Legendary No U at level 1. Only the first eligible cooldown is brought forward. Both QA modes skip selected-hero and run-result profile writes.

## Creator acceptance

- [ ] Recognize the instant of activation and read the cyan edge as a player-centered, 200 U counterattack in both maps.
- [ ] Track the short bright slashes as positive HP loss. Check that the shielded elite can show the small double chevron without a slash.
- [ ] Follow the two-second boss marker and four-second normal marker. Look for their independent removal.
- [ ] Read hostile telegraphs, projectiles and enemy animations through the effect in Dense.
- [ ] Repeat with Reduced Motion. Confirm that the fixed boundary and stationary contact marks still convey the outcomes.
- [ ] Approve or request changes to this exact treatment.

## Rules and provenance

- Approved runtime base [`1c2ec76`](https://github.com/pedro-ai-coder/aura-farmer-godot/commit/1c2ec76cd06d6f1485a79fbbee97ccfac70ac5c8), following [production integration #161](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/161). The approved V3 sources and game art are untouched.
- [Canonical V3](https://github.com/pedro-ai-coder/clutchpunks-canon/blob/2d0430d552a9125370b3b00f78e5b973fd1dc3fe/archive/v3/GDD_V3_SOURCE.md) and the [creator decision](https://github.com/pedro-ai-coder/clutchpunks-canon/blob/2d0430d552a9125370b3b00f78e5b973fd1dc3fe/decisions/CREATOR_SIX_TO_SEVEN_V3_VISUAL_APPROVAL_2026-11-24.md). The live combat resolver owns timing, target selection, HP and weaken. The renderer uses one pulse snapshot and up to 48 contact accents.
- The [prior audit](PASSIVE_VFX_AUDIT_V1.md) records the unresolved future-born weaken discrepancy. Those enemies can receive weaken during their spawn telegraph while damage is rejected. A marker appears when a recipient becomes visible if its authoritative No U weaken is still active.
- Production Web, Android, iOS and Web Performance Review presets exclude the two No U review resources. Only the explicit No U preview staging adds them. Review and ordinary packs both keep the approved Six → Seven renderer.

## Reproduce

```sh
godot --headless --path . --script res://tests/no_u/test_counter_pulse.gd
python3 tests/six_to_seven/review_export.py --no-u --target web --stage /tmp/cpk-no-u
godot --headless --path /tmp/cpk-no-u --import
godot --headless --path /tmp/cpk-no-u --export-pack Web /tmp/cpk-no-u.pck
python3 tests/six_to_seven/review_export.py --no-u --verify /tmp/cpk-no-u.pck
```

Native capture uses the actual seed-451 Solo run at 1280 × 720 with the preview fixture and the existing QA Recorder. Run `godot --path . --audio-driver Dummy --script res://tests/no_u/capture.gd -- <ruin-alley|msg-factory> <1|2> <baseline|candidate|reduced> <capture|measure> <output-folder> <commit>`. Timing measures elapsed CPU wall time across simulation and the native frame draw callback with VSync disabled. The capture path adds image readback and recording and is excluded from the benchmark.
