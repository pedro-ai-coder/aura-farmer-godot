# M0 main reconciliation — 31 October 2026

The threat recovery is reviewable in [Draft PR #91](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/91). A separate technical reconciliation branch proposes only the existing exact floor-clearance cache for `main`, its differential regression, and review documentation. It does not import the candidate HUD/buttons, alter approved artwork, or reconcile the complete visual integration. No merge or production deployment is authorized.

## Exact comparison

| Role | Ref / full commit |
| --- | --- |
| Canonical main | `main` — `bc690618ac1183e078c2ba84cf49af9839d2d794` |
| Published and creator-tested integration | `fix/m0-navigation-ui-recovery` — `05bcef23ae0f040795cacd88e42542b55bc6488e` |
| Threat recovery / device review candidate | `fix/m0-threat-indicator-recovery` — `bfab07e55c0130416199cc5cfaf2180c35942e22` |
| Common ancestor | `201127a6377f2a8d557d5edc51b63e4f426e2273` |
| Safe technical proposal | `reconcile/m0-validated-technical`, based directly on the main commit above |

There are **2 main-only / 39 integration-only commits by ancestry**, but PR #85 selectively reproduced earlier fixes. An ancestry count is not a missing-feature count. Main versus the recovery has **657 different paths**, predominantly retained review evidence. The [complete file/commit inventory](evidence/overnight-2026-10-31/reconciliation-inventory.json) lists every path, all three Git object IDs, latest integration change, classification, and all 41 divergent commits. [Verified remote PR/build metadata](evidence/overnight-2026-10-31/verification.json) records the source review chain.

## Historical PR disposition

| PR | Verified disposition | Reconciliation meaning |
| --- | --- | --- |
| #80 | Closed, not merged; head `9f3cc26` | Functional Quit/hero/Shield work was selectively consolidated by #85. Do not merge the full animation experiment chain again. |
| #81 | Closed, not merged; head `09ad704` | Original button candidates remain retrievable. Presence through descendant integration is not exact-art approval. |
| #82 | Closed, not merged; head snapshot `f94282f` | Navigation, touch fast path, fullscreen and DPR subset already in #85. Its branch subsequently advanced to the published `05bcef2`. |
| #83 | Merged into integration, `f6034fc`; source `d93c63d` | HUD V2 components remain candidate artwork. Not present in main. |
| #84 | Merged into main, `6c9697b`; source `2f0179c` | Current §8.2 typography acceptance contract. Must survive consolidation. |
| #85 | Merged into main, `bc69061`; source `41715e9` | Selective technical consolidation, deliberately excluding candidate HUD/button art. |
| #86 | Merged into integration, `2e148a7`; source `bf8d81d` | `55d45f0` adds geometry cache and optional diagnostics; `bf8d81d` restricts diagnostic exports. Split these responsibilities. |
| #87 | Merged into integration, `8120019`; source `d948fc8` | Compact desktop HUD and contextual Safe Spot presentation depend on integrated HUD. |
| #88 | Merged into integration, `f94282f`; source `090989d` | Safe-edge HUD anchors and mobile layouts; candidate presentation dependencies. |
| #89 | Merged into integration, `7b5ca51`; source `03f26b1` | Build, Settings, results and max-level presentation. Not a new level/progression rule. |
| #90 | Merged into integration, `05bcef2`; final source `d5931f6` | Boss-health framing, Flex containment, threat overlay and later explicit permanent-HUD no-fade fixes (`ccc6bcd`, `6b83e78`, `d5931f6`). Preserve the final fixes, not an earlier fading implementation. |

## File-level decisions and dependencies

| Files | Actual difference / decision |
| --- | --- |
| `scripts/enemy_navigation.gd`, `scripts/floating_joystick.gd`, `tests/recovery_m01/test_navigation_stress.gd` | Byte-identical main/integration: cover steering, spawn/navigation stress and joystick baseline are already consolidated. No duplicate port. |
| `scripts/profile_store.gd`, `solo_clock.gd`, `solo_enemy_rules.gd`, `solo_offer_rules.gd`, `solo_passive_rules.gd`, `hero_animation.gd`, `approved_visuals.gd` | Byte-identical. No save-schema, content, scheduling, animation identity or approved-master replacement to reconcile. |
| `scripts/solo_world_rules.gd` | Independent cache absent from main. Port exact integration implementation: immutable edge lengths and conservative clearance certificates, original exact fallback, skipped zero-axis checks. No geometry, collider, RNG, speed or navigation-policy change. |
| `tests/main_reconciliation/{baseline_world,test_geometry}.gd` | Main-specific frozen reference and 388,512 differential floor/cover/axis comparisons. Only the reference's global `class_name` declaration is replaced for isolated loading. |
| `.github/workflows/godot-ci.yml`, `scripts/validate.sh` | Preserve main's workflows; append this Draft branch to the validation allowlist and register only the new geometry test. No required check disabled, trigger widened to push, or unrelated evidence job enabled. |
| `scripts/solo_run.gd` | Mixed optional instrumentation and later Safe Spot presentation, including calls into `gameplay_hud.safe_label_origin`. Do not wholesale replace main. Existing gameplay remains intact; diagnostics are not a prerequisite for the cache. |
| `scripts/performance_probe.gd`, `web/performance.js`, `scripts/web_platform.gd` | Opt-in review diagnostics. Retain source history, defer an independent port unless needed. Ordinary exports must exclude recorder code. |
| `web/platform.js`, `scripts/build_web.sh`, `scripts/promote_approved_icons.py`, `export_presets.cfg` | Main already has fullscreen gesture/refusal/retry, safe metrics, touch fast path and compact DPR cap. Later differences include candidate-art-backed DOM Settings and a diagnostic preset. Preserve main exclusions now; port visual resources and DOM styles together only after approval. |
| `scripts/clean_cut_skin.gd`, `clean_cut_secondary.gd` | Integrated UI references new HUD, button feedback and scene accents. Separating them from their source resources would change the tested appearance or break loading. Excluded from technical proposal. |
| `scripts/hero_clash_{hud,hud_meter,flex_dial,button_art,button_feedback,scene_accent,threat_overlay}.gd` | Live candidate UI dependency chain. Threat overlay relies on HUD reserved regions and sprite transforms; it cannot be cherry-picked alone into main's old HUD. #91 targets integration accordingly. |
| `scripts/verify_{button_candidates,hud_candidates,performance_export}.py` | Integration export checks accompany those dependencies. Do not weaken main's candidate exclusions to make a partial port pass. |
| `assets/ui-button-candidates/v1/**`, `assets/ui-hud-candidates/v2/**` | Candidate source/raster/SVG/shader manifests are not approved-art registries. Excluded from technical proposal. |
| `tests/{button_art,hud_v2,hud_edges,ui_cohesion,ui_final_polish,threat_indicator,frame_pacing,mobile_fluency}/**` | Review fixtures, evidence and integration-specific regressions. Retain immutable history; migrate applicable tests with the corresponding authorized implementation. Geometry reference/test are the isolated exception. |
| `tests/recovery_m01/test_layout.gd`, `test_clean_cut_secondary_input.gd`, `test_m0_interface_fixes.gd`, `test_flex_readability.gd`, `test_spotlight_theme.gd`, `test_hero_clash_button_motion.gd`, `test_web_platform.cjs` | Later assertions describe integration's candidate controls. Preserve main tests now; reconcile individual assertions with selected UI, not by dropping them. Remaining helper/evidence paths are enumerated in the inventory. |
| `docs/GDD.md` | Integration lacks PR #84's final typography acceptance text. **Preserve main verbatim**, including source/font/wordmark approval and actual rendered acceptance. Do not restore the older integration paragraph. |
| `docs/recovery/M0_TECHNICAL_CONSOLIDATION_2026-10-29.md` | Main-only #85 record. Preserve it; an integration tree replacement would delete it. |

The safe proposal changes one runtime file. The cache was validated afresh against **main's** collision implementation; 388,512 comparisons passed. Full mandatory main-branch CI and its official Web export must pass on the final reconciliation PR head. These checks do not validate integration's candidate art or replace #91's device review.

## Exact artwork boundaries

The [213-entry classification](evidence/overnight-2026-10-31/art-classification.json) records file identifiers, SHA-256, authority and runtime role. Runtime dependency and artistic approval are separate properties.

| Class | Sources and consequences |
| --- | --- |
| Creator-approved exact artwork | 19 original masters, 37 item PNGs and 84 promoted Clean Cut resources remain byte-identical. Includes five future-only passive illustrations without playable offers. Older intake labels saying “candidate” do not revoke later explicit hash-specific approval. |
| Integrated candidate awaiting formal approval | 24 button PNGs and their 24 editable SVGs; 20 HUD SVGs and the portrait-crop shader; Archivo Black/Archivo sources; procedural Hero Clash brand and typography treatment. Their manifests still explicitly record candidate status. |
| Rejected/superseded | Historical diamond/rectangular/left-only joystick treatments are superseded by GDD §7.1's approved full-playfield circular control. Older generic V5/pre-correction scene compositions are historical references where corrected V2 supersedes them. No unidentified exact approved image is revoked. |
| Review-only | `assets/art-production/**` source/reference material, generators, test fixtures and screenshots. Exact approved selections retain their individual approval; the directory as a whole is not a production permission. |
| Production runtime dependency | Approved actors/world/icons plus integrated candidate controls and fonts. Removing candidates would visibly change the creator-tested build; do not silently revert them during technical consolidation. |

Files requiring explicit supersession decisions before visual consolidation:

- `assets/runtime-clean-cut/v2/support/wordmark.png` (approved SHA-256 `49eb4d1054d6675a5dad42ec3fa0352d202564e3aa655487d69365b2b9e83255`) and its recorded original SVG versus candidate `scripts/hero_clash_brand.gd`. Preserve both sources; approve the replacement/version explicitly.
- Approved Barlow sources and the approved treatment baseline versus `assets/fonts/hero-clash/{ArchivoBlack.ttf,Archivo.ttf}` and `scripts/clean_cut_typography.gd`. These candidate files are already common to main/integration; this technical PR neither adds nor approves them.
- Approved `menu/primary-*`, `menu/secondary-*` and applicable selection frames versus `assets/ui-button-candidates/v1/manifest.json`'s exact 24-state family.
- Approved `support/hp`, `support/wave`, `support/pause`, `support/xp`, equipment plate usage and `flex/*` versus the exact HUD V2 manifest's components/shader and the live Flex dial. Source bytes remain retained. A direction approval does not supersede all of these by implication.

## Clean sequence, checks and rollback

1. Review #91 against integration; inspect native transitions and the protected exact-build preview, then perform the short Pixel regression. Creator decides any later merge; do not change production during review.
2. Independently review the technical reconciliation PR against `bc69061`. It can land without UI art decisions once its applicable CI/export checks and owner authorization are complete. Do not merge #80/#81/#82 wholesale.
3. Record explicit logo/font/button/HUD source-version decisions, retaining original approval hashes and adding any authorized supersession links. If not approved, leave the visual integration separate; commission only a precise scoped correction.
4. From the then-current main, prepare separate clean commits for approved component resources/loaders; HUD/secondary-screen bindings; threat fix with no-fade history and tests; and coherent Web resource/export validation. Port later source slices, not stale GDD or historical review binaries. Keep optional diagnostics separate.
5. On that assembled head run mandatory import/gameplay/navigation/RNG/profile/UI/touch/geometry/browser-adapter tests, approved/candidate hash checks, official Web/PCK exclusions and licensed-font packaging. Re-capture all six viewports, verify protected metadata, normal Web flows and physical regression. Document remaining art/device gates before requesting a release decision.

Rollback is commit-based: preserve `bc69061`, `05bcef2` and the current production deployment `dpl_BVt9GgzKfedAsRsS3FpomqoP3Vky`. The cache port can be reverted as a single scoped commit without a profile migration. The threat change can likewise be reverted independently on integration. Any future deployment rollback requires explicit authorization; no alias, branch, approved registry or player save was changed here.

Recommended merge order, **only after separate creator authorization**: #91 into integration after regression; isolated technical reconciliation into main; approved visual consolidation onto current main; final closed-playtest release decision. Green CI is not any of those authorizations.
