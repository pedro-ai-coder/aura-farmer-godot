# AURA FARMER — FULL VISUAL & GAMEPLAY RECOVERY

## FINAL PLAYABLE ART DIRECTION IMPLEMENTATION

**Priority:** P0 — Critical Production Recovery
**Creator evaluation:** 3/10 — Current iteration rejected
**Status:** Full visual and gameplay recovery authorized
**Scope:** Godot implementation, artwork integration, visual production, UI/UX, gameplay feel, input systems, enemy behavior, performance, testing, and delivery
**Target:** A fully playable, visually final-quality Aura Farmer experience consistent with the canonical GDD and approved art direction.

---

# 0. EXECUTIVE DIRECTIVE

The current Aura Farmer gameplay iteration has been rejected by the creator.

The creator rates the current experience **3/10** and considers it substantially worse than an earlier version.

The regression affects both visual identity and gameplay experience.

The current implementation does not adequately follow the approved visual direction, does not convincingly integrate the intended final artwork, and lacks the gameplay quality expected of a production-quality survivor game.

This is not a request for minor polishing.

This is a comprehensive recovery assignment.

**Your responsibility is to recover Aura Farmer as an integrated, final-quality playable game, not merely improve individual assets, screens, or isolated mechanics.**

You are expressly authorized to modify:

- Godot scenes and scene hierarchies.
- Gameplay and presentation scripts.
- UI architecture and layout.
- Visual assets and their integration.
- Shaders, particles, animation, effects, and transitions.
- Input handling and virtual joystick logic.
- Enemy movement, navigation, and collision implementation.
- Camera presentation and visual scaling.
- Runtime performance and asset loading.
- Build, testing, and validation infrastructure.

You must preserve canonical gameplay design unless a deviation is explicitly approved.

The **canonical GDD is the source of truth**.

The selected visual direction is:

**Character Hype Broadcast — Clean Cut**, evolved from the approved Hero Spotlight V5 direction.

The assignment is not complete until the new visual system exists in the actual playable Godot build and the gameplay experience has been demonstrated through direct runtime testing.

Do not declare completion based on mockups, screenshots of isolated scenes, newly created directories, or implementation summaries.

---

# 1. NON-NEGOTIABLE SOURCE OF TRUTH

Before editing the game, identify and inspect all authoritative project materials.

## 1.1 Required sources

Locate and read:

1. The latest canonical Aura Farmer GDD.
2. The approved Art Bible and relevant creator art-direction decisions.
3. The Character Hype Broadcast — Clean Cut approval.
4. The original approved character master artwork.
5. The approved Hero Spotlight V5 materials.
6. The approved V5 icon batch.
7. The most recent art-production deliverables.
8. The current Godot implementation.
9. Relevant merged and open pull requests.
10. The last known visually superior playable implementation, where retrievable.

Create a source-of-truth inventory identifying:

- Document or asset.
- Location.
- Version, revision, or commit.
- Approval status.
- Applicable systems.
- Conflicts or ambiguities.
- Current implementation status.

## 1.2 Authority rules

Apply the following hierarchy:

1. Explicit creator decisions and approvals.
2. Latest canonical GDD for gameplay mechanics and balance.
3. Approved master character artwork and art-production assets.
4. Approved Clean Cut art direction and Art Bible.
5. Existing implementation, only where it does not conflict with higher-authority sources.

For gameplay mechanics, the GDD must remain authoritative.

For visual treatment, approved artwork and the latest authorized art direction must remain authoritative.

Do not treat the current game as the visual source of truth.

Do not infer new canonical rules from previous code behavior.

Do not silently change:

- Weapon and passive rules.
- Rarity distributions.
- Upgrade availability.
- Inventory or equipment limits.
- Enemy archetypes and behaviors defined by the GDD.
- Wave structure or progression.
- Damage formulas or character statistics.
- Recovery mechanics.
- Legendary selection rules.
- Run completion conditions.
- Economy and progression rules.

If the current implementation violates the GDD, correct the implementation.

If the source documents genuinely conflict, preserve the latest explicitly approved decision and document the conflict.

Do not invent missing canonical values.

---

# 2. BASELINE AND REGRESSION AUDIT

Before making substantial changes, perform a structured audit.

## 2.1 Establish baselines

