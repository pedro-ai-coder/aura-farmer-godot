# Full visual and gameplay recovery — execution checkpoint

Status: **PARTIALLY COMPLETE; rendered baseline and final visual acceptance BLOCKED.**

This is an initial recovery checkpoint, not the final game requested by the creator. The exact mandate is retained in `CREATOR_RECOVERY_DIRECTIVE_2026-10-24.md`. No gate is accepted solely because tests pass.

## Reproducible starting point

- Repository: `pedro-ai-coder/aura-farmer-godot`.
- Base: `main`, `d1c0de06d09910e9cba330b6e964a266b102684d`.
- Isolated branch: `recovery/full-visual-gameplay`.
- Open Godot PR inventory at intake: none returned by GitHub.
- Original Phaser project is reference-only and has not been modified.
- Engine downloaded and checked against the repository's pinned SHA-256: Godot 4.7.2, `cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`.
- Original actor/world resources: all 19 downloaded through the pinned manifest and byte/hash verification.
- Current main already integrates the approved Clean Cut V2 skin and recent held-pointer fixes. It is not appropriate to start from the old V5 layout or recreate the icon batch.
- Prior rendered images in `docs/art/evidence/clean-cut-v2-review/` are historical staged captures. They are not current-commit captures and do not prove a full run. A last known *creator-preferred* playable commit has not yet been established.

## Source authority and discrepancies

`source-inventory.json` pins located baseline sources. It is a partial inventory, not a claim that all historical documents and visual references have been audited.

| Source | Authority / usage | Intake result |
| --- | --- | --- |
| Latest attached recovery directive | Current explicit creator mandate | Transcribed with normalized whitespace; rejects the current experience, authorizes recovery and prohibits automatic merge |
| `docs/GDD.md` | Canonical gameplay and platform rules | Located; relevant UI/input/progression and precedence sections inspected; full rule-by-rule audit remains open |
| `docs/GDD_SOURCE.md` | GDD provenance | Canonical Godot edition supersedes original Phaser import |
| `docs/art/CREATOR_ICON_APPROVAL_2026-10-24.md` | Exact icon byte approval | Eight V5 weapons + 28 V5 passives + separately approved Touch Grass V2 = 37; preserve all 37 |
| `docs/art/CREATOR_CLEAN_CUT_V2_APPROVAL_2026-10-24.md` | Exact five-screen component approval | PR 69 source `c1e13cdca5e0645e5f809dc6453ee75f979c8d4e`; 84 promoted resources |
| `assets/approved-assets.json` | Original actor/world provenance | 19 pinned resources verified after download |
| `assets/runtime-clean-cut/v2/manifest.json` | Production resource mapping | All 84 hashes match approved sources |
| `assets/runtime-icons/manifest.json` | Runtime icon mapping | Existing pipeline tests pass; current runtime rendering still needs visual inspection |
| `docs/art/HERO_SPOTLIGHT_V5.md` | Historical visual foundation | Located; later Clean Cut decisions supersede conflicting treatments |
| `docs/art/CLEAN_CUT_V2_INTEGRATION.md` | Historical integration log | Contains obsolete paragraphs about PR 69 being open and approval pending; latest dated approval and current Git history take precedence |
| Existing scene/code | Implementation evidence only | Must not override GDD or creator approvals |

The latest rejection concerns the integrated experience. It does not revoke the explicit instruction to preserve approved icon and character bytes. Older repo restrictions on producing art do not negate the new recovery authorization; new art must still respect identities and declared approval status.

## Discrepancy matrix

