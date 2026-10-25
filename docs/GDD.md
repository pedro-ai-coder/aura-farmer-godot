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

### 5.9 Nine canonical weapons — exactly three per class

One equipped starter occupies a normal weapon slot; players can never equip more than **three distinct weapons** and cannot duplicate a weapon ID. Weapon class compatibility remains binding. The intervals below are **base intervals before equipment-level and frequency modifiers**, and `P` is the current offensive power.

| Stable weapon ID | Class | Base cadence / geometry | Level-1 primary attack and operational contract |
| --- | --- | --- | --- |
| `ratio-blaster` — Ratio Blaster | Ranged | **0.65 s**; target within **520 U**; projectile **650 U/s** | One **0.20P** shot; stops at first valid enemy or obstacle; auto/manual aim, max **0.8 s** flight |
| `no-cap` — No Cap | Ranged | **1.60 s**; directional **600 U × 32 U** line | Thrown cap deals **0.50P**, piercing up to **four enemies** (once each), at **750 U/s**; no return-leg bonus hit |
| `brainrot-feed` — Brainrot Feed | Ranged | **3.00 s**; nearest enemy within **480 U** | Mark the enemy's **current position**; after **0.45 s**, explode in **100 U** radius for **0.65P**; telegraph does **not** track the target |
| `keyboard-warrior` — Keyboard Warrior | Melee | **0.75 s**; **100° cone / 95 U** | Two key-strikes **0.18P** each at **0.00/0.12 s**; one total primary proc; facing locked at start |
| `ban-hammer` — Ban Hammer | Melee | **2.40 s**; **120° cone / 125 U** | **0.30 s** windup included; **0.90P** hit, **40 U** push on commons and **15 boss stagger** within attribution limits |
| `touch-grass` — Touch Grass | Melee | **1.50 s**; **180° arc / 145 U** | **0.40P** grass whip; **15% slow for 1.5 s**; remains melee |
| `cope-shield` — Cope Shield | Tank | **2.00 s**; **100° cone / 100 U** | **0.45P** bash; grants own **4% max-HP shield for 2 s only on a real hit**; this own-shield source does not stack with itself |
| `chad-hands` — Chad Hands | Tank | **1.20 s**; **90° cone / 90 U** | Two **0.22P** punches at **0.00/0.18 s**; every **third successful activation** replaces second punch with **0.40P / 110 U slam**; one proc total |
| `personal-space` — Personal Space | Tank | **2.80 s**; **135 U** centered pulse | **0.40P** once per target; targets hit inflict **8% less damage for 2 s**; no continuous damage ticks or no-hit defensive benefit |

#### 5.9.1 Item levels, rarity, and replacement rules

**Rarity level caps:** Common **1–4**, Rare **1–3**, Epic **1–2**, Legendary **level 1 only**. Item rarity and level are separate persistent-in-run fields; item rarity promotion retains `min(old_level, new_rarity_cap)`.

**Weapon rarity multiplier R:** Common **1.00**, Rare **1.50**, Epic **2.00**, Legendary **2.60**. Weapon's own damage and own-shield generation multiply by `R × [1 + 0.15 × (item_level − 1)]`. Its base attack interval decreases **5% per level above 1**, then undergoes the global frequency formula in §5.2. Distinct support pulses from legendary weapons have their separately specified support formulas and must **not** receive an additional weapon-rarity multiplier unless explicitly stated.

UI must accurately compare old/current/new values and their trade-offs. A Common-4 cadence can be preferable to Rare-1, so **do not** present every promotion as strictly superior. Upgrading an existing weapon does not consume another slot. Replacing a passive with a different passive starts the new item at **level 1 of its fixed rarity**, removes the old item's buffs/stacks and active effects, and **preserves any per-ID cooldown history** until the run ends to prevent re-equip exploits. Weapon and passive levels do not share a progression counter.

#### 5.9.2 Nine approved legendary weapon variants

All have **R = 2.60, level 1**; extra hits are secondary unless otherwise explicitly specified and do **not** grant extra procs:

| Weapon | Legendary name | Approved additional effect |
| --- | --- | --- |
| Ratio Blaster | **Comment Apocalypse** | Every fourth activation sends **two extra 0.10P raw-before-R shots**, same direction, separated by **0.08 s** |
| No Cap | **Final Verdict** | Cap leaves a line which detonates after **0.7 s** for **0.25P × R**, at most one secondary hit per target |
| Brainrot Feed | **Infinite Scroll** | Main explosion is followed after **0.3 s** by three fixed side impacts spaced **80 U**, each **0.15P × R**, max one such secondary hit per target |
| Keyboard Warrior | **Caps Lock** | Every third activation finishes with **120 U / 0.25P × R** additional arc |
| Ban Hammer | **Perma Ban** | After primary impact, a **220 U** forward fissure triggers after **0.5 s**, **0.30P × R**, with warning |
| Touch Grass | **Go Outside** | Every third activation replaces the arc with a **150 U** circle; damage **×1.25**, **25% slow for 2 s** |
| Cope Shield | **Unbothered** | Every third successful strike gives allies within **140 U** a **5% caster max HP × S/100** shield for **3 s**; do **not** also multiply this support pulse by R |
| Chad Hands | **Gigachad Moment** | Third-successful-activation slam adds **0.20P × R** and reaches **140 U** |
| Personal Space | **My Aura, My Rules** | Every second pulse grants a **4% caster max HP × S/100** shield within **160 U** for **3 s**; do **not** also multiply this support pulse by R |

### 5.10 Passive catalogue: ten Common, eight Rare, six Epic, four Legendary

Every passive retains a unique stable ID and its approved class eligibility. The initial M0/M1 offer subset has **23 passive IDs**; the five future-only entries are listed at the end of this section. All passive timers use the paused active-simulation clock. `C` denotes current Common level (1–4), `R` Rare level (1–3), and `E` Epic level (1–2). Level contributions within one passive add rather than recursively multiplying themselves. Support quantities use `S/100` and applicable Certified W effects unless described as an attribute or a source-specific exception.

#### 5.10.1 Ten Common passives — all currently offerable

| Stable ID / name | Eligible class | Exact effect and conditions |
| --- | --- | --- |
| `main-character` — Main Character Energy | All | **+6%C weapon damage** (up to +24%); never increases healing/shields |
| `terminally-online` — Terminally Online | All | **+5%C weapon attack frequency** (up to +20%); respects global +100% cap, does not speed passive timers |
| `built-different` — Built Different | All | **+8%C max HP** (up to +32%); acquiring heals only the new HP capacity, removing clamps current HP to new maximum |
| `thick-skin` — Thick Skin | All | **3%C damage reduction** (up to 12%), combining multiplicatively with other reductions |
| `caught-4k` — Caught in 4K | All | **+5%C movement speed** (up to +20%); overall bonus movement cap **+60%** |
| `big-meme` — Big Meme Energy | All | **+6%C area radius** (up to +24%); does not automatically increase projectile travel or healing range |
| `timeline` — Across the Timeline | Ranged | **+8%C weapon range** (up to +32%); projectile speed adapts to preserve maximum flight time |
| `hands-on-sight` — Hands On Sight | Melee | **+7%C damage against a target within 150 U** (up to +28%); evaluated per actual hit |
| `cope-harder` — Cope Harder | Tank | **+8%C shields granted** (up to +32%), subject to global cap; creates no shield by itself |
| `certified-w` — Certified W | All | **+6%C healing and shields granted** (up to +24%); does not automatically heal, can multiply applicable Cope Harder bonus |

#### 5.10.2 Eight Rare passives — five currently offerable, three future-only

