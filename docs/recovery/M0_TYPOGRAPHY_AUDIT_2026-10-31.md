# M0 typography / issue #76 audit — 31 October 2026

**Issue [#76](https://github.com/pedro-ai-coder/aura-farmer-godot/issues/76) remains open. Final typography acceptance is not established.** Assessed runtime: `bfab07e55c0130416199cc5cfaf2180c35942e22`, with typography/brand bytes identical to the published `05bcef2`. No font, logo or UI redesign was made by the threat fix.

Authority is canonical **main GDD V3 §8.2 including PR #84**, not the older paragraph still on integration. The creator-selected Hero Clash/Clean Cut direction permits evaluating this treatment, but does not approve all candidate source files. Passing tests, packaged licenses and native screenshots do not clear the explicit interactive-Web/creator acceptance gate.

## Actual rendering evidence

- [Five approved references versus actual Godot, same 1600×900 viewport](evidence/overnight-2026-10-31/approved-reference-vs-runtime.jpg). Left: exact retained approved source previews; right: actual native output. Different illustrative heroes/offers are identified; this is a hierarchy/source comparison, not an equivalent-gameplay before/after benchmark.
- [Desktop seven-screen gallery](evidence/overnight-2026-10-31/typography-1600x900.jpg) and [landscape mobile gallery](evidence/overnight-2026-10-31/typography-844x390.jpg). Full-size frames and measurements are linked below.
- [Capture provenance, exact readbacks and measured font sizes](evidence/overnight-2026-10-31/typography-audit.json). Full live-Control layout audits are retained as `layout-1600x900.json.gz` and `layout-844x390.json.gz` beside it. The reference preview hashes match their original `FILE_HASHES.json`.

| Screen | Full desktop | Full mobile | Observation / acceptance gap |
| --- | --- | --- | --- |
| Main Menu | [1600](evidence/overnight-2026-10-31/hero-menu-1600x900.jpg) | [844](evidence/overnight-2026-10-31/hero-menu-844x390.jpg) | Filled Archivo wordmark and blue/gold framing replace the original outline-style illustrated lettering visually. Original wordmark bytes remain intact. Exact candidate supersession and final composition require creator approval. |
| Hero Selection | [1600](evidence/overnight-2026-10-31/hero-selection-1600x900.jpg) | [844](evidence/overnight-2026-10-31/hero-selection-844x390.jpg) | Original three heroes, strong live names and Flex headings; upright filled headline differs from the reference's compact angled/offset display treatment. This is a deliberate candidate interpretation, not pixel fidelity. |
| Three-card Upgrade | [1600](evidence/overnight-2026-10-31/choice-selected-1600x900.jpg) | [844](evidence/overnight-2026-10-31/choice-selected-844x390.jpg) | Live title/body/progression/CTA hierarchy; descriptions wrap. Footer text reaches the lower-right diagonal cut; final letters lose background contrast. See defect below. |
| Six-card Legendary | [1600](evidence/overnight-2026-10-31/legendary-selected-1600x900.jpg) | [844](evidence/overnight-2026-10-31/legendary-selected-844x390.jpg) | Six legal offers remain accessible by scrolling/focus. Only the first row fits mobile initially; this is not missing content. Footer has the same diagonal-cut defect. |
| HUD | [1600](evidence/overnight-2026-10-31/playing-shield-1600x900.jpg) | [844](evidence/overnight-2026-10-31/playing-shield-844x390.jpg) | Critical numbers use functional type, with separate HP/Shield and icon-based equipment. Candidate HUD composition differs materially from original approved plates; full names remain in Build/tooltips. |
| Victory | [1600](evidence/overnight-2026-10-31/won-1600x900.jpg) | [844](evidence/overnight-2026-10-31/won-844x390.jpg) | Gold result heading, original hero and live-stat grid; small secondary row labels need device reading. This zero-time fixture proves result presentation only. |
| Run Over | [1600](evidence/overnight-2026-10-31/lost-1600x900.jpg) | [844](evidence/overnight-2026-10-31/lost-844x390.jpg) | Coral outcome heading uses the same system; no extra identity family or baked dynamic values. Same fixture limitation. |

Thirty-four real native frames (17 states × two viewports) were captured with official Godot 4.7.2 Compatibility/OpenGL3, X11/Mesa llvmpipe. ReviewRun uses defaults and suppresses saving; no actual player profile is loaded or written. Reduced Motion is on. Godot readback for requested 844×390 is 843×390. The seven selected screens are shown at original pixel size; sheets resize actual frames. They are neither browser screenshots nor physical-device proof. #91 separately retains threat coverage at all six canonical viewports.

## Sources and hierarchy

The issue's original diagnosis mentions Inter display faces. That is historical: current visible Clean Cut roles use **Archivo Black** for headlines/card names and **Archivo** variable weights 500/700 for body/UI/numbers. `scripts/clean_cut_typography.gd` provides reusable roles, live text, line spacing, controlled outlines, cached FontVariations, tabular-number features and a packaged symbol fallback. `scripts/clean_cut_secondary.gd` applies the same family to Settings/Build/results. Inter survives as a controlled symbol/legacy fallback, not the primary current display identity.

Candidate font provenance remains `assets/fonts/hero-clash/manifest.json`: Archivo Black SHA-256 `dd9a89a019b4849f66ab75455fe7bdf931311042cbb0f0f97acc061539703180`; Archivo `0e094a7d3c7c4c25cf1310c4b30014f1dae9332220b1c2c88f4fa996f0b05053`. Original PR #78 sources and their SIL OFL files remain packaged. Main and integration contain identical font/brand/token sources; no new family was introduced. Four licensed Barlow baseline files and the approved wordmark are preserved. [Exact source classification](evidence/overnight-2026-10-31/art-classification.json) keeps license verification separate from artistic approval.

Actual typography has a coherent bold foundation: uppercase major headings, identity names on cards, sentence-case descriptions, functional numbers, and limited strokes rather than thick universal outlines. The original reference uses narrower, angled, offset display emphasis; the candidate uses wider upright filled letters and revised placement. A successful font load cannot decide whether that difference satisfies the creator's intended display character.

## Observed compact limits and smallest corrections

| Item | Actual observation | Status / next action |
| --- | --- | --- |
| Card footer and authored diagonal edge | At both captured sizes, right-aligned `TAP TO SELECT` / selected-state copy enters the card's lower-right cut, making end letters harder to read. Control rectangles pass ordinary peer-overlap checks; the authored silhouette is the missing constraint. | **FAIL — presentation defect.** Small follow-up: reserve the diagonal-cut inset in `clean_cut_skin.gd::cards_layout` for `offer_parts[i]["state"]`; measure complete strings inside it and add a silhouette-aware regression. Preserve description space, labels and clickable bounds. No redesign or shrink-to-fit of essential content. |
| Gameplay numbers at requested 844×390 | HP 15 px, Shield 13.5 px, wave 17.25 px, XP/level 15 px in actual rendered scale. Hero name 18 px. | **PENDING DEVICE QA.** Read on Pixel 8a at normal browser scale; native font metrics are not comfort evidence. |
| Card information at requested 844×390 | Card title 18.75 px, description 13.5 px, normal rarity 12.75 px, progression and Legendary category/footer 11.25 px. | **PENDING DEVICE QA.** Prioritize progression/category/footer only if actual reading fails; rebalance spacing/scroll rather than introducing another family. No arbitrary universal size gate is asserted. |
| Results secondary labels | 10.5 px in this mobile readback; display headline 34.5 px and hero 21.75 px. | **PENDING DEVICE QA.** Test meaningful nonzero results on device. If uncomfortable, adjust secondary-grid text and row spacing within the existing system. |
| Brand/source supersession | Candidate wordmark, type treatment and source manifests retain pending status. | **PENDING CREATOR APPROVAL.** Approve exact rendered candidate/source versions or request a precise change in width, angle, depth or hierarchy. Do not infer approval from the selected direction. |

No speculative typography adjustment is included in the threat fix or isolated main geometry port. The remaining footer defect is explicitly recorded instead of being hidden behind green layout tests.

## Evidence needed to resolve #76

Retain the existing reference comparison and role/source inventory; correct the diagonal footer inset in a small subsequent scoped change; capture that exact final build across all six viewports and real Web desktop/mobile; review live menu/hero/cards/HUD/results plus secondary flows and all button states; perform actual device readability checks; then record explicit creator rendered-typography and source/version approval. Keep exact original font/wordmark records until the approved supersession is documented. #76 is not closed by this audit, and M0 typography is not declared final.
