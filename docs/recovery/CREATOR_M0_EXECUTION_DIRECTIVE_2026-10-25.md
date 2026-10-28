# AURA FARMER — WORK EXECUTION DIRECTIVE

## M0.0 — Gameplay & Visual Recovery Completion

**Priority:** P0 — Critical Production Recovery  
**Project:** Aura Farmer  
**Repository:** `pedro-ai-coder/aura-farmer-godot`  
**Authoritative specification:** `docs/GDD.md` — GDD V3.0  
**Target engine:** Godot 4.7.2, GDScript, Compatibility renderer  
**Current visual direction:** Character Hype Broadcast — Clean Cut  
**Target milestone:** M0 — Fully Polished Closed Web Playtest  
**Execution status:** Authorized to implement, test, document, and open pull requests. **Not authorized to merge or publicly release.**

---

# 0. EXECUTIVE MANDATE

You are responsible for completing the functional, visual, interaction, and performance recovery of Aura Farmer's Godot implementation.

The creator has rejected the current integrated gameplay experience as insufficiently polished. Previous automated tests and approved artwork integrations have not yet produced the expected final-quality playable game.

**Your objective is to deliver a cohesive, fully playable, visually polished Web game that satisfies the canonical GDD V3.0 and is suitable for subsequent closed-test acceptance.**

This is an implementation assignment, not a research-only task, a mockup task, or an invitation to produce another theoretical development plan.

You must inspect the current implementation, reproduce its defects, make actual code and presentation corrections, run the required tests, capture genuine gameplay evidence, and submit reviewable pull requests.

You must preserve approved gameplay behavior and all exact creator-approved artwork.

**Do not declare M0.0 complete based only on green CI checks, isolated rendered screenshots, headless tests, or statements that visual components have been integrated.**

Completion requires an actual interactive Web build, credible visual evidence, an uninterrupted normal gameplay run, documented regression results, and creator review.

## 0.1 Non-negotiable restrictions

You are **not authorized** to:

1. Modify the Phaser repository or any Phaser source file.
2. Change approved gameplay balance values, including HP, damage, XP, drop rates, wave timing, boss difficulty, movement-speed values, weapon cadence, rarity probabilities, Flex coefficients, recovery values, or equipment limits.
3. Introduce new gameplay mechanics, new playable heroes, additional passive offers, new weapons, new item rarities, extra upgrade choices, or new maps.
4. Enable prototype-only concepts P4–P7 or unapproved P8 in normal gameplay.
5. Build or integrate a backend.
6. Implement Discord Activity integration as part of this assignment.
7. Add authentication, telemetry collection, cloud saves, monetization, paid infrastructure, or services requiring additional expenditure.
8. Alter save compatibility or existing stable gameplay identifiers.
9. Replace approved source artwork silently, promote candidate art without explicit creator approval, or treat a merged asset integration as final visual acceptance.
10. Merge any pull request automatically.
11. Deploy publicly, expand tester access, make release announcements, or declare Milestone 0 complete.
12. Present staged screenshots, AI-generated samples, software-render benchmarks, or headless test results as genuine normal-play Web evidence.

You **are authorized** to modify Godot scenes, UI composition, presentation scripts, input handling, collision/navigation implementation, animation playback, shaders, particles, visual feedback, resource-management logic, rendering efficiency, Web packaging, and testing infrastructure, provided every change respects the canonical GDD and artwork approval contracts.

You may prepare new visual compositions or isolated art **as explicitly labeled candidates** where existing approved material is insufficient. New identity-bearing artwork and replacements must receive explicit creator approval before production promotion. Do not let such candidate artwork silently enter a normal Web export.

All code, technical documentation, comments, commit messages, test descriptions, reports, and PR descriptions must be written **in English**.

---

# 1. SOURCE OF TRUTH AND PROJECT CONTEXT

## 1.1 Read the current sources before implementing

Read the actual latest contents of:

- `docs/GDD.md`
- `docs/GDD_DECISION_REGISTER.md`
- `docs/GDD_V3_RECONCILIATION.md`
- `docs/GDD_SOURCE.md`
- `AGENTS.md`
- `README.md`
- `docs/art/CREATOR_CLEAN_CUT_V2_APPROVAL_2026-10-24.md`
- `docs/art/CREATOR_ICON_APPROVAL_2026-10-24.md`
- `docs/art/CLEAN_CUT_NATIVE_REVIEW.md`
- `docs/art/CLEAN_CUT_V2_INTEGRATION.md`
- `docs/QA_BACKLOG.md`
- `docs/WEB_ALPHA_ACCEPTANCE.md`
- `docs/WEB_ALPHA_SURVIVAL_EVIDENCE.md`
- `docs/V5_ACCEPTANCE_STATUS.md`, for historical comparison only
- `assets/approved-assets.json`
- `assets/runtime-icons/manifest.json`
- `assets/runtime-clean-cut/v2/manifest.json`

Inspect the relevant tests, production scripts, scene files, approved art resources, and other current repository documents as needed.

Also inspect:

**Existing recovery PR #73:**  
https://github.com/pedro-ai-coder/aura-farmer-godot/pull/73

**Recovery branch:**  
`recovery/full-visual-gameplay`

**Important recovery documents on that branch:**

- `docs/recovery/CREATOR_RECOVERY_DIRECTIVE_2026-10-24.md`
- `docs/recovery/RECOVERY_STATUS.md`
- `docs/recovery/source-inventory.json`
- `docs/recovery/evidence/`

**GDD V3.0 integration PR #75:**  
https://github.com/pedro-ai-coder/aura-farmer-godot/pull/75

The GDD V3.0 is already merged into `main` and is the authoritative specification. Some document headings may still contain historical wording such as “draft”; use verified Git history and the latest owner-approved decisions to determine the actual authority of the current document.

## 1.2 Current starting-point facts

At the latest verified inspection:

- PR #75 was merged.
- The canonical `main` GDD is V3.0.
- PR #73 remained **open, draft, and unmerged**.
- PR #73 contained a focused functional correction for reopening deferred legendary selection.
- The PR #73 branch had not completed the overall requested recovery.
- PR #73's local headless validation reported **46 Godot phases, 11 Python tests, and Node adapter checks passing**.
- Those results did **not** establish final visual acceptance, browser gameplay quality, actual Web FPS, or an uninterrupted gameplay run.
- The recovery environment had previously been unable to launch graphical Godot because usable X11/Wayland support was missing.
- The approved Clean Cut V2 integration and 37 approved icon PNGs were already present in the merged project.
- `docs/QA_BACKLOG.md` and issue #52 still contained unresolved gameplay, visual, and normal-health survival concerns.

These are starting-point observations, **not permanent assumptions**.

Re-check all branch heads, merges, commits, issues, assets, and tests before taking action.

## 1.3 Decision precedence

Use the following authority hierarchy:

