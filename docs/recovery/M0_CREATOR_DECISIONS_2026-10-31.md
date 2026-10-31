# M0 creator decision sheet — final recovery

**Recommendation:** retain the current Hero Clash / Clean Cut identity, accept the narrow footer-layout correction after viewing it, and decide the three source batches below. No broad redesign is proposed. Technical checks do not grant these approvals. Issue #76 remains open.

**Build to inspect:** the final head and protected preview linked in [PR #93](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/93). Its runtime source is identical to `541ec8988543152de169c438538a60ef63e87a81`; subsequent additions are tests/evidence/docs only. Production remains `05bcef2`. Nothing has been merged or deployed to production by this work package.

## First visual check

[Desktop before/after](evidence/m0-final-2026-10-31/footer-comparison-1600x900.jpg) · [Mobile before/after](evidence/m0-final-2026-10-31/footer-comparison-844x390.jpg) · [All six sizes](evidence/m0-final-2026-10-31/footer-six-viewports.jpg).

Both complete strings now clear the diagonal corner. At 844×390 with asymmetric test insets, selected text measures 223 logical units in a 257.23-unit label, with 60 units of right clearance. Font family/size, descriptions, selection semantics and clickable rectangles are unchanged. Native before/after uses identical offers/RNG/button geometry. **Recommended decision: accept the footer inset; request only a precise correction if the new position is unsatisfactory.**

## Three exact source batches

The [source approval ledger](evidence/m0-final-2026-10-31/source-approval-ledger.json) provides every filename and SHA-256, existing provenance/status and a deterministic bundle hash. Approve coherent batches, rather than dozens of files individually. These are proposals; no registry is promoted.

| Batch | Current sources and review | Required decision |
| --- | --- | --- |
| **L — logo/type** | `hero_clash_brand.gd`, `clean_cut_typography.gd`, exact Archivo Black/Archivo files and OFLs/manifest. [Current menu](evidence/m0-final-2026-10-31/current-hero-menu-844x390.jpg); [approved reference versus runtime](https://github.com/pedro-ai-coder/aura-farmer-godot/blob/4bea450ff499269281a40655740dae9157acb08a/docs/recovery/evidence/overnight-2026-10-31/approved-reference-vs-runtime.jpg). | Is this the final **Aura Farmer** logo/type treatment, or identify an exact glyph/hierarchy/composition correction? Legibility is already accepted; exact source supersession is still pending. The filled upright Archivo treatment differs from the original outline/angled reference lettering. |
| **B — buttons v1** | 24 runtime PNGs + 24 editable SVGs + manifest; four families × normal/hover/focus/pressed/selected/disabled. [Actual Godot static gallery](../../tests/button_art/evidence/components.png), reused because rendering/source bytes are unchanged. | Approve this exact coherent state family or name the specific family/state needing correction. Current production appearance alone is not the source approval record. |
| **H — HUD V2** | 20 exact SVGs, existing portrait-crop shader, manifest/generator. [Current HP/Shield HUD](evidence/m0-final-2026-10-31/current-playing-shield-844x390.jpg), [READY](evidence/m0-final-2026-10-31/current-ready-844x390.jpg), [boss](evidence/m0-final-2026-10-31/current-boss-844x390.jpg). | Approve this exact source batch, including the existing shader, or identify a precise component correction. Original hero/world/enemy/icon identities are preserved. |

Bundle identifiers: **L `a11d7f6a9db2fa0e116ca56b0982165c4e65584be5779490e4979a11de4a8f73`**; **B `ec26e85b1a6a6a573f263baf84796155cd61de10b8c3ee9f742dd5c5b2fb1a9c`**; **H `f367a1682cea7fe594a9bedae0340b8dbac853bcce99bd1c200930698a184846`**. A decision can name L/B/H and this ledger at PR #93's exact final commit; no need to approve each file separately.

The 19 original masters, 37 icons, 84 approved Clean Cut resources, Barlow sources and approved wordmark remain immutable. Approving L/B/H would authorize the specified visual supersessions with original records retained; a separate ledger/GDD integration commit must record that decision. Historical diamond/rectangular joystick treatments remain superseded, and review-only material stays excluded from exports.

## Minimal remaining personal review

- On Pixel 8a/Brave, inspect one normal selected card and both Legendary rows at ordinary browser scale. Confirm complete footer strings and unchanged selection/Confirm/Defer. **Do not repeat the already accepted movement/threat/legibility campaign:** only the footer rectangle changed.
- The review browser cannot run Godot because WebGL2 is unavailable. Exact-final-build normal-health Web completion and browser save/reload evidence remain uncollected; native fixtures are not a substitute. Record that evidence on a supported browser before final release sign-off, without artificially invulnerable test state.
- Decide later whether **#93** may merge into integration and **#92** may merge independently into main. Neither is merged automatically. Full visual consolidation remains gated by L/B/H and #76's explicit rendered/source acceptance.
- Make the separate closed-release decision only after those gates. No release, production deployment or tester opening is authorized here.

No additional technical P0 defect was reproduced within the executed suite. [Final acceptance matrix](M0_FINAL_RC_2026-10-31.md) and [main integration sequence](M0_FINAL_CONSOLIDATION_2026-10-31.md) retain the exact scope and remaining evidence limits.
