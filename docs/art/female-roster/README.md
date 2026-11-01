# Complete female appearance roster — runtime creator review

This extends the playable Pixel Vixen baseline `0c0f6de2d8b058c00a75970bf9da70d5cdd5c6db` in [PR #97](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/97). The creator's 31 October 2026 instruction authorizes Byte Baddie and Block Queen as immediately selectable/playable **cosmetic appearances**, using the attached `female_variants_reference_pack.zip`. New artwork remains a candidate; no merge, production deployment or automatic visual approval is authorized.

| Appearance | Canonical hero ID | Original starter | Original Flex |
| --- | --- | --- | --- |
| Pixel Vixen | `sigma` | No Cap | Deadpan Verdict |
| Byte Baddie | `cool-kid` | Keyboard Warrior | CTRL + CHAOS |
| Block Queen | `alpha` | Cope Shield | Giga Chad Rampage |

There are still three gameplay heroes and six visual choices through the existing Original/Female selector. No new kit, unlock, weapon rule, balance value, backend or Phaser change is included. Reference captions such as Keybat, Rage Type, Aura Shield and Squad Aura are not gameplay definitions and are not implemented.

## Actual artwork and provenance

Six new original PNGs were produced with built-in **imagegen**, using the creator's full/HUD reference crops and the existing Pixel Vixen artwork as style references. The complete prompts and reference roles are recorded in [prompts.json](prompts.json). No external game artwork or proprietary font is copied. New source PNGs retain the generated alpha and are not repainted, upscaled from gameplay cells or substituted with original male art.

| Asset directory | Gameplay atlas | Selection illustration | Dedicated HUD illustration |
| --- | --- | --- | --- |
| [`byte-baddie/v2`](../../../assets/art-candidates/byte-baddie/v2) | `byte-baddie-atlas-v2.png`, 1024×1536 | `byte-baddie-portrait-v2.png`, 1254×1254 | `byte-baddie-hud-v2.png`, 1536×1024 |
| [`block-queen/v2`](../../../assets/art-candidates/block-queen/v2) | `block-queen-atlas-v2.png`, 1024×1536 | `block-queen-portrait-v2.png`, 1254×1254 | `block-queen-hud-v2.png`, 1536×1024 |

Each atlas contains **24 distinct source poses**: four each for idle, movement, attack, hurt, Flex and defeat. Each manifest pins its PNG SHA-256 hashes/dimensions, reference ZIP/crop hashes, exact canonical identity, preview-only candidate status and the hash of `frames.json`.

The source poses are close enough to require explicit registration rather than blind uniform-grid sampling. Cached masks extract original source pixels, exclude adjacent poses, preserve body pivots and keep a constant world scale. The touching Block Queen defeat poses are separated at their source-column boundary. The development-only [registration tool](../../../scripts/prepare_female_frames.py) reproduces the committed geometry from the unchanged PNGs; it writes JSON only and never edits PNGs. `python3 scripts/prepare_female_frames.py` checks reproduction (requires Pillow/NumPy); `--write` is restricted to unapproved preview candidates.

Movement uses the authored three-quarter view with mirroring, comparable to the Pixel Vixen baseline. These are not eight-direction/rear-view masters. Creator review of animation quality remains necessary.

## Integration

- `hero_appearance.gd` resolves resource paths from canonical IDs and refuses incomplete packages. Asset slugs never become gameplay/save hero IDs.
- `female_appearance_art.gd` provides the shared portrait/atlas resolver and prepares all masked frame textures **before a run**, caching them across playback/Retry. No image/style/atlas reconstruction occurs per rendered frame.
- `female_hero_animation.gd` uses the original hero animation state/flip/Flex phase. Pixel Vixen delegates to its existing unchanged playback/registration; Alpha's visible slam phases follow the original presentation rather than introducing extra apparent slams.
- Hero Selection, menu illustration, HUD, results and Retry use the chosen appearance. All female HUD portraits bypass the original male portrait-crop shader; Original restores that shader.
- The existing focused-button Enter path previously fell through on key-down and started the prior hero before the card accepted on release. The fallback now respects the live focused control. Real keyboard and touch tests exercise all three choices.
- Startup and v2 import share profile application, preserving canonical selected IDs and the existing optional `appearance` preference. No schema/version change is introduced.

## Actual Godot evidence

Official **Godot 4.7.2 / Compatibility / X11 / Mesa llvmpipe** rendered the real game with actual pointer/keyboard/touch controls. The [save-isolated capture harness](../../../tests/female_roster/capture.gd) produced **132 native captures** across 1920×1080, 1600×900, 1280×720, 915×412, 844×390 and 390×844: selection plus each female hero's idle, movement, attack, hurt, Flex, defeat and victory. A further native gallery shows 72 source poses across the three appearances.

- [All three female selections](evidence/female-selection-1600x900.webp) · [Portrait selection](evidence/female-selection-390x844.webp)
- [Byte Baddie: HUD/gameplay](evidence/byte-baddie-idle-1600x900.webp) · [Mobile Flex](evidence/byte-baddie-flex-844x390.webp) · [Victory](evidence/byte-baddie-victory-1600x900.webp)
- [Block Queen: HUD/gameplay](evidence/block-queen-idle-1600x900.webp) · [Mobile movement](evidence/block-queen-moving-844x390.webp) · [Defeat](evidence/block-queen-defeat-1600x900.webp)
- [Actual Godot animation gallery](evidence/atlas-gallery-1920x1080.webp)
- [Capture/binding report](evidence/runtime.json)

Selected images are lossless WebP; decoded RGB pixels match the unresampled native PNG readbacks. Compact-canvas rounding can remove one physical pixel; actual readbacks are recorded. The fixtures freeze wall-clock simulation between captures, supply a durable target for attacks/Flex and use lethal damage/boss-kill scenarios for results. These are **not** ordinary full runs, human playtests, physical-device validation or FPS measurements. Remaining captures can be reproduced with the harness; the nine selected images are committed here.

## Validation and approval boundary

The full existing validation command set passed locally (**84 commands**, with Python subprocess timeouts in the restricted environment). The linked PR's GitHub check executes the unmodified required `bash scripts/validate.sh` and is authoritative for its exact final head. The additional import assertions are also exercised by the focused roster suite.

The roster regression checks real keyboard/touch selection and start at all six viewports, Original hero/art preservation, correct female names/portrait/atlas bindings, all cached frames, result identity, actual Retry, save/restart/import and fail-closed preparation. For each canonical hero, **420 irregular-step frames** compare all recorded combat/world/event state and seeded RNG between Original and Female, including movement, attacks, damage and actual Flex. Canonical animation phases also match.

`verify_female_variants.py` checks exact RGBA PNGs, all six states, registered geometry and candidate status. Negative resource tests reject every missing PNG, wrong source bytes, missing exported texture/metadata, V1 fallback and independent hero IDs. Web export must include all six new imported textures plus both manifests/geometries; the existing Pixel Vixen and original art/font/icon/export-isolation checks remain mandatory.

The protected exact-build preview and CI result are linked in PR #97. The cloud browser used earlier in this session reports missing WebGL2; no successful interactive Web or physical Pixel 8a validation is claimed without an actual supported-browser run. Native rendering is not a substitute for creator-device review.

Pixel Vixen's three PNGs, its atlas registration/playback and all original approved hero/enemy/environment/icon/UI source assets are preserved. New candidates have not been promoted into the approved production art registry. Completing the selectable roster does not authorize merge, production deployment or artistic approval of the new bytes.
