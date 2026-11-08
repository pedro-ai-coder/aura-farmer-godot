# CLUTCHPUNKS — Motion Language V1

**Status:** PROPOSED / implementation candidate only.
**Authority:** GDD V3, approved exact asset sources and existing decision register.
**Runtime:** Godot 4.7.2 / Compatibility renderer.
**Scope:** all three canonical hero kits, with original and female visual appearances (six selections), and all 17 existing enemy kinds, including event bosses and Big Hater.

## Direction

The objective is an expressive but readable 2D roguelite presentation. A shared, conservative body-motion layer supplements the existing approved authored sprites: travel-driven bounce, idle breathing, limited squash/stretch, hit/attack accents, and heavier profiles for large enemies. It does not replace source art or promise missing authored frames.

Warning, charge-warning, charging, terminals, defeat and the reduced-motion accessibility mode remain anchored/neutral. Only sprite presentation and hero weapon-grip cosmetics are affected; attack deadlines, hit volumes, physics, AI, deterministic RNG, saves and GDD values are untouched.

## Technical notes

- Motion is a pure function of existing pose, travel and event clocks.
- Neither character dictionaries nor canonical pose descriptors are changed.
- No new textures, atlases, per-frame resource generation or gameplay RNG are introduced. The returned small motion descriptors remain a performance review item at high enemy density.
- No additional hit-stop or camera shake is introduced because those require more careful readability and deterministic simulation review.
- No new artwork or proposed scene content is approved by this PR.

## Acceptance gate

1. Run `bash scripts/validate.sh`, including the new `motion-language` test, at the exact source commit.
2. Review all six hero appearances through idle, travel, attack, hurt, Flex and defeat; confirm identical combat behavior.
3. Review representative normal enemies, each of the four event bosses, Big Hater and the terminal; verify danger warnings and weapon grips remain grounded.
4. Verify reduced-motion behavior, actual Web performance, real input responsiveness and frame-time stability. Use the established 300-enemy/150-projectile fixture as supporting evidence, not a substitute for ordinary human play.
5. Obtain explicit creator visual approval before merging to production.

**Unverified:** No Godot, browser or FPS test was executed while authoring the change. The test and visual review remain required.

**Rollback:** Revert the focused PR; no asset, save-schema or gameplay-contract migration is needed.

## Iteration 2 — Ranged kit pilot (PROPOSED)

The first V1 transform was too subtle to serve as visual acceptance. The same PR now iterates the **Sigma / Pixel Vixen** shared ranged kit first, not all characters simultaneously. With existing approved art, the pilot introduces travel-driven 12-step-per-second source-frame cycling, noticeable forward launch, running lean, direction-change banking, planted-stop settling, and stronger attack/idle body language. The female appearance gets a deliberately softer motion amplitude for its separate authored sprites.

The sprite transform and attached weapon grip share the same offset, rotation and scale to avoid floating equipment. Only actually travelled distance enters the run animation; pressing into a wall no longer shows run frames. The other kits and enemy motion remain on their V1 treatment until the ranged pilot is accepted.

**Acceptance still pending:** authored frame-by-frame polish and real native/browser comparison. No new source artwork or approved animation masters were generated. This code pass alone must not be advertised as matching the quality of the reference games, and must pass actual Godot 4.7.2 tests before review.
