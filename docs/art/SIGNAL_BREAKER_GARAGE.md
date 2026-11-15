# Signal Breaker Garage playable slice

**Status:** VERIFIED_FUNCTIONAL_LOCAL; ENVIRONMENT_PROPOSED; FINAL_VISUAL_ACCEPTANCE_PENDING.

Baseline runtime: `0007cb62aca84e6af8a1018c82b684199c7e8cdb`. Product authority: Canon `a1e670ff889b1a804a9c8b97b755e433a5cf3c95`, GDD V4.0 and inherited unchanged V3 gameplay. Brand decision CPK-BRAND-2026-11-13-01; hero source/production manifests retained unchanged.

## Provenance

Exact approved Garage reference `69acb29bd9ea9ce6c692e6c37fe984d24ad5ff4e3d3ce32f48e55a236f588929` was not recovered in the bounded Art-tree/workspace/generated-image/Downloads checks. This does not claim exhaustive recovery or binary presence in Art Git. A new background is explicitly PROPOSED, Art commit `a36ad90be52c6fcdb6ee5da7bb536ddca4c59391`; it is not the approved original. The game copy is hash-identical and separately inventoried. Exact approved 2026-11-13 wordmark derivatives come from Art `6b0da4f4cee5a72caec3c12b87c3e5817d94f969`; two runtime copies have independent hashes and source paths. No hero bytes were repainted, mirrored or substituted.

## Actual runtime architecture

The application enters `scenes/signal_breaker_garage.tscn`. The coordinator instantiates the existing `scenes/main.tscn` Solo scene, retaining its rules, input, RNG and storage owner. While in the Garage that scene is hidden and processing/input are disabled. PLAY enables it and calls the real `start_run` with selected kit/appearance. Returning to its menu reopens the Garage. Settings use the existing functional interface and return correctly. This avoids forking the entire gameplay controller or changing the operational Solo map.

The environment-only candidate raster is one layer. Native local light, contact platform/shadow and foreground edge are separate CanvasItems; the exact approved CPK sign and individual selected hero are separate textures. Real Theme-based Button/Grid/Panel/Label controls own interaction. No UI is baked into the image. Ambient motion is a restrained local alpha drift without RNG; reduced motion freezes it. No fake profile, currency, shop, inventory/progression or new kit.

All six identities are selectable directly. They map to sigma/original, cool-kid/original, alpha/original, sigma/female, cool-kid/female, alpha/female. Role, starter and Flex bind to actual existing kit/catalog data. Primary actions are HERO SELECT and PLAY; BACK and SETTINGS are supporting navigation/accessibility. Keyboard Tab/Enter and 1–6, mouse and owned touch press/release are supported. Leaving a target cancels its touch activation. Input coordinates reuse the existing safe-area helper and focus owners.

## Executed local checks

Godot 4.7.2 Compatibility on Windows/RX6800XT: focused Garage suite PASS headless and native. It verifies actual mouse selection across six identities, focused keyboard acceptance, touchscreen selection, safe/non-overlapping 48px-minimum targets at six viewports, menu RNG/time isolation, real Solo start/starter, pause, return and settings. Native captures at 1280×720, 915×412 and 390×844 were visually inspected; layout issues found during inspection were corrected. Exact asset hash checker runs separately. Large captures remain local in `cpk-production-review-2026-11-15/`.

These checks are not physical-phone tests, full normal-run artistic acceptance, new art approval or production release authorization. The old operational scene remains available for regression tests; new entry coverage verifies the configured application scene separately. Full integration/Web validation follows the remaining presentation batches. No merge or production deployment.