| Stable ID / name | Eligible class | Exact effect and conditions | Initial offer status |
| --- | --- | --- | --- |
| `get-ratiod` — Get Ratio'd | Ranged | After **3 primary hits on one enemy within 4 s**, that target takes **+[4+2(R−1)]% team damage** for **4 s**; **6 s/caster** cooldown; same marks do not stack | **Future-only** |
| `no-cap-streak` — No Cap Streak | Ranged | Every **fifth directional weapon activation** gets **+R pierces and +10% damage**; nontravelling AoE gets damage only; once per activation | **M0/M1** |
| `w-wifi` — W Wi-Fi | Ranged | After **12 s in combat**, and every 12 s thereafter, a stationary **160 U** zone lasts **4 s**, granting **+[8+4(R−1)]% weapon frequency** to self/allies; same zones do not stack | **M0/M1** |
| `let-him-cook` — Let Him Cook | Melee | Each primary-hit event grants a stack of **+[2+R]% damage**, max **5 stacks**, expires **3 s after most recent hit** | **M0/M1** |
| `ego-check` — Ego Check | Melee | After **4 primary hits on one enemy within 5 s**, target receives **+[4+2(R−1)]% damage** for **4 s**; **8 s/caster** cooldown; shares Exposed category with Get Ratio'd, strongest only | **Future-only** |
| `homie-check` — Homie Check | Melee | Every **8 primary hits** heal self/allies within **140 U** for **[2+R]% caster max HP** × S/100, with minimum **6 s** between pulses; hits inside lockout do not accumulate | **M0/M1** |
| `uno-reverse` — Uno Reverse | Tank | Receiving **10% own max HP** in premitigation **direct attack** damage within **6 s** charges the next weapon attack with **+[15+10(R−1)]% damage** for up to **4 s**; **6 s** cooldown; transfers/hazards excluded | **Future-only** |
| `big-chad` — Big Chad Energy | Tank | Every **10 s in combat**, grant self/allies within **160 U** a **[5+2(R−1)]% caster max HP** shield for **4 s**; first pulse at 10 s, equivalent shields refresh not sum | **M0/M1** |

#### 5.10.3 Six Epic passives — four currently offerable, two future-only

| Stable ID / name | Eligible class | Exact effect and conditions | Initial offer status |
| --- | --- | --- | --- |
| `its-over` — It's So Over | All | **+[15+10(E−1)]% damage** against targets below **30% HP**; no automatic execute/percentage-boss-HP effect | **M0/M1** |
| `brainrot-rain` — Brainrot Rain | All, PvE only | Every **10 s** with a valid enemy within **320 U**, four **[0.25+0.10(E−1)]P / 65 U** impacts; seeded positions telegraph **0.8 s** ahead, hits separated **0.2 s**, max **2 hits per target/cast** | **Future-only** |
| `aura-viral` — Aura Goes Viral | All | On Flex activation, self/allies within **180 U** gain **+[12+6(E−1)]% frequency** for **5 s**; strongest with W Wi-Fi, no Flex cooldown benefit | **M0/M1** |
| `take-l` — Take the L | All | Every **1 s**, link lowest-health ally within **180 U**, redirect **[10+5(E−1)]%** of their damage to caster; max **15% caster HP per 5 s**, disengages below **25% caster HP**; no recursive transfer | **Future-only** |
| `so-back` — We Are So Back | All | Crossing from **≥30% to below 30% HP** due to damage starts **[10+5(E−1)]% max HP** healing over **5 ticks/5 s**, plus **10% max-HP shield for 3 s**; **45 s** cooldown; never prevents fatal hit or revives | **M0/M1** |
| `six-to-seven` — Six → Seven | All | On **seventh primary hit across all three weapons**, **[0.35+0.15(E−1)]P** explosion within **90 U** around struck target; at least **2 s** between explosions, counter freezes during lockout; sixth hit signals 6/7; secondary blast creates no loop | **M0/M1** |

**Transfer compatibility for later content:** Take the L and Beta Flex may transfer damage at most once per original hit using the **largest eligible** percentage. Transferred damage creates no Aura, proc, reactive shield or further transfer; support absorption metrics do not become offensive boss damage counters.

#### 5.10.4 Four Legendary passives — level 1 only, all currently offerable