1. Latest explicit creator decisions.
2. Canonical GDD V3.0 for current gameplay and milestone scope.
3. Exact approved artwork and creator approval ledgers for visual source identities.
4. Current Clean Cut art direction and applicable approved compositions.
5. Existing Godot implementation, only when consistent with the above.
6. Historical Phaser behavior only when the GDD explicitly requires parity or leaves an existing behavior unspecified.
7. Historical plans, V5 screenshots, old Work prompts, and implementation notes as supporting evidence only.

No source below the GDD may silently redefine gameplay.

If an actual contradiction remains, record the precise clauses and request the minimum necessary creator decision. Continue all independent authorized work instead of inventing a new rule.

---

# 2. MILESTONE 0 PRODUCT CONTRACT

## 2.1 What M0 actually is

Milestone 0 is:

**A fully visually polished Web version of Aura Farmer, without a backend, playable by a very restricted closed testing group.**

M0 must deliver:

- A cohesive final-quality Clean Cut visual experience.
- The current approved solo gameplay.
- Functional Web input and UI on supported desktop and mobile browsers.
- Correct normal gameplay progression and recovery mechanics.
- Responsive combat and reliable enemy movement.
- Readable animations, projectiles, pickups, danger zones, and boss telegraphs.
- Correct local persistence and normal run completion.
- A verified playable Web build.
- Evidence sufficient for creator review before closed-test distribution.

M0 is **not** a public alpha.

M0 does **not** require backend infrastructure, Discord Activity, online accounts, cloud persistence, in-game feedback submission, competitive modes, or native applications.

## 2.2 Approved playable content

The M0/M1 playable character roster contains exactly:

- Sigma — `sigma`
- Cool Kid — `cool-kid`
- Alpha Chad — `alpha`

The current approved game includes:

- Nine canonical weapons.
- Twenty-three offered passive items from the 28-passive design catalogue.
- A maximum of three weapon slots.
- A maximum of five passive slots.
- Common, Rare, Epic, and Legendary progression under the GDD's exact item-level caps.
- Individual Aura-driven Flex abilities.
- Five waves of 120 active-gameplay seconds each.
- Event bosses at their approved schedule.
- A single legendary selection opportunity.
- Big Hater at 10:00.
- Recoverable Berserk beginning after 120 seconds of boss combat.
- Ruin Alley as the active map.
- Street Snack, Aura Magnet, and Safe Spot.
- Legitimate victory, defeat, replay, pause, menu, and local-save flows.

Preserve all exact GDD rules.

The signature Flexes are:

- Sigma — **Deadpan Verdict**
- Cool Kid — **CTRL + CHAOS**
- Alpha Chad — **Giga Chad Rampage**

Do not reactivate historical starter Flex implementations.

## 2.3 Release-readiness distinction

**Passing PR tests** makes a scoped change eligible for owner approval.

**M0 product acceptance** also requires a completely polished visual experience and credible real-play evidence.

Never confuse these two gates.

---

# 3. EXECUTION STRATEGY AND BRANCH MANAGEMENT

## 3.1 Begin with a current repository audit

Before modifying code:

1. Confirm the current `main` HEAD SHA.
2. Confirm the merged state of PR #75.
3. Confirm the exact head, diff, draft status, and CI history of PR #73.
4. Enumerate other currently open PRs and related branches.
5. Inspect relevant GDD, artwork, gameplay, and UI changes merged after PR #73 branched.
6. Determine whether PR #73 can be safely rebased onto current `main` or whether its focused correction should be ported into a fresh, scoped recovery branch.
7. Check all relevant conflicts and regressions.

**Do not build the recovery on a stale pre-V3 GDD interpretation.**

Preserve the existing recovery evidence and commit provenance.

## 3.2 Handle PR #73 correctly

PR #73 is a **partial checkpoint**, not the final recovery.

Its confirmed correction addresses a deferred legendary selection control that had become inaccessible beneath the hidden legacy presentation.

Preserve its validated behavior:

- The player can reopen the same six deferred legendary offers.
- No reroll is performed.
- The re-entry action is visible and interactive.
- The action obeys normal input ownership and screen boundaries.
- The action expires at 9:55.
- It disappears once the legendary right is consumed.
- It does not interfere with Flex or the normal choice flow.

Choose a safe integration strategy:

**Option A:** Rebase/continue the existing recovery branch if it can be updated cleanly and maintained as a focused, reviewable implementation.

**Option B:** Reimplement or cherry-pick the isolated validated fix onto current `main`, using an explicit replacement recovery branch when continuing PR #73 would introduce avoidable conflicts or stale unrelated changes.

Document the decision and preserve the original test evidence.

Do not merge PR #73 simply because its isolated regression passes.

Do not create competing PRs that implement the same fix without identifying the supersession relationship.

## 3.3 Use scoped and reviewable PRs

Prefer logical PR boundaries:

- **M0.0-A — Recovery baseline and focused functional regressions**
- **M0.0-B — Enemy navigation, gameplay responsiveness, and performance**
- **M0.0-C — Clean Cut secondary UI and full screen-flow completion**
- **M0.0-D — Gameplay HUD, card presentation, animations, and visual feedback**
- **M0.0-E — Web/mobile interaction and responsive quality**
- **M0.0-F — Integrated full-run QA, visual evidence, and acceptance documentation**

These are suggested scopes, not permission to merge or deploy automatically.

Avoid oversized PRs that combine unexplained gameplay changes, significant new artwork, and unrelated Web infrastructure.

Each PR should include:

1. Relevant GDD references.
2. The specific reproduced defects.
3. Root cause.
4. Code and asset modifications.
5. Tests added or modified.
6. Before/after evidence where applicable.
7. Actual validation results.
8. Known limitations.
9. Any pending creator art approval.
10. The exact branch and commit tested.

**Do not merge any PR without explicit creator approval.**

---

# 4. GATE 0 — BASELINE RECONSTRUCTION AND DISCREPANCY AUDIT

This phase is mandatory.

Do not immediately start recoloring panels or changing animation timings.

## 4.1 Establish the reproducible baseline

Record:

- Current Git SHA.
- Current Godot version and renderer.
- Current asset manifests and hashes.
- Relevant current Godot scene hierarchy.
- Entry scene and gameplay controller.
- Current Clean Cut skin implementation.
- Input/joystick architecture.
- Enemy navigation and collision systems.
- Existing rendering and simulation profiling infrastructure.
- Current Web export/build configuration.
- Last known creator-preferred playable version, if retrievable.

If a historical comparison cannot be reproduced, document that limitation explicitly.

Do not fabricate a last-known-good revision.

## 4.2 Inspect the real player journey

Audit every reachable screen and gameplay state:

1. Main Menu.
2. Hero Selection.
3. Sigma / Cool Kid / Alpha presentation.
4. Starting a game.
5. Ordinary movement and automatic combat.
6. Gameplay HUD and inventory.
7. Three-card upgrade selection.
8. Card focus, selection, and confirmation.
9. Legal weapon/passive replacement.
10. Six-card legendary selection.
11. Legendary defer/reopen/expiration.
12. Pause.
13. Build inspection.
14. Settings.
15. Profile/local-save controls.
16. Exit confirmation.
17. Enemy encounters and event bosses.
18. Flex activation, active effects, and recovery.
19. Boss encounter and Berserk.
20. Victory.
21. Defeat.
22. Retry and return to menu.
23. Mobile joystick and touch interaction.
24. Responsive layout/orientation changes.