Identify:

- Current playable revision.
- Current base branch and commit SHA.
- Last known better visual revision.
- Current approved artwork revision.
- Current UI architecture.
- Current input and movement implementation.
- Current wave and enemy systems.

Where possible, reproduce and capture both the current and previous versions under comparable conditions.

If the previous version cannot be reconstructed, explicitly report this limitation.

## 2.2 Audit required areas

Inspect:

- Main Menu.
- Hero Selection.
- Gameplay HUD.
- Three-Card Upgrade Selection.
- Six-Card Legendary Selection.
- Pause Menu.
- Settings.
- Run completion and game-over screens.
- Character presentation.
- Weapons and passive icons.
- Arena environments.
- Camera and character scale.
- Enemy spawn and movement.
- Attack presentation.
- Input responsiveness.
- Mobile joystick.
- Animation and VFX.
- Runtime performance.

Produce a severity-ranked discrepancy matrix.

For every relevant discrepancy, include:

- Affected scene or system.
- Expected result.
- Observed result.
- Authoritative source.
- Root cause or current hypothesis.
- Required correction.
- Validation method.
- Completion status.

Do not skip the audit and proceed directly to superficial UI changes.

**Gate 0 acceptance:** A reproducible baseline, authoritative source inventory, and issue matrix exist.

---

# 3. ART DIRECTION — CHARACTER HYPE BROADCAST: CLEAN CUT

## 3.1 Mandatory visual transformation

The game must adopt an identifiable final production visual language.

Clean Cut must not be interpreted as:

- Recoloring the current UI.
- Adding angular corners to existing panels.
- Reusing the entire V5 layout.
- Replacing a background gradient.
- Increasing border contrast.
- Placing approved icons inside generic widgets.
- Making a superficial typography change.
- Exporting attractive compositions without integrating them into the game.

The actual composition, hierarchy, typography attitude, shape language, interaction states, hero presentation, and visual rhythm must reflect the approved direction.

## 3.2 Build a production design system

Create or update a coherent Godot-ready visual system containing:

### Typography

- Approved font hierarchy and type treatment.
- Headings, card titles, body text, numerical information, and labels.
- Consistent text spacing.
- Legibility under gameplay conditions.
- Appropriate scaling at supported resolutions.
- Distinctive treatment of important gameplay information.

### Composition

- Strong visual hierarchy.
- Deliberate asymmetry where supported by the approved direction.
- Meaningful negative space.
- Clear focal points.
- Strong hero presentation.
- Controlled decorative elements.
- Separation between informational and interactive areas.

### Shape language

- Final approved panel geometry.
- Distinct button and card structures.
- Non-generic silhouettes.
- Clear selected, unselected, focused, disabled, and pressed states.
- Reusable but screen-appropriate visual elements.

### Color and contrast

- Palette derived from approved materials.
- Reliable hierarchy between backgrounds and interactive elements.
- Consistent rarity treatments.
- Accessible text contrast.
- Gameplay contrast independent of decorative richness.

### Motion and presentation

- Appropriate opening and closing transitions.
- Selected-item feedback.
- Lightweight animation where it materially improves comprehension.
- Consistent animation timing.
- Avoidance of unnecessary motion or visual noise.

Use actual production-ready resources.

Prefer authored visual assets and reusable isolated components over procedural approximations of approved art.

## 3.3 Artwork integrity

Preserve all approved original character identities and master artwork.

Preserve the exact approved V5 candidate PNG artwork for these weapon IDs:

`ban-hammer`, `brainrot-feed`, `chad-hands`, `cope-shield`, `keyboard-warrior`, `no-cap`, `personal-space`, `ratio-blaster`.

Preserve the exact approved V5 passive PNG assets identified in the latest creator approval record.

The previously approved batch contains 28 passives, for a total of 36 approved weapon and passive icons.

Do not approximate, regenerate, redraw, or silently replace these assets.

Verify the complete approved passive ID list against the authoritative approval record before auditing the batch.

Check file integrity, source mapping, imports, runtime display, and correct ID associations.

Preserving approved icons does not mean preserving the current generic UI surrounding them.

## 3.4 Asset manifest

Maintain a machine-readable asset manifest containing:

- Asset ID.
- Intended usage.
- Approval source.
- Canonical source file.
- Current production file.
- Import settings.
- Resolution and transparency.
- Associated Godot scene or component.
- Implementation status.
- Verification status.

Ensure the build loads real assets, not disconnected files in an asset folder.

**Gate 1 acceptance:** The implemented visual system is unmistakably Clean Cut, respects approved assets, and provides real reusable production components.

---

# 4. GAMEPLAY PRESENTATION RECOVERY

The current gameplay presentation suffers from weak visual hierarchy.

The environment competes with the player, enemies, attacks, and gameplay feedback.

Recover the visual priority of the action.

## 4.1 Camera and gameplay scale

Audit:

- Camera framing and zoom.
- Character apparent size.
- Enemy apparent size.
- Attack apparent size.
- Safe visible combat area.
- Distance between gameplay focus and HUD.
- Desktop/mobile framing consistency.
- Effects of resolution changes.

Do not blindly copy another game's zoom.

Derive the correct presentation from Aura Farmer's gameplay requirements and approved art direction.

Preserve canonical world-space gameplay values unless explicitly authorized to change them.

If a camera or presentation change materially affects enemy visibility, combat difficulty, or gameplay behavior, test and document the impact.

## 4.2 Environment clarity

Preserve the intended environmental identity.

However:

- Reduce visually competing noninteractive details where necessary.
- Control saturation and contrast in the combat area.
- Separate obstacles from decorative props.
- Make collision-relevant objects visually understandable.
- Maintain consistent object scale and perspective.
- Avoid hiding characters behind unnecessary foreground decoration.
- Keep projectiles and enemy threats distinguishable from environmental details.

Do not replace the environment with generic placeholders.

Do not make the arena visually sterile.

The target is a distinctive environment that supports gameplay readability.

## 4.3 Character presentation

Ensure the player character remains identifiable at all supported gameplay scales.

Review:

- Idle and locomotion animation.
- Movement direction feedback.
- Character silhouette.
- Attack animation.
- Damage reaction.
- Temporary invulnerability presentation, if specified.
- Interaction with the surrounding environment.
- Visual layering and occlusion.
- Death and recovery feedback.

Character identity must remain consistent with approved artwork.

**Gate 2 acceptance:** Gameplay visuals clearly prioritize the player, threats, attacks, and relevant pickups while maintaining the approved world identity.

---

# 5. GAMEPLAY FEEL AND COMBAT SYSTEM

This is a major implementation task, not an optional polish pass.

## 5.1 Player movement

Audit the input-to-movement pipeline.

Verify:

- Immediate response to valid directional input.
- Correct normalization of diagonal movement.
- Consistent movement across frame rates.
- Correct acceleration and deceleration behavior as specified or already approved.
- Correct collision response.
- No unexplained hesitation.
- No persistent movement after input release.
- No stuck input after focus loss or touch cancellation.
- Correct interaction with obstacles and enemies.

Separate actual input/physics defects from intended canonical movement characteristics.

Do not alter player movement statistics to disguise input problems.

## 5.2 Weapon presentation

Audit every implemented weapon, including the eight approved weapon IDs.

For each weapon, verify:

- Correct canonical functionality.
- Correct firing conditions.
- Correct target acquisition behavior.
- Correct activation timing.
- Correct damage application.
- Correct range and projectile behavior.
- Correct collision or hit detection.
- Visible attack origin and direction.
- Distinct attack identity.
- Clear hit confirmation.
- Appropriate elimination feedback.
- Correct interaction with passive modifiers.

A weapon must not merely deal invisible damage while an unrelated animation plays.

Presentation must reflect actual gameplay behavior.

## 5.3 Combat feedback

Implement coherent feedback for:

- Attack initiation.
- Projectile travel where relevant.
- Successful hit.
- Miss or obstruction where relevant.
- Damage received.
- Enemy elimination.
- Pickup collection.
- Level-up.
- High-impact or rare gameplay events.

Choose effects according to gameplay semantics.

Possible techniques include short hit flashes, authored particles, impact animations, modest hit-stop, sound cues, and localized VFX.

Do not automatically apply all effects to every interaction.

Never introduce artificial combat pauses that damage control responsiveness.

Prioritize clarity and performance.

## 5.4 Enemy movement and behavior

Investigate previously observed issues where enemies become stationary or fail to pursue the player.