| Stable ID / name | Effect | Trigger and limits |
| --- | --- | --- |
| `absolute-cinema` — Absolute Cinema | **+25% weapon damage** always; **+20% additional weapon damage** while Flex is active | Does not multiply support or Flex-generated damage; one legendary total |
| `w-squad` — W Squad | **+25% healing/shields granted**; on Flex activation grant self/allies within **200 U +10% weapon damage** | Team buff lasts **6 s**, same-source buffs do not stack; no Flex recharge |
| `too-sigma` — Too Sigma to Fall | Shield self/allies within **200 U** for **25% of caster max HP** | Trigger only on damage crossing caster HP **from ≥25% to below 25%**; shield lasts **5 s**, **60 s** cooldown; no fatal-hit prevention/revive |
| `no-u` — No U | Control pulse within **200 U** deals **0.30P** and reduces normal-enemy damage by **20%** | Every **15 s in combat**, debuff **4 s**, first trigger at 15 s; boss instead **10% reduction for 2 s**; no reflected damage/recursive procs |

**Design balance principle:** legitimate support builds contribute via effective healing, shielding, prevention and amplified allied damage. They must not be judged only by direct DPS, nor assumed to grant all support advantages plus peak damage.

**Exactly five catalogue entries remain excluded from current M0/M1 offers:** `get-ratiod`, `ego-check`, `uno-reverse`, `brainrot-rain` and `take-l`. Approved icon artwork for these identities is **not** gameplay/content approval. The other **23** entries listed above are the active initial passive subset.

### 5.11 Rarity generation, choices and the single legendary window

Normal upgrades first choose a **legal category** (upgrade equipped / acquire new compatible item / legal rarity promotion), then roll a legal rarity. No normal upgrade can roll Legendary; reweight among remaining legal options without inventing a rarity for a fixed-rarity passive.

| Wave | Common | Rare | Epic | Legendary in normal offers |
| --- | ---: | ---: | ---: | ---: |
| **1** | 90% | 10% | 0% | 0% |
| **2** | 70% | 28% | 2% | 0% |
| **3** | 45% | 45% | 10% | 0% |
| **4** | 25% | 50% | 25% | 0% |
| **5** | 10% | 50% | 40% | 0% |

If there is an eligible equipped-item upgrade, favor including at least one in the three distinct normal cards. Do not force one offence, defence or support category on every draw; preserve long-run variety and class/slot legality. Ordinary card descriptions show current value → new value, correct rarity level/cap and any replacement impact.

**Legendary opportunity (exactly one selection per run):**
1. At **6:00** during wave 4, show **six legal cards**: the player's **three compatible legendary weapons** plus **three different legendary passive buffs from the four-item pool**.
2. The player may **take one** or **defer**. At **8:00** in wave 5, re-display the **same six stored offers**, **no reroll**.
3. After another deferral, the same existing offer may be reopened through an actual live in-game control until **9:55**. After that it expires without automatic selection.
4. Taking any one legendary **consumes the entire run's single legendary right**. No second legendary, even if the first is discarded/replaced later. If a weapon is already equipped, promote it in the same slot; otherwise use a legal free slot or require explicit replacement confirmation. A passive legendary occupies a passive slot and may similarly require confirmed replacement. Never enable Confirm for an illegal state.
5. Legendary and ordinary offers obey one-modal priority, pause the solo simulation, preserve input ownership and cannot let background gameplay continue. The deferred-reopen control is a required working element, not a hidden legacy button.

### 5.12 Bestiary, enemy behaviors and spawn integrity

The enemy ID `beta` represents the **hostile Beta Bot**, distinct from the future playable **Beta Bro**. Enemy combinations should create danger through different counterplay and clearly distinct silhouettes rather than invisible rule changes.

**Baseline table is wave-1 solo before normal enemy/elite scaling.** Contact damage cooldown is at least **0.75 s per enemy**, with **0.25 s of global protection against subsequent contact hits**; this does not necessarily nullify hostile projectiles or telegraphed hazards.

