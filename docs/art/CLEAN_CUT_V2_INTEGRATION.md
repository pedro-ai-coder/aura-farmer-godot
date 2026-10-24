# Clean Cut creator corrections — integration tracker

Source PR #69 remains open and unmerged. Audited source: `c1e13cdca5e0645e5f809dc6453ee75f979c8d4e`, `assets/art-production/character-hype-clean-cut/v2/creator-corrections-v1/`. The direction is authorized; **none of the new decorative components is creator-approved for production**. Existing 37 approved icon PNGs and original actor/world masters remain unchanged.

## Intake evidence

`CLEAN_CUT_V2_INTAKE.json` records verified file sizes/hashes for all 226 declared entries, 79 component SVGs, 79 transparent PNG exports, 29 screen compositions and 340 resolved local references. All SVGs parse. Approved Sigma/Cool Kid/Alpha/Ruin Alley copied masters match the existing approved source bytes. The 37-icon ledger/source hashes match. Current PR #69 CI passed at audit; a CI pass is not art approval.

The corrected package supersedes diamond/arrow joystick art and duplicate/generic Flex treatments. Earlier HUD packages are supporting references only. The five corrected compositions were inspected directly. Runtime must use individual layers and actual controls, never screen composites.

Three equipment component exports (`build-inspection`, `build-strip-full`, `build-strip-mobile`) contain eight example icons and baked example names/levels. They are reference composites, not usable live equipment backgrounds. Use isolated slot states and live equipment text/icons instead. Fixed type labels in card frames and CTRL/ENTER identity marks are not numerical gameplay data; avoid duplicate type labels when placing live text. New headline/font packaging still needs an explicit licensed runtime choice. No missing SVG is silently paired with another PNG.

## Approved joystick implementation

The shipping procedural circular fallback now uses radius 80, thumb radius 35, saturation travel 119 and proportional thumb displacement. The entire safe playfield is eligible, including left/center/right and terrain beneath passive HUD; actual visible Button/Range/scroll/edit control rectangles take priority. Disabled buttons reserve their area but cannot become armed while held. A UI-started drag never becomes movement.

Movement and UI pointers are independent. Touch release activates its original enabled button only when still inside; emulated mouse events are consumed to prevent duplicate GUI actions. Held buttons reuse their pressed style and keyboard focus. Owner release does not cancel another held UI finger. Mode/focus/pause/result/restart/viewport changes clear ownership and visuals; touch-origin input remains unbiased when the visible ring is edge-clamped. Responsive geometry fits the safe area. Desktop mouse/keyboard and normalized movement speed are unchanged. Gameplay action touch targets use 64 reference units to retain approximately 48 physical pixels at the existing minimum canvas scale.

`test_mobile_joystick.gd` exercises left/center/right/top terrain, disabled and dragged-away UI, independent Flex, second-pointer ownership, release/cancel/focus/pause/modal/restart/resize, denied fullscreen/safe insets and desktop independence. It also routes real ScreenTouch/ScreenDrag events through SceneTree, not only direct handler calls. Existing Web fullscreen/orientation rejection tests remain required. Full suite: 41 Godot phases and 11 Python regressions. Native captures cover 28 staged cases at 1280×720, 915×412, 844×390 and 390×844 (compact canvas rounding is preserved in metadata). Native Compatibility/llvmpipe is not physical-device or browser WebGL2 acceptance.

## Next independent milestone

Prepare an isolated, clearly labelled Godot review branch for all five compositions, preserving live navigation, starter identity, equipment/offer data, states and the new joystick. Use exact candidate hashes for review only, with no candidate promotion or production export. Build the per-component review/approval manifest and actual reference-to-Godot discrepancy matrix. New art approval must identify the exact independent component files and supporting brand/background layers; the already-approved 37 icons must not be requested again. Until approval, production keeps approved resources and the input correction only.

## Isolated native review milestone

The next independent milestone is implemented on the draft review branch. See `CLEAN_CUT_NATIVE_REVIEW.md` and `CLEAN_CUT_REVIEW_RESOURCES.json`: five native live screens, original navigation/offer signals, 108 staged renders, before/after evidence, exact unapproved source hashes and production export exclusion. This is a review implementation, not creator acceptance or a production promotion. Compact HUD polish, full state coverage and gameplay/device acceptance remain explicit follow-ups.
