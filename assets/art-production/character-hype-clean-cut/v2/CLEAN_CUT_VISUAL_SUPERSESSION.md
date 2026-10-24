# Character Hype Broadcast — Clean Cut visual specification

**Status:** production art candidate, pending creator review.  
**Scope:** screen composition and reusable artwork for the five P0 screens in this folder. This document does not edit or replace the GDD.

## Clean Cut identity

Clean Cut is an authored street-poster arcade identity. Use oversized graphic character cutouts; hand-built wordmark art; warm paper and hard ink; print-like urban illustration; diagonal crop geometry; solid-color slabs; and asymmetric negative space. Headline typography is condensed, heavy, and stacked, with outline/offset treatments as part of the brand artwork. Live descriptive copy stays simple and readable. No font binary is included or licensed by this package.

Use cut corners, clipped trapezoids, hard offset shadows, slashed badges, and distinct silhouettes by screen and choice. Provide clear focus, pressed, and disabled states. Pair every color cue with a shape, label, icon, or line pattern.

## V5 visual rules superseded

| V5 rule or convention | Clean Cut replacement |
|---|---|
| One hero-first composition repeated across presentation screens | A distinct composition per flow: poster menu, three unequal hero stages, map-forward HUD, three varied upgrade slates, and compact 3×2 legendary spread |
| Uniform rounded panels, buttons, and card geometry | Cut-paper polygons, clipped corners, angled caps, hard ink outlines, offset shadows, and purpose-specific silhouettes |
| Fixed shared card template and sizes across choice types | Separate hero, upgrade, and legendary frames, with separate idle, hover/focus, selected and disabled artwork where applicable |
| V5 button radius and border treatment as the visual identity | Hard-edged control plates with default, hover, keyboard-focus, pressed and disabled variants |
| Inter-only display hierarchy for all prominent titles | A condensed stacked headline attitude and a separately drawn Aura Farmer wordmark; body copy stays readable and licensed font integration is a separate implementation decision |
| Deep navy/blue slabs or generic gradients as the default backdrop | Illustrated paper/urban poster environments, graphic color blocks, and the existing approved Ruin Alley map during gameplay |
| Repeated glow, noise, and interchangeable filler badges | Sparse print texture, controlled slashes, crop marks, and functional state marks only |

## Rules that remain binding

- Existing approved Sigma, Cool Kid, Alpha Chad, and Ruin Alley masters are copied unchanged. Do not redraw, recolor, crop, or regenerate them.
- Existing V5 base palette and semantic color meaning remain available for continuity. Clean Cut changes composition, distribution, shape, and typography treatment; color never carries meaning alone.
- The GDD remains canonical for characters, names, catalog, effects, offer legality, timers, gameplay state, interaction, responsive layout, accessibility, and cross-platform requirements.
- Keep hostile telegraphs readable. Support keyboard focus, reduced-motion settings, contrast, text labels, and touch targets that meet the GDD minimum. Static art is a composition reference, never a live scene or data source.
- New wordmark/environment art, new frame art, and all Clean Cut comps are PRODUCTION_CANDIDATE_PENDING_CREATOR_REVIEW. Existing approved masters keep their original provenance.

## Five screen contracts

1. **Main Menu:** poster environment, separate wordmark and Sigma source master, three navigation actions. Action labels are live UI content in implementation.
2. **Hero Selection:** exactly Sigma, Cool Kid, and Alpha Chad; current role and Flex names from GDD §7.2. Selection and portrait layers stay separate.
3. **Gameplay HUD:** Ruin Alley master unchanged. Preview state WAVE 3 at 05:42 shows Big Hater in 04:18, matching the canonical 10:00 schedule. Values are simulation-bound.
4. **Three-card upgrade:** three offers, one choice. Examples are sourced from the current catalog; legal offers and states are data-bound.
5. **Six-card legendary:** three weapon evolution slots and three legal legendary-buff slots, one choice. The time row uses GDD 06:00 first / 08:00 reprise / 09:55 final offer. The six shown offers are examples, not an offer guarantee.

## Handoff

The screen SVGs are full-screen art compositions; PNGs are review exports. Shared brand, background, character and component files are independent artwork. Do not ship static screens as runtime. Build live controls from the parts and bind all variable data to canonical game state.