| Stable enemy ID / name | HP / speed U/s / damage / XP | First appearance | Approved behavior, warning and counterplay |
| --- | --- | --- | --- |
| `npc` — NPC | **35 / 75 / 8 / 5** | Wave 1 | Chases nearest player; gray phone-carrying enemy, contact only |
| `hater` — Hater | **50 / 60 / 10 / 8** | **1:00 during wave 1** | Maintains **260 U** range; every **3 s** sends comment-line projectile at **180 U/s** for **10** damage, with **0.6 s** warning; flank/close distance |
| `reply-goblin` — Reply Goblin | **25 / 125 / 6 / 6** | Wave 2 | Fast group contact chaser; low HP and compact tilted outline |
| `beta` — Beta Bot | **120 / 45 / 16 / 12** | Wave 2 | Heavy frontal plate reduces damage from forward **100° cone by 40%**; rear vulnerable; turns at most **90°/s** |
| `ratio-ram` — Ratio Ram | **80 / 60 / 20 / 10** | Wave 2 | Every **5 s**, locks direction through **0.9 s** warning then charges **280 U at 320 U/s**; no steering mid-charge |
| `doomscroller` — Doomscroller | **70 / 50 / 8 per tick / 12** | Wave 3 | Every **6 s** marks a target's current floor location; **1 s** warning, **70 U** zone for **3 s**, ticks **1/s** |
| `hype-bot` — Hype Bot | **65 / 55 / 6 contact / 12** | Wave 3 | Every **8 s** grants up to **three mobs within 160 U** shields worth **15% of their max HP for 4 s**; never shields a boss |
| `fanum-leech` — Fanum Leech | **90 / 70 / 10 / 12** | Wave 3 | Every **5 s** warns **0.8 s** and tethers a player within **200 U**, dealing **three ticks of 5**; breaks past **240 U**, steals no XP/items/currency |
| `ping-sniper` — Ping Sniper | **60 / 40 / 24 / 12** | Wave 4 | Seeks **400 U** spacing, every **6 s** locks laser direction with **1.2 s** telegraph then fires once; dodge laterally/use real cover |
| `copium-puffer` — Copium Puffer | **90 / 45 / 12 per tick / 12** | Wave 4 | After death, **1 s** warning before **80 U** cloud lasts **3 s**, ticking **1/s** |
| `comment-mod` — Comment Mod | **100 / 50 / 10 / 14** | Wave 5 | Every **8 s** heals up to three nearby mobs within **180 U** by **8% of their max HP**; never heals boss or other Mods |

**Spawn:** enemies arrive at least **260 U** from players, with **0.8 s** portal warning and legal placement away from solid or inescapable geometry. Ranged attacks honor covers. **Elites begin wave 3**, have **×2.5 max HP, ×1.3 damage, 60 XP** and a clearly distinct enlarged silhouette. Each elite gets **exactly one visible modifier**: either **+15% speed** or an initial **20% shield**, never a hidden combination. At most **two simultaneous elites in solo** (four in future co-op).

**Navigation quality:** active chasers must navigate around the two existing static solid covers and arena boundaries; they may not remain unexpectedly blocked. Intended attack-range holds, boss telegraph locks, knockback and stagger recovery are distinct from pathfinding failures. The **two original static obstacles are non-destructible**, not prototype P4 loot crates.

### 5.13 Event encounters — four fixed encounters

Event-boss HP below is the approved encounter-time solo value: do **not** multiply by wave HP again. In future co-op only the explicitly defined party-count boss factor applies; event adds scale with their normal wave rules.

| Event boss / clock | Solo HP / XP | Attack and counterplay contract |
| --- | --- | --- |
| **Reply Guy — 2:15** | **1,400 / 120** | Comment cone **18 damage**, **0.8 s** warning, every **4 s**; summons **four NPCs every 12 s**; **1.5 s** vulnerable window after cone |
| **Mod Supremo — 4:15** | **3,200 / 240** | **130 U** circular Ban Slam **28 damage**, **1 s** warning, every **6 s**; two ground silence lines every **10 s**, **15 damage** without disabling controls; at **50% HP**, summon **two Haters once** |
| **Ohio Express — 6:15** | **2,800 / 120** | Every **9 s**, sequence of **three fixed straight charges**, **22 damage** each and **0.8 s** warning per charge; **2 s** recovery; no direction change mid-charge |
| **Doomscroll Prime — 8:15** | **5,200 / 240** | Every **7 s**, two **100 U** zones with **1 s** warning, **12 damage/s** lasting **3 s**; forward burst every **4 s** for **18 damage**; destroying **two 250-HP terminals** interrupts next zone sequence for **4 s** |

Events do not pause the wave or create off-system free cards. If an event boss survives into a later wave, do not apply another HP multiplier. At **10:00**, all surviving event bosses withdraw **without XP/loot**; defeating them is a reward opportunity, not a hidden final-boss prerequisite.

### 5.14 Big Hater — final boss and recoverable Berserk

**Encounter entry:** boss telegraph at **9:30**, Big Hater at **10:00** on a readable bounded arena. Remaining ordinary mobs leave without XP. Existing uncollected XP crystals are collected without inventing new XP. Big Hater starts at the **approved initial solo tuning value of 30,000 max HP**, with no additional wave-5 HP multiplier. **Its actual viability with ten minutes of normal build progression is not yet balance-proven** and must be reviewed without silent HP/XP/damage tuning.

**Base combat:** boss contact deals **12 damage once each 1 s**, never stacking contact and a main slam on the same frame. Primary attack slots last **6 s** and repeat in this order: **Hate Slam → Ratio Beam → Comment Ring → Adds**. Preparation and execution fit the slot; incompatible main attacks do not overlap.

- **Hate Slam:** **120° cone / 200 U**, **1 s** warning, **35 damage**, locks position/direction **0.3 s** before hit, then **1.2 s** recovery.
- **Ratio Beam:** **600 × 60 U** straight beam, **1.2 s** warning, **30 damage**; direction stays fixed after lock, honors designated solid cover.
- **Comment Ring:** expanding ring **80 → 280 U in 1.5 s**, **25 damage once per expansion**, **25 U** band width, **1 s** warning with a clearly signaled **70° safe gap**.
- **Adds:** **four NPCs plus one Hype Bot**; at most **eight living adds solo** (16 in five-player scale). Adds cannot shield/heal boss. Defeating Hype Bot applies **+10% boss damage taken for 3 s**, sharing Exposed category with other modifiers (strongest, not additive).

**Persistent HP thresholds:** at **70% HP**, Comment Ring becomes **two expansions separated by 0.8 s**, with safe opening maintained. At **35% HP**, Ratio Beam leaves a **2 s** lingering zone dealing **8 damage/s**. Each threshold unlocks once even if later regeneration raises health.

**Stagger:** shared **0–100** meter; heavy weapons and named effects contribute up to **20 stagger/s total**. At 100 the boss is exposed/stationary for **3 s**, takes **+15% damage**, and then the meter resets with a **20 s** filling lock. Stagger interrupts windup but never erases already resolved damage; identical exposure bonuses use the largest. Stagger remains useful during Berserk, without reverting Berserk.

**Berserk / FULL HATER MODE:** warnings at **60/30/10 s remaining**. After **120 active seconds of boss combat**, enter recoverable Berserk (nominal **12:00** game clock), change silhouette/audio/outline, and apply all of the following **without** instant healing, teleporting, cancelling existing hits or increasing max HP:

| Berserk property | Approved initial rule |
| --- | --- |
| Extra resistance | **35% reduced received damage**, multiplicative with other applicable modifiers; cannot be removed by Ego Check |
| Regeneration | **0.10% of max HP per second**, **1 s** tick, capped at max HP |
| Damage per blow | **×2 immediately**, then **×1.10 per 30 s of Berserk**, capped at **×3 pre-Berserk damage** |
| Primary attack interval | **6 s → 4.8 s**, with at least **0.8 s** warning |
| Stagger | Still functions; during a **3 s** exposed window **regeneration is suspended** without resetting its underlying timer |

Berserk is **not a scripted wipe at 12:00**. With 30,000 HP, the initial regeneration is **30 HP/s**; ignoring other defenses, sustained **raw DPS greater than 30 / 0.65 ≈ 46.2** can in principle overcome it. This arithmetic illustrates possibility, **not validated encounter difficulty**. At **240 s of boss combat** (nominal game **14:00**), display a final-effort warning; there is still **no hard time-limit defeat**. Boss adds grant no kill XP/death Aura and cannot be farmed for endless level-25 recovery. Victory/defeat freezes unresolved combat properly, permits correct result saving and does not award bonus loot for dragging the encounter.

