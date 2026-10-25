# GDD V3.0 — Consolidation and No-Gameplay-Change Review

**Prepared:** 25 October 2026  
**Purpose:** Evidence and review checklist for a focused documentation-only replacement of the operational GDD.  
**New canonical candidate:** [`GDD.md`](GDD.md)  
**Preserved exact original:** [`GDD_V2_ARCHIVE.md`](GDD_V2_ARCHIVE.md)  
**Original V2 Git blob SHA:** `8a932be607add8b3c3cd646e168467f027cf0f6a` (unchanged byte-for-byte).  
**Owner decision ledger:** [`GDD_DECISION_REGISTER.md`](GDD_DECISION_REGISTER.md).  
**Review/merge status:** Draft pending owner PR review, CI, and explicit merge; no live runtime changes.

## Authorized 25 October milestone deltas

| Requirement | Approved binding consolidated state | GDD V3 |
| --- | --- | --- |
| M0 audience/platform | **Very restricted closed test; Web-only** | §§2.1, 10.2 |
| M0 art | **Fully polished visual experience** with current **Clean Cut** identity, *not just integrated assets* | §§2.1, 8, 10.2 |
| M0 backend | **None**; game and local saves cannot require it | §§2.1, 4, 10.2 |
| M1 distribution | **Public alpha: ordinary Web + Discord Activity** | §§2.2, 9.1, 10.3 |
| M1 backend | **Available, operational backend**; service, fields and privacy contract must be specified before implementation | §§2.2, 9.2 |
| M1 feedback | **Request feedback from testers inside the game** with real submission/collection | §§2.2, 9.3 |
| M2 onward | Evaluate multiplatform, **not automatically approved native releases** | §2.3 |
| PR-level acceptance | Applicable mandatory checks/tests pass, then **owner approves PR**; not equivalent to full release/art approval | §§10.1–10.3 |

## Design-contract preservation matrix

| Domain | V2 source | V3 section | Spot-checked invariants |
| --- | --- | --- | --- |
| Core progress/time | §§3–6, §25 | §§5.1–5.5 | 10-minute boss entry; five 120s waves; event 2:15/4:15/6:15/8:15; 9:30 warning; 12:00 nominal Berserk |
| XP | §5 | §§5.3–5.4 | `30 + 8L + L²`; cap 25; +2 HP/+1% damage per level; transition 80/120/160/200; normal cap 100 |
| Aura | §6 | §5.5 | Single 100-point meter; +0.5/s passive, +1 per primary event, max 2/s event rewards, 30s Flex lock |
| Hero stats/traits | §7.1 | §5.6 | **9 stable heroes defined**; **only 3 playable starters**; no change to HP/speed/P/class/trait |
| Signature Flex | §7.2 | §5.7 | Full authorized **Deadpan Verdict / CTRL + CHAOS / Giga Chad Rampage** detail retained from original English approved section, with section links normalized |
| Weapons | §§8, 8.1–8.2 | §5.9 | **9 IDs/attacks and 9 legendary variants**, base cadences and special support shield formulas |
| Passive catalog | §9 | §5.10 | **28 IDs** (10 Common, 8 Rare, 6 Epic, 4 Legendary); **23 offered** and **5 future-only** |
| Rarity/legendary | §10 | §5.11 | caps **4/3/2/1**; normal rarity probability table; 6 legendary offers at 6:00, same at 8:00, expires 9:55 |
| Enemies | §11 | §5.12 | **11 distinct enemy IDs**; existing cover/navigation and elite constraints |
| Events/final boss | §12 | §§5.13–5.14 | **4 event bosses**; Big Hater 30,000 initial HP; 70%/35% phases; recoverable Berserk/timers |
| Recovery | Annex C.2 | §6 | P1 **5/20%, 18%, 56 U**; P2 **2/8%, 72 U, existing XP only**; P3 **(1100,565), 68 U, 2 s charge, 25% heal, 90 s cooldown** |
| Mobile | Annex C.1 | §7 | Full-playfield circular joystick **80/35/119** and independent Flex touch; no left-48% rule |
| Art | §26 + Annex A | §8 | Clean Cut for now; **19 originals, 37 icons, 84 UI resources** with exact existing approval ledgers |
| Later co-op/PvP | §§13–15 | §11 | Original design intents and numeric co-op factors preserved as future-only specifications |
| Concept experiments | §24 / Annex C.2 | §§6, 11.3 | P4–P7 isolated prototype concepts only, P8 unapproved |

