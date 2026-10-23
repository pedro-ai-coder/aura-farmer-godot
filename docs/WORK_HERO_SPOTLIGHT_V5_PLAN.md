# Aura Farmer — Hero Spotlight V5 Godot Production Work Plan

**Status:** Production implementation plan, 23 October 2026.  
**Product, gameplay and visual authority:** [Canonical Godot GDD](GDD.md), especially §§7.2, 16, 23–26, Annex A and Annex C.  
**Detailed V5 visual handoff:** [HERO_SPOTLIGHT_V5.md](art/HERO_SPOTLIGHT_V5.md) and [hero_spotlight_v5_tokens.json](art/hero_spotlight_v5_tokens.json).  
**Illustrated source:** *Aura Farmer — Production Visual Art Bible V5.0* (56-page PDF). Attach the actual PDF to Work. The companion *Visual Production Handoff V5* asset bundle should also be attached if available; its existence in the repository must not be assumed.  
**Godot:** `pedro-ai-coder/aura-farmer-godot` — Godot 4.7.2, GDScript, Compatibility renderer; Web, Android and iOS.  
**Read-only Phaser reference:** `pedro-ai-coder/aura-farmer`; pinned approved provenance in `assets/approved-assets.json`.

## Mission

Implement **Arcade Street Clean — Hero Spotlight** as a genuinely playable, polished game-wide visual system, following the **actual V5 full-screen images and scene contracts**, while retaining every current approved gameplay rule and stable ID. The GDD wins whenever the original V5 PDF contains older game clocks, Flex labels, skill descriptions, icons, counters or unapproved functionality.

This is not an authorization to redraw established hero identities, invent abilities, alter Phaser, automatically ship unapproved standalone art, add costs, or claim live-device validation from screenshots alone. The goal is the **approved visual composition with real Godot UI, gameplay sprites and truthful state**.

### Non-negotiable latest gameplay rules

- Five **120-second** waves; Hater at **1:00**; transitions **2:00 / 4:00 / 6:00 / 8:00**; event bosses **2:15 / 4:15 / 6:15 / 8:15**; legendary windows **6:00 and 8:00**, final expiry **9:55**; warning **9:30**, Big Hater **10:00**, recoverable Berserk after **120 seconds of boss combat** (~12:00); later last-effort cue ~14:00. Preserve the shared clock and test boundaries.
- Starter Flexes in §7.2: **Sigma / Deadpan Verdict**, **Cool Kid / CTRL + CHAOS**, **Alpha Chad / Giga Chad Rampage**. Current GDScript implementation and automated evidence are described in `docs/FLEX_V2_VALIDATION.md`; re-audit rather than duplicate the mechanics. **Never revert to Sigma Stare, Cool Kid Giga Chad Rampage or Alpha Hold**, regardless of V5 picture labels.
- Three equipped weapons and five passives, one legendary per run, normal **three** legal offers, legendary **three compatible weapons + three passive** cards and accurate choose/defer behavior.
- Approved recovery P1–P3: **Street Snack**, **Aura Magnet**, **Safe Spot** under Annex C.2. P4–P7 are only concept-approved isolated prototypes; P8 is unapproved. No experimental content in normal game.
- Preserve Aura generation/resource rules, hitboxes, enemy/world navigation, attack timings, save compatibility, seeded RNG and pause/input semantics.
- **Visual-only PRs must not modify gameplay numbers.** Existing honest-health controller tests have not reached Big Hater with any of the three starters under the ten-minute schedule (see `docs/CLOCK_COMPARISON.md` / `docs/FLEX_V2_VALIDATION.md`). Treat survival tuning as an **open, separately specified balance workstream**, not permission to stealth-buff while polishing UI.

## Baseline and evidence before editing (Phase 0)