Do not assume that five approved headline compositions mean all secondary screens are visually finished.

## 4.3 Create an actionable defect matrix

For every defect include:

| Field | Required content |
| --- | --- |
| ID | Unique stable issue ID |
| Severity | P0 / P1 / P2 |
| Area | Gameplay, UI, Art, Input, Performance, Web, QA |
| Reproduction | Steps and environment |
| Expected | Exact GDD/art reference |
| Observed | Real result with evidence |
| Root cause | Verified code-level cause or labeled hypothesis |
| Scope | Files/systems requiring changes |
| Correction | Specific implementation approach |
| Test | Automated and/or rendered verification |
| Evidence | Screenshot, video, metric, trace |
| Status | Open / Implemented / Verified / Blocked |
| Owner approval | Required or already approved |

Use explicit categories:

**P0:** Blocks actual gameplay, loses input, breaks progression, prevents accurate simulation, corrupts saves, creates unavoidable enemy stalls, or prevents acquisition of trustworthy rendered evidence.

**P1:** Significant gameplay feel problems, unpolished reachable screens, unreadable choices, input conflicts, major animation deficiencies, performance regressions, or visibly inconsistent Clean Cut implementation.

**P2:** Minor alignment, polish, nonblocking visual refinements, or additional diagnostic improvements.

Do not downgrade a known P0 issue merely because an isolated unit test passes.

## 4.4 Rendered evidence is mandatory

Try to run the actual Godot game in a real graphical environment and test the exported Web game in a browser with working WebGL2.

The previous recovery environment lacked usable X11/Wayland support.

Do not repeat the same unsuccessful package-installation loop indefinitely.

Instead:

1. Detect and report available graphical, browser, and build capabilities.
2. Use a compatible graphical runner, browser automation environment, or provided interactive Work environment when legitimately available.
3. Produce actual runtime screenshots and gameplay recordings.
4. If graphical execution remains unavailable, perform the code and headless work possible, record the blocker, and **leave rendered acceptance explicitly incomplete**.

Never substitute generated mockups for executed game captures.

**Gate 0 exit:** current baseline recorded, source authority verified, PR #73 integration strategy determined, reproducible defects ranked, and actual rendering availability established or honestly blocked.

---

# 5. GATE 1 — GAMEPLAY RESPONSIVENESS AND TECHNICAL FLUIDITY

The creator identified poor gameplay fluidity as a major defect.

Treat fluidity as both a technical and experiential problem.

## 5.1 Separate technical performance from perceived quality

Investigate:

**Technical performance**

- FPS and frame-time stability.
- CPU simulation time.
- Enemy update cost.
- Projectile update and collision cost.
- UI refresh/layout cost.
- Texture/resource loading.
- Draw calls and overdraw.
- Allocations and garbage pressure.
- Slow frames during wave transitions.
- UI modal opening/closing latency.
- Spawn bursts, projectile density, and special effects.

**Perceived fluidity**

- Character movement responsiveness.
- Animation synchronization.
- Movement acceleration/visual sliding.
- Enemy pursuit and state transitions.
- Hit feedback.
- Projectile and impact readability.
- Flex startup, execution, and recovery.
- Camera follow and clamping.
- Pause and upgrade transition quality.

A constant FPS value alone does not prove good combat feel.

## 5.2 Instrument real full-game performance

Measure at least:

- Average FPS.
- Median frame time.
- P95 frame time.
- P99 frame time.
- Worst meaningful frame-time spikes.
- Simulation time where measurable.
- Rendering/UI time where measurable.
- Enemy and active projectile populations.
- Memory/resource behavior if available.
- Game scene and viewport used.
- Renderer/device/browser.
- Build SHA.

Measure representative segments:

1. Main menu and hero selection.
2. Opening minute.
3. Normal-density combat.
4. High-density wave combat.
5. A normal upgrade modal.
6. A legendary modal.
7. A crowded event-boss encounter.
8. Big Hater and Berserk.
9. Mobile-sized Web layout.

If possible, use a deterministic representative scenario to compare before/after.

Compare identical seeds, content and viewports.

### Performance reference targets

Historical references include:

- 60 FPS desktop.
- 30 FPS mobile.
- A synthetic 300-enemy / 150-projectile stress fixture.

Under GDD V3.0, these are **diagnostic reference objectives**, not automatic numeric M0 PR rejection thresholds.

Still report them honestly where measured.

Do not confuse the 300-enemy synthetic stress fixture with the canonical 100-normal-enemy simultaneous solo-wave cap.

Do not change gameplay spawning or combat values merely to improve a benchmark.

## 5.3 Inspect the Clean Cut refresh architecture

Specifically inspect:

`scripts/clean_cut_skin.gd`

The latest merged implementation includes a per-frame path equivalent to:

`_process(delta) → refresh()`

The previous recovery audit identified repeated full UI refresh and dynamic style allocation, including creation of `StyleBoxEmpty` and `StyleBoxFlat` resources during refresh.

This is a **concrete performance hypothesis**, not already validated as the dominant bottleneck.

Profile and inspect it.

Where justified:

- Cache immutable style resources.
- Cache approved textures and layouts.
- Separate visual state changes from static layout construction.
- Update HUD content only as often as the represented state requires.
- Use signal/state invalidation for discrete transitions.
- Avoid recreating texture/style nodes every frame.
- Avoid redundant string formatting and Control hierarchy work.
- Preserve existing live interactions and focus states.

Do not apply an indiscriminate UI rewrite that creates new input regressions.

## 5.4 Keep the gameplay simulation authoritative

All improvements must preserve:

- Existing world-unit movement speed.
- Enemy behavior and attack windows.
- Weapon attack cadence.
- Aura gain rules.
- Damage and mitigation formulas.
- Hit attribution.
- Deterministic RNG.
- XP and drop contracts.
- Pause semantics.
- Boss timing.
- Save behavior.

A visual-only transition must not:

- Delay a legitimate attack.
- Move an enemy hitbox.
- Grant invulnerability.
- Stop simulation unintentionally.
- Change player DPS.
- Alter the length of a wave.
- Trigger duplicated hit events.

## 5.5 Acceptance checks

This gate requires:

- A before/after full-game performance profile.
- No unexplained severe frame-time regressions.
- Demonstrably improved responsiveness where a performance defect was found.
- Functional movement and attacks throughout the run.
- No invalid shortcut changes to approved balance.
- Relevant deterministic tests still passing.

**Gate 1 exit:** quantified performance changes and reproducible evidence of correct, responsive gameplay.

---

# 6. GATE 2 — ENEMY NAVIGATION, MOVEMENT, AND COMBAT CORRECTNESS

The creator reported that enemies sometimes remain motionless.

This must be investigated and resolved without destroying legitimate enemy attack behavior.

## 6.1 Locate the relevant implementation

