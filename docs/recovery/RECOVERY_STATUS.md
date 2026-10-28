# M0.0 recovery — current implementation checkpoint

**Status: PARTIAL. PR #73 remains draft and unmerged. M0 is not accepted or released.**

The current mandate is [the attached M0 execution directive](CREATOR_M0_EXECUTION_DIRECTIVE_2026-10-25.md). The earlier directive and evidence remain in Git history and this directory. The canonical GDD V3 entered main through merged PR #75 (`9d1b44f7c5ec9ea62382b0e83161ee7e5295aa1f`). Recovery was continued by merging that main revision into the existing branch, preserving the original deferred-legendary fix and provenance. No competing recovery PR was created.

## Latest combat checkpoint

Runtime `ef089759553ec3691b5bbf2e72d958908b05c3b2` adds bounded hit/death/pickup feedback, weapon geometry cues, larger reward/equipment art, consistent HP rounding and collectible phase XP. **48 Godot phases, 11 Python tests and Node checks pass in [CI run 40373810656](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/40373810656).** See [combat recovery report](COMBAT_RECOVERY_REPORT.md) for current source identity and limitations. New local media was lost before publication and must be regenerated; older captures below remain historical.

## Earlier UI checkpoint

- Live Clean Cut pause, build inspection, settings, exit confirmation, profile import/export and victory/defeat flows reuse the original signal-bound controls.
- Presentation revision invalidation prevents legacy layout/styles from overwriting the cached skin. Idle refreshes reuse layout and styles; keyboard focus follows the visible production controls.
- Held-pointer regression covers pause/build/settings/sound/quit/STAY/resume/retry at desktop, landscape and portrait sizes. Existing legendary defer/reopen tests remain passing.
- XP text is separate from its progress bar. The illustrative blue segment embedded in the approved SVG is masked by actual progress; zero and half-progress assertions prevent misleading data. Empty HUD slots no longer paint repeated name plates; desktop equipment occupies one row.
- Safe Spot retains its exact 68 U activation boundary and original behavior with a smaller center marker. Big Hater's approved Berserk artwork now follows the canonical 720-second boundary instead of the stale 1080-second presentation threshold.
- Production exports exclude all test/review scripts, with a PCK regression and actual export inspection. Approved artwork bytes are unchanged.

## Verified evidence

Runtime revision: `c30bb05bf612aa6075019feebef1fb8898950172`; complete source tree `606ba810c7771f8f867bf23ae4da18aa76a0e4de`. Local equivalent revision `5f4c46bdb520dbe067da56896f17599152295fa2` has the identical tree.

| Check | Actual outcome |
| --- | --- |
| Full local validation | **47 Godot phases, 11 Python tests, Node lifecycle checks PASS** |
| GitHub CI on runtime revision | **PASS**, [run 140](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/40243934011) |
| Web export and actual PCK inspection | **PASS**: 19 original masters, 37 icons, 84 Clean Cut resources, zero candidate/test entries |
| Native render | **87 staged screenshots** across 1280×720, 915×412 and 390×844; 16 current plus three baseline screenshots retained in this PR |
| Navigation diagnostic | **2,048 static-cover trajectories, zero reproduced stalls**; navigation code unchanged |
| Normal-health scripted regression | Sigma, seed 451, strategic controller: **victory at 674.7167 s**; no HP/XP/clock/damage grants; not human or Web play |
| Performance diagnostic | Seven fixed-seed staged scenes with simulation plus native software rendering; skin refresh mean decreases in every compared scene. Overall frame times vary; no physical-device FPS claim |

See [the validation report](M0_UI_VALIDATION_REPORT.md), [capture inventory](evidence/m0-ui/captures.json), and retained raw logs for exact scope and limitations.

## Remaining defects and acceptance gates

| ID | Area | Current status / next evidence |
| --- | --- | --- |
| R01 | Deferred legendary access | Verified by real Viewport pointer regression; owner review remains separate |
| R02 | Secondary UI fallback | Implemented and input-tested, current native captures available; final creator visual approval pending |
| R03 | HUD hierarchy | XP and inventory corrections implemented; full dense-combat/mobile visual acceptance remains open |
| R04 | UI refresh cost | Implemented, cache regression and before/after diagnostic measured; real browser/device performance remains open |
| R05 | Enemy pursuit / combat feel | Static-cover sweep passes; no new stall reproduction and no AI/balance changes. Human dense-play review remains open |
| R06 | Touch / joystick | Existing event-routing suite passes; real multitouch browser/device ergonomics remain unverified |
| R08 | Graphical execution | Native X11/Compatibility rendering now works. Earlier missing-display blocker is resolved for native only |
| R09 | Berserk artwork timing | Corrected and boundary-tested at 719.99 / 720 / 800 seconds; simulation timing unchanged |
| R10 | Illustrative XP in approved source | Masked by live values, verified at zero and half progress; source artwork preserved |
| R11 | Web interaction / full-run recording | **Not verified**. Earlier Vercel permission obstacle was resolved; the observed cloud browser lacked WebGL2. Current-source human-run video and physical-device QA remain pending |
| R12 | Phase-transition crystal | Implemented in `ef08975`: collectible 80/120/160/200 XP at canonical phase boundaries; progression, clock, collection and magnet regressions pass. Human presentation review remains pending |

Five-screen final composition/animation polish, all weapon/Flex visual states, full normal-play videos, complete device/browser QA and creator sign-off are **not complete**. Native staged captures, automated survival, green CI and a successful Web export do not establish those gates. No Phaser edits, new mechanics, balance adjustments, backend, new source artwork, manual public deployment, access expansion or merge were performed.