1. Read `AGENTS.md`, the entire GDD, V5 handoff, current `main` commit, open PRs, CI, Vercel state and `docs/MIGRATION_PROGRESS.md`. Re-check facts when resuming from a new Work run; do not assume old SHA/current PR state.
2. Inspect the **actual embedded imagery** in PDF pages **6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46 and 48**. These are the 22 scene composition targets, not a textual moodboard. Compare side by side with real Godot captures.
3. Inventory all approved binary assets and distinguish (a) pinned original masters/atlases, (b) 22 V5 **composition references**, (c) candidate 9+28 standalone transparent icons in a **separate handoff archive if supplied**, and (d) missing new logo/Flex/VFX/character art. Verify hashes/licenses/provenance, do not fabricate inventory or claim extracted PDF crops are approved source masters.
4. Record a **22-row visual coverage matrix** (ID, PDF page, current Godot code/scene, screenshot link, gap, asset-ready/blocked, desktop/mobile tested, next PR). Add separate 37-icon availability/approval/32px QA checklist.
5. Run the current validation suite (`bash scripts/validate.sh`) if the environment has the actual Godot 4.7.2 binary and required assets. Record observed pass/fail, not assumed green. Capture baseline screenshots at 1600×900 and 1280×720, plus representative mobile landscape/portrait.
6. Prioritize visibly broken player paths, legibility and game fluidity over decorative VFX. Verify failures before fixes and retain regression cases.

**Phase 0 output:** committed audit/matrix, asset-source report, baseline comparison and prioritized implementation list. Avoid expanding scope.

## Phase 1 — Design system, reusable Godot UI and correct source art (P0)

- Build a shared Godot theme and token layer for approved V5 values: **Inter** typography (properly licensed and imported), navy/deep ink/cream/gold/sky/coral/teal palette, thick ink outlines, comic shadows, selection rings, physical button states, modal/backdrop layers, rarity frames, accessible focus, reduced motion and tabular HUD numerals.
- Implement composable, testable UI primitives using **live** `Control` nodes rather than screenshot textures: `PrimaryButton`, `SecondaryButton`, `HeroCard`, `UpgradeCard`, `LegendaryCard`, `InkPanel`, `StatusPlate`, `ModalShell`, `FocusOutline`, `IconSlot`, `WaveBanner`, `FlexIndicator`.
- Preserve the approved hero portraits and Ruin Alley art as authentic assets. V5 menu layout uses hero-left and controls-right; implement an independent logo and clean background plate **only once genuinely approved standalone exports exist**. Never bake the buttons, selectable text or counters into a PNG or infer font files from a flattened picture.
- Use layout containers/anchors, 8 px spacing rhythm, ~48 px mobile interaction minimum, dynamic safe areas and one-modal/focus-trap rules. Avoid generic AI-template gradients/glass/glow; match V5 specific compositions.
- Verify theme at 1600×900, 1280×720, 1920×1080 and at least one narrow landscape size; capture focus, selected, disabled, hover and touch states.

**Phase 1 exit:** reusable UI design system and recorded real-render screenshots; no gameplay or save regressions; missing isolated art flagged explicitly.

## Phase 2 — Critical complete player journey: V5 scenes 01–05 (P0)

Implement in small, sequential PRs, first **01 Main Menu (p.6)** and **02 Hero Select (p.8)**, then **03 Gameplay/HUD (p.10)**, **04 Three-card Upgrade (p.12)** and **05 Six-card Legendary (p.14)**.

- Main Menu: authentic illustrated Sigma hero-left; strong logo on the correct area; **PLAY / HEROES / SETTINGS** as three functional primary destinations, no decorative non-working quit button on Web; remove doubled menu typography and overlapping controls.
- Hero Select: three identity-preserving hero portraits; correct class, starter, new signature Flex label; one clear START action; no fabricated unlocks.
- Gameplay/HUD: small, readable independent plates for HP/shield, XP/level, wave/timer, Aura/Flex, actual 3+5 build; do not cover enemy telegraphs or heavily crop actors. Show correct 10-minute schedule.
- Normal Upgrade: three **legal** cards, correct category/rarity, icon/current→new comparison and explicit confirmation; freeze simulation while modal active.
- Legendary: exactly **six** legal choices (3 weapons + 3 passives), defer/legal expiry, one per run, current GDD names and slots; cannot silently enable reroll or show invented rewards.
- Render matching V5 composition checks and exercise actual keyboard/mouse/touch actions. No static mocked selections or screenshots where live data is required.

