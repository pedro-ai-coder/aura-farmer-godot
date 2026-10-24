# Clean Cut corrections — isolated native implementation review

Status: **DRAFT / NOT PRODUCTION ART APPROVAL**. Art PR #69 remains unmerged. Production PR #70 is merged at `7d8a6c9b2ea22055213e39eb44c42d8904dafdbd`; the public PCK was downloaded and inspected: 37 approved icons, 19 original masters, no candidate directory entries. See `evidence/clean-cut-v2-review/joystick-published.json`.

## Reproduce

Use official Godot 4.7.2, Compatibility renderer, from this review branch:

```sh
godot --path . --script res://tests/review_clean_cut_candidates.gd -- /absolute/output --interactive
godot --path . --script res://tests/review_clean_cut_candidates.gd -- /absolute/output
godot --headless --path . --script res://tests/test_clean_cut_review.gd
bash scripts/validate.sh
```

The interactive entry loads a nonpersistent test profile and starts at the real main menu. The default project scene and production resource registries are unchanged. Regular Web previews deliberately show the approved production UI, not this candidate adapter. Candidate raw bytes are loaded by a native-only, hash-checked whitelist. All three export presets exclude the review adapter, entry point and functional test. The PCK checker rejects their paths as well as candidate art. No full-screen reference screenshot is used as an interactive UI.

## Exact review sources and approval boundary

`CLEAN_CUT_REVIEW_RESOURCES.json` identifies 84 exact resource entries: 76 individual corrected component PNGs and eight supporting background/brand/HUD layers, from source commit `c1e13cdca5e0645e5f809dc6453ee75f979c8d4e`. Every entry has its SHA-256 and `runtime_promotion: false`. This is an inventory for review, **not an approval ledger**. Nothing has been added to `icon_approvals.json` and the 37 approved icon bytes are untouched.

The three baked equipment composites are deliberately excluded; every slot uses an independent frame, the current approved icon and actual item name/level. Illustrative card offers are replaced with actual offer data, current comparisons, separate selection/confirmation and the existing six-offer legendary cache/defer behavior. The original hero portraits, actor animations, map and gameplay/VFX systems remain in use.

The wordmark source contains SVG text unsupported by the Godot SVG decoder. Its QA-only PNG is a technical rasterization using the existing licensed Inter fonts. The manifest records both derived PNG and original SVG hashes. This conversion is **not a newly approved master**. No old SVG has been paired with Touch Grass v2.

## Actual evidence and parity matrix

`evidence/clean-cut-v2-review/` contains five before screenshots, 12 full-size final screenshots, six contact sheets, capture metadata and exact used-resource IDs. All 108 final images were rendered by official Godot 4.7.2, native X11 Compatibility on software Mesa/llvmpipe. Six requested sizes: 1600×900, 1280×720, 1920×1080, 915×412, 844×390 and 390×844. Actual output dimensions are retained, including 390×843 canvas rounding. Full-resolution files not retained in Git are explicitly marked in `captures.json`; every capture is represented on a contact sheet. Screenshots are staged fixtures, not survival runs.

| Corrected source composition | Native implementation and evidence | Remaining gap / acceptance |
| --- | --- | --- |
| Main Menu | Separate poster background, cut navy surface, original Sigma cutout, exact wordmark conversion and three live buttons; `menu-1600x900.jpg` | Native typography/portrait scaling differs from illustrative SVG; creator review pending |
| Hero Selection | Three independently selectable real starters, original portraits, correct starter icons, signature help, selected frame and separate Start; `heroes-1600x900.jpg` | Portrait view scrolls; focus/selected art used, no acceptance of new art implied |
| Gameplay HUD | Live HP/XP/Aura, wave/clock, 3+5 independent slots, single hero-specific Flex, pause, actual boss HP and circular movement component; `playing-1600x900.jpg`, `joystick-844x390.jpg`, `boss-1600x900.jpg` | Compact equipment text and warning contrast require further polish; boss uses existing master and animation, not a new export |
| Three-card Upgrade | Three actual offers, type-aware frames, approved icons, live name/body/comparison, selected state and explicit Confirm; `choice-1600x900.jpg`, `choice-390x844.jpg` | Responsive scrolling replaces all-three-at-once portrait composition; compact typography not visually accepted |
| Six-card Legendary | Six actual offers, weapon evolution/passive distinction, cached reopen, defer and explicit Confirm; `legendary-1600x900.jpg`, `legendary_last-390x844.jpg` | Portrait scroll exposes sixth option; no approval of future-only gameplay |

Each contact sheet also shows selected normal/last legendary card, three active signatures, three ready states, three recovery states, boss and joystick. Charging appears in default gameplay. Hover/focus/pressed/disabled are bound to native Button states; the current image set is not complete visual acceptance of every state. Disabled Flex art is not displayed as an extra duplicate control in paused/choice screens. Signature effects use existing simulation state and existing VFX, not newly commissioned Flex animation. High-density performance, all 22 original V5 targets, secondary-screen reskin, physical Android/iOS, browser WebGL2 and normal-health full-run acceptance remain outstanding. No FPS or device claim is made.

## Validation and continuation

The baseline suite passed all 41 Godot phases and 11 Python regression cases before adding review-specific checks. The review branch adds simulation/RNG immutability checks over 108 staged viewport/state combinations and functional tests at desktop, compact landscape and portrait: actual hero signals, Start, three-card selection/confirmation, six-card defer/cache/sixth pick and pause/resume. The CI workflow explicitly allows this one isolated review branch to run while remaining a draft; other drafts retain the existing skip behavior. No validation or merge protection is relaxed. The final full validation script passed all 43 Godot phases and 11 Python regression cases, including these two checks; the retained validation log records the actual run. Production PCK inspection proves the candidate adapter/art is absent; this is not a Web candidate visual test.

Continue visual polish and state coverage in this draft branch. Do not merge it or PR #69 as a production change. Before production integration, obtain explicit creator approval of exact independent resource hashes, then promote approved files through the established inventory/approval/export pipeline in a scoped development PR. The existing 37-icon approval must not be requested again. Keep future-only passives out of offers. Balance issue #52 and broader visual follow-up #49 remain open; no damage, HP, XP or drop rules were modified here.
