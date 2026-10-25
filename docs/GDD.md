# Aura Farmer — Game Design Document V3.0

**Status:** Consolidated draft, pending owner review and merge.  
**Decision cutoff:** 25 October 2026.  
**Engine:** Godot 4.7.2, GDScript, Compatibility renderer.  
**Current production visual direction:** Character Hype Broadcast — Clean Cut.  
**Authoritative source after merge:** `docs/GDD.md` in `pedro-ai-coder/aura-farmer-godot`.  
**Historical predecessor:** [GDD V2.0 — unmodified archive](GDD_V2_ARCHIVE.md).  
**Decision provenance:** [Owner Decision Register](GDD_DECISION_REGISTER.md), [approved Clean Cut art](art/CREATOR_CLEAN_CUT_V2_APPROVAL_2026-10-24.md) and [approved icons](art/CREATOR_ICON_APPROVAL_2026-10-24.md).

> **Source-of-truth rule:** This document defines the current approved design and milestone requirements. Historical Phaser milestones, 15-minute schedules, old Flex names, first-release mandatory native targets, previously rejected visuals and obsolete missing-asset assertions in the archived V2 are **not operational requirements**. Preserve all approved mechanics and stable content IDs unless an explicit owner decision changes them. A green CI check never creates design or art approval.

## 1. Product identity and design goals

Aura Farmer is an original, expressive 2D cartoon action-survival/roguelite with internet-meme humor, automatic weapon attacks, meaningful limited equipment builds, a hero-specific manual **Flex** driven by one Aura resource, readable enemy patterns, event bosses, and a final encounter with **Big Hater**.

The core visual identity uses the original **Option A — Cartoon Arcade** hero, enemy and environment identities, expressed through the current **Character Hype Broadcast — Clean Cut** UI composition and interaction language. Inspiration from games such as Brotato and Swarm concerns readable mechanics and presentation principles, **not copied characters, artwork, map geometry or numbers**.

**Experience pillars:** meaningful build choices; distinct recognizable heroes; active movement and enemy counterplay; high-impact but readable Flex; humor conveyed by original silhouettes and attacks; visual polish rather than generic dashboard UI; clear XP/Aura progression; reliable control on the supported platform.

**Immediate mode:** solo PvE in Ruin Alley. Future content such as co-op, ranked, arena, additional heroes/maps, monetization and optional roguelite prototypes remains outside M0/M1 unless separately approved.

## 2. Approved milestone sequence and release scope

The **owner's 25 October 2026 decision** below supersedes the older Web/Discord first-demo sequence and the 21 October commitment to deliver Web, Android and iOS with equal priority immediately. Godot remains suitable for a possible later native expansion; future platform evaluation is not an M0/M1 release obligation.

| Milestone | Audience and distribution | Required product outcome | Not required / outside scope |
| --- | --- | --- | --- |
| **M0 — Closed Web Playtest** | **Web only**, very restricted invited tester group | **Fully visually polished** Web solo build using the approved Clean Cut direction, current playable content and complete live UI flows; no backend dependency | No backend, Discord Activity, public alpha, native apps, account service, cloud saves, multiplayer, PvP, monetization or new gameplay content |
| **M1 — Public Alpha** | Publicly accessible alpha through **Web and Discord Activity** | Retain M0-quality playable solo game; integrate an **available/operational backend**; **ask testers for feedback inside the game**, with a working submission/collection flow; independently validate ordinary Web and Discord journeys | Native Android/iOS/desktop application release, full nine-hero content, competitive/co-op modes, store, season pass, new power systems, automatic launch from a PR merge |
| **M2 and later — Platform/content evaluation** | To be decided | Reassess native platforms, further playable content and other modes with separately approved scope and delivery gates | No presumed native-platform commitment, timetable or paid service |

### 2.1 M0 — minimum playable and finished visual experience

M0 contains the **three playable starters** (`sigma`, `cool-kid`, `alpha`), **nine canonical weapons** (three per class), **23 currently offered passives** out of the 28-item approved catalogue, **three weapon slots**, **five passive slots**, **Ruin Alley**, progression/XP/Aura/Flex, five two-minute waves, event bosses, the legendary choice, Big Hater/Berserk, Street Snack, Aura Magnet and Safe Spot, and legitimate win/loss/retry and local-save flows.

**“Fully visually polished” is an explicit M0 delivery requirement, not an assertion that the currently merged UI is already accepted.** All visible user journeys must share the approved Clean Cut art direction: menu; hero selection; gameplay, HUD, Flex and boss feedback; normal/legendary/replacement cards; build inspection; pause; settings; quit confirmation; victory/defeat; world pickups; enemy, weapon and character presentation; and responsive supported Web viewports. No generic fallback panel, placeholder symbol for an available approved icon, dead button, unresolved overlapping/cropped text, unapproved new identity art, misleading simulated data or visually unfinished transition may be presented as a finished M0 screen.

**M0 has no backend:** solo gameplay, local profile/save, access to the restricted Web deployment and closed-test observation must function without a server-side game service. Tester feedback can be gathered externally by the closed-test organizers; an in-game feedback backend is not an M0 requirement.

