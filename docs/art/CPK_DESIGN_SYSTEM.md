> **Current status — 2026-11-15:** The creator accepted the exact reviewed Neon version and authorized main integration and production publication under [CPK-NEON-PRODUCTION-2026-11-15-01](CREATOR_NEON_PRODUCTION_APPROVAL_2026-11-15.md). Earlier candidate/no-release wording below is historical. The exact integrated Garage background is now approved for this use; its missing older reference is still unrecovered. Gameplay, hero pixels and approved wordmark remain unchanged.

# CPK presentation foundation

**Status:** IMPLEMENTED_REVIEW_CANDIDATE. Visual design-system application is not final creator acceptance.

Product authority: Canon `a1e670ff889b1a804a9c8b97b755e433a5cf3c95`, `gdd/GDD.md` V4.0; unchanged V3 rules inherited. Brand source: CPK-BRAND-2026-11-13-01, Art main `6b0da4f4cee5a72caec3c12b87c3e5817d94f969`. No invented logo or additional kit.

`assets/ui/cpk/theme.tres` is the shared native Godot Theme. `scripts/cpk_design_system.gd` owns reusable component helpers and tokens: dirty off-white #F3E9DB, orange #FF6A00, violet #9B00FF, charcoal surfaces, restrained borders, 8px spacing unit, minimum 48px touch targets. Archivo/Archivo Black reuse existing licensed font bytes. Violet is an accent, not low-contrast small text. Primary orange has charcoal text; secondary charcoal uses off-white text. Focus has a separate off-white outline, distinct from selection; disabled styling remains readable without implying interactivity.

Buttons, cards, panels and labels use native controls and retain their real input signals, focus and accessible text. The foundation has no simulation, RNG, storage, motion loop, remote service or screen-capture UI. Adoption can proceed in independently reviewable Garage and journey changes. Existing presentation remains operational until those adapters consume the shared system.

Executed locally on Windows with Godot 4.7.2 Compatibility: full project import, `--headless --script res://tests/test_cpk_design_system.gd` PASS, and native `--script res://tests/cpk_design_gallery.gd -- <capture.png>` rendered and inspected at 1280×720. Screenshot remains in the creator's local `cpk-production-review-2026-11-15/`. This focused foundation delivery does not claim full gameplay/browser validation or creator visual approval.
