# Shared CPK journey presentation

**Status:** IMPLEMENTED_REVIEW_CANDIDATE; functional checks are evidence, not final visual acceptance.

The new Garage and the existing gameplay journey now share off-white/orange/charcoal surfaces and Archivo typography. Existing semantic rarity colors and HP/shield/damage cues remain distinct. The three kits and six identity sprites are unchanged.

`ArcadeTheme` adapts existing native components to `CpkDesignSystem` tokens. The typography Theme derives from the shared native resource. Tactile action buttons retain the existing hitboxes, input/focus ownership, restrained press travel, cancellation and reduced-motion behavior, but draw cached native Theme StyleBoxes. Historical PNG styles remain inspectable/hash-pinned and are not overwritten or falsely marked approved. Primary/secondary/destructive/focus/selected/disabled appearances stay distinct. The active exact CPK wordmark replaces reconstructed legacy lettering.

For existing decorative HUD/card frames only, one shared lightweight canvas shader maps legacy decorative gold/navy/cream toward CPK orange/charcoal/off-white. It is not assigned to heroes, world art, item icons or boss portraits. HP and shield semantics remain intact. New modal/upgrade backdrops use the separately proposed Garage layer where appropriate; pause retains its existing real-world context. Every label, meter, offer and result remains bound to the authoritative game data.

Executed locally on Windows/Godot 4.7.2: tactile-button regression, six-resolution button/quit-confirmation tests, six-viewport HUD/threat/settings tests, complete card/deferred-Legendary/replacement/outcome/retry/save-reload flow, and typography/category/compact-selection tests all passed. The existing native creator-feedback capture utility generated real rendered gameplay, upgrade, pause and confirmation states for visual inspection. Those staged captures are QA scenarios, not normal gameplay or device-performance evidence. Full aggregate/export validation follows final presentation integration.

Remaining: final visual approval, physical-device/long-session review, new directional animation drawings and broader environment modernization. No merge, production deployment, canonical balance change or source-art repainting is authorized by these results.
