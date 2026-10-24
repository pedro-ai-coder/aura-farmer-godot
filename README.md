# Aura Farmer — Godot

Shared solo implementation for **Web, Android and iOS** using Godot 4.7.2, GDScript and the Compatibility renderer. The canonical `docs/GDD.md` is the gameplay authority. The Phaser reference repository remains unchanged.

## Approved visual identity (23 October 2026)

The creator-approved production target is **Option A — Cartoon Arcade / Arcade Street Clean — Hero Spotlight**, defined in [canonical GDD §26](docs/GDD.md) and its [Hero Spotlight V5 visual handoff](docs/art/HERO_SPOTLIGHT_V5.md). The [production visual tokens](docs/art/hero_spotlight_v5_tokens.json) give stable palette, typography and component reference dimensions.

The illustrated **Production Visual Art Bible V5** contains 22 finished-look scene targets plus 9 weapon and 28 passive icon designs. These visual handoff binaries were delivered separately and **are not checked into this repository by the documentation approval PR**. The development team must import and verify the actual master files before implementation and visual acceptance; do not treat text-only specifications as replacement artwork.

The GDD remains authoritative for all gameplay labels, rules and timing. In particular, the current starter Flexes are **Deadpan Verdict (Sigma)**, **CTRL + CHAOS (Cool Kid)** and **Giga Chad Rampage (Alpha Chad)**, with the approved 10-minute survival schedule. Do not reuse historical Flex labels or earlier run durations visible in concept-art mockups. This approval does not authorize gameplay changes, Phaser edits or release.

## Current state

The three approved starters, nine weapons/legendary variants, active solo passive subset, 3+5 inventory limits, offers, XP/Aura/Flex, five-wave timeline, events and Big Hater logic are implemented with deterministic regression coverage. The Cartoon Arcade UI preserves approved menu art and catalog symbols. Menus include explicit hero Play, options/save navigation, card/replacement confirmation, pause/build inspection, exit confirmation, result retry, preferences and profile transfer. Approved art is fetched from pinned, hash-verified Phaser assets.

This is **not final migration acceptance**. Visual and responsive review is deferred to the owner. Normal-play balance, complete audio/animation polish, real-device lifecycle/export tests, rendered FPS/stress measurements and the 85/100 acceptance score remain outstanding. Read `docs/MIGRATION_PROGRESS.md` and `docs/NATIVE_READINESS.md` for evidence and limits.

## Run and validate

1. Install the exact Godot 4.7.2 editor.
2. Run `python3 scripts/sync_approved_assets.py` to fetch the approved artwork.
3. Import `project.godot`, then run the main scene.
4. Run `bash scripts/validate.sh` for import, gameplay, save, input, art and scene regressions. The validation workflow requires GNU `timeout` and Node.js 18+ for browser lifecycle adapter regressions.

Select a hero with buttons or 1–3, then press Play or Enter. Move with WASD/arrows or the floating left-side touch joystick. Use E/Space for Flex, M for mouse/automatic aim and P/Escape/B for pause/build. Select upgrade cards with buttons or 1–6, then confirm with the button or Enter. Escape cancels replacement/exit confirmation without resuming combat behind the modal.

## Saves and platform builds

Web uses `aura-farmer:profile:v2` in same-origin localStorage. Native uses an atomic `user://profile_v2.json`; old v1/slice data remains untouched. Main-menu **SAVE DATA / IMPORT SAVE** transfers JSON across browser origins, preserving historical IDs and a Godot backup. No cloud account or cross-save backend is added. Proposed new unlock thresholds remain disabled. Approved Street Snack, Aura Magnet and Safe Spot follow canonical Appendix C.2 and the Phaser recovery contract.

Vercel uses `scripts/build_web.sh` with the official verified engine/templates. Payload filenames include the commit revision; `/build.json` identifies the deployed build and avoids stale `index.pck` caches. Android/iOS presets are preparation only; SDKs, signing identities and device verification remain local prerequisites. No native release is authorized or published.

## Integration workflow

Use one scoped implementation PR at a time. Required automated checks must pass before merging. The owner authorized integration of already approved logic and deferred visual validation on 22 October 2026. This does not approve new mechanics, artwork, paid services, native releases or a claim of complete parity.