**Phase 2 exit:** player can navigate through a new run, receive and interact with real legal upgrade screens, and see a cohesive professional Hero Spotlight shell.

## Phase 3 — Combat, recovery, weapons, boss and Flex visual identity (P0)

Cover V5 **10, 13–20, 22** as independent, sim-bound art workstreams:

- **Signature Flex presentation (13–14, pp.30,32):** real *Deadpan Verdict* target mark, three-hit payoff; six *CTRL + CHAOS* keyboard beats and ENTER; *Giga Chad Rampage* protected stance, three slams and countershock. Visual events must derive from actual §7.2 mechanics. Historical Cool Kid oversized Rampage sprites **must not** become Alpha art.
- **Enemy & boss readability (10,17,20, pp.24,38,44):** retain approved sprites/atlas IDs, world pivots and hitboxes. Distinguish 17 existing enemy/boss variants; show actual telegraphs, hit/defeat and event windows. Show boss health, 10:00 entry and 120-second Berserk countdown; large cinematic banners must be temporary and never mask an imminent warning.
- **Weapon and passive iconography (15–16, pp.34,36):** integrate isolated **approved** art only after verified source import, stable ID map, alpha and 32/64 px comparison; prioritize nine current weapons + 23 offered solo passives, preserve readiness for all 28 passive catalog IDs. If exports are missing or individually unsigned, record a blocking art ticket instead of shipping a PDF crop or arbitrary icon.
- **Pickups and Safe Spot (18,22, pp.40,48):** cyan XP crystal; shape-distinct Snack/Magnet; teal/green Safe Spot, real two-second charge and 90 s cooldown; exact existing gameplay rules. Separate art layers never produce damage/XP.
- **Wave transition (19, p.42):** dynamic named banner at actual 2/4/6/8-minute boundaries; no gameplay pause or fake loading screen.
- Improve hit/impact readability, enemy foot pivots, animation states and moment-to-moment movement feel only with faithful simulation-bound VFX. Confirm no navigation or performance regression.

**Phase 3 exit:** gameplay recording with authentic visuals, all three new Flexes, XP/drop/healing, event telegraphs and actual boss UI; deterministic VFX timing tests.

## Phase 4 — Secondary screens and continuity (P1)

Cover **06 Pause (p.16), 07 Settings (p.18), 08/09 Results (pp.20,22), 12 Build Inspection (p.28), 21 Quit Confirmation (p.46)**.

- All screens share the V5 theme; no generic Godot button islands or accidental blank/double-layered modal interfaces.
- Pause freezes simulation and combat animation; Settings live sliders/toggles are persisted, including audio and reduced motion; robust Back/Apply path.
- Build inspection shows 3 weapons/5 passives, actual names/icons/rarity/levels and empties. Do not add slots.
- Victory/Defeat displays truthful final run time, equipped items, kills, player and profile state; replay resets only run-scoped state.
- Quit confirmation preserves pause and focus, does not count an abandoned run as a victory.
- Check legibility/scrolling on compact viewports.

**Phase 4 exit:** every normal run/pause/result/exit flow works and visually matches its V5 reference.

## Phase 5 — Responsive mobile and platform parity (P1)

Cover **11 Mobile Landscape (p.26)** and mobile variants of all 22 other scenes.

- Floating-left touch joystick at the thumb's start point; right fixed Flex control, separate pointers, cancellation/focus-loss/pause resets.
- Responsive UI safe areas, Android/iOS notch/cutout, landscape and usable portrait fallback, orientation/fullscreen permission rejection, on-screen keyboard/screen resize.
- Preserve keyboard/mouse paths and never add a second button to activate a Flex.
- Touch targets ~48 px minimum; scroll large upgrade/legendary panels without losing Confirm/Defer, and preserve selected cards through resize.
- Reduced motion must keep enemy attacks readable and status clear.
- Independently test actual web/mobile browser and native Android/iOS where tools/devices are available. If hardware is absent, label it **not verified**; do not assert pass.

