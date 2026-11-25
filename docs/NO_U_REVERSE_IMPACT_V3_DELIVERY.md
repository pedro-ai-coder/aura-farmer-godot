# No U Reverse Impact V3 â€” creator review

**EXPERIMENTAL â€” PROPOSED â€” NOT FOR PRODUCTION.** Visual polish proposal, no creator approval claimed. No merge or production deployment performed.

Draft PR: https://github.com/pedro-ai-coder/aura-farmer-godot/pull/164, stacked on preserved V2 #163. Exact playable source: `37faa8da7ae12d2fb982acf778fb9c3537c351d1`. Historical V2 parent: `53f4e14bb014edd3338e98efc5a63e5241e8a88f`. GitHub identity: `pedro-ai-coder`; commit email: `pestrela@proton.me`.

## Play the comparison

Extract the Windows review ZIP and keep the EXE and PCK together. Open **CLUTCHPUNKS No U V3 Review.exe**, select a hero and Solo, then choose either map. Turn **NO U QA NORMAL** or **DENSE** on. The treatment defaults to **C / REVERSE IMPACT V3** when QA is enabled. Its live HUD says **READY ON HP LOSS** or **RECHARGE**. Choose **INPUT / HP HIT** for an explicit eligible hit at 1.25 s, or **LIVE COMBAT** for real enemy damage. The input selector also exposes shields, simultaneous hits, recharge, fatal and environment cases.

Use the treatment button to select **A / BASELINE**, **B / COUNTER-PULSE V1**, or **C / REVERSE IMPACT V3**. A and B retain periodic gameplay; C reacts to surviving eligible HP loss and is not periodic. In Settings enable **Reduced Motion**, then repeat on both maps. Return to the Garage for a fresh selection. QA remains off for ordinary runs; review outcomes never write progression.

## Presentation

- Immediate compact white source-facing hit accent; neutral upper accent for source-less/environmental hits.
- 50 ms energy compression around an open player center, followed by accelerating, then decelerating, retaliatory ribbons.
- Irregular scissor-cut cyan/magenta wave with thick ink backing, white cores, layered wake and a distinct inward-hook reversal signature. Thin inset perimeter segments identify the exact 200 U extent; thick energy and fragments stay inside it. No full-screen flash, camera shake, game-speed change or new particle system.
- Confirmed positive HP loss gets a strong local slash; lethal recipients get a separate split white finisher at their resolved position. Shield-only recipients receive no HP accent. All contact/finisher rendering shares the existing bounded 48-recipient capacity.
- Weaken uses a broken attack/sword symbol, downward double chevrons and a shrinking duration underline. Boss/normal fade groups and split expiration remnants use actual active-time deadlines and reject superseded status applications. This represents lower enemy attack, never vulnerability.
- Delayed decelerating chips and independent opacity tails resolve naturally. Reduced Motion holds geometry stationary and fades once, retaining all recipient/status distinctions.
- A short original synthesized retaliation sound uses the existing eight-voice priority mixer, mute and modal suspension. No audio asset download or new audio system. Videos are silent; the separate WAV is the actual generated signature for listening review.

The quality reference was Six â†’ Seven V3's timing, contrast and resolved-contact discipline. No U keeps its own reversal hooks, alternating cyan/magenta ribbons and broken-attack vocabulary; neither Six â†’ Seven renderer changed.

## Executed verification

Godot **4.7.2 Compatibility**, actually executed on Windows / AMD Radeon RX 6800 XT:

- 53 reactive assertions and **4,800 V3-versus-historical-V2 identical authoritative frames** across both maps and densities. Eligibility, shields, survival, empty pulses, recursion, same-time hits, cooldown boundaries, exact weaken expiry, environment, victory, retry, cleanup and profile isolation pass. Explicit checks separate shield-only and lethal contacts.
- Preserved V1: **1,440 paired frames**, both maps/densities and lifecycle pass. Six â†’ Seven: **390 paired frames** pass.
- Ordinary gameplay: **1,320 frames** reproduce the existing production control state hashes exactly. Baseline Solo controller, V1 renderer/scenario, historical V2 renderer and both Six â†’ Seven renderer blobs are unchanged; see preservation.json.
- Actual final ordinary PCK excludes **all five No U experimental resources** and all QA/test resources. Actual review PCK includes the expected treatments and excludes QA/test resources. All ordinary platform presets retain exclusions. See package-verification.json and raw export/verification logs.
- Actual final exported review PCK passed **12 A/B/C picker/activation/profile-isolation cases**, including the V3 default and reactive readiness. Diagnostic loading used the official engine with the real exported PCK; no human EXE playtest is claimed.
- Native mixer diagnostic passed cue acceptance, eight-voice bound, mute, suspension and audio-only RNG isolation with Dummy audio output. No human listening approval claimed.
- Full existing [CI #365](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/45659447000) **passed** for exact playable source 37faa8d, including the full mandatory suite and actual ordinary/review exports. The Six → Seven-specific CI step was skipped by its existing scope condition; its local 390-frame integration test passed. CI-RESULT.json and the full CI log are included. Prior successful and failed diagnostic logs remain available; checks do not imply artistic acceptance.

## Performance

1280Ã—720, VSync disabled, 3.6 active seconds, first 35 frames excluded, screenshot/recorder readback disabled. Values are **medians of three alternating P95 runs**, milliseconds. Activation samples cover the first 29 frames from the resolved activation. Measurement includes CPU simulation through draw completion, not monitor scanout. A/B have intentionally different periodic combat; V2/C use matching reactive authoritative outcomes in every measured pair.

| Dense map / treatment | Frame P95 | Activation P95 |
|---|---:|---:|
| Ruin Alley / baseline A | 2.551 | 3.043 |
| Ruin Alley / Counter-Pulse V1 B | 2.824 | 4.158 |
| Ruin Alley / historical reactive V2 | 3.430 | 5.053 |
| Ruin Alley / Reverse Impact V3 C | 4.523 | 6.379 |
| Ruin Alley / V3 Reduced Motion | 4.288 | 6.087 |
| MSG Factory / baseline A | 2.322 | 2.938 |
| MSG Factory / Counter-Pulse V1 B | 2.985 | 4.317 |
| MSG Factory / historical reactive V2 | 3.345 | 4.830 |
| MSG Factory / Reverse Impact V3 C | 4.230 | 6.254 |
| MSG Factory / V3 Reduced Motion | 4.190 | 5.866 |

V3 versus V2 adds **1.093/0.885 ms** frame P95 and **1.326/1.424 ms** activation P95 on Ruin Alley/MSG Factory. This is a measured rendering regression accepted only as a creator-review tradeoff for smooth connected wave geometry, not a production acceptance. Maximum individual V3 activation P95 is 6.426 ms in this bounded desktop sample. The first unbatched attempt was substantially slower (~11/13 ms); those diagnostics are retained. Batched enemy feedback removes that principal overhead. Raw variance, individual runs and intermediate attempts are preserved.

Web, software rendering, mobile and physical-device performance **were not re-certified** in this native iteration. The historical V2 software-rendered Web limitation remains unresolved evidence, not a passing V3 result. Native timings do not establish a universal frame budget.

## Evidence and limits

The evidence ZIP contains normal-speed and 0.25Ã— A/B/C videos for Normal/Dense on **both maps**, Reduced Motion comparisons for both densities/maps, full-size V3-only videos, actual trigger/compression/burst/damage/weaken/decay/expiration screenshots, controlled lethal/shield-only/expiration tableaux, QA Recorder traces, all 30 final performance reports, preservation/packaging proof, logs and reproduction scripts. SHA-256 manifests identify delivered files.

A/B video sources are from fcb18f5, whose baseline/V1 simulation and renderer blobs are unchanged in final source. C/Reduced Motion captures and final timings use exact playable source 37faa8d. All comparisons use the same Sigma seed 451 and fixed 60 Hz inputs. 1Ã— footage shows actual activation timing; 0.25Ã— comparison clips explicitly align each treatment to its own activation. Compression and burst are presentation phases; gameplay damage remains immediate on resolution.

Dense stationary combat can defeat the player before weaken expires. Frozen frames are never labeled as expiration in the final capture harness. Clearly labeled controlled tableaux use the real damage resolver and explicit active-time sampling to show the 2 s boss and 4 s normal expiration, including the clean post-expiry state; they are not normal combat recordings. Prior frozen snapshots, unbatched/fully-batched treatments and measurements remain under history or diagnostic folders in the local evidence root. Existing Counter-Pulse V1 and V2 history/evidence are untouched.

The future-born weaken discrepancy and environmental HP-loss assumption remain exactly as documented for V2. This work makes no new canonical gameplay decision. Creator evaluation of impact, identity, Dense readability and sound remains pending. **Do not merge, deploy to production or infer final approval.**

## Reproduce

Run from the checkout using the pinned Godot 4.7.2 executable:

```text
godot --headless --path . --script res://tests/no_u/test_reverse_impact.gd
godot --headless --path . --script res://tests/no_u/test_counter_pulse.gd
godot --headless --path . --script res://tests/six_to_seven/test_integration.gd -- v3
godot --path . --audio-driver Dummy --script res://tests/no_u/capture_reverse.gd -- ruin-alley 2 reverse capture <absolute-output> 37faa8da7ae12d2fb982acf778fb9c3537c351d1
godot --path . --audio-driver Dummy --script res://tests/no_u/capture_v3_stages.gd -- <absolute-output>
python tests/six_to_seven/review_export.py --no-u --target windows --stage <fresh-absolute-stage>
godot --headless --path <stage> --import
godot --headless --path <stage> --export-release "No U Review" <absolute-output.exe>
python tests/six_to_seven/review_export.py --no-u --verify <absolute-output.pck>
```

The bundle's capture/measurement/assembly scripts run from the shared workspace root and record exact source SHA. CPK_NO_U_RENDERER=v2 switches only the measurement renderer to preserved V2; diagnostics can omit presentation layers without changing gameplay. These switches exist only in the excluded capture harness.
