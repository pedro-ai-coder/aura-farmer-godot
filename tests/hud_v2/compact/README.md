# Desktop compact HUD review

Baseline: PR #86, `bf8d81d` (stacked on the existing HUD review). This is a sizing/presentation refinement; source artwork and approval records are unchanged.

[Desktop before/after](desktop-before-after.jpg) · [After](start-1600x900.jpg) · [READY](ready-1600x900.jpg) · [Safe Spot states](safe-states.jpg) · [Mobile viewport](start-844x390.jpg)

The desktop status, banner, XP, eight-slot strip, Pause and circular Flex reserve **22.5% less combined layout rectangle area** (275,406 → 213,496 logical units² at 1280×720). This measures layout rectangles, not opaque pixels. HP stays at 24 logical px; item levels are raised clear of the rarity stroke. Charging ability-name emphasis is reduced; READY retains full emphasis.

The ordinary distant Safe Spot has no label. Nearby injured players see availability; the progress arc/text uses the actual two-second charge. Actual healing triggers a brief existing-feedback-based pulse and “HP RESTORED”. Cooldown is subdued, with remaining time shown only nearby. Reduced Motion retains static progress and readable state text. Position, radius, healing, cooldown and pause behavior are unchanged.

Evidence is actual Godot 4.7.2 Compatibility/X11 software rendering with controlled fixture data, not human/device play. The existing 1600×900 baseline capture is reused at the same state/resolution. Four Safe Spot crops share one gallery; no new production assets were generated. The 844×390 viewport reads back at 843×390; all ten captured mobile control rectangles and font sizes match the earlier runtime report exactly.

Targeted checks: HUD for all heroes/six viewports (including boss/Shield/XP and real Pause/Quit), canonical recovery lifecycle, multitouch, stable drag fast path, and unchanged irregular-frame simulation/RNG hashes. Final CI and Web export results are linked in the PR. The P0 physical-mobile frame-pacing gate remains separate and unresolved by this UI task.
