# Cross-platform readiness and remaining acceptance

Godot 4.7.2, GDScript and the Compatibility renderer remain shared across Web, Android and iOS. Native export presets are preparation only: no signed binary, store release or device approval is produced by this work.

## Local build prerequisites

- Install the exact matching official Godot 4.7.2 export templates.
- Android: install the SDK/JDK versions required by that editor, configure the local editor tool paths, then choose the approved package identity and signing configuration. Credentials must stay outside Git; the repository ignores keystores and environment files.
- iOS: export on a supported macOS/Xcode environment with the matching templates. Set the approved bundle identity, team and signing locally. A physical iOS device and signing access are still required.
- The Android/iOS presets deliberately retain editor defaults for unapproved package identities and credentials. Do not distribute exports with placeholder identities.
- CI validates shared scripts and Web builds; it does not compile or sign native applications.

## Persistence and lifecycle

Web uses the Phaser v2 key in same-origin localStorage. Native uses atomic user://profile_v2.json writes. The previous Godot slice file and Phaser v1 key remain untouched. Menu copy/paste export/import is available for transferring a profile across browser origins; it retains a Godot backup and historical unlocks. Invalid/unavailable storage does not prevent playing.

Touch release/cancellation, focus loss, pause and choice modals clear the owned joystick pointer. Movement entered in a modal is suppressed until release. On Web, an eligible trusted DOM touch gesture attempts supported fullscreen and then orientation lock; denial/unavailability is caught. Browser CSS safe-area insets and native DisplayServer safe rectangles drive UI margins. Focus loss pauses gameplay; pointer ownership clears on pause, resize and modal entry. Actual landscape, fullscreen-denied/iOS fallback, safe-area layouts, suspend/resume and persistence require device/browser checks.

## Evidence and limits

Recovery now includes approved seeded Snack/Magnet drops and the timed Safe Spot; all clocks use active simulation time.

The regression suite exercises all three starter heroes, nine weapons, approved passive/offer rules, independent events, boss/berserk/stagger, save migration, menu confirmation and controlled victory/restart timelines. The controlled timeline jumps between boundary scenarios and uses an explicit final hit; it is not an unassisted human full run or a balance test.

The continuous seeded integration fixture runs all three starters with the real clock, movement, spawns, drops, legal choices and Flexes. It uses a protected-player subclass and 0.25-second frames through the production fixed substeps, then explicitly defeats a surviving boss if needed. This isolates progression; it does not establish survival balance or rendering behavior.

A synthetic headless sample starts with 300 enemies and 150 player projectiles and executes 60 iterations. It checks simulation survival without silently deleting entities and prints CPU elapsed time. It does not measure rendered FPS, mobile performance, sustained projectile density, memory stability over a full run or the 85/100 migration acceptance score.

Visual acceptance is explicitly deferred by the owner. The authenticated remote browser lacks WebGL2; production build readiness does not prove correct rendering. Outstanding acceptance includes desktop/mobile comparisons, a normal full run, audio/animation polish, real reference-device FPS/stress measurements and native device exports/lifecycle tests. Do not declare the full migration complete from green CI alone.
