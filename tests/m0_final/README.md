# M0 final footer and flow validation

This extends existing PR #93 (`fix/m0-card-footer-safe-inset`), rather than creating a competing fix. Runtime source is the existing `541ec8988543152de169c438538a60ef63e87a81`: a 44-unit footer inset in `clean_cut_skin.gd`. No further runtime change is introduced by these validation/evidence additions.

`test_flow.gd` uses actual Viewport pointer events, visible scroll intersections and real callbacks. Across all six canonical sizes it selects all three normal, six Legendary and five replacement cards, measures the complete selected footer, preserves hit rectangles and RNG, defers/reopens/confirms a Legendary, replaces the chosen passive, verifies terminal/retry/menu transitions and reloads an isolated native outcome profile. Fatal damage/boss defeat are controlled fixtures, not a normal-health human run. Existing pointer, secondary, keyboard, typography and deferred-Legendary suites also cover all six viewports.

Run: `godot --headless --path . --script res://tests/m0_final/test_flow.gd -- /tmp/flow.json`. To validate actual native rendering/event routing, omit `--headless` and use the Compatibility renderer. `scripts/validate.sh` includes this regression in mandatory CI. No test is disabled or waived.

`capture_footer.gd` renders genuine Godot normal/Legendary first and last-row states with the same live fixture data. Example: `godot --path . --rendering-driver opengl3 --script res://tests/m0_final/capture_footer.gd -- 844 390 /tmp/footer`.

For the before frames, the runner loads the exact `cbdc63776db807ee3082ba3b54920665a5a2b6f3` skin; after uses the exact existing PR #93 skin. All other runtime sources are identical. No screenshot is painted or synthesized. Offers, RNG, selected index and every button rectangle match. [Retained evidence and source hashes](../../docs/recovery/evidence/m0-final-2026-10-31/verification.json) include 24 native footer frames, six after viewports, exact readbacks and ten executed native suites. The matched before/after fixture has no safe-inset change; additional event tests cover asymmetric insets separately.

The creator already accepted PR #91's threat/controls/fluidity/legibility on Pixel 8a/Brave. Its tree equals the `cbdc637` integration baseline; accepted gameplay/input/artwork bytes remain unchanged. Do not reopen movement tuning or treat this native test as a fresh physical-device certification. The review browser visibly lacks WebGL2; exact-candidate normal-health Web play and browser persistence are not claimed.