Inspect:

- Target references.
- Navigation updates.
- Collision masks and layers.
- Obstacle handling.
- Velocity calculation.
- Steering behavior.
- Spawn placement.
- Object pooling and reactivation.
- Enemy state transitions.
- Offscreen behavior.
- Timer dependencies.
- Animation state synchronization.
- Physics processing.
- Target invalidation and reacquisition.

Build reproducible test cases for stuck enemies.

An enemy may be stationary only if its canonical behavior or active state justifies it.

Do not hide AI defects by despawning problematic enemies.

## 5.5 Threat density and wave pacing

Verify actual wave behavior against the canonical GDD.

Measure:

- Spawn frequency.
- Active enemy count.
- Enemy lifespan.
- Density distribution.
- Time spent without meaningful threats.
- Interaction between camera framing and visible density.
- Performance at high enemy counts.

If a wave feels empty, determine whether the cause is incorrect spawning, excessive camera coverage, enemy navigation defects, or an intended balance rule.

Correct implementation defects.

Do not invent new wave numbers, spawn rates, or health values.

## 5.6 Build progression feedback

Weapon and passive upgrades must have a recognizable consequence.

Where the GDD defines an observable combat change, ensure the gameplay reflects it.

Where a passive modifies only statistical behavior, provide the appropriate approved UI feedback rather than inventing a new visual effect that could misrepresent the mechanic.

Test upgrade stacking, modifier calculations, repeated selections, and interactions with the inventory system.

**Gate 3 acceptance:** Movement is responsive, enemy behavior is correct, every implemented attack is readable, and combat progression is observable without compromising canonical rules.

---

# 6. HUD AND INPUT REBUILD

## 6.1 Gameplay HUD

Rebuild the HUD using the approved Clean Cut visual language.

Audit and restructure:

- Health presentation.
- Experience and level.
- Wave and timer.
- Weapon inventory.
- Passive inventory.
- Aura information.
- Temporary or contextual states.
- Pause and settings access.
- Safe Spot presentation.
- Other indicators required by the GDD.

Requirements:

- Gameplay remains the primary visual focus.
- Essential information is readable at a glance.
- Secondary information does not dominate the screen.
- Labels and numerals remain legible at supported resolutions.
- Equipment icons use approved sources.
- No overlapping interface elements.
- No excessive stacking of unrelated widgets.
- No large generic panels obscuring gameplay.
- Correct scaling for mobile and desktop.
- Support for relevant interaction and input states.

The Safe Spot indicator must accurately communicate its canonical function while avoiding unnecessary visual domination of the scene.

Do not change Safe Spot gameplay rules.

## 6.2 Mobile joystick — mandatory correction

The joystick must follow the interaction principles of the Brotato mobile joystick.

**The joystick must NOT be diamond-shaped.**

Required presentation:

- Circular base.
- Circular thumb indicator.
- Consistent analog direction feedback.
- Appropriate thumb radius and interaction area.
- Clear touch-state feedback.
- Visual compatibility with the final Clean Cut design.

Required behavior:

- Support joystick activation from either the left or right side according to the intended touch-control scheme.
- Do not hardcode movement input to the left side only.
- Respect safe areas and reserved UI interaction zones.
- Correctly track the initiating touch identifier.
- Preserve input tracking when other touches occur.
- Handle touch release and cancellation.
- Avoid teleporting or snapping movement unexpectedly.
- Avoid stuck directional input.
- Support normal movement directions and diagonals.
- Behave correctly with different screen resolutions and orientations supported by the project.
- Keep control behavior separate from purely cosmetic joystick rendering.

Support left- and right-side operation without creating competing movement commands.

If a screen-wide floating joystick is incompatible with an authoritative control rule, apply the authoritative rule and document the conflict.

Test on actual touch input or a valid multi-touch emulator with explicit evidence.

A mouse-only simulation does not prove mobile joystick correctness.

## 6.3 Desktop controls

Verify keyboard and any other canonically supported desktop input methods.

Test:

- Key press and release.
- Opposite directional inputs.
- Pause and resume.
- Window focus changes.
- Interactions with menus.
- Input isolation during upgrade selection.
- Gamepad input if supported by the GDD.

