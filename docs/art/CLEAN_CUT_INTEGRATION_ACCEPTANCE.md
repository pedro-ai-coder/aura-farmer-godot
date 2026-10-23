# Clean Cut approved PNG integration — 24 October 2026

The creator approval gate is resolved for the 37 exact PNGs in [the durable decision](CREATOR_ICON_APPROVAL_2026-10-24.md). This is the selected **Character Hype Broadcast — Clean Cut** refinement of Hero Spotlight V5, recorded in GDD §26. Gameplay, original approved masters, source candidate bytes, saves and the new separately approved mobile-joystick requirements remain unchanged by this art milestone. Joystick implementation is tracked separately.

## Implemented

- All 37 selected PNGs are copied unchanged into hash-named runtime paths. Eight weapons and 28 passives use the approved V5 PNGs; Touch Grass uses only the exact approved Clean Cut v2 256px PNG. It has no matching SVG and does not inherit the V5 SVG. Existing approval/export guards remain in force.
- All nine current weapon and 23 current passive identities use the central registry in live normal/legendary/replacement cards, equipped build slots and HUD. Five future-only passives have approved resources registered but remain absent from gameplay offers. No additional items or mechanics are enabled.
- Names, categories, rarity, level, effects, selection, confirmation and keyboard behavior remain live data. Compact build names are separated from rarity/level, with taller narrow tiles to prevent clipping. Opening build resets stale scroll. Offer scroll identity includes the run ID so a new run cannot inherit an old row. Full HUD item names/category/rarity/level can be read in a passive pointer caption; it does not intercept touches or change movement. Full named build inspection remains available from Pause on touch devices.
- The batch regression compares every imported image against its exact approved PNG after the pinned Godot lossless import's alpha-edge processing, tests every current playable card ID, all three real starter offer generators, future-only exclusions, compact long-name/meta fit, scroll reset and unchanged simulation/RNG/profile data. Original PNG bytes are SHA-verified independently; no art master is altered by this standard texture import.

## Actual visual evidence

[Capture metadata](evidence/approved-clean-cut/captures.json) records **50 actual functioning UI captures**, ten states at each of five requested windows: normal/default/selected, legendary/default/selected/last row, empty/full/scrolled build, replacement and HUD. Baseline is `d76ac43` before PNG promotion; both use the same staged real interfaces, not static screenshot UI. [Normal before/after](evidence/approved-clean-cut/compare-choice_selected-1280x720.jpg), [legendary](evidence/approved-clean-cut/compare-legendary_selected-1600x900.jpg), [compact last row](evidence/approved-clean-cut/compare-legendary_last-915x412.jpg), [portrait build](evidence/approved-clean-cut/compare-build_full-390x844.jpg), [HUD](evidence/approved-clean-cut/compare-hud-915x412.jpg).

All 37 **actual imported textures** were rendered at exact [32px](evidence/approved-clean-cut/approved-32px.png) and [64px](evidence/approved-clean-cut/approved-64px.png), on navy and cream. These are engine captures with canonical labels, including the five clearly nonplayable registry entries; the gallery is QA-only. Textures preserve the approved silhouettes. Existing similar-shield/fist/target families and tiny details remain the creator-acknowledged nonblocking refinements, not permission to redraw approved bytes.

Actual desktop capture pixels are 1600×900, 1280×720 and 1920×1080. Existing canvas rounding yields 915×411 for requested 915×412 and 390×843 for 390×844; raw metadata preserves this limitation. No physical-device acceptance is inferred. Reviewed V5 PDF pages 10/12/14/28/34/36 remain composition references; compact legendary/build scrolling, larger build tiles, the current HUD strip, background dimming and other previously recorded broader parity gaps are not claimed solved by icon integration.

## Performance and release gates

[Measured lookup evidence](evidence/approved-clean-cut/lookup-performance.json) used native Godot 4.7.2 Compatibility/Mesa llvmpipe with a warm OS file cache: first lookup of all 37 textures took 17,134µs; 37,000 cached lookups took 32,903µs. Aggregate decoded RGBA image data is 9,699,328 bytes (not a physical GPU VRAM measurement). Real gameplay loads lazily and reuses texture references. These CPU microbenchmarks are not browser startup, FPS, memory-budget or physical-device acceptance.

The required suite now has **41 Godot phases plus 11 Python regressions**. CI and the official Web export must pass before merge. The PCK guard requires every approved PNG import/texture, the 19 original approved masters and enemy metadata; it rejects candidate/source/review leakage and unsigned runtime resources. Actual production build SHA, PCK hash/size and per-icon published-export verification will be attached to the merged PR and then reflected in the readiness register after observed deployment. Browser WebGL2 and physical Android/iOS acceptance remain separate gates. No new normal-health run is claimed because gameplay was not changed.

## Current per-item matrix

All rows below have explicit PNG approval, exact source/promoted hashes, verified Godot import and actual 32/64px chart evidence. Export status is pending the actual built-pack inspection at this commit, not assumed from source import. The machine-readable authoritative paths, hashes and creator references are in `assets/runtime-icons/manifest.json`, `docs/art/icon_approvals.json` and `v5_icon_readiness.json`.

| Category | ID | Selected version | Live UI / gameplay scope |
| --- | --- | --- | --- |
| passive | `absolute-cinema` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `aura-viral` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `big-chad` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `big-meme` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `brainrot-rain` | `v5-candidate` | Registered future-only; never offered |
| passive | `built-different` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `caught-4k` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `certified-w` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `cope-harder` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `ego-check` | `v5-candidate` | Registered future-only; never offered |
| passive | `get-ratiod` | `v5-candidate` | Registered future-only; never offered |
| passive | `hands-on-sight` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `homie-check` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `its-over` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `let-him-cook` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `main-character` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `no-cap-streak` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `no-u` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `six-to-seven` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `so-back` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `take-l` | `v5-candidate` | Registered future-only; never offered |
| passive | `terminally-online` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `thick-skin` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `timeline` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `too-sigma` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `uno-reverse` | `v5-candidate` | Registered future-only; never offered |
| passive | `w-squad` | `v5-candidate` | Existing item: cards, build and HUD |
| passive | `w-wifi` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `ban-hammer` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `brainrot-feed` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `chad-hands` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `cope-shield` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `keyboard-warrior` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `no-cap` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `personal-space` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `ratio-blaster` | `v5-candidate` | Existing item: cards, build and HUD |
| weapon | `touch-grass` | `clean-cut-v2` | Existing item: cards, build and HUD |
