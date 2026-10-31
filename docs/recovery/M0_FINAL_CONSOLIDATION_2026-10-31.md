# M0 final consolidation recommendation — 31 October 2026

**No merge or production deployment is authorized.** The existing integration can supply a protected review candidate; full visual consolidation into canonical main remains blocked on exact source approvals, not on another movement or typography redesign.

## Reverified refs

| Role | Exact source / disposition |
| --- | --- |
| Canonical main | `bc690618ac1183e078c2ba84cf49af9839d2d794`, including PR #84 §8.2 typography acceptance. Preserve this contract. |
| Actual production | `05bcef23ae0f040795cacd88e42542b55bc6488e`; READY deployment `dpl_BVt9GgzKfedAsRsS3FpomqoP3Vky`, verified production build metadata. |
| Integration after creator-accepted #91 | `cbdc63776db807ee3082ba3b54920665a5a2b6f3`. Its tree is identical to tested #91 head `bfab07e55c0130416199cc5cfaf2180c35942e22`. It is newer than production. |
| #92 — technical main proposal | `4bea450ff499269281a40655740dae9157acb08a`, branch `reconcile/m0-validated-technical`, Draft/unmerged. [CI success](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/41153193424); official Web export/build identity previously verified and source/head unchanged. |
| #93 — footer / current RC | Existing branch `fix/m0-card-footer-safe-inset`, initial runtime commit `541ec8988543152de169c438538a60ef63e87a81`. [Initial actual CI success](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/41198340165). This work appends validation/evidence/docs to the same PR; final head, final mandatory CI and exact preview are recorded in [#93](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/93). No competing footer branch. |

There are **2 main-only / 41 integration-only commits** by ancestry after #91. The footer runtime differs from main at **659 paths**; this includes historical retained evidence and semantic duplicates of #85. [Current classified inventory](evidence/m0-final-2026-10-31/current-reconciliation.json) explicitly compares main, production, integration and the footer runtime. Subsequent test/doc additions are enumerated in #93's file list, not silently counted as runtime divergence. The original detailed [PR #80–#90 commit/file analysis](https://github.com/pedro-ai-coder/aura-farmer-godot/blob/4bea450ff499269281a40655740dae9157acb08a/docs/recovery/M0_MAIN_RECONCILIATION_2026-10-31.md) remains applicable with these updated heads.

## PR recommendations

**#92:** technically safe to approve for an independently authorized merge into main. Its sole runtime change is the already validated exact floor-clearance cache. `solo_world_rules.gd` SHA-256 `10571113e0cdf3c7d3c29056f173c061046011440963ef9e517c62a4a1b51c0d` equals integration's implementation, so do not copy or recreate the optimization in another PR. Its frozen-main test passed 388,512 differential comparisons. Main GDD, art, Web adapter, saves, values and navigation policy are unchanged. CI/export apply to its own exact head; they do not approve integration art. Historical assessment docs in #92 are superseded by the final acceptance report where #91 acceptance and #93 resolution change a status. No code amendment to #92 is needed solely to update that historical account.

**#93:** recommend approval after its final mandatory CI/export is green and the creator reviews the small footer change. Keep its target on integration. The existing runtime fix moves the label edge inward by 44 logical units; it does not alter hit rectangles or artwork. This work strengthens actual pointer/scroll/keyboard/selected-state coverage across all six viewports, including five-passive replacement, and supplies exact before/after evidence. Do not infer a production deployment or source-art approval from its mergeability.

No other independently actionable technical P0 was reproduced in the executed scopes. Other main differences are either already consolidated by #85, optional diagnostics, or dependency-coupled UI presentation. Do not manufacture another optimization or duplicate #93 merely to create a new PR.

## Exact source approval boundary

The [grouped approval ledger](evidence/m0-final-2026-10-31/source-approval-ledger.json) supplies every path/hash and bundle identifier. It is a **proposal, not an approval registry**.

| Source class | Current treatment / integration rule |
| --- | --- |
| Approved exact sources | 19 masters, 37 icons and 84 Clean Cut promoted resources remain byte-immutable. Existing Barlow resources and approved wordmark PNG/SVG remain retained. Five future-only passive icons do not become gameplay offers. |
| Candidate L | Current Archivo Black/Archivo binaries, OFL/provenance and procedural logo/typography source. Already shared by main/integration; merged presence does not promote them. Explicit exact-source supersession is still needed. |
| Candidate B | 24 button runtime PNGs, 24 editable SVGs and manifest. Four coherent families/six states; current game depends on these. Removing them changes the tested appearance. |
| Candidate H | 20 HUD SVGs, portrait-crop shader, manifest/generator. Depends on the live HUD, meters, circle/Flex and reserved geometry. Removing them changes accepted HUD composition. |
| Superseded/historical | Diamond/rectangular/left-only joystick treatments are superseded by the approved circular full-playfield control. Older generic V5/pre-correction compositions remain history where corrected V2 supersedes them. Do not revoke unrelated approved hashes by implication. |
| Review-only | `assets/art-production/**` as a library, generators, test fixtures, screenshots and new recovery evidence. Exact individually approved source selections retain their approval; the directory is not wholesale shipping approval. |
| Runtime/export dependency | Approved original art/icons plus the integrated candidate controls/fonts and existing HUD shader. This is a dependency classification, not permission to approve sources. Maintain ordinary Web exclusions for review/diagnostic content. |