Inspect the current equivalents of:

- `scripts/solo_run.gd`
- `scripts/enemy_navigation.gd`
- `scripts/solo_enemy_rules.gd`
- `scripts/solo_world_rules.gd`

Verify the current actual functions and calling hierarchy before changing them.

Review the merged navigation fixes already in `main`.

Do not assume an earlier bug remains after a later PR without reproducing it.

## 6.2 Distinguish legitimate stops from navigation bugs

Normal stops may be valid when an enemy:

- Maintains its preferred attack distance.
- Charges or telegraphs a shot.
- Locks aim before firing.
- Performs a scripted dash/charge.
- Is staggered or in recovery.
- Is committing to a boss attack.

Unintended stops include:

- Repeatedly trying to walk through an obstacle.
- Failing to choose an alternate path around static cover.
- Oscillating indefinitely between two blocked directions.
- Remaining stationary while in an active pursuit state with a reachable player.
- Getting stuck in concave map geometry.
- Continuing to target an obsolete position.
- Never recovering from an obstacle-avoidance state.

## 6.3 Reproduce navigation failures deterministically

Test at least:

1. NPC approaching the first static cover from each side.
2. NPC approaching the second cover from each side.
3. Reply Goblin fast pursuit around covers.
4. Beta Bot heavy movement and frontal-facing limitations.
5. Mirrored approaches.
6. Concave floor boundaries.
7. Player moving around cover corners.
8. Dense multi-enemy pursuit.
9. Ranged Hater stopping at legal distance.
10. Ping Sniper maintaining its prescribed spacing.
11. Ratio Ram committed straight-line charge.
12. Enemy recovery after knockback/stagger.
13. Enemy behavior while player moves near the map edge.
14. Restart and wave transition after an enemy was blocked.

For each failure, capture:

- Enemy ID.
- Enemy position.
- Player position.
- Intended movement vector.
- Actual displacement.
- Movement state.
- Current attack/telegraph state.
- Collision result.
- Obstacle identity.
- Active simulation time.

## 6.4 Correct navigation without changing tuning

Acceptable techniques include:

- Better collision-aware direction selection.
- Persistent obstacle-side navigation decisions.
- Deterministic alternative-side recovery.
- Clear re-evaluation when stuck.
- Legal path steering around static covers.
- Reduced oscillation through stable state.
- Correct movement-state transitions.
- Proper separation between movement intent and attack lock.

Do not:

- Increase enemy speed.
- Reduce enemy damage.
- Remove obstacles.
- Allow clipping through walls.
- Disable collision.
- Teleport stuck enemies without an explicit approved mechanism.
- Simplify enemy attacks.
- Change preferred attack distances.
- Randomize navigation without preserving deterministic behavior.

## 6.5 Movement and combat verification

Confirm:

- Melee chasers can reach reachable targets.
- Ranged enemies keep their approved distance and still fire.
- Charge enemies lock direction correctly.
- Enemy attacks preserve windup, impact, and recovery.
- Contact damage cooldowns are unchanged.
- Boss attacks preserve their telegraph and hit semantics.
- Navigation does not prevent lawful defeat or survival outcomes.

**Gate 2 exit:** no reproduced unexplained persistent enemy stalls, with deterministic regression tests and actual-play evidence.

---

# 7. GATE 3 — CLEAN CUT UI: COMPLETE PLAYER JOURNEY

The current Clean Cut integration covers five primary screen families, but previous recovery inspection confirmed a legacy fallback for some secondary screens.

M0 requires a coherent entire game.

## 7.1 Preserve the approved five-screen source package

The following art package is already explicitly approved:

**Character Hype Broadcast — Clean Cut V2 corrected compositions**

1. Main Menu.
2. Hero Selection.
3. Gameplay HUD.
4. Three-card Upgrade Selection.
5. Six-card Legendary Selection.

Approval source:

`docs/art/CREATOR_CLEAN_CUT_V2_APPROVAL_2026-10-24.md`

Runtime source manifest:

`assets/runtime-clean-cut/v2/manifest.json`

The selected set contains **84 approved runtime resources**:

- 76 isolated production-component PNGs.
- Eight supporting visual resources.

Use the exact recorded source hashes.

The approved corrected package includes the circular mobile joystick and the three hero-specific Flex button families.

Three old equipment-strip illustration composites contain baked example data; these are **not** valid dynamic UI components.

## 7.2 Audit and correct the entire UI architecture

Inspect how:

- `scripts/clean_cut_skin.gd`
- `scripts/arcade_presentation.gd`
- relevant scenes
- runtime asset bindings
- buttons and focus/hover/selected states

currently interact.

Identify which screens use the actual production Clean Cut skin and which revert to historical generic UI.

Eliminate inconsistent presentation.

Do not simply draw a Clean Cut image above an older clickable screen.

All final UI must use live Godot Controls and real authoritative game state.

## 7.3 Main Menu

Confirm:

- Correct approved composition.
- Proper logo/wordmark.
- Correct character cutout.
- Functional Play/Hero Selection navigation.
- Functional Settings.
- Clear buttons and interaction states.
- Keyboard and pointer navigation.
- Responsive safe margins.
- No hidden clickable controls beneath artwork.
- No overlapping or clipped titles.
- No generic style fallback.
- No stale placeholder content.

A successful screenshot of the menu does not prove that its buttons work.

Test actual click, focus, keyboard confirmation, and return navigation.

## 7.4 Hero Selection

Ensure:

- Exactly three playable heroes.
- Correct original identity for each.
- Approved corresponding artwork.
- Correct starter weapon artwork.
- Accurate current Flex name and description.
- Visually distinct selected/unselected/focused states.
- The selected hero is unambiguous.
- Play/Start works correctly.
- Responsive cards remain usable at mobile-Web sizes.

Do not present future heroes as playable.

## 7.5 Gameplay HUD

The HUD must prioritize gameplay information over decoration.

Correct and polish:

- Hero HP.
- XP and current run level.
- Aura and Flex.
- Wave number.
- Current timer.
- Boss health.
- Three weapon slots.
- Five passive slots.
- Real item icons.
- Current rarity and level.
- Active/recovery state feedback.
- Pause.
- Relevant pickups and status effects.

Investigate previously documented defects:

- XP text intersecting its progress bar.
- Overly large empty-slot labels.
- Safe Spot markers dominating the scene.
- Decorative panels occupying too much of the viewport.
- Weak differentiation between informational and interactive UI.
- Repeated duplicate labels.
- Incorrect stacking/priority over danger telegraphs.

Confirm with current rendered evidence.

Do not change gameplay values to make HUD space easier to manage.

## 7.6 Three-card upgrade selection

This is a priority visual feature.

Requirements:

- Three legal cards.
- Exact approved icon for each current item.
- Strong visual separation between cards.
- Clearly differentiated rarity.
- Item name.
- Item category.
- Current level/rarity.
- Effect description.
- Real current-versus-new effect values where applicable.
- Selected/focused state.
- Disabled/illegal state.
- Explicit confirmation.
- Correct replacement journey when slots are full.
- No duplicated or stale labels.
- Reliable keyboard, mouse, and touch behavior.