**Gate 4 acceptance:** HUD is production-quality and the circular mobile joystick works correctly from both supported screen sides, including multi-touch and cancellation cases.

---

# 7. FIVE CRITICAL SCREEN IMPLEMENTATIONS

These five screens are the minimum mandatory visual-production scope.

All artwork must be implemented in Godot.

A static image of the intended interface is not an implemented screen.

## 7.1 Main Menu

Create the final Clean Cut presentation.

Required:

- Approved Aura Farmer branding and logo.
- Distinctive background composition.
- Strong visual hierarchy.
- Final typography treatment.
- Appropriate hero presentation.
- Production-quality primary actions.
- Complete hover/focus/pressed/disabled states where applicable.
- Smooth and coherent transitions.
- Correct navigation.
- Desktop/mobile responsive layouts.
- No generic legacy menus.

Ensure the first screen immediately communicates the game's identity.

## 7.2 Hero Selection

Required:

- Approved character artwork.
- Strong hero-centered composition.
- Correct character identity.
- Canonical character information.
- Distinct available, selected, and locked states.
- Appropriate visual feedback on hero selection.
- Readable character details.
- Correct progression or unlock restrictions.
- Correct navigation into gameplay.
- Responsive layouts.

Do not approximate character artwork.

Do not invent or modify hero abilities.

## 7.3 Gameplay HUD

Implement the final HUD specified in Section 6.

The result must be assessed during live combat, not only in an empty test scene.

Verify early-wave, dense-wave, low-health, level-up, and contextual gameplay states.

## 7.4 Three-Card Upgrade Selection

Completely redesign the current generic selection experience.

Required:

- Approved Clean Cut composition.
- Strong three-card layout.
- Distinct weapon and passive presentation.
- Approved artwork displayed prominently.
- Correct names, levels, descriptions, and statistics.
- Canonical rarity treatments.
- Selected state with clear visual emphasis.
- Correct confirmation action.
- Correct gameplay pause and resumption.
- Correct application of the chosen upgrade.
- Safe handling of missing or unavailable choices.
- Keyboard, mouse, and touch interaction as applicable.
- Responsive layout without clipped text or icons.
- Appropriate entry and selection animation.

The player must experience the choice as an important gameplay reward.

Do not invent gameplay choices to improve the appearance.

## 7.5 Six-Card Legendary Selection

This must not be a compressed copy of the three-card layout.

Required:

- A distinct final presentation appropriate for legendary decisions.
- Six visible, identifiable options when required by the GDD.
- Correct canonical option pool and restrictions.
- Appropriate visual hierarchy and rarity emphasis.
- Readable information for every card.
- Strong selected state.
- Correct selection and confirmation.
- Correct handling of repeated input.
- Responsive composition for mobile.
- No inaccessible offscreen options.
- No clipping, overlapping, or unreadable content.
- Correct gameplay continuation.

If a compact viewport requires scrolling or a responsive alternative, all six options must remain discoverable and accessible.

Do not alter legendary mechanics to accommodate the interface.

## 7.6 Required deliverables for each screen

Provide:

1. Final implemented Godot scene.
2. Referenced production assets.
3. Reusable isolated assets where applicable.
4. Interaction and animation states.
5. Desktop screenshot from the running build.
6. Mobile screenshot from the running build.
7. Short interaction recording.
8. Mapping to approved art-direction sources.
9. Validation result.

**Gate 5 acceptance:** All five screens are final-quality, functional, and present in the real playable build.

---

# 8. COMPLETE THE REST OF THE INTERFACE

After the five primary screens, complete the remaining interface surfaces required for a playable run.

Include all applicable:

- Pause menu.
- Settings and options.
- Confirmation dialogs.
- Wave transitions.
- Level-up feedback.
- Inventory states.
- Tooltips and contextual information.
- Character unlock messaging.
- Game-over flow.
- Victory or run-completion flow.
- Post-run results.
- Navigation and back actions.
- Loading and transition states.
- Error and unavailable-content states.

No screen on the normal player journey may unexpectedly return to a generic legacy presentation.

Use shared components, but preserve intentional distinctions between gameplay, selection, and result screens.

Ensure all controls are actually connected to working functionality.

**Gate 6 acceptance:** The complete normal gameplay journey uses a coherent final art direction without incomplete or placeholder UI transitions.

---

# 9. GAMEPLAY SYSTEM INTEGRATION

After visual reconstruction, validate that all systems remain functional.

Audit:

- Hero selection and hero-specific properties.
- Wave start and completion.
- Enemy spawning and despawning.
- Weapon behavior.
- Passive effects.
- Damage and recovery.
- XP collection.
- Level-up transitions.
- Upgrade generation.
- Upgrade application.
- Inventory restrictions.
- Legendary selection.
- Pause/resume state.
- Death and game-over.
- Run completion.
- Restart behavior.
- Any additional systems required by the GDD.

Create automated tests for deterministic systems wherever feasible.

Create manual test procedures for presentation and device-specific behaviors.

Do not assume visual refactoring has preserved game logic.

Specifically test pause/resume and upgrade state transitions for:

- Duplicate upgrade application.
- Lost input focus.
- Stuck movement.
- Incorrect timers.
- Enemy movement during an unintended pause state.
- Duplicate scene transitions.
- Missing artwork or stale UI bindings.

**Gate 7 acceptance:** A full run can be completed using the redesigned experience, and canonical systems still behave correctly.

---

# 10. PERFORMANCE AND TECHNICAL QUALITY

Performance is part of gameplay quality.

Profile rather than guess.

## 10.1 Required metrics

Record on representative target hardware or clearly identified test environments:

- Average FPS.
- Frame-time distribution.
- 1% low FPS, where measurement supports it.
- Significant frame-time spikes.
- Relevant CPU and GPU timings.
- Memory usage.
- Object and particle counts.
- Scene transition performance.
- Asset loading behavior.

Capture performance at:

- Main Menu.
- Hero Selection.
- Early wave.
- Mid-density combat.
- High-density combat.
- Three-card selection.
- Six-card selection.
- Run completion.

## 10.2 Optimization areas

Investigate as needed:

- Excessive draw calls.
- Texture import and filtering.
- Texture size and memory pressure.
- Repeated asset loads.
- Overdraw and transparent effects.
- Particle limits.
- Enemy pooling.
- Projectile pooling.
- Unnecessary per-frame allocations.
- Expensive collision checks.
- Navigation recalculations.
- UI layout rebuilding.
- Excessive shader costs.
- Scene instantiation spikes.

Keep the final art direction intact.

Do not solve performance issues by indiscriminately removing the newly approved visual identity.

## 10.3 Frame-rate stability

Establish performance budgets based on supported platforms and project requirements.

Do not present an unmeasured FPS target as already achieved.

If a target cannot be met, report the tested hardware, observed results, known bottlenecks, and remaining work.

**Gate 8 acceptance:** No known critical runtime defect remains, performance is measured, and the supported experience is demonstrably playable.

---

# 11. PARALLEL ART-PRODUCTION COORDINATION

A separate art-production workflow is already producing visual assets.

This recovery Work has permission to modify both visuals and gameplay logic.

However, it must not overwrite, discard, or invalidate approved assets without an explicit authorization or documented technical necessity.

## 11.1 Ownership model

This Work owns:

- Final gameplay integration.
- Godot scene implementation.
- UI/UX implementation.
- Gameplay feel.
- Input and enemy behavior.
- Runtime VFX and animation integration.
- Asset import and binding.
- Performance.
- End-to-end validation.

The parallel art-production workflow owns its explicitly assigned artwork deliverables until they are handed off.

## 11.2 Conflict prevention

Before modifying shared files:

- Inspect active branches and relevant open PRs.
- Identify shared-file overlap.
- Record overlapping asset and scene ownership.
- Use isolated branches or worktrees where practical.
- Keep the integration branch rebased or otherwise synchronized safely.
- Do not silently replace newer approved artwork with older files.
- Do not duplicate assets under ambiguous names.
- Do not automatically merge unrelated art-production PRs.

## 11.3 Missing assets

If a required final asset is missing:

1. Search the approved sources.
2. Search current art-production outputs.
3. Determine whether it may be authored within this Work's approved scope.
4. Produce it consistently with approved art direction if authorized.
5. Otherwise record a blocking dependency.

Temporary stand-ins may be used only for internal development.

They must be explicitly tracked and must not be represented as final production artwork.

**A final delivery may not silently depend on temporary placeholder art.**

---

# 12. QUALITY ASSURANCE AND ACCEPTANCE MATRIX

Create a persistent test matrix.

Use statuses:

- PASS
- FAIL
- BLOCKED
- NOT TESTED

Do not mark untested functionality as passing.

## 12.1 Visual acceptance

All must pass:

- Main Menu implements Clean Cut.
- Hero Selection implements Clean Cut.
- Gameplay HUD implements Clean Cut.
- Three-Card Upgrade implements Clean Cut.
- Six-Card Legendary implements Clean Cut.
- Secondary screens remain consistent.
- Approved characters are preserved.
- Approved icons are preserved.
- Final assets are actually loaded.
- No visible placeholder art remains on the normal gameplay path.
- Desktop/mobile layouts remain usable.
- UI text and icons are legible.
- Important states are visually distinct.

## 12.2 Gameplay acceptance

All must pass:

- Responsive movement.
- Consistent collisions.
- Correct canonical movement behavior.
- Correct enemy pursuit.
- No unexplained stationary enemies.
- Correct weapon functionality.
- Visible and distinct attack feedback.
- Accurate damage application.
- Correct XP and pickup behavior.
- Correct upgrade application.
- Correct wave state transitions.
- Correct pause and resume.
- Correct death and completion flow.
- Full run completion.

## 12.3 Mobile acceptance

All must pass:

- Circular joystick.
- No diamond-shaped control.
- Left-side activation.
- Right-side activation.
- Multi-touch behavior.
- Touch cancellation.
- No stuck input.
- No UI overlap at supported mobile resolutions.
- Correct safe-area handling.
- Functional selection screens.

## 12.4 Regression acceptance

Verify that:

- No approved gameplay mechanic has been removed.
- No canonical rule has been changed without approval.
- No approved character identity has been altered.
- No approved icon has been replaced.
- No previously fixed critical defect has returned.
- No screen has silently regressed to the old generic UI.
- No blocking runtime errors remain.

---

# 13. MANDATORY EVIDENCE PACKAGE

Provide direct evidence from the running Godot build.

## 13.1 Screenshots

Capture:

1. Main Menu.
2. Hero Selection.
3. Gameplay — early wave.
4. Gameplay — dense combat.
5. Gameplay — low health.
6. Three-Card Upgrade.
7. Six-Card Legendary.
8. Pause Menu.
9. Settings.
10. Run-completion or game-over screen.
11. Mobile HUD.
12. Mobile joystick activated on the left.
13. Mobile joystick activated on the right.

Screenshots must represent actual runtime scenes.

Do not substitute conceptual artwork.

## 13.2 Videos

Deliver at least:

**Video A — Full Gameplay Run**

An uninterrupted full run on a supported platform, showing actual gameplay, upgrades, wave progression, and conclusion.

**Video B — Visual Experience Walkthrough**

Show the Main Menu, Hero Selection, gameplay, upgrade selections, secondary menus, and end-of-run flow.

**Video C — Mobile Controls**

Demonstrate left-side and right-side joystick activation, movement, touch release, and relevant multitouch interactions.

**Video D — Combat and Enemy Behavior**

Demonstrate player movement, multiple weapon behaviors, pursuit, obstacles, collisions, hits, eliminations, and dense combat.

**Video E — Regression Comparison**

Where the earlier playable revision is recoverable, show comparable old-versus-new footage or matched screenshots.

Clearly label which versions are being compared.

## 13.3 Technical evidence

Include:

- Build instructions.
- Godot version.
- Tested platforms.
- Test configurations.
- Automated test results.
- Manual test matrix.
- Performance report.
- Known limitations.
- Asset manifest.
- Source-of-truth compliance notes.
- Final change summary.

If a platform could not be tested, state it explicitly.

Never fabricate performance or compatibility evidence.

---

# 14. DEVELOPMENT ORDER AND EXECUTION

Implement the recovery in the following order:

**Phase 0 — Audit and baseline**

Establish source-of-truth mapping and regression evidence.

**Phase 1 — Visual system**

Implement real Clean Cut foundations and reusable components.

**Phase 2 — Gameplay presentation**

Correct the camera, environment hierarchy, character visibility, and combat composition.

**Phase 3 — Gameplay feel**

Repair movement, enemy behavior, attacks, collision feedback, and combat presentation.