## Reconciled historical contradictions

- **Former mandatory native first release:** superseded by M0 Web; M1 Web + Discord; M2+ optional evaluation.
- **Former initial 9-hero/28-passive playable requirement:** full design catalogue retained; M0/M1 actively use 3 heroes, 9 weapons and 23 offered passives.
- **Former Phaser/TypeScript-first development instruction:** current operational engine is Godot; Phaser is source reference only.
- **15:00 boss / 180s waves:** preserved only as archived provenance; live approved 10:00 boss / 120s waves.
- **Old starter Flex names or prior Cool Kid enlarged Rampage:** preserved in history only; current named contracts under V3 §5.7.
- **Hater introduction discrepancy:** old bestiary indicated first Hater after 1:30 while approved shortened-wave schedule states **1:00**. V3 explicitly uses **1:00**, matching the newer wave directive rather than silently retaining both.
- **Visual targets:** current Clean Cut supersedes generic V5 panel/card styling, not original approved hero/world masters. Pending **rendered final owner acceptance** remains explicit.
- **Historical art said missing:** exact previously approved 19 originals, 37 icons, 84 UI resources are now inventoried and linked, with future-only passive visuals distinguished.
- **Legacy acceptance score:** 85/100 PoC target and old native platform gates are not M0/M1 PR blocking requirements. M0 visual quality remains a separate delivery condition despite passing tests.

## Coverage and consistency checks

The proposed GDD should retain these stable IDs, **not promote future content by mentioning it**:

- **Hero IDs (9):** `sigma`, `nerd`, `six-seven`, `cool-kid`, `ohio`, `rizzler`, `alpha`, `fanum`, `beta`.
- **Weapon IDs (9):** `ratio-blaster`, `no-cap`, `brainrot-feed`, `keyboard-warrior`, `ban-hammer`, `touch-grass`, `cope-shield`, `chad-hands`, `personal-space`.
- **Passive IDs (28):** cross-check V3 §5.10 against `docs/art/icon_approvals.json` and the untouched original V2 §9. Five currently unoffered IDs: `get-ratiod`, `ego-check`, `uno-reverse`, `brainrot-rain`, `take-l`.
- **Enemy IDs (11):** `npc`, `hater`, `reply-goblin`, `beta`, `ratio-ram`, `doomscroller`, `hype-bot`, `fanum-leech`, `ping-sniper`, `copium-puffer`, `comment-mod`.
- **Fixed events (4):** Reply Guy, Mod Supremo, Ohio Express, Doomscroll Prime.

**Do not claim gameplay parity from this documentation alone.** Gameplay runtime files are unchanged by this PR; if a reviewer finds a discrepancy between current approved rules and V3 English rendering, correct the documentation *before* merge without silently changing the game.

## Open decisions deliberately not invented

- Which backend service/provider/hosting, data retention, authentication boundaries, privacy and consent requirements, and costs are authorized for M1.
- The exact prompt copy/frequency/categories/data schema/moderation UX for tester feedback.
- The complete approved visual implementation of **every** screen and the specific artwork whose previously granted approval may have been revoked: reconcile by exact version/hash and real owner review.
- Final creator acceptance of M0 gameplay fluency, full-run quality and integrated Clean Cut appearance.
- M2 native platform lineup, priorities, signed packaging and release timing.
- Future content/solo balance changes, if suggested by genuine testing.

## Documentation-only PR validation

- Confirm original archived GDD matches the original Git blob hash.
- Confirm all 9 hero, 9 weapon, 28 passive and 11 enemy stable IDs are represented.
- Review all approved initial game numeric clauses against the V2 archive and already approved later decisions.
- Confirm M0 backend is **not** required; M1 Web + Discord Activity + backend + in-game tester feedback **is** required.
- Confirm no runtime scripts, scenes, exported art assets, source hashes, save migration, Phaser code, cost commitments or automatic releases are in the PR.
- Run required repository checks, record outcomes on the exact PR commit, and request owner approval. A merged register PR #74 must precede this stacked consolidation PR unless the base is explicitly retargeted and conflicts are resolved.
