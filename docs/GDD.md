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

### 5.1 Four separate progression systems

| System | Source of progression | Result | Persisted between runs? |
| --- | --- | --- | --- |
| **Run XP and level** | Collect existing enemy/event XP crystals | Offers and small baseline stat increases | No |
| **Wave / encounter progression** | **Five 120-second** active-simulation intervals | Threat composition, difficulty, events and available rarities | No |
| **Aura / Flex** | Combat participation, survival and event rewards | One hero-specific manually activated Flex | No |
| **External account/rank progression** | Run results and future objectives | Future unlocks/rewards | Only when separately implemented |

Aura never purchases levels; activating Flex does not spend XP. Wave changes do not reset run level. XP/level and Aura must have separate readable HUD displays. No independent Alpha/Sigma currency or obsolete Focus ability.

### 5.2 Shared movement and combat formulas

- **Movement/aim:** free movement; weapons attack automatically on their own cadence. Directional attacks support manual/automatic aim. Auto-aim selects the nearest legal enemy with stable-ID ties, respecting legal range and obstacle line of sight; AoE attacks need no per-shot click. The only initial manually activated special action is Flex.
- **Units:** `U` denotes world units. A character's collision radius is **16 U**. Reference baseline is **100 max HP, 180 U/s movement speed, P = 100 offensive power, S = 100 support power** unless the hero's own table overrides it. Weapon raw damage = weapon coefficient × current P × applicable modifiers.
- **Weapon cadence:** `max(0.20 s, base_interval / (1 + total_attack_frequency_bonus))`. The total frequency bonus is capped at **+100%**. Level-dependent reductions to the base interval apply before the global frequency multiplier. Frequency does **not** accelerate passive/Flex clocks. Cooldown begins at attack emission; without a target, stay ready and recheck every **0.10 s**, without accumulating burst debt. A valid support recipient can activate a support pulse without an enemy target.
- **Damage mitigation:** hero base physical resistance is listed with each hero. Independent reduction sources combine **multiplicatively**, subject to the normal **60% total player mitigation ceiling**. Shields absorb **after** mitigation. No unnamed immunity to boss mechanics is implied.
- **Primary hit/proc attribution:** each **primary weapon activation** produces at most **one proc event**, regardless of simultaneous targets/projectiles. Secondary hits never create new procs, Aura, XP or recursive chains unless their canonical contract explicitly says otherwise. DoT damage does not multiply hit counters.
- **Support:** healing and shields scale with **S**, not P. Weapon damage bonuses do not increase healing. Identical buffs from multiple sources use the strongest current value and refresh duration rather than summing. Different shield sources combine up to **40% of recipient max HP**; ordinary shields have maximum **6 s** duration unless a specific approved source contract is narrower. Healing caps at max HP; regeneration never revives.
- **Slow/stagger:** strongest slow wins; standard maximum **40%**. Bosses suffer half the slow and cannot be moved or stunned. Explicit interrupts contribute to stagger instead. Hostile attacks must signal danger using geometry/silhouette and audio, not color alone.

### 5.3 XP, levels and normal upgrades

- Every hero starts **run level 1**, with **one level-1 starter weapon occupying one of the three slots**.
- Default XP drops: **normal enemy 5, fast enemy 6, ranged enemy 8, heavy/support enemy 12, elite 60, mini-boss 120, major event boss 240**. Exact bestiary/event values override defaults. No last-hit XP advantage.
- Required XP to advance `L → L+1`: **`30 + 8L + L²`**. In future team modes multiply the requirement by **`1 + 0.20 × (n − 1)`** for `n` players. Overflow carries forward, and multiple earned levels queue distinct upgrade decisions.
- Initial maximum run level is **25**. After level 25, each equivalent of the level-25 XP threshold restores **5% HP to living team members**, with at least **20 s** between grants; it gives no additional card or Flex charge.
- Each earned level grants **one offer of three distinct legal cards**: acquire eligible weapon/passive; upgrade equipped item; or perform a legal rarity promotion/replacement where the wave allows it. In addition, every level grants **+2 maximum HP and +1% base damage** (maximum **+48 max HP and +24% damage** at level 25). The +2 HP gain heals **only the 2 HP newly added**.
- If three different legal item cards do not exist, fill the shortfall with **8% max-HP healing** or an **8% max-HP shield lasting 6 s**. Never offer incompatible/maxed items, counterfeit fourth weapon slots or starter passives outside the five passive slots.
- Upgrade offers are individual. In a future co-op implementation the team shares one XP bar; any crystal is credited only once, levels are gained together, and each hero receives their own legal choice.

### 5.4 Current short-run wave and encounter schedule

**One active simulation clock governs this schedule.** A standard pre-boss run lasts **10:00 active minutes**, not the superseded 15:00 version. Paused/menu time does not advance it. After Big Hater arrives, combat may continue beyond the boss's berserk phase; there is no arbitrary hard defeat cutoff.

| Phase | Active game clock | Target run level at phase end | Enemies, events and offers |
| --- | --- | --- | --- |
| **1 — First Post** | **0:00–2:00** | **5–7** | NPC onboarding/movement; initial Hater at **1:00** |
| **2 — Comment Section** | **2:00–4:00** | **9–11** | Charges and projectiles; **Reply Guy at 2:15** |
| **3 — Going Viral** | **4:00–6:00** | **13–16** | Persistent zones/support enemies; **Mod Supremo at 4:15** |
| **4 — Cancel Storm** | **6:00–8:00** | **18–21** | Elites and mixed threats; **Ohio Express at 6:15**; first legendary at **6:00** |
| **5 — Final Ratio** | **8:00–10:00** | **23–25** | Peak pressure; **Doomscroll Prime at 8:15**; deferred legendary reprise at **8:00**, expiration **9:55** |
| **Big Hater** | **10:00 onward** | **25 target, not requirement** | Warning **9:30**; final boss at **10:00**, recoverable berserk **120 s into its combat** (nominally **12:00**); final-effort prompt after **240 s combat** (nominally **14:00**) |

The target levels are **tuning targets, not automatic level grants**. Cumulative solo XP targets for levels **5/10/15/20/25** are **230 / 915 / 2,275 / 4,560 / 8,020**. Revalidate ordinary runs with the shorter schedule before proposing XP, boss or spawn balance changes. On the four phase transitions (2/4/6/8 minutes), grant exactly one shared XP crystal of **80/120/160/200 XP** respectively, multiplied by the applicable team XP factor; its collection is credited once, not an extra off-system upgrade.

**Difficulty scaling by wave** (HP / damage / spawn-density relative to wave 1): `1.00/1.00/1.00`, `1.30/1.15/1.20`, `1.65/1.30/1.40`, `2.05/1.50/1.65`, `2.50/1.75/1.90`. Enemy movement speed does **not** scale by wave. Within a wave, spawn rate increases linearly by up to **10%**. Solo baseline spawn is **0.8 enemies/s**; current cap is **100 simultaneously active normal-wave enemies solo** and **160 at five-player scale**, interpolated by party size. At cap, postpone spawning—never invisibly kill enemies or discard created XP. A **300-enemy / 150-projectile** fixture is historical **stress-test work**, not the ordinary approved 100-enemy solo spawn cap.

**Choice and pause semantics:** a solo normal or legendary choice pauses simulation and active time immediately. The future co-op policy (not an M0/M1 feature) batches team pauses when a choice is pending: every **20 s**, a pause of up to **12 s**, ending when everyone confirms; disconnected players cannot block pauses, and a **60 s** timeout may choose only a legal upgrade to an already equipped nonlegendary item, never automatically take a legendary. All selection UI must prevent combat input leakage.

### 5.5 One Aura resource and hero Flex lifecycle

Aura is a single **0–100** meter, capped at 100 with no stored overflow. Gain **+0.5 Aura/s** while alive and simulation is unpaused; successful primary hits gain **+1 Aura**, capped at **2 Aura/s per hero**. Actual healing/shield assistance consumed by another ally can contribute +1 Aura/s within the **same** 2/s cap, never above it. Surviving a mini/major boss defeat grants **+10 Aura**. Attacking invulnerable targets or overfilling shields generates no qualifying Aura.

At **100 Aura**, the hero's manual Flex is **READY**. A successful activation consumes 100, blocks passive Aura generation during the active Flex, and enforces at least **30 s between activations**. Aura never consumes or grants XP. Current expectation of ~45–90 s between Flex uses is a **tuning hypothesis**, not a promised interval. No random-critical Flex damage. All scheduled Flex hit/counter events use the paused active-simulation clock and clear on terminal outcomes or restart.

### 5.6 Approved character catalogue and first-run starters

The complete **design roster is nine characters, three per class** (Ranged, Melee, Tank), but **M0/M1 provide only Sigma, Cool Kid and Alpha Chad as playable heroes**. Preserve all eight historical hero IDs and add the ninth (`beta`) only under a separately approved content rollout; do not silently migrate unlock identities. There are no separate Alpha/Sigma resource currencies. `P` and `S` are distinct: **S = 100** for every baseline hero, and DPS/Support are build specializations, not hero classes.

| Stable ID / hero | Class | Base max HP / speed U/s / P / mitigation | Approved starter weapon | Passive innate trait |
| --- | --- | --- | --- | --- |
| **`sigma` — The Sigma** | Ranged | **100 / 180 / 100 / 0%** | **No Cap**; dark angular hood, gold emblem and recognizable thrown cap | **Lock In:** 2 s without changing priority target grants +10% damage to that enemy; resets on target switch/loss for 1 s |
| `nerd` — Nerd (future playable) | Ranged | **85 / 180 / 105 / 0%** | Ratio Blaster; square glasses and tilted posture | **Calculated:** every fifth starter primary activation gains +25% damage on that activation; no critical hit |
| `six-seven` — Six Seven Kid (future) | Ranged | **90 / 190 / 95 / 0%** | Brainrot Feed; visible 67 jersey and six/seven gestures | **Counter:** seventh starter activation gains +20% area radius; independent of the Six → Seven passive |
| **`cool-kid` — Cool Kid** | Melee | **110 / 190 / 95 / 5%** | **Keyboard Warrior**; blue pompom beanie and layered streetwear | **Too Cool:** after 3 s continuous movement, +10% melee damage; ends after 1 s stopped |
| `ohio` — Ohio Kid (future) | Melee | **85 / 215 / 100 / 0%** | Touch Grass; agile blue outfit | **Ohio Route:** each 300 U traveled in combat strengthens next primary attack with 20% slow for 1 s; 3 s between activations |
| `rizzler` — The Rizzler (future) | Melee | **95 / 190 / 90 / 5%** | Keyboard Warrior with comb/microphone visual skin; slim purple coat | **Good Vibes:** every 10 s heal self and most-injured ally within 160 U for 3% recipient max HP × S/100; no Aura/procs |
| **`alpha` — Alpha Chad** | Tank | **140 / 160 / 90 / 15%** | **Cope Shield**; broad shoulders and squared jaw | **Certified Unit:** taking direct damage gives +20% to the next punch; 4 s cooldown, one charge |
| `fanum` — Fanum Lord (future) | Tank | **125 / 170 / 90 / 10%** | Personal Space; TAX snack bag and round green silhouette | **Tax Collector:** +50% pickup radius; every ten XP pickups gives own 5% max-HP shield for 3 s; 8 s cooldown; no additional XP |
| `beta` — Beta Bro (future) | Tank | **120 / 180 / 85 / 10%** | Chad Hands; foam gloves and protective backpack | **Homie First:** every 12 s grants 6% recipient max-HP shield for 4 s to lowest-health ally within 180 U, self in solo |

**Future-only proposed unlock examples (not enabled in M0/M1):** end wave 2 → Nerd; defeat first major event boss → Rizzler; end wave 4 → Ohio; collect 500 cumulative XP → Fanum; complete a run → Six Seven; 1,000 cumulative effective protection/healing → Beta. These are proposals pending progression and solo-fairness review, not current production entitlements.

### 5.7 Hero-specific Flex — approved current PvE contract

**Approved owner decision:** The signature Flex redesign replaces the three original solo-starter kits, while retaining the stable hero IDs `sigma`, `cool-kid` and `alpha`. The approved public names are **Deadpan Verdict**, **CTRL + CHAOS** and **Giga Chad Rampage**, respectively. *Giga Chad Rampage* now belongs to **Alpha Chad**, not Cool Kid; the historical Cool Kid contact-immunity Flex and historical Alpha Hold kit are superseded. The other six characters' Flexes remain unchanged.

All nine heroes use the single **Aura** resource and common activation rules in §5.5: 100 Aura spent on a successful activation, no passive generation during the active Flex, at least 30 seconds between activations, normal pause semantics, no new ability button, and no carry-over between runs. The numbers below are **approved initial PvE implementation specifications**; they are not claims of validated balance. The Godot implementation must match these approved contracts and their deterministic regressions; Phaser remains an unchanged historical reference. Balance corrections require new recorded GDD decisions.

| Hero | Flex / active duration | Approved PvE effect and counterplay |
|---|---|---|
| **Sigma** | **Deadpan Verdict**, **6 s** | Lock one eligible priority enemy within **600 U**; activation without an eligible target does not spend Aura. During Flex, primary weapon hits against the locked target gain **+40% damage** and an applicable directional projectile gains **+1 pierce**. When **three successful primary weapon activations** hit the active marked target, deliver **one** focused Verdict hit worth **0.75P**, subject to all normal target defenses. The Verdict can trigger at most once per Flex. See §5.7.1 for retargeting and boss limits. |
| Nerd | **Spreadsheet Diff**, 6 s | One 600 U line in aim direction every 0.75 s, 0.45P per enemy, max eight strikes; aim refreshes before each shot; unaffected by weapon frequency. |
| Six Seven Kid | **SIX… SEVEN!**, 3.5 s | Six radial six-projectile bursts every 0.5 s at 0.10P each; a seventh 1.0P pulse at 3.5 s within 200 U. One hit per target per burst. |
| **Cool Kid** | **CTRL + CHAOS**, **5 s** | Gains **+25% movement speed** and performs **six** distinct keyboard-cone attack beats over the Flex, each for **0.20P** in **110° / 115 U**, with up to **five** eligible targets per beat. A directional **ENTER!** finisher at **4.50 s** deals **[0.45 + 0.10 × successful beats]P**, maximum **1.05P**, in **130° / 145 U**. Receives **15% less direct non-boss enemy contact damage** while active; **no contact-damage aura or complete immunity**. See §5.7.2. |
| Ohio Kid | **Only in Ohio**, 5 s | Leaves movement trails lasting 2 s; enemies take 0.12P every 0.5 s and 20% slow; +30% movement; overlapping trails do not double-tick. |
| Rizzler | **Unspoken Rizz**, 6 s | Mobile 180 U aura: 30% slow on normal enemies, +15% ally frequency, and 2% caster-max-HP × S/100 healing per second per recipient; half slow on bosses. |
| **Alpha Chad** | **Giga Chad Rampage**, **6 s** | Enters an unmistakable heavy shield stance, gains a **25% max-HP self-shield**, draws normal PvE enemies within **180 U** for **2 s**, and performs **three** 0.40P slams in **150 U** at **0/2/4 s**. Takes **20% less direct non-boss enemy contact damage** during the window. At **5.50 s**, one **180 U** shockwave deals **0.50P plus up to 0.50P** based on damage absorbed by this Flex's own shield (maximum **1.00P**). Knockback affects only non-boss enemies; boss receives **10 stagger** subject to the global stagger budget. See §5.7.3. |
| Fanum | **Fanum Tax**, 6 s | Pulses every 1 s for 0.15P in 160 U and 3% caster-max-HP × S/100 shields to allies. This shield source renews and stacks to 12% target max HP, under global caps. |
| Beta | **No Homie Left Behind**, 5 s | Redirects 20% post-mitigation ally damage within 200 U, max 30% self-HP per activation; 35% reduction on transferred/self damage without recursive transfers; solo keeps personal reduction. |

#### 5.7.1 Deadpan Verdict — deterministic precision and payoff

- **Target choice:** At activation, acquire the highest-priority eligible enemy within 600 U using the existing targeting priority and stable-ID tie-break. If none exists, remain READY and spend no Aura. Once locked, target cannot change while alive, even if other enemies become closer or it moves temporarily out of range. Targeting weapons retain their own legal range and line-of-sight checks.
- **Retarget:** If the marked enemy dies, the next successful primary weapon activation can lock the next eligible enemy in the same 600 U radius. Until it does, no bonus is applied; the 6 s timer still expires. A temporary loss of visibility does not teleport projectiles or grant bonus hits.
- **Damage:** +40% applies only to *primary weapon damage actually hitting the current locked target*; other targets and secondary areas do not inherit the damage bonus. +1 additional pierce applies only when a primary weapon has a directional, piercing projectile; do not grant fictitious pierce to melee/area attacks. The normal Lock In hero trait remains independent under §5.6.
- **Verdict counter:** Count at most **one qualifying success per primary weapon activation**, even when that activation sends multiple projectiles or hits more than one target. Maintain the count across legitimate death/retarget within a single Flex. On the third qualifying success, resolve a **single 0.75P** secondary hit on the marked target if still alive after the primary damage. If the primary hit defeats it, show the finisher confirmation but do not generate damage on another target. The finisher never auto-executes by percentage HP and never ignores boss mitigation, armor, shields or invulnerability.
- **Feedback:** Distinct character stare entry, clear marked-target frame and line, visible 1/3 → 3/3 build-up, one comic **VERDICT!** impact and a brief exit. *Visual* freeze-frame emphasis does **not** freeze simulation or enemy movement.

#### 5.7.2 CTRL + CHAOS — skillful keyboard melee combo

- **Activation:** The 5 s window begins immediately on a successful Aura activation. The +25% movement-speed bonus uses the existing movement-cap rules. The hero remains player-steered, not auto-dashed or teleported. Existing weapons keep their normal activation timers, weapon slots, and abilities.
- **Keyboard beats:** Schedule **six** independent, **secondary** 0.20P cone strikes at relative active times **0.35 / 1.05 / 1.75 / 2.45 / 3.15 / 3.85 s**. Each beat is **110°** wide and **115 U** long, starts at the hero's current position and uses the current manual aim if available, otherwise current movement facing (last non-zero facing while idle). Per beat, select up to **five** legal targets in range, ordered nearest first then by stable enemy ID. Each target is hit no more than once by that beat. A beat counts as **successful** if at least one real target receives damage; multiple targets count as one beat, not multiple combo stacks.
- **ENTER! finisher:** At **4.50 s**, hit legal targets in the currently aimed **130° / 145 U** cone once each for **0.45P + 0.10P per successful prior beat**, capped at **1.05P**. Successful-beat count is at most six, never carries to the next Flex and cannot be charged by normal weapon hits or passive procs. A missed finisher still plays a reduced, clear end-pose without dealing damage.
- **Protection and limits:** During Flex, apply **15% multiplicative reduction** to **direct non-boss enemy contact attacks only**, alongside existing mitigation. Boss attacks, enemy projectiles, scripted hazards and special zones still hit normally; no full immunity, contact-on-touch attack, iframes, movement stun or knockback from the Flex. Beat/finisher damage is Flex-secondary damage: **no extra Aura, on-hit passive procs, weapon cooldown refunds or recursive combo charges**. Use the current P from §5.2, not item-rarity multipliers.
- **Feedback:** Blue/teal keyboard trails, recognizable keystroke silhouettes and a six-step progress indicator; the finale visibly spells **ENTER!**. Use the approved Cartoon Arcade design and approved assets; missing dedicated art must go through art approval rather than reusing Alpha's silhouette. Reduced-motion mode retains readable attack outlines and timing.

#### 5.7.3 Giga Chad Rampage — heavy frontline shield and countershock

- **Entry:** For **6 s**, Alpha visibly anchors into a powerful stance, granting a self-shield of **25% max HP** for this window (subject to the global **40% max-HP total shield cap**). The shield is tracked as a **separate named Flex shield source** so absorption can be attributed correctly. Normal non-boss PvE enemies within **180 U** are taunted for the first **2 s**; the boss cannot be forcibly retargeted, stunned or interrupted.
- **Slam cadence:** Exactly **three** 0.40P impact pulses at elapsed **0.00 / 2.00 / 4.00 s** in **150 U**, once per target per slam. Keep the existing attack telegraphs and committed enemy/boss patterns intact. Slams do not move Alpha, create a fourth weapon or generate extra primary procs.
- **Protection:** Apply **20% multiplicative mitigation** only to direct non-boss enemy contact hits during Flex, in addition to the character's base mitigation. Boss contact, telegraphed attacks, hostile projectiles and hazardous ground effects remain dangerous. No invulnerability, passive Aura regeneration while active or forced boss facing.
- **Final countershock:** At **5.50 s**, pulse once within **180 U** for **[0.50 + min(0.50, 2 × absorbed_flex_shield_HP / max_HP)]P**, up to **1.00P** total per target. Count **actual damage absorbed only by the shield granted at this Flex activation**; do not count other shields, overkill, unused shield, healing or prevented damage from mitigation. Resolve against normal defenses and cap one shockwave hit per target. Push non-boss common/elite enemies up to **40 U** along a walkable path without clipping through solid covers. Against Big Hater, do not push, taunt or stun; contribute **10 stagger**, still subject to the shared **20 stagger/s** ceiling and existing stagger lock.
- **Feedback:** Gold/coral power-up silhouette, heavy shield border, **three** distinguishable earth-shaking but accessibility-safe slams, visible shield absorption feedback, and a single final **GIGA!** shockwave. Avoid long camera shakes and keep enemy danger telegraphs above friendly visual effects in readability priority.

#### 5.7.4 Shared implementation, UI, balancing and migration rules

- Damage of these Flex actions uses the existing player power **P** and standard damage/defense ordering from §5.2. Flex-generated beats, Verdict and shocks are **secondary**: do not count them as primary weapon activations, target-lock triggers, XP-generating events, passive on-hit events or Aura charge events. No random critical hits or new RNG streams.
- Scheduled effects advance exclusively on the **active simulation clock**, freeze on pause/choice menus, stop on defeat, and fully clear on victory, hero change, restart or new run. Simultaneous enemy deaths, target loss and weapon-hit ordering must be deterministic. No frame-rate-dependent repeated hits.
- Preserve hero IDs `sigma`, `cool-kid`, `alpha`, stable weapons/passives, three weapon slots, five passive slots, one legendary opportunity, saves/profile schema and the §5.5 Aura/30-second lock. Store new counters only in transient per-run state; they do not migrate as permanent upgrades.
- The **original Cool Kid Giga Chad sprite-sheet frames are historical approved artwork**: do not silently treat Cool Kid's widened silhouette as Alpha's asset, and do not claim the new Flex art is finished. A new approved visual brief/assets may be needed for each signature state. Use compatible existing assets for interim animation and report the gap honestly.
- UI: READY, activation, remaining seconds, countdown/beat progress, primary target, shield charge and finisher state must be readable on keyboard, touch and reduced-motion layouts without obscuring threats.
- Acceptance: deterministic timing boundaries; correct one-hit-per-target and one-proc-per-activation contracts; repeated activations; target loss/death; max five beat targets; shield attribution; special-hazard and boss counterplay; cover-safe knockback; no Aura/proc loops; paused and restarted lifecycle; ordinary-health three-hero full runs under the new ten-minute schedule; real mobile/desktop visual review.
- **Balance gate:** Start with the above approved *initial tuning values*; benchmark measured damage, survival, damage prevention, boss viability, readability and active-play Flex uses before release. Any changes to the approved numbers must be documented in the GDD rather than silently tuned in code.

**PvP boundary:** These are *solo PvE contracts*, not arena implementations. Competitive skill timing, damage and mitigation require their own future approved table. Boss taunts do not control human targets, and no PvE damage/immunity rule implicitly transfers to PvP.


### 5.8 Illustrative builds (design test cases, not mandated offers)

- **Ranged DPS:** Sigma + No Cap / Ratio Blaster / Brainrot Feed, Main Character Energy, Terminally Online, Get Ratio'd, It's So Over, Absolute Cinema.
- **Ranged Support (future Nerd):** Certified W, W Wi-Fi, Aura Goes Viral, Take the L, W Squad.
- **Melee DPS (future Ohio):** three melee weapons plus damage, frequency, combo, Six → Seven and legendary damage.
- **Melee Support (future Rizzler):** Homie Check, Ego Check, Certified W, Take the L and W Squad.
- **Tank DPS:** Alpha plus Tank weapons, counterattack/damage/frequency effects and an offensive legendary.
- **Tank Support (future Beta):** Big Chad Energy, Cope Harder, Certified W, Take the L and Too Sigma to Fall.

These are **testing examples** and may contain catalogue items **outside the current 23-passive offer subset**. They are not guarantees that all such offers can appear in M0/M1.

