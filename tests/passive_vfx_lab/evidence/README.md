# Passive VFX V1 session and evidence

Session date **2026-11-23** (Europe/Lisbon). Game baseline `34767716e1c9b5ecb6e7361e6aced6d13d052817`. Tested source `81a47c47872124a2a91021e285fdea0ac15765e6` on `feat/passive-vfx-lab-v1`. Godot 4.7.2 Compatibility on Windows with an AMD Radeon RX 6800 XT. All lab runs are synthetic fixtures at seed 451. The Chrome check is a separate automated opening of the production export.

## Captures

| Evidence | What to look for |
| --- | --- |
| [Normal speed](six-to-seven-normal.mp4) · [Quarter speed](six-to-seven-slow.mp4) | The player marks 6/7 at the feet. The next qualifying hit centers the proposed blast on the struck enemy. |
| [Armed](six-to-seven-armed.webp) · [Impact](six-to-seven-impact.webp) | Three enemies in the low-density fixture lost 35 HP each to the same resolved burst in both panels. The armored enemy to the right is outside the blast. |
| [Dense playback](six-to-seven-dense.mp4) · [Dense impact](six-to-seven-dense.webp) | Three weapons, five passives, five recorded burst contacts, a concurrent No U pulse and a red hostile warning. |
| [Reduced Motion](six-to-seven-reduced.webp) | The static perimeter and target marks remain. Radial motion and the onset flash are absent. |
| [Landscape](landscape.webp) · [Portrait](portrait.webp) | Native captures at the requested 844×390 and 390×844 window sizes. Portrait stacks the two views. |
| [Recovery](hud-recovery.webp) · [Ready](hud-ready.webp) | The ground effect has cleared. The existing passive slot shows recovery and then resumes progress after the lockout. |

The stills are genuine Godot viewport readbacks encoded to WebP. The videos are captured at 30 playback frames per second from fixed-step Godot frames and encoded to H.264. The traces bundle preserves each baseline and candidate QA Recorder ZIP. The data keeps exact contacts and includes the pre-staged synthetic provenance. [Capture records](captures.json) · [Trace ZIPs](session-traces.zip).

## Checks

| Check | Result |
| --- | --- |
| Lab | **PASS**. 9,660 paired state/RNG frames across 23 identities. Replay, 3 real weapon triggers, 35%/50% coefficients, exact 90 U boundary, excluded shield-only and unborn targets, two-second lockout, pause, restart, winning hit, HUD fit and legal dense loadouts. |
| Existing regressions | **PASS**. 19 suites, including 5,376 passive feedback and 3,456 weapon-presence state comparisons, six production HUD sizes, mobile joystick, combat, RNG, legendary effects, boss and continuous seeded three-hero runs. |
| Windows standalone | **PASS**. The export uses the separate local review project and its lab scene. Standalone boot and a native viewport capture succeeded. |
| Production Web | **PASS**. Parsed PCK directory excludes all lab and test resources. Exact release export booted in Windows headless Chrome/WebGL2. Real input opened the Garage map selection, entered Ruin Alley and moved during an active run. |
| Physical mobile | **NOT RUN**. Native portrait and landscape evidence covers layout. Device touch comfort, thermal behavior and physical mobile rendering/pacing remain unmeasured. |
| Approval and later passes | **BLOCKED on creator review** for the proposed visual language. Remaining passives have audited priorities and design contracts. |

[Lab log](lab-tests.log) · [Regression log](regressions-final.log) · [Web log](web-browser-playing.log) · [Production pack check](production-pack-check.log) · [Review pack check](review-pack-check.log).

## Performance

See the paired metrics and per-frame data in [validation.json](validation.json) and [performance.json.gz](performance.json.gz). Six alternating blocks per density, each with 120 active 60 Hz simulation steps and one native 1200×740 viewport. The window and game scenes were rendered. The reported wall timings encompass callback-to-render completion with no screenshot readback or MP4 encode. This test characterizes the proposed effect's local cost under the recorded load.

| Fixture | Whole-block frame P95 baseline → candidate | Burst-window frame P95 baseline → candidate |
| --- | --- | --- |
| Low density | 1.316 → 1.275 ms | 1.187 → 1.829 ms |
| Dense with overlap | 1.973 → 2.206 ms | 2.119 → 2.404 ms |

These are medians of three per-block P95s. The burst window exposes the added cost more clearly than the whole block. The small whole-block decrease in low density is measurement variation.

## Audit record

- Verified authenticated GitHub and HTTPS identity as `pedro-ai-coder` and Git author/committer email as `pestrela@proton.me`. Used a dedicated worktree from game main and one scoped draft per repository guidance.
- Read GDD V3, decision and asset records, current main, game PRs #154 and #155, and the exact QA Recorder and Scenario Mode PR heads. Canon SHA `8f9d4f7e1ee589a8857478e281986054ed9b0e6c`, art SHA `7fbd6d31331e2b5c463f824efd6aa3ef7c7984fc`, QA SHA `fba982b35d3838f7dd34c9c58e13129fda81a031`, evidence-index SHA `af57dc861cdd31bc5b948872247edce7d24a78f3`, Recorder PR #103 `8449b0a9207f2ec9c4899a779592fde82913e1ea`, Scenario PR #105 `8900fcf9576fce89d75be2b6dd8c69fcb093888a`. [QA Recorder #103](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/103) · [Scenario Mode #105](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/105).
- Reused the recorder and the legal build validator in the excluded lab. Production changes are limited to an optional post-resolution event. No rules, saves or approved asset bytes changed.
- An initial video encode rejected an odd framebuffer height. The successful encode pads to even dimensions. A hand-written pack count expected 14 resources, while Godot emits 13 entries under the lab path with the scene binary in its remap directory. The passing check verifies real pack paths and isolation.
- Native QA exposed a clipped split-pane HUD and a dense capture interrupted by operating-system focus changes. The lab now fits the HUD to each viewport and owns the shared interactive pause. Automated capture keeps its fixed clock. Both cases have regression checks and successful native recaptures.
- A shell-based local Web server attempt was rejected by automatic execution review. The localhost check completed with an in-process Node HTTP server and the workspace's existing Chrome automation pattern.
- This tracked report and its hashes are the session record. The evidence repository had no designated append-only entry for this sprint. Source and findings remain reviewable through the game draft.