Check the known compact-layout regression where the third card could wrap onto a second row at 915×412.

Use a verified responsive layout rather than an absolute rule that causes text to become unreadable on small screens.

## 7.7 Six-card legendary selection

This is a premium moment of the run and must not look like an ordinary upgrade modal with twice as many cards.

Maintain:

- Exactly six legal offers: three legendary weapons and three distinct legendary passive buffs.
- Strong legendary visual treatment.
- Unique emphasis and recognizable gold/rarity identity.
- Accurate item/ability effects.
- Accessible navigation to every card.
- Explicit legal confirmation.
- Optional Defer.
- Reopen from the existing stored offer.
- No reroll.
- Same offer again at 8:00.
- Expiration at 9:55.
- No second legendary selection.
- Correct selected, hovered, pressed, disabled, and spent states.

Ensure the sixth card is reachable in compact/mobile layouts.

Do not use a static screenshot to simulate this interface.

## 7.8 Secondary and terminal screens

Bring the following to the same level of visual quality:

- Pause.
- Build inspection.
- Settings.
- Profile/local save.
- Export/import save interaction.
- Exit confirmation.
- Run victory.
- Run defeat.
- Retry.
- Return to menu.
- Error/empty states.
- Appropriate confirmation dialogs.

These screens must use the coherent Clean Cut design system, correct art and icon bindings, responsive layout and live interaction.

No generic navy rounded rectangle or unstyled system button should remain where a production component is required.

Preserve all existing functionality, including cancel, resume, and non-destructive save actions.

## 7.9 UI acceptance

For every screen, deliver:

- Desktop screenshot.
- Compact Web screenshot.
- Actual interaction test.
- Focus/selected/disabled state verification where applicable.
- Source-art comparison.
- Layout/overlap check.
- Status in the visual acceptance matrix.

**Gate 3 exit:** every reachable gameplay UI screen has cohesive, functioning Clean Cut production presentation without a legacy visual fallback.

---

# 8. GATE 4 — ARTWORK, ANIMATION, VFX, AND COMBAT READABILITY

## 8.1 Approved art must be preserved

Do not re-create or replace the currently approved icon batch.

Already approved:

**37 exact weapon/passive PNG assets**

- Nine weapon PNGs, including **Touch Grass Clean Cut v2**.
- Twenty-eight passive PNGs.
- Twenty-three passives are currently offered.
- Five future-only passive illustrations remain disabled in normal gameplay.

The other existing approvals include:

- Nineteen pinned original visual resources.
- Original character identities.
- Original Ruin Alley art.
- Existing approved enemy masters/atlases.
- The 84 approved Clean Cut runtime resources.

Consult the exact manifest and approval ledgers for filenames, versions and hashes.

The old Touch Grass V5 SVG must never be labeled as the matching source for the approved Touch Grass v2 PNG.

The absent matching v2 SVG is a known **nonblocking source-art follow-up**, not permission to replace the approved PNG.

## 8.2 Preserve character identity

**Sigma**

- Dark hood.
- Gold identity details.
- Recognizable thrown-cap starter.
- Precision/marked-target presentation.
- Deadpan Verdict must communicate targeting and its special hit buildup.

**Cool Kid**

- Blue pompom beanie.
- Agile cartoon silhouette.
- Keyboard weapon identity.
- CTRL + CHAOS must show distinguishable attack beats and the ENTER! finisher.

**Alpha Chad**

- Broad shoulders and heavy silhouette.
- Recognizable tank identity.
- Shield and weight.
- Giga Chad Rampage must visually represent shield activation, three slams, and the final shockwave.

Do not reuse historical enlarged Cool Kid Rampage artwork as Alpha's new Flex art.

Do not change hitboxes to fit an animation.

## 8.3 Animation quality

Inspect and improve:

- Idle states.
- Locomotion.
- Direction/facing.
- Attack preparation.
- Attack impact.
- Recovery.
- Hurt.
- Defeat.
- Flex activation and exit.
- Weapon-specific timing.
- Enemy windups and stagger.
- Boss phase transitions.

The GDD includes historical detailed animation-production guidance.

Aim for authored, expressive movement and visible synchronization between simulation and presentation.

Do not fake missing authored movement solely through permanent rotation, shaking, zooming, bobbing, or procedural wobble.

If an approved source asset lacks sufficient animation coverage:

1. Record the precise gap.
2. Reuse approved art only where visually and technically legitimate.
3. Prepare any genuinely new artwork as a separate candidate if authorized by the existing art workflow.
4. Do not describe a candidate as approved.
5. Do not ship a changed identity-bearing resource without creator approval.

## 8.4 Weapon and projectile presentation

Review all nine weapon families:

- Ratio Blaster.
- No Cap.
- Brainrot Feed.
- Keyboard Warrior.
- Ban Hammer.
- Touch Grass.
- Cope Shield.
- Chad Hands.
- Personal Space.

For each:

- Confirm recognizable silhouettes.
- Correct real geometry and direction.
- Telegraph before delayed attacks.
- Clear impact.
- Clear secondary legendary behavior.
- Correct depth ordering.
- Short, legible effects.
- No obscuring the enemy or player.
- No double-hit illusion when there was only one hit.
- No mechanical damage changes.

## 8.5 Enemies and boss readability

Ensure:

- Distinct silhouettes for major enemy families.
- Elite status is unmistakable.
- Ranged enemies show aiming/windup.
- Hazard zones show shape and timing.
- Ratio Ram direction is readable.
- Hater projectiles are visible.
- Big Hater's attack states are legible.
- Berserk looks stronger without hiding hit timing.
- Friendly effects do not cover dangerous ground geometry.

The visually dramatic experience must still support real counterplay.

## 8.6 Upgrade-card artistic finish

Review:

- Rarity frames.
- Card proportions.
- Icon prominence.
- Background hierarchy.
- Typography.
- Selected state.
- Keyboard focus.
- Hover state.
- Confirmation feedback.
- Legendary special presentation.

Use exact approved artwork when available.

New decorative refinements must remain consistent with Clean Cut and may not silently redefine approved identities.

## 8.7 Art acceptance

Create a detailed art matrix:

| Asset/screen | Approved source | Runtime result | Difference | New approval needed? | Status |
| --- | --- | --- | --- | --- | --- |

The creator's final visual review must use screenshots and video from the actual game.

**Gate 4 exit:** complete artwork coverage and honest distinction between already approved art, newly prepared candidate improvements, and actual integrated final-quality experience.

---

# 9. GATE 5 — WEB, MOBILE, JOYSTICK, AND RESPONSIVE INTERACTION

M0 is Web-only, but it must work through the supported browser experience, including mobile browsers.

## 9.1 Canonical joystick requirements

Preserve the approved full-playfield floating circular joystick.

The joystick:

- Appears at the first eligible touch on unobstructed visible gameplay terrain.
- Can activate on the left, center, or right.
- Does not use a fixed left-half activation zone.
- Is circular, not diamond-shaped.
- Uses the approved larger geometry.
- Never appears on top of an interactive UI-origin touch.
- Supports movement while a second finger activates Flex.
- Cleans up correctly when touch is released, paused, cancelled, or focus is lost.

Reference geometry:

- Outer radius approximately **80** reference canvas units.
- Inner thumb radius approximately **35**.
- Saturation travel approximately **119**.

Scale responsively, without changing player movement speed or analog-control rules.

## 9.2 Input priority

Actual UI hit regions must take priority over ground movement.

Test:

- Flex.
- Pause.
- Upgrade cards.
- Legendary cards.
- Confirm and Defer.
- Scroll containers.
- Settings buttons.
- Exit confirmation.
- Profile actions.
- Touch movement.
- Simultaneous touch pointers.

No synthetic mouse duplication or accidental click-through is permitted.

## 9.3 Mobile browser layouts

Test these reference viewports where applicable:

- 1920×1080.
- 1600×900.
- 1280×720.
- 915×412.
- 844×390.
- 390×844.

Use actual effective viewport and safe-area boundaries.

Validate:

- Landscape gameplay.
- Functional portrait fallback where supported.
- Fullscreen request behavior.
- Orientation lock success or graceful refusal.
- Browser resize.
- Scrollable choice modals.
- Readable card effects.
- Visible Confirm/Defer.
- No clipped titles.
- Joystick/button non-overlap.
- Correct input release on orientation and focus changes.

Test in real mobile browsers when available.

An emulated mobile viewport is useful, but do not present it as a physical-device test.

## 9.4 Web export and runtime quality

Verify:

- Godot Web export completes.
- Required approved resources are included.
- Rejected/candidate sources are excluded.
- No unexpected script/resource load errors.
- Actual WebGL2 startup and interaction.
- Real Play, Pause, Resume, Retry, and menu navigation.
- Browser audio activation policies.
- Local profile persistence.
- Save export/import where supported.
- Cache-safe build identification.
- No destructive profile reset.
- No backend request is necessary to play.

Use a private or review-only preview environment; do not open public access without authorization.

**Gate 5 exit:** Web input, responsive layout, joystick, and actual browser gameplay validated without critical interaction defects.

---

# 10. GATE 6 — SOLO FULL-RUN, PROGRESSION, AND BALANCE INTEGRITY

Do not stop after proving that the title screen and the opening wave work.

## 10.1 Validate the entire run

Test the full canonical sequence:

1. Start at run level 1.
2. Initial starter weapon equipped.
3. Wave 1 and first Hater at 1:00.
4. Wave 2 and Reply Guy at 2:15.
5. Wave 3 and Mod Supremo at 4:15.
6. Wave 4, first legendary opportunity at 6:00, Ohio Express at 6:15.
7. Wave 5, deferred legendary revisit at 8:00, Doomscroll Prime at 8:15.
8. Legendary expiration at 9:55.
9. Big Hater warning at 9:30 and arrival at 10:00.
10. Boss mechanics, stagger, HP thresholds, and movement.
11. Recoverable Berserk after 120 active seconds of boss combat.
12. Legitimate victory or defeat.
13. Accurate results.
14. Correct profile-save behavior.
15. Retry and clean restart.

Use the GDD for exact gameplay values.

The run clock must stop during appropriate solo modal pauses.

## 10.2 Validate all three starters

Test:

- Sigma — Ranged.
- Cool Kid — Melee.
- Alpha Chad — Tank.

Include:

- Early game.
- Midgame.
- High-density encounters.
- Typical equipment progression.
- Correct Flex use.
- Recovery opportunities.
- Ranged pressure.
- Boss entry when reached.

A single Sigma full run is **not** proof of successful Cool Kid and Alpha normal-health gameplay.

## 10.3 Issue #52 — normal-health survival

Review:

https://github.com/pedro-ai-coder/aura-farmer-godot/issues/52

Previous evidence included:

- Some Sigma wins.
- Alpha reaching Big Hater in selected observations.
- No demonstrated Cool Kid boss entry in the latest scripted batch.
- Inconsistent normal-health survival outcomes.

The previous scripts are valuable diagnostics, **not human win-rate measurements**.

Investigate:

- Cool Kid's ranged-enemy response.
- Event boss attack pressure.
- Ordinary recovery pickup accessibility.
- Alpha's real tank mitigation and boss response.
- Actual ability use.
- Target/aim behavior.
- Legal equipment choices.
- Source-attributed received damage.
- Possible gameplay implementation bugs.

Do not compensate by changing approved HP, damage, attack frequency, spawn density, drop probability, or boss health.

When a problem is purely balance-related, prepare a **separate balance-change proposal** referencing measured evidence and exact suggested GDD changes.

Do not implement the proposed balance change without approval.

## 10.4 Recovery parity

Verify the existing approved values:

**Street Snack**

- 5% eligible normal-enemy drop probability.
- 20% eligible elite drop probability.
- 56-world-unit pickup radius.
- 18% maximum-HP healing.

**Aura Magnet**

- 2% eligible normal-enemy drop probability.
- 8% eligible elite drop probability.
- 72-world-unit pickup radius.
- Collect all currently available XP crystals exactly once.
- Generate no new XP and no unapproved additional Aura.

**Safe Spot**

- Ruin Alley at `(1100, 565)`.
- 68-world-unit activation radius.
- Two continuous seconds of valid charge.
- 25% maximum-HP healing.
- Ninety seconds of active-gameplay cooldown.
- Charge reset on leaving or invalid conditions.

Do not turn the two existing static obstacles into destructible crates.

## 10.5 Legendary integrity

Confirm:

- Legal rarity distributions.
- Correct maximum item levels.
- Legal slot replacement.
- Correct one-legendary-per-run limit.
- Correct saved offer after deferral.
- No reroll exploit.
- Correct expiration.
- No double legendary acquisition.
- Correct menu pause/input ownership.
- Correct card visual feedback.
- No accidental duplication or recursion of weapon/passive effects.

## 10.6 Required evidence

Produce:

- Real complete-run gameplay recording.
- Event timestamps.
- Hero and equipment used.
- RNG seed where controllable.
- Actual outcome.
- Relevant gameplay logs.
- Visuals of normal and legendary selection.
- Boss and Berserk evidence when reached.
- Detailed record of any remaining legitimate survival/balance concerns.

Never stage fake enemy deaths, force god mode, skip waves, prefill XP, or give hidden equipment in a run represented as normal gameplay.

Controlled fixtures are allowed **only when explicitly labeled as controlled tests**.

**Gate 6 exit:** real full-run evidence plus reliable, legal, reproducible progression tests for the three starters, with unresolved balance questions transparently reported.

---

# 11. GATE 7 — INTEGRATED VISUAL AND GAMEPLAY ACCEPTANCE

The game must be reviewed as one coherent experience.

Individual assets and successful unit tests are not sufficient.

## 11.1 Required actual gameplay video package

Deliver at least four labeled video groups:

**Video A — Main Menu and Hero Selection**

Show:

- Initial load.
- Approved menu.
- Character selection.
- Selection states.
- Settings navigation.
- Start flow.
- Relevant desktop/mobile layout behavior.

**Video B — Early and Midgame**

Show:

- Actual live movement.
- Enemy pursuit.
- Weapon attacks.
- Damage/recovery.
- XP/Aura/HUD.
- Normal upgrade choice.
- Core animation and effects.
- Event bosses.

**Video C — Late Game, Legendary, and Big Hater**

Show:

- Three-card progression.
- Six-card legendary.
- Defer/reopen behavior.
- Dense combat.
- Big Hater.
- Berserk where encountered.
- Terminal result or a clearly documented legitimate unsuccessful run.

**Video D — Mobile Web and Interaction**

Show:

- Circular joystick activation on the left.
- Circular joystick activation in the center.
- Circular joystick activation on the right.
- First pointer movement.
- Independent second-pointer Flex.
- Pause.
- Card selection.
- Scrolling.
- Resize/orientation fallback.
- No touch/input conflicts.

Also provide an **uninterrupted normal full run**, separate from an edited highlights reel.

## 11.2 Screenshot package

Capture real Godot/Web frames of:

- All primary and secondary menus.
- Each starter in Hero Selection.
- Gameplay HUD under typical load.
- Gameplay HUD under heavy load.
- Upgrade card selection.
- Legendary choice and deferred state.
- Pause and build inspection.
- Settings and profile.
- Victory and defeat.
- Mobile/compact layout.
- Real boss attack telegraphs.
- Safe Spot active/cooldown.
- Flex active and recovery states.

Name each file with:

- Screen/state.
- Resolution.
- Relevant character.
- Build/commit.
- Whether it is native Godot, browser WebGL2, or an explicitly controlled fixture.

Do not mislabel staged review harness output as a continuous playable run.

## 11.3 Before/after comparison

For every major correction, show:

- Previous actual behavior or screenshot, if reproducible.
- Revised actual behavior or screenshot.
- The same viewport and comparable game state.
- A brief explanation of why the new result is closer to the approved Clean Cut target.

If the original old build cannot be reproduced, say so.

## 11.4 Creator review

Submit:

1. The playable Web preview.
2. An ordered visual gallery.
3. Four video groups.
4. The uninterrupted full-run recording.
5. The discrepancy matrix.
6. A concise summary of resolved and unresolved issues.
7. Any newly proposed/replaced artwork requiring approval.
8. Performance measurements.
9. All relevant PRs and test results.

Do not mark a screen as **creator-approved final** without a real creator decision.

**Gate 7 exit:** complete evidence package ready for explicit visual and experiential review.

---

# 12. GATE 8 — AUTOMATED QA, RELEASE HYGIENE, AND FINAL REPORT

## 12.1 Required existing validation

Run the repository's official validation entry points where applicable:

- `python3 scripts/sync_approved_assets.py`
- Godot import using the pinned engine.
- `bash scripts/validate.sh`
- `bash scripts/build_web.sh`
- Relevant approved-icon/art verification scripts.
- Existing deterministic progression/combat tests.
- Existing enemy navigation tests.
- Existing mobile layout and input tests.
- Existing card and legendary regressions.
- Existing recovery, boss, and save tests.

Follow the actual current repository commands if they have changed.

Do not replace the official test suite with an undocumented subset.

## 12.2 Required new regression coverage

Add focused automated tests for each corrected functional defect.

Expected coverage includes, where relevant:

- Uninterrupted legitimate movement input.
- Reproducible enemy obstacle navigation.
- Accurate ranged-distance holds.
- Enemy attack windup/recovery preservation.
- Deferred legendary reopen.
- No legendary reroll.
- Correct sixth-card access.
- UI screen transitions.
- No click-through.
- Proper keyboard focus.
- Full-playfield joystick.
- Independent Flex multitouch.
- Touch release/focus loss.
- Gameplay pause and modal clock boundaries.
- Resource/asset manifest integrity.
- Current equipment/rarity legality.
- Restart/reset lifecycle.
- Profile persistence and corruption handling.
- No unexpected duplicate damage/procs/rewards.

Only introduce tests that correspond to actual product requirements or demonstrated defects.

## 12.3 Protect approved assets

Before final PR submission verify:

- All 19 pinned original art resources remain unchanged.
- All 37 approved icon PNG resources maintain their expected exact hashes.
- All 84 approved Clean Cut resources preserve their approved exact identities.
- Source-candidate and review-only directories are absent from the shipping Web PCK.
- No historical rejected diamond joystick is promoted.
- No five future-only passive items have become offerable.
- No new unapproved hero or special ability art has been silently shipped.

If a new candidate asset is produced, separate its approval status from the production runtime resources.

## 12.4 Protect gameplay

Compare modified gameplay code against the GDD V3.0.

Any changes to deterministic rules must be classified as:

- **Bug fix restoring an already approved rule**, or
- **Proposed new gameplay/balance change requiring owner approval**.

Only the first category is authorized to enter implementation as part of this assignment.

Do not disguise a change in numeric balance as “feel improvement.”

## 12.5 Final technical acceptance criteria

The implementation is technically ready for creator review only if:

- Required automated CI checks pass.
- The Web build compiles and launches.
- A real playable Web run is demonstrated.
- Known P0 functional issues are resolved.
- Enemy navigation problems are corrected or explicitly isolated with honest evidence.
- Approved rarity/XP/Aura/Flex/boss/recovery contracts are preserved.
- Normal and legendary selection work correctly.
- Secondary UI screens no longer visibly fall back to incompatible generic styles.
- The mobile Web joystick operates throughout legal playfield terrain.
- Performance is measured and reported rather than guessed.
- Screenshots and videos represent the actual tested revision.
- No unauthorized mechanics, assets, backend, or balance changes are introduced.
- All remaining P1/P2 items are explicitly documented.
- The creator can inspect the final build and compare it to the visual target.

**Milestone acceptance remains a creator decision.**

---

# 13. GRAPHICAL ENVIRONMENT OR TOOLING BLOCKERS

The earlier Work session reported that actual graphical Godot execution was blocked by unavailable X11/Wayland support.

This is a known issue.

You must make a bounded attempt to obtain a functioning graphical validation environment using authorized existing capabilities.

If available, use:

- An actual graphical Godot session.
- An interactive browser/desktop environment.
- A verified WebGL2 browser session.
- An appropriate existing browser test runner.
- Approved repository CI and preview infrastructure.

Do not repeatedly retry installations that already failed due to environment privileges without a concrete reason to expect a different outcome.

Do not change the engine version solely to make visualization easier.

Do not modify gameplay to avoid the blocker.

If graphical testing remains impossible:

1. Continue the code, architecture, deterministic, asset, and headless corrections that can be completed safely.
2. Produce a valid Web export if possible.
3. Record exactly what was executed and what was not.
4. State which acceptance gates remain blocked.
5. Provide the user with a runnable preview and precise external validation steps where feasible.
6. Do not fabricate FPS, screenshots, videos, visual sign-off, or real gameplay observations.
7. Do not declare the assignment fully complete.

