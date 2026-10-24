# Creator Approval — Clean Cut V2 Five-Screen Corrected Art

**Decision date:** 24 October 2026.  
**Authorization source:** Explicit creator instruction in the Aura Farmer development conversation: *“aprova e avança com a integração dessa arte”*, referring to the new five-screen Clean Cut art in PR #69 and its already-built native integration PR #71.

## Selected, immutable package

- Production direction: **Character Hype Broadcast — Clean Cut**, under canonical GDD §26.
- Art PR: [#69](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/69); selected art commit: `c1e13cdca5e0645e5f809dc6453ee75f979c8d4e`.
- Selected corrected package: `assets/art-production/character-hype-clean-cut/v2/creator-corrections-v1/`.
- **Artistically approved**: corrected compositions for Main Menu, Hero Selection, Gameplay HUD, three-card Upgrade Selection, six-card Legendary Selection, and the corrected associated isolated components, including circular mobile joystick and three hero-specific Flex button families. Exact per-file SHA-256 is pinned in source `manifests/FILE_HASHES.json`; runtime-promoted version identifiers, source hashes and paths are pinned in `assets/runtime-clean-cut/v2/manifest.json`.
- The runtime selected set is **84 exact reviewed source resources** (76 independent component PNGs plus eight supporting visual files, including the technical rasterization of the approved wordmark SVG). The remaining three complete equipment strip compositions remain illustration-only because they bake example equipment data; their individual slot artwork is used instead.
- **Approved original artwork remains immutable**: all 37 previously approved weapon/passive icon PNGs, original Option A hero masters, Ruin Alley map and enemy atlases preserve previous source versions and hashes.

## Supersession and non-approvals

- Corrected circular floating joystick supersedes earlier rejected diamond/arrow visuals.
- The latest corrected screen compositions supersede the older generic V5 panel/card treatments in those five flows; previous candidate examples stay available solely as non-shipping comparison references.
- This approval does **not** authorize new gameplay rules, additional playable heroes/passives, new balance values, save changes, backend, or changes to the GDD's approved input ownership.
- Do not promote other legacy, rejected, or reference-only asset variants by inference. Modified or later-exported artwork requires a new hash and explicit creator authorization.

## Engineering validation obligations

1. Integrate the selected art into *live* Godot Control nodes with actual game data; do not ship screenshot composites.
2. Verify source SHA-256 and promoted file byte identity; check Godot import and Web export inclusion.
3. Keep candidate source libraries, review screenshots, QA harnesses and rejected artwork excluded from production PCK.
4. Preserve the GDD-approved full-playfield, first-touch joystick and independent Flex multitouch.
5. Retain all previously passing combat, level-up, legendary, profile, and responsive input regressions.
6. Perform native visual comparison and browser/device checks. This art approval does not itself certify native rendering, WebGL2, FPS or physical-device ergonomics.

**This document records the creator's actual approval.** A CI green status or previous PR existence did not constitute that approval.