M0 release/readiness requires **a creator visual review of actual interactive gameplay**, not simply static mockups or passing headless tests. Record the exact playable build/revision, representative desktop/mobile Web viewports, at least one normal complete run with victory/defeat paths observed as applicable, and evidence of correct input, UI and transitions. Existing unverified device metrics must not be invented.

### 2.2 M1 — public alpha, Discord Activity and feedback

M1 builds directly on the **approved M0 game**, retaining the same approved gameplay and visual quality unless the GDD explicitly changes. Deliver two genuinely usable player entries: ordinary **Web** and **Discord Activity**. The Discord experience must use its supported SDK/integration and preserve game rules, scene state, UI, input, pause, results and persistence as allowed by the platform; a Discord-themed mockup or untested embed is not sufficient.

The **backend must be deployed and operational**, not only described or scaffolded. It supports the M1 requirements approved in a subsequent technical contract; **do not infer a specific provider, mandatory player accounts, paid hosting, global cross-save, ranked, or multiplayer** merely from the word “backend.”

**Ask alpha testers for feedback from inside the game.** Include a visible, accessible, non-blocking request and a usable submission journey (for example, a post-run invitation plus an on-demand feedback entry; the exact UX is subject to design approval). Preserve player choice to skip/dismiss and keep gameplay usable if feedback delivery fails. The backend/feedback contract must define permitted collected fields, submission schema, consent/privacy notice, retention/access, rate limiting/abuse handling, failure/retry messaging, and the distinction between feedback data and gameplay data before implementation. No user-identifying or extra telemetry collection is silently authorized.

M1 public release is a deliberate product action, **separate** from integrating individual approved PRs. Validate the actual production Web and Discord builds, working backend, usable tester feedback flow and required privacy/security and regression checks before announcement or broader access.

### 2.3 M2+ — proposals, not implicit commitments

At M2 or later the owner may choose native Android/iOS/Windows/macOS/Linux applications, additional maps/heroes/passives, cooperative modes, competitive arena, cosmetics and account features. Native platform priority, signing/device prerequisites, spending and acceptance criteria remain **undecided**. Existing Android/iOS export preparation is reusable engineering work, not a promise of release.

## 3. Decision statuses and product boundaries

| Classification | Meaning |
| --- | --- |
| **Approved gameplay** | Explicit owner-approved rule/number; implement and test as written. A different number or mechanic requires another owner decision. |
| **Approved art, exact version** | Owner-approved source file/version/hash in an approval ledger; integration must preserve identity and applicable restrictions. |
| **Current art direction** | Clean Cut **for now**; not blanket acceptance of every rendered screen, future variant or previously rejected image. |
| **Initial tuning, not balance-proven** | Approved starting values remain in force, but real unprotected play may reveal a need to propose changes. |
| **Concept-only prototype** | Experiment in isolated work only; not enabled in M0/M1 default gameplay. |
| **Unapproved / TBD** | Do not infer defaults or ship new behavior, artworks, services or balance values. |

**Initial roster:** Sigma (Ranged), Cool Kid (Melee) and Alpha Chad (Tank); nine playable weapons, three per class; **23 of 28 passives currently offered**, explicitly excluding `get-ratiod`, `ego-check`, `uno-reverse`, `brainrot-rain` and `take-l` from the initial 23. All four approved legendary passives remain in the offer pool. Items with approved future-only illustrations do **not** thereby become playable.

**Full design catalogue, later scope:** nine heroes (three per class); nine weapons; 28 passives (10 Common, 8 Rare, 6 Epic, 4 Legendary); support/DPS build specializations; co-op/arena rules retained for future design reference but **not M0/M1 implementation deliverables**. `Wild` is future-only and not an active mode.

## 4. Engine, simulation and persistence contracts

The active independent codebase is **Godot 4.7.2, GDScript and the Compatibility renderer**. Maintain shared, deterministic gameplay regardless of Web access channel. The original `pedro-ai-coder/aura-farmer` Phaser repository is the historical parity source for unspecified previously implemented behavior (notably P1–P3 recovery), and **must not be modified by this migration**.

Keep input, renderer, audiovisual presentation, source catalog and persistence adapters separate from authoritative gameplay rules. Game RNG must support seeded deterministic reproduction, and **visual-only effects may not consume gameplay RNG or change damage/XP/spawns**. Simulation-time actions freeze during pause/modal selection, rather than advancing with wall clock. Avoid frame-rate-dependent duplicate events.

**Persisted profile:** maintain existing stable hero/item IDs and local versioned profile/save compatibility. Godot Web uses the existing versioned browser profile policy and preserves Phaser v2/v1 data without destructive overwrites; support explicit export/import where origins differ. Starting or abandoning a run must not invent won/lost results, unlock items or persist temporary equipment. M1 backend does **not** automatically replace or synchronize local saves; any backend profile migration or account feature requires its own decision.

**Interfaces and regressions:** preserve one active modal, live interactive Godot controls, clean restart, focus/release cancellation, keyboard/mouse/touch input isolation, accessible reduced-effects preference, and accurate game-state-driven HUD/card values.

## 5. Current solo run: progression, combat, content and encounters

The following sections are **binding numeric gameplay specifications**, consolidated from approved V2 §§3–12 and the later approved Flex 2.0/shorter-run/recovery amendments. Every numeric balance change requires explicit review; automated parity tests do not amount to balance approval.