Partial technical completion is acceptable only when accurately identified.

---

# 14. MANDATORY DELIVERABLES

Create or update appropriate English-language project documentation to deliver the following.

## 14.1 Recovery source inventory

A document such as:

`docs/recovery/M0_0_SOURCE_INVENTORY.md`

Include:

- Latest main and implementation branch SHAs.
- GDD V3.0 revision.
- Current creator approval references.
- Exact approved art manifests.
- Relevant PRs.
- Reused components.
- Historical conflicts.
- Current authoritative contracts.

## 14.2 Recovery issue matrix

A structured file such as:

`docs/recovery/M0_0_ISSUE_MATRIX.md`

Every issue must have reproduction, cause, correction, validation, and state.

Link existing QA issue IDs where possible instead of inventing duplicates.

## 14.3 Visual acceptance matrix

A file such as:

`docs/recovery/M0_0_VISUAL_ACCEPTANCE.md`

For each screen or asset group:

- Approved reference.
- Actual rendered result.
- Asset source version/hash when applicable.
- Corrective work.
- Tested resolutions.
- Interaction states.
- Creator approval status.
- Remaining gap.

## 14.4 Performance report

A file such as:

`docs/recovery/M0_0_PERFORMANCE.md`

Include:

- Exact source commit.
- Test hardware/environment.
- Renderer/browser.
- Run scenario.
- Enemy/projectile populations.
- Average/median/P95/P99 frame time.
- Before/after observations.
- Bottleneck attribution.
- Limitations.

Use real measurements only.

## 14.5 Gameplay and regression report

A file such as:

`docs/recovery/M0_0_GAMEPLAY_QA.md`

Include:

- Tests executed.
- Test results.
- Full-run outcomes.
- Character coverage.
- Enemy navigation cases.
- Upgrade/legendary cases.
- Recovery and Flex validation.
- Boss and save validation.
- Open gameplay issues.

## 14.6 Evidence manifest

Create a machine-readable manifest, such as:

`docs/recovery/evidence/m0_0/evidence-manifest.json`

For each meaningful artifact record:

- Evidence ID.
- Type.
- Related issue/gate.
- Real or controlled context.
- File path or retrievable URL.
- Game source SHA.
- Platform.
- Resolution.
- RNG seed if applicable.
- Character.
- Run/game state.
- Timestamp.
- Verification status.

Use an efficient evidence format and avoid committing unnecessarily enormous media files when an approved artifact or PR attachment mechanism exists.

## 14.7 Playable Web build

Provide:

- Actual successful Web export.
- Build identifier.
- Source commit SHA.
- Reproducible build command.
- Relevant checksum/manifest evidence.
- A functioning authorized review link when available.
- Clear distinction between private preview and public production.

Do not automatically publicize or enlarge access.

## 14.8 Pull requests

Deliver focused PRs containing:

- Real code changes.
- Tests.
- Documentation.
- Evidence.
- Validation details.
- A clear pending-approval state.

Never merge them automatically.

## 14.9 Final creator-facing report

Conclude with a compact management summary and detailed supporting links.

Include:

**A. Executive status**

- M0.0 completion state.
- Main accomplishments.
- Remaining blockers.
- Requested approvals.

**B. PR inventory**

For each PR:

- Number and URL.
- Scope.
- Branch/head commit.
- CI state.
- Testing outcome.
- Merge status.

**C. Issue outcomes**

- P0 fixed / remaining.
- P1 fixed / remaining.
- P2 deferred / remaining.

**D. Visual outcomes**

- Which screens are actually polished.
- Which exact artworks are approved.
- Which new artwork candidates require creator approval.
- Which visual gaps remain.

**E. Gameplay and performance outcomes**

- Real run evidence.
- Character coverage.
- Navigation results.
- Actual performance numbers.
- Measured regressions or improvements.

**F. Release recommendation**

One explicit conclusion:

- **READY FOR CREATOR M0 VISUAL ACCEPTANCE REVIEW**, or
- **NOT READY — SPECIFIC BLOCKERS REMAIN**.

Do not claim M0 itself is released.

---

# 15. REQUIRED WORK ORDER

Execute in this order.

| Order | Work package | Exit requirement |
| --- | --- | --- |
| **0** | Latest-source and PR #73 audit | Canonical baseline and defects understood |
| **1** | Recovery-branch integration and critical regressions | Correct current V3-based implementation baseline |
| **2** | Performance/fluency investigation | Bottlenecks identified and measured |
| **3** | Enemy navigation and gameplay correctness | Reproduced movement defects fixed and tested |
| **4** | Full Clean Cut UI architecture and secondary screens | No inconsistent legacy visual fallback |
| **5** | HUD, cards, animations and combat effects | Coherent polished gameplay presentation |
| **6** | Web/mobile joystick and interaction QA | Correct control behavior on supported layouts |
| **7** | Real complete-run and three-hero QA | Uninterrupted play evidence and tracked balance risks |
| **8** | Final Web build, media, PRs and acceptance package | Creator-reviewable delivery with required green checks |

Independent tasks may run in parallel when doing so does not compromise shared source versions, approved asset hashes, test reproducibility, or reviewable PR boundaries.

For example, an art inventory/secondary-screen design review may progress while navigation diagnostics are being implemented.

However, final acceptance must be based on one coherent integrated build, not an assortment of unrelated successful demonstrations.

---

# 16. FINAL INSTRUCTIONS TO THE WORK AGENT

You must perform the implementation work, not merely produce a proposed plan.

Begin by auditing the **current** repository and verifying how the previously incomplete PR #73 relates to the merged GDD V3.0.

Use the recovery artifacts where useful, but do not inherit obsolete assumptions or mark unverified gates as passed.

Prioritize:

1. True gameplay fluidity and correctness.
2. Reliable enemy navigation.
3. Complete Clean Cut visual coherence.
4. Visually finished weapon/passive/legendary selection.
5. Correct mobile Web interaction.
6. Uninterrupted full-run verification.
7. Real rendering and performance evidence.
8. A reviewable, fully documented implementation.

**Do not change Phaser.**

**Do not change approved balance.**

**Do not implement a backend.**

**Do not implement Discord Activity.**

**Do not merge pull requests automatically.**

**Do not declare final visual or Milestone 0 acceptance on the creator's behalf.**

Preserve all existing creator-approved source artwork and gameplay identities.

If additional artwork or balance changes appear necessary, prepare a precise proposal and keep it separate from the approved production implementation until an explicit owner decision is obtained.

Do not substitute visual mockups for actual running Godot/Web output.

Do not substitute technical CI success for gameplay quality or creator approval.

Your final deliverable must make it possible for the creator to run Aura Farmer, inspect the actual integrated visual experience, assess the difference from the rejected version, review the code and tests, and decide whether the game is finally ready for the restricted M0 playtest.

**The project is not finished when individual features work. It is finished for M0.0 review when the approved game functions as one coherent, fluid, visually polished experience and the remaining acceptance decisions are explicit.**