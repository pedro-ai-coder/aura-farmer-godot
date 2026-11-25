# No U Reverse Impact V2 delivery

**EXPERIMENTAL — NOT CANONICAL — NOT APPROVED FOR PRODUCTION.** Creator gameplay/artistic acceptance remains pending.

- [Protected playable Preview](https://aura-farmer-godot-5u7lea9ii-pedroestrela6-8110.vercel.app/) — Vercel account authentication required; bare URL redirects to Vercel login. Deployment `dpl_FbfWQiF3jL9YTH2kD4QVHf8RELYq`, Preview (`staging` API target), READY. No production publication or merge.
- [Separate Draft PR #163](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/163), stacked on preserved V1 #162 for a focused diff.
- Exact playable source: `67287673e8a68e2a3ac9a5ce480d3568177e5b8f`.
- Production baseline: `1c2ec76cd06d6f1485a79fbbee97ccfac70ac5c8`.
- V1: `be7f478946f21fa190efd34bc3107603ef209ddf`. Both approved Six to Seven renderer blobs and both V1 review renderer/scenario blobs are unchanged.

## Gameplay and technical QA

Godot 4.7.2 Compatibility actually executed: 49 V2 assertions and 4,800 identical-input paired authoritative frames; 1,440 V1 paired frames; 1,320 final ordinary-versus-production exact state frames; 390 Six to Seven integration frames. All PASS. Boundary tests include partial/full shields, fatal/nonpositive damage, environment, radius, boss/normal weaken, exact expiry, same-time events, recursion, attacker death during contact, lethal outgoing damage, pause, retry, menu cleanup and no profile writes.

[CI #362](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/45588346953) passed the full existing regression suite plus V1/V2 and actual ordinary/review export checks. The Six to Seven review-only CI step was skipped by its scope condition; its local integration test passed. Ordinary packages exclude all four No U resources. QA fixtures use the real Garage, combat and equipment systems. No RNG calls, save schema changes, progression changes or approved asset edits were added.

The exact protected build passed 20 authenticated Chrome functional cases: A/B/C x Normal/Dense x both maps, Reduced Motion on both, and six selectable V2 damage cases. Recharge reactivated after its 15-second deadline; fatal incoming damage produced defeat without a pulse; shield-only input did not trigger until later genuine HP loss. Every case checked browser storage isolation and script errors. Twelve additional screenshot-free browser measurements passed. Browser selection used Cool Kid; native captures used Sigma, consistently within each A/B/C comparison.

## Performance

Native: Windows / RX 6800 XT / 1280x720, VSync disabled, 3.6 active seconds, 35 warm-up frames excluded, no image readback or recorder. Values below are medians of three alternating P95s. Timing includes CPU simulation through draw completion, not GPU scanout.

| Dense scenario | A frame / activation ms | B frame / activation ms | C frame / activation ms |
|---|---:|---:|---:|
| Ruin Alley | 2.393 / 2.775 | 3.207 / 4.019 | 3.236 / 4.816 |
| MSG Factory | 2.362 / 3.053 | 2.892 / 4.098 | 3.123 / 4.597 |

C versus B increased native frame P95 by 0.029/0.231 ms and activation P95 by 0.797/0.499 ms. Investigation identified additional reversal geometry/status backing and a later, intentionally different combat state at activation; these measurements do not isolate renderer-only cost. Median activation P95 remains below 5 ms; one individual C run measured 5.264 ms. Raw samples retain variance/outliers. The first pass accidentally included post-defeat frames, was retained separately, and was replaced by the active-only pass above.

Web: existing `web/performance.js`, injected locally through DevTools; only visible/playing RAF callbacks, screenshots and pause disabled for measurement. One bounded run per treatment/map/backend, not a physical-device certification. No instrumentation was added to the shipped Preview.

| Dense Web backend / map | A P95 ms | B P95 ms | C P95 ms |
|---|---:|---:|---:|
| RX 6800 XT / D3D11 / Ruin Alley | 16.8 | 16.8 | 16.8 |
| RX 6800 XT / D3D11 / MSG Factory | 16.8 | 16.8 | 16.8 |
| SwiftShader software / Ruin Alley | 33.4 | 83.3 | 100.2 |
| SwiftShader software / MSG Factory | 33.5 | 100.1 | 100.1 |

Hardware-accelerated Chrome confirms the adapter in every report. The software-rendered tail is a material known limitation: both candidate treatments are substantially slower than A, with C around 100 ms P95. The hardware comparison distinguishes this from a general 60 Hz Web regression on this desktop, but does not establish acceptable low-end/mobile/software performance. Creator/device evaluation and any later optimization remain separate; no automatic artistic acceptance is inferred.

## Evidence and reproduction

The downloadable creator bundle contains ten silent side-by-side videos (normal/quarter-speed, Normal/Dense, both maps, Reduced Motion), activation/damage/weaken screenshots, fourteen QA Recorder ZIPs, raw native/Web performance reports, final browser console traces, source/baseline state hashes, full CI log, test logs, reproduction helpers and SHA-256 manifest. Videos use the same seed 451 and input schedule; quarter-speed explicitly aligns each treatment to its own activation. V2 gameplay is intentionally different. Native captures use 596ce02 with renderer bytes identical to final source; final changes only refine the QA caption, measurement harness/tests and CI trigger. Final native measurements, Web checks and CI use playable source 6728767.

Run commands and the compact [creator checklist](NO_U_REVERSE_IMPACT_V2.md#creator-acceptance) are in `NO_U_REVERSE_IMPACT_V2.md`. `AI_ACTION_AUDIT_NO_U_V2.md` is append-only and records retries, failures, deviations and skipped validation. Delivery documentation may advance the Draft PR head beyond the exact playable source; no runtime changes follow that source.

## Unresolved decisions and review limits

- Environmental HP loss is eligible only under the documented experimental assumption; canonical eligibility still needs a creator decision.
- Future-born damage/weaken discrepancy is preserved: unborn enemies reject damage but can receive weaken, displayed after birth if still active.
- Dense stationary combat crowds overlap and can defeat the player before weaken expiry. Use Normal or move to evaluate the longer status/cooldown. No survivability changes were added.
- Software-rendered Web performance is limited; no mobile/physical-device certification or human playtest/artistic approval is claimed.
- This experiment remains a Draft, dependent on V1 for the focused diff. Do not merge, promote to canon or deploy to production.