**Phase 4 — HUD and joystick**

Implement production UI and correct mobile controls.

**Phase 5 — Five critical screens**

Build the Main Menu, Hero Selection, Gameplay HUD, Three-Card Upgrade, and Six-Card Legendary screens.

**Phase 6 — Remaining interfaces**

Complete the full player journey.

**Phase 7 — Gameplay integration**

Verify weapons, passives, progression, transitions, and canonical logic.

**Phase 8 — Performance and QA**

Run profiling, device testing, regression testing, and full-run validation.

**Phase 9 — Final delivery**

Provide the playable build, evidence package, and reviewable PR.

These phases are execution gates, not independent mockup deliverables.

Work continuously through the authorized scope.

Do not stop after the audit or first visual improvement unless a genuine technical blocker prevents further progress.

Commit coherent milestones.

Do not claim a later gate is complete when an earlier dependency remains unresolved.

---

# 15. DEFINITION OF DONE

The assignment is complete only when ALL of the following are true:

1. The creator-approved Clean Cut direction is recognizably and consistently implemented.
2. The final artwork exists in the actual playable build.
3. All five critical screens are production-quality and functional.
4. Secondary screens follow the same identity.
5. Approved character and icon artwork is preserved.
6. Gameplay visual hierarchy is substantially improved.
7. Combat has readable attacks, impact feedback, and progression.
8. Player movement is responsive and consistent.
9. Enemy pursuit and movement defects are resolved.
10. The mobile joystick is circular and works correctly on both supported screen sides.
11. The complete gameplay loop follows the canonical GDD.
12. A full run can be completed.
13. Desktop and mobile layouts are validated on appropriate test environments.
14. Performance and regression tests are documented.
15. No critical visual, gameplay, or input defects remain.
16. The build and implementation can be independently reviewed.
17. The evidence package is complete.
18. No required final art is silently replaced by placeholders.
19. No unrelated or unapproved gameplay redesign has been introduced.
20. The creator can directly inspect the implemented result before approving the merge.

If any item remains incomplete, mark the project as PARTIALLY COMPLETE or BLOCKED.

Do not describe the implementation as final when mandatory acceptance criteria have not passed.

---

# 16. GITHUB AND FINAL DELIVERY

Use an isolated recovery branch.

Create a reviewable pull request containing the implementation and documentation.

Organize commits into coherent work units.

Before opening or finalizing the PR:

- Run available project checks.
- Run Godot import validation.
- Execute available gameplay tests.
- Inspect runtime errors.
- Verify committed assets.
- Check for missing references.
- Review unintended gameplay changes.
- Review conflicts with parallel art-production work.

The final PR must include:

### A. Executive summary

What was broken and how it was corrected.

### B. Before/after evidence

Comparable screenshots and footage.

### C. Gameplay recovery

Movement, combat, AI, upgrade feedback, and HUD improvements.

### D. Visual recovery

Clean Cut implementation and asset integration.

### E. GDD compliance

What was preserved, what was corrected, and any unresolved source conflict.

### F. Testing

Results, supported environments, failures, and limitations.

### G. Review package

Paths or links to the build, videos, screenshots, asset manifest, and validation matrix.

### H. Remaining issues

Every known unresolved issue must include severity and reproduction details.

Do not automatically merge the PR.

Request creator review after delivering the implementation and evidence.

---

# 17. FINAL CREATOR DIRECTIVE

This is an explicit rejection of the current visual and gameplay experience.

The goal is not to make Aura Farmer marginally better.

The goal is to restore and materially improve the game until it delivers the final-quality experience already defined by its canonical design and approved art direction.

You have authorization to perform substantial visual and technical reconstruction.

Use that authorization.

Do not preserve weak current implementations merely because they already exist.

Do not compromise the approved identity for implementation convenience.

Do not confuse asset integration with visual art direction.

Do not confuse a working gameplay loop with satisfying gameplay.

Do not confuse a completed task list with a completed game.

**Deliver a real, coherent, production-quality, fully playable Aura Farmer experience — and prove it through the running build.**

The GDD remains the source of truth.

The creator's art approvals remain authoritative.

Gameplay feel, visual identity, technical reliability, and integration must be treated as one product.

**Begin the recovery work now.**
