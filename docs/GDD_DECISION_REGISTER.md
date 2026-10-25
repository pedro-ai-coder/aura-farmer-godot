# Aura Farmer — Approved Owner Decision Register

**Decision date:** 25 October 2026  
**Status:** Owner decisions approved; documentation integration pending PR merge.  
**Authority:** Creator decisions of 25 October 2026. The canonical GDD remains authoritative for unchanged gameplay. This register is a companion to `docs/GDD.md`, not a new gameplay specification.

## Current decisions

| ID | Topic | Approved decision | Earlier guidance superseded |
| --- | --- | --- | --- |
| D-01 | M0 | **Web-only private test**, available to a **very restricted group**. | Browser-plus-Discord first delivery and compulsory native-first milestones. |
| D-02 | M1 | **Public alpha** through **Web and Discord**, including a **backend and an in-game feedback mechanism**. | Older text that excludes backend/Discord from the first public alpha. |
| D-03 | M2+ | **Consider** native multiplatform expansion starting at M2 or later; no native release commitment now. | The 21 October requirement to deliver Web/Android/iOS with equal priority in the first slice. |
| D-04 | Initial scope | **Sigma, Cool Kid and Alpha Chad; nine weapons; 23 offered passives; three weapon slots; five passive slots**. The nine-hero/28-passive catalog is future scope. | Section 19's full-catalog acceptance for an initial demo. |
| D-05 | Art | **Character Hype Broadcast — Clean Cut** is the current visual direction **for now**, preserving individually approved art and original identities. | Older competing UI-style targets. |
| D-06 | M0/M1 PR approval | **Approve scoped PRs after all required applicable checks/tests pass**. Failed or unrun mandatory checks cannot be described as passing. **No automatic merge or public launch** follows from green checks. | Former 85/100 score as an M0/M1 PR acceptance threshold. |
| D-07 | Session clock | Keep the latest **five 120-second waves**, final Big Hater at **10:00**, recoverable Berserk at **12:00** (two minutes after boss entry). | Historical 15-minute run/180-second waves. |
| D-08 | Engine | **Godot 4 / GDScript** is the active game codebase; Phaser remains the reference and must not be altered. | Historical Phaser/TypeScript refactor plan. |
| D-09 | Asset status | Recognize all previously approved original masters, icon PNGs and Clean Cut UI resources identified below. | Older claims that these files remain missing or unapproved. |
| D-10 | GDD restructuring | Establish this register now. A **completely restructured next GDD edition is under consideration**, not yet authorized. The existing title GDD V2.0 does not authorize replacing its content. | Any implied automatic document rewrite. |

## Milestone boundaries

**M0 — Restricted Web Test.** Web build playable by a very restricted invited group; current approved solo game slice only. No Discord distribution, public alpha, backend, feedback service, native app, co-op, PvP or monetization requirement in M0.

**M1 — Public Alpha.** Web and Discord access, **backend and in-game feedback** are required milestone capabilities. The architecture/provider, privacy and data retention, account/authentication decisions, moderation, cost authorization and implementation details remain to be specified. Do not invent backend features or a payment obligation. The roster is the same approved initial slice unless separately expanded.

**M2+ — Platform evaluation.** Android, iOS, Windows, macOS and Linux native targets, release sequence and acceptance criteria remain to be evaluated and approved. Godot export readiness does not establish a delivery commitment.

**M0/M1 PR acceptance:** applicable mandatory regression, build, integration, export and deployment checks must pass for the PR's actual scope. The owner approves the PR when those checks pass. Tests passing do not themselves grant visual quality approval, automatic merge, public publication or launch authorization. The previously proposed 60 FPS desktop, 30 FPS mobile, 300-enemy/150-projectile stress objectives and 85/100 PoC score may inform QA, but **are not standalone mandatory M0/M1 PR blockers** under this new decision unless separately approved as such.

## Existing approved art and asset inventory

| Group | Approved material | Canonical approval/source |
| --- | --- | --- |
| Original artwork | **19 pinned original character, map, enemy and animation/master resources**, retaining Option A source identities. | `assets/approved-assets.json`; GDD Annex A. |
| Weapons | **Nine approved icon PNGs:** eight V5 exact-byte icons plus **Touch Grass Clean Cut v2**. | `docs/art/CREATOR_ICON_APPROVAL_2026-10-24.md`; `docs/art/icon_approvals.json`; `assets/runtime-icons/manifest.json`. |
| Passives | **28 approved icon PNGs**, of which **23 are offered/playable**; five future-only artworks do not unlock gameplay content. | Same icon approval and manifest. |
| Clean Cut UI | **Five approved corrected screen compositions** (Main Menu, Hero Selection, Gameplay HUD, three-card Upgrades, six-card Legendary), integrated with **84 approved immutable runtime resources**. | `docs/art/CREATOR_CLEAN_CUT_V2_APPROVAL_2026-10-24.md`; `assets/runtime-clean-cut/v2/manifest.json`; PR #71. |

The exact source hashes and approved versions in those ledgers control promotion; later variants or unspecified newly polished images are **not automatically approved**. The old diamond joystick design and earlier generic screen variants do not supersede corrected Clean Cut.

## Unchanged gameplay and non-approvals

- Current canonical signature Flexes: Sigma **Deadpan Verdict**, Cool Kid **CTRL + CHAOS**, Alpha Chad **Giga Chad Rampage** (GDD 7.2).
- Approved recovery P1 Street Snack, P2 Aura Magnet (collect existing XP only), P3 Safe Spot; preserve deterministic Phaser parity, IDs, saves, Aura, rarity and equipment limits.
- Full-playfield **circular floating joystick**, with actual interactive UI priority and independent Flex touch, remains approved.
- P4–P7: **isolated prototype concepts only**, not approved normal gameplay. P8: **not approved**. The two static map covers are not destructible crates.
- No new balance, new gameplay feature, unapproved artwork, Phaser changes, store launch or paid service is authorized by this register.

## Historical sections to reconcile in a future GDD PR

- GDD introduction, sections 0/17/19/23 and Annex B: Phaser refactor, first-demo content and compulsory cross-platform first delivery.
- GDD sections 5/10/12 and old artwork examples: 15-minute schedule and obsolete Flex names; retain only as explicitly historical records.
- GDD section 26 and Annex A: Clean Cut as current UI authority, while original Option A actors/world and exact approved art hashes remain intact.
- GDD Annex C: current joystick and recovery contract take precedence over older proposals.
- Repository README and development guidance: milestone platform priority and PR acceptance need alignment.

## Decisions still open

1. M1 backend data model/provider, operational/security/privacy architecture and any new costs.
2. M1 in-game feedback workflow, storage, consent, moderation and access policy.
3. Exact public alpha release authorization, communications and operational readiness checks.
4. Whether to introduce additional measurable M0/M1 performance gates.
5. Native platforms and timelines from M2 onward.
6. Full GDD rewrite structure/name and any precise future art substitutions.

**Precedence:** owner decisions dated 25 October 2026 supersede contradictory historical *delivery or acceptance* text. All other gameplay rules in the canonical GDD continue unchanged.