**Phase 5 exit:** accessible, state-correct desktop and mobile interface; distinct unverified native-device requirements recorded.

## Phase 6 — Cohesive QA, fluidity, survival viability and performance

1. Produce the complete **22-scene** and **37-icon** V5 comparison matrix; each row has V5 page, real game screenshot, code/commit, pass/partial/blocked decision and remaining differences.
2. Capture production-scope video at 1600×900, 1280×720 and real representative touch layouts: main menu, selection, early/dense combat, upgrade, legendary, three Flexes, Snack/Magnet/Safe Spot, boss/Berserk, victory and defeat.
3. Re-run `bash scripts/validate.sh`, seeded combat/drop/save/clock/Flex/recovery regressions and official Godot Web export. Inspect real runtime logs and actual browser rendering, not only compilation.
4. Carry out **normal-health, non-protected full runs** for all three starter heroes, multiple seeds and varied builds. Track survival, boss entry, boss win, wave-by-wave deaths, level/build at 10:00, XP availability, recovery, meaningful offers, damage prevented, Flex use and boss viability. Earlier reproducible samples in `docs/CLOCK_COMPARISON.md` / `docs/FLEX_V2_VALIDATION.md` **did not reach Big Hater**.
5. Diagnose progression/survival failure and propose measured tuning changes as a separate GDD decision where numeric changes are required. Do not silently buff heroes or alter XP to declare the art milestone done.
6. Measure rendered desktop FPS (60-reference), representative mobile FPS (30-reference) and the approved 300-enemy/150-projectile stress objectives; report test hardware and methodology. Low-end tuning may reduce decorative particles, **not** hitboxes or hostile telegraphs.
7. Verify web publish revision with versioned build metadata. Vercel READY confirms artifact build, not pixel parity. Verify production origin with a real browser when supported; local fixture/software rendering is supplementary evidence.
8. Use owner visual review for final sign-off, especially individual newly created icon/animation masters. Keep owner approval and device-test gates distinct from CI.

**Phase 6 exit:** defensible acceptance report with verified facts, remaining production blockers and no unsupported claims of a polished, fully balanced or cross-platform-approved release.

## Execution rules and persistence

- Work in **one scoped PR at a time**; inspect current open PRs and merged commits before touching files. Small reviewable PRs for architecture, P0 screens, cards, gameplay visuals, secondary screens and responsive/mobile. No diverging UI styles across concurrent efforts.
- Reproduce issues before changing code; run local relevant tests, CI, Web export and visual comparisons for affected screens before merging. Respect GitHub permissions, branch protection and required reviews.
- Owner has already approved GDD-defined gameplay and V5 overall visual direction, so continue **independently** through authorized implementation stages without asking for permission at each PR. **New identity-bearing art, individual candidate icon master sign-off, new balance values, P4–P8 production mechanics, costs, credentials, native store publishing or other new product decisions remain gated.**
- Update `docs/MIGRATION_PROGRESS.md`, `docs/QA_BACKLOG.md` and the V5 coverage/evidence matrix after each integrated milestone. Keep Phaser untouched.
- Explicitly distinguish **implemented**, **automatically tested**, **visually compared**, **owner-approved art**, **device-tested**, **production deployed**, and **balance-accepted**. These are not equivalent.
- If Work session limits interrupt progress, leave completed changes/PRs, CI status and next steps durably in GitHub; on restart, resume from `main` + tracker, never reimplement already merged work.
- All code, PRs, technical docs and outward artifacts remain in **English**.

## Suggested first five PR scopes

1. `G3.0: Audit V5 assets, baseline captures and visual parity matrix`.
2. `G3.1: Implement Hero Spotlight theme and reusable live UI primitives`.
3. `G3.2: Restore Hero Spotlight menu and three-hero selection`.
4. `G3.3: Implement illustrated normal and legendary choice cards`.
5. `G3.4: Rebuild gameplay HUD and cross-viewport camera-safe overlays`.

Subsequent PRs should follow the phase order and findings, **not** simply copy the original V5 screenshots if the latest GDD differs.
