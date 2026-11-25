# No U Reverse Impact V2

**EXPERIMENTAL — NOT CANONICAL — NOT APPROVED FOR PRODUCTION.** Direction B is authorized only for implementation/evaluation. Technical PASS does not grant artistic or gameplay approval.

## Play

In the Garage choose a hero and Ruin Alley or MSG Factory. Cycle **NO U QA OFF** to **NORMAL** or **DENSE**, then select **A / ORIGINAL**, **B / COUNTER-PULSE V1**, or **C / REVERSE IMPACT V2**. Choose an optional **INPUT** case and Start Run. Retry preserves the treatment/case; return to Garage to change it. Settings controls Reduced Motion. The V2 caption shows READY or recharge in active seconds.

The short white/magenta X at enemy feet means effective HP damage. The cyan broken-attack/down-arrow means reduced outgoing enemy damage. The cyan perimeter marks exactly 200 U. These are separate outcomes; a shielded enemy can show weaken without a damage X.

**LIVE COMBAT** adds no scripted damage. **HP HIT**, **SHIELD ONLY**, **SIMULTANEOUS**, **RECHARGE**, **FATAL**, and **ENVIRONMENT** call real shield/damage/hazard systems at specified active times. These are QA inputs, not game rules. Inputs first occur at 1.25 s; Recharge also hits at 2 and 16.25 s. Natural enemies remain active and can affect results. Normal/Dense include a boss, shielded elite and low-HP enemy; Dense adds a crowd. A/B Live preserve the V1 fixture and prime only the first periodic pulse to 1.25 s. Ordinary production remains first due at 15 s.

## Experimental contract

- Positive effective player HP loss qualifies, after ordinary mitigation/shield resolution. Partial absorption qualifies; full absorption and nonpositive damage do not.
- Fatal damage resolves defeat without activating No U or preventing death. Survival is checked before retaliation.
- Initially ready on legal acquisition. Successful activation starts 15 active seconds of cooldown. An eligible pulse with no nearby recipients still counts as activation.
- A resolving guard, pre-observer cooldown reservation and same-active-time stamp prevent recursive/duplicate activation. Visuals consume no gameplay RNG. Identical V2 inputs/seeds must match; V1 and V2 intentionally need not match.
- The existing resolver applies 200 U / 0.30 times offensive power, followed by normal outgoing damage reduction 20% for 4 s or boss 10% for 2 s. No reflection, invulnerability, healing, knockback, stun, progression change or new damage multiplier.
- **Environmental eligibility remains unresolved.** This experiment includes source-less and enemy-sourced hazards when positive HP loss and survival qualify. The existing `hazard` flag identifies only certain sustained hazards, not all environmental origins, and is not an eligibility filter. The Environment case schedules a real source-less hazard.
- **Future-born weaken remains unresolved and unchanged.** Unborn enemies reject pulse damage but can receive weaken. Their marker appears only after birth while that exact application is active. No unrelated fix is included.

## Isolation and provenance

V1 `be7f478946f21fa190efd34bc3107603ef209ddf`, Draft PR #162 and historical evidence are preserved. Production baseline is `1c2ec76cd06d6f1485a79fbbee97ccfac70ac5c8`; main was verified at this SHA. The separate Draft PR is stacked on V1 for a focused V2 diff, not integration approval.

The [canonical V3 rule](https://github.com/pedro-ai-coder/clutchpunks-canon/blob/2d0430d552a9125370b3b00f78e5b973fd1dc3fe/archive/v3/GDD_V3_SOURCE.md) remains periodic. [Six to Seven V3 approval](https://github.com/pedro-ai-coder/clutchpunks-canon/blob/2d0430d552a9125370b3b00f78e5b973fd1dc3fe/decisions/CREATOR_SIX_TO_SEVEN_V3_VISUAL_APPROVAL_2026-11-24.md) does not approve No U gameplay/artwork. Its two renderer blobs remain unchanged.

Only an explicit No U review export loads the experiment. Ordinary presets exclude all four review resources. The optional controller hooks are inert without a review instance. QA runs skip selected-hero and result progression writes. Staging uses a separate native app identity; the authenticated Preview origin isolates browser storage. No new persistent keys/schema, assets, dependencies or paid services.

## Reproduce

Use Godot 4.7.2 Compatibility from the checkout:

```sh
godot --headless --path . --script res://tests/no_u/test_counter_pulse.gd
godot --headless --path . --script res://tests/no_u/test_reverse_impact.gd
godot --headless --path . --script res://tests/six_to_seven/test_integration.gd
python tests/six_to_seven/review_export.py --no-u --target web --stage /tmp/no-u-v2-stage
godot --headless --path /tmp/no-u-v2-stage --import
godot --headless --path /tmp/no-u-v2-stage --export-pack Web /tmp/no-u-v2.pck
python tests/six_to_seven/review_export.py --no-u --verify /tmp/no-u-v2.pck
godot --headless --path . --export-pack Web /tmp/no-u-ordinary.pck
python tests/six_to_seven/review_export.py --verify /tmp/no-u-ordinary.pck
godot --path . --audio-driver Dummy --script res://tests/no_u/capture_reverse.gd -- ruin-alley 2 reverse capture /tmp/no-u-capture COMMIT_SHA
```

Capture arguments: map, density 1/2, baseline/candidate/reverse/reduced (reduced is C), capture/measure, output directory, source SHA. Native captures use seed 451, 60 Hz, 1280 x 720 and the existing QA Recorder. Measurement excludes readback/recording and reports CPU wall time through native draw completion, not GPU time. Web results must distinguish software rendering and active-game intervals. Results and deviations are recorded in the delivery report and append-only action audit.

## Creator acceptance

- [ ] Incoming damage clearly causes retaliation; full absorption/fatal cases remain silent.
- [ ] The 200 U boundary reads correctly in both maps and Dense.
- [ ] HP damage is distinct from cyan reduced-threat status, including shields and lethal hits.
- [ ] Weaken communicates reduced outgoing damage and expires independently for bosses/normals.
- [ ] READY/recharge is readable without hiding combat or hostile warnings.
- [ ] Reduced Motion retains outcome/range clarity without traveling-wave motion.
- [ ] C feels meaningfully reactive beside A/B and approaches the approved Six to Seven quality benchmark.
- [ ] Decide environmental eligibility and future-born weaken separately; record changes or explicit approval for this exact prototype.