| ID / severity | System | Expected | Observed evidence / cause | Correction and validation | Status |
| --- | --- | --- | --- | --- | --- |
| R01 / P1 | Deferred legendary action | Player can reopen the same six legal offers during the canonical window using visible UI | `legendary_button` remains under hidden `ArcadePresentation`; actual held-pointer regression fails at 1280×720, 915×412, 390×844 | Move the existing action into the live skin; preserve signal, offers, timing and spent state; verify pointer navigation, safe bounds and Flex separation | PASS after fix (headless pointer regression); rendered review pending |
| R02 / P1 | Secondary screens | Coherent Clean Cut presentation throughout the player journey | `clean_cut_skin.refresh()` disables itself outside menu/heroes/playing/choice/legendary/replace and returns to the legacy presentation | Audit and rebuild pause/settings/results/profile/confirmation with live controls and approved resources; capture each transition | NOT TESTED visually; architectural fallback confirmed |
| R03 / P1 | HUD hierarchy | HP/XP/time/equipment legible and combat primary | Historical `playing-1600x900.jpg` shows XP label intersecting its bar, large empty-slot labels and dominant Safe Spot marker | Reproduce current commit first; measure label/control rectangles, then redesign layout without changing recovery rules | NOT TESTED on current rendered build |
| R04 / P1 | UI CPU cost | Static layout/styles should not be rebuilt unnecessarily | Skin `_process` calls full refresh every frame; HUD creates fresh `StyleBoxEmpty` and eight label `StyleBoxFlat` resources per refresh | Profile current live frame cost, cache invariant resources and update layout on invalidation; compare equivalent scenes | NOT TESTED performance; code path confirmed |
| R05 / P1 | Enemy pursuit and combat feel | GDD behavior, no unexplained stalls | Creator report; no fresh rendered reproduction in this environment | Reproduce by enemy/state/position and record traces before changing AI or balance | NOT TESTED in live play |
| R06 / P1 | Joystick | Circular first-touch control across safe terrain; independent Flex touch | Existing code and selected assets already implement circular presentation and full-playfield ownership | Execute existing tests; still require rendered multitouch and device ergonomics evidence | NOT TESTED visually/on device |
| R07 / P2 | Approval/status documentation | Current approval and integration status unambiguous | Historical integration log retains mutually outdated milestones | Treat immutable approval ledger as authoritative; reconcile historical wording separately | OPEN |
| R08 / P0 delivery blocker | Rendered baseline, screenshots, recordings and FPS | Real Godot rendered evidence | Native launch fails: no X11 display; Wayland initialization fails; no Xvfb executable; local package download reports no xvfb package | Resume in a graphical Godot environment; retain headless results as technical-only evidence | BLOCKED |

## Environment limit

The engine executes in headless mode, but native graphical launch fails with `X11 Display is not available`, followed by Wayland/DisplayServer initialization errors. `apt-get download xvfb` returned `Unable to locate package xvfb`. A further attempt to refresh package indexes into workspace-local directories failed because the package transport could not call setgroups/seteuid in this runtime. This session has no validated graphical runner. Headless execution must not be reported as rendered gameplay, mobile device validation, video evidence or FPS.

No engine substitution, artwork approximation or changes to canonical balance are justified by this environment limitation.

## Acceptance gates

| Gate | Status | Remaining requirement |
| --- | --- | --- |
| 0 — complete audit and baseline | BLOCKED | Current rendered baseline, preferred prior revision, full source/discrepancy audit |
| 1 — final visual system | NOT TESTED | Visual fidelity, reusable component and interaction-state review |
| 2 — gameplay presentation | NOT TESTED | Early/dense/low-health visual review |
| 3 — movement/combat/AI feel | NOT TESTED | Live reproduction, corrections and complete attack evidence |
| 4 — HUD and touch | NOT TESTED | Final HUD and rendered multitouch/device evidence |
| 5 — five screens | NOT TESTED | Desktop/mobile actual-build captures and interactions |
| 6 — remaining interface | FAIL | Confirmed legacy fallback remains |
| 7 — complete integrated run | NOT TESTED | Uninterrupted normal full run and regression evidence |
| 8 — performance and technical quality | NOT TESTED | Measured complete-game frame times on identified targets |
| Final delivery | BLOCKED | Playable reviewed build, videos A–D, comparison where recoverable, complete acceptance matrix |

## Continue in a graphical environment

1. Check out the recovery branch and re-check current PR/asset overlap.
2. Verify source and runtime manifests; do not regenerate the 37 approved icons.
3. Run `python3 scripts/sync_approved_assets.py`, then `bash scripts/validate.sh` with Godot 4.7.2 available.
4. Capture the base commit and recovery branch using the same viewport, seed, hero and game state. Record whether each capture is staged or continuous play.
5. Complete Gate 0 and implement the remaining phases in the creator's order. R01 is only an initial functional regression correction.
6. Deliver a full playable run, visual walkthrough, multitouch demonstration and combat/AI recording; measure simulation plus rendering rather than reusing the old render-only benchmark as full-game FPS.
7. Request creator review of the concrete implementation/evidence. Do not automatically merge.

## Executed validation

- Baseline: **45 Godot phases PASS**, 11 Python tests PASS, Node browser-lifecycle adapter checks PASS.
- Recovery: **46 Godot phases PASS**, 11 Python tests PASS, Node checks PASS, including the new real Viewport held-pointer regression.
- New regression failed on the base implementation at all three viewports and passed after the correction. It covers re-entry without reroll, safe bounds, Flex separation, deadline and spent-state visibility.
- All 84 immutable Clean Cut resources and 19 original actor/world resources verified. Approved artwork bytes and gameplay rule files are unchanged.
- These are headless technical checks, not full visual, FPS, browser/device or uninterrupted gameplay acceptance.
- Raw logs and `evidence/validation-summary.json` accompany this checkpoint. No current rendered screenshot, video or final build is claimed.