Potential supersessions must name the exact originals: approved wordmark raster `49eb4d1054d6675a5dad42ec3fa0352d202564e3aa655487d69365b2b9e83255` and its recorded SVG; Barlow baseline versus batch L; approved primary/secondary/selection usage versus B; approved HP/wave/pause/XP/equipment/Flex visual usage versus H. Preserve old bytes and approval history. The footer inset itself changes no asset identity.

## Ready-to-execute clean sequence after authorization

1. **Preserve checkpoints:** main `bc69061`, production `05bcef2`/deployment above, accepted integration `cbdc637`, and final #93 exact head/preview. No force update, alias promotion or save migration.
2. **Land only authorized technical work:** #92 may land independently of #93. #93 may land on integration after its review; neither action is executed here. Do not merge old stacked #80/#81/#82 wholesale.
3. **Record source decisions:** obtain exact L/B/H decisions and explicit rendered #76 acceptance. Add a source/version/supersession record as a separate approved governance commit; keep main's §8.2 contract. Generic “the style looks good” is not that record.
4. **From then-current main, stage coupled UI slices:** approved B/H resources and loaders; `hero_clash_button_art.gd`, `hero_clash_button_feedback.gd`, `hero_clash_scene_accent.gd`; `hero_clash_hud.gd`, `hero_clash_hud_meter.gd`, `hero_clash_flex_dial.gd`; compatible `clean_cut_skin.gd` / `clean_cut_secondary.gd` bindings. Keep the footer inset. Port accepted `hero_clash_threat_overlay.gd` together with its HUD reserved-region/bounds interface and all no-fade/visibility/priority regressions. It cannot be cherry-picked into main's older HUD alone.
5. **Resolve mixed technical/UI files explicitly:** preserve #85's navigation/spawn/touch fixes already in main. `solo_run.gd` differences mix optional probes with Safe Spot placement/context tied to `gameplay_hud.safe_label_origin`; do not replace the entire file or alter canonical calculations. Keep `enemy_navigation.gd`, `profile_store.gd`, IDs/clocks/rules/animation contracts authoritative. Optional `performance_probe.gd`, `web/performance.js` and performance export hooks are not ordinary-release prerequisites.
6. **Port Web resources atomically:** existing styled fullscreen DOM controls depend on candidate B images and L font/license files, associated skin coordinate publication, `web/platform.js`, export presets and `build_web.sh`. Preserve trusted gesture/refusal/retry, orientation/safe areas, CSS touch mapping and compact DPR cap. Include only explicitly approved runtime paths; exclude `assets/art-production`, authoring/review files, tests and performance diagnostics. Keep ordinary preset features empty and validate candidate/approved manifests correctly for the selected source status.
7. **Port corresponding tests with each slice:** button-art, HUD V2/edge layouts, mobile fluency/touch, UI cohesion/final polish/threat, footer/Legendary/keyboard/replacement/secondary input, browser adapter and geometry/state traces. Preserve all existing main tests and source hashes. Do not drop an assertion because a partial dependency port fails.
8. **Validate the assembled exact head:** official 4.7.2 import; full mandatory gameplay/RNG/navigation/collision/profile/UI suites; six viewport native interaction/layout evidence; approved/candidate hash and license checks; official Web/PCK verification; protected build metadata; supported interactive Web and final owner acceptance. No full visual-integration branch is misleadingly labelled release-ready before approvals.

Recommended decisions are separate: authorize #92, authorize #93 on integration, authorize exact L/B/H/#76 source integration, then authorize the assembled restricted-release build. The first two can be reviewed independently. No branch merge authorizes opening the tester cohort.

## Rollback

Production is unchanged and can remain on the verified `dpl_BVt9GgzKfedAsRsS3FpomqoP3Vky` while all review work proceeds. If later authorized, revert #93's narrow UI commit independently to return to `cbdc637`; revert #92's scoped cache commit independently on main. Preserve all approved source objects and profiles. Future visual slices should be individual dependency-complete commits so they can be reverted coherently. Restoring/promoting a Vercel deployment is a separately authorized release action, not executed as part of this recommendation.
