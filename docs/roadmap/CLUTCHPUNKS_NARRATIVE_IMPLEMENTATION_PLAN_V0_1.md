# CLUTCHPUNKS — Narrative & Website Implementation Plan v0.1

**Date:** 1 November 2026
**Status:** Planning proposal; no runtime code, external web deployment, public alpha or new playable map authorized.
**Source of truth:** [GDD V3.0](../GDD.md) for every gameplay, art approval, engine, milestone and persistence contract.
**Inputs:** [World Bible](../narrative/CLUTCHPUNKS_WORLD_BIBLE_V0_1.md) · [Season 01 Bible](../narrative/SEASON_01_THE_FEED_IS_BROKEN_V0_1.md) · [Brand](../brand/CLUTCHPUNKS_BRAND_DIRECTION_V0_1.md) · [Chapter 00 Website](../web/CHAPTER_00_WEBSITE_EXPERIENCE_V0_1.md).

## 0. Delivery strategy and boundaries

**Goal:** Establish CLUTCHPUNKS as a coherent, extensible narrative brand without slowing the existing M0 visual/combat recovery. Build the story and documentation **first**; after creator approval, build the Chapter 00 website as a separate reviewable deliverable; later add non-invasive story presentation to the approved Ruin Alley run; treat Chapters 02–05 as future proposals requiring their own GDD-approved gameplay specs.

**Never assume** a new season means a paid season pass, hidden retention economy, account requirement, live service backend or time-limited removal of prior chapters.

### Workstreams

| ID | Workstream | Current target | Release boundary |
| --- | --- | --- | --- |
| N0 | Narrative canon review | World/Season 01 bibles, reveal policy, copy | Docs only |
| B0 | Brand identity | Original CLUTCHPUNKS wordmark, emblem, applications | Art candidate approval only |
| W0 | Website MVP | Chapter 00 static-first narrative portal | Protected preview, then separately approved public teaser |
| G0 | Game narrative touchpoints | Optional banners, boss voice-line UI, post-run teaser | Separate Godot PR; no combat or save changes |
| F0 | Future level design | Levels 02–05 narrative briefs to full gameplay GDD contracts | M2+ / separate creator authorization |
| O0 | Operations and release | Naming checks, DNS plan, marketing copy, tests | No publication without explicit owner launch decision |

## 1. Phase A — approve the narrative before implementation

**Task A1 — Creator narrative review**
- Confirm story thesis, attention/echo/memory rules and comedy-vs-mystery intensity.
- Approve Season 01 chapter arc, Ruin Alley post-victory sting and Crown Court reveal.
- Confirm future location names are placeholders or replace them.
- Decide whether the season finale has a named villain and how much the website may spoil.
- Confirm appearance-specific voice has no independent lore/playable kit.
- Record each choice in the GDD / narrative decision trail with a date and exact approved source revision.

**Task A2 — Editorial canon pass**
- Mark every phrase as **approved canon / editorial candidate / future concept / spoiler**.
- Verify exact spelling of hero, weapon, Flex, pickup, encounter, map and phase names against GDD.
- Resolve the ambiguity between **Season**, **Chapter** and **playable Level**.
- Freeze a complete English Chapter 00 script and an accurate three-kit/six-appearance hero matrix.
- Maintain a lore glossary and a chronology/continuity matrix.

**Acceptance:** One creator-reviewed canon map; zero contradictions with GDD; a clear spoiler policy; all unapproved expansions visibly marked.

## 2. Phase B — identity and art candidate package

**Task B1 — Brand discovery and clearance**
- Evaluate exact **CLUTCHPUNKS** mark, close spellings and visual similarities in relevant territories/classes.
- Check search/store/community handles and domains (Steam, app stores, social names and website domain where relevant).
- Record results, screenshots, dates and constraints; do not state trademark clearance without a qualified review.

**Task B2 — Design original logo**
- Start with **Broken Broadcast** route (see Brand Direction), plus one Crew Mark alternative.
- Deliver editable wordmark master, emblem, color/mono variants, clearspace, typography provenance and license records.
- Render at 32, 64, 320 px, desktop title and mobile. Preview with **current approved** hero cutouts and Clean Cut references.
- Maintain side-by-side comparison with the last approved runtime logo; avoid an automatic wordmark overwrite.

**Task B3 — Art acceptance**
- Exact files, hashes, source/master provenance, review images and creator verdict.
- Distinguish accepted marketing logo from any separate in-game runtime wordmark supersession.
- Do not replace pinned actor masters, game icons or UI assets.

**Acceptance:** Creator exact-source approval for selected brand assets, verified rights/provenance and readable screen applications. No unsupported claim that a concept mockup is production art.

## 3. Phase C — build Chapter 00 website in small reviewable PRs

**Architectural recommendation:** A lightweight **static-first** narrative site with componentized content, versioned English copy and no mandatory backend. Choose framework/hosting only after checking the existing Vercel/Godot deployment separation and owner preference. Do not couple website builds to Godot's expensive Web export.

**Suggested PR sequence:**

| PR | Scope | Evidence / acceptance |
| --- | --- | --- |
| W-01 | Standalone site skeleton, semantic navigation, content model and private preview | Build, 404 handling, no public gameplay URL, baseline keyboard/mobile checks |
| W-02 | Approved CLUTCHPUNKS brand tokens and Chapter 00 visual compositions | Creator-approved sources, responsive screenshots, alt text, provenance |
| W-03 | Full English story sequence, feed cards, signal interruption and hero selector | Accurate 3 kits/6 appearances, no spoiler leaks, reduced-motion and keyboard QA |
| W-04 | Archive/story routes, privacy/legal content, verified pre-public CTA | No fake functionality; functional links; private test boundary preserved |
| W-05 | Security/performance/launch review | Link audit, no unapproved analytics/scripts, review of static hosting and actual mobile browsers |

**Implementation constraints:**
- Use URL paths and content records separated from visual components; represent future chapters as **unpublished**, not publicly discoverable draft pages.
- Avoid using a fake live player count, fake comments or fabricated real-world news.
- Copy should be stored in editable source records, not baked into flattened images.
- Preserve usable static HTML reading order and respect reduced motion.
- Avoid publishing spoilers in metadata, open graph cards, sitemap, JSON payloads or filenames linked publicly.
- Source artwork through manifest/approved hashes, not improvised art copies.
- Verify the public play CTA **against real deployed access** at release time. The current M0 game remains invitation-only; a public website **must not** accidentally expose it.
- Keep Web game origin and \`aura-farmer:profile:v2\` data stable. Domain changes need a separate migration design and save tests.

**Acceptance:** Story is understandable without animation/sound, looks unmistakably CLUTCHPUNKS, works on mobile, and cannot impersonate a public game release while M0 remains closed.

## 4. Phase D — add narrative touchpoints to the existing game only after review

This phase is **not** part of the docs-only PR and is subordinate to M0's actual visual polish and performance work.

**Proposed narrowly scoped game PR G-01**
- Authorize only approved, localized-capable, optional **phase-entry/boss-intro/result** narrative text.
- Bind timing to actual authoritative game events; never drive gameplay from narrative animation timers.
- Respect priority of warning geometry, health/XP/Aura, joystick, Flex, upgrade and Legendary selection UI.
- Keep consistent with the chosen original/female appearance; no new hero IDs, stats, equipment, targeting or hitboxes.
- Keep no-motion/low-effects alternative with identical information.
- If a post-victory sting is added, show it only for a **true** victory, after normal result/save settlement; no accidental result edits.

**Testing:** seed-deterministic gameplay parity, unit/integration tests for true win/defeat/retry, no new pause or focus regressions, actual browser recordings desktop/mobile, visual signoff and negative tests around low HP/overlapping boss warnings.

**Do not:** alter 5 × 120 s waves, four fixed event clocks, 10:00 Big Hater entry, 120 s Berserk, balance, or approved Godot assets without a separately approved game GDD change.

## 5. Phase E — plan later levels as gated expansions, not implicit Season 01 delivery

For **each** proposed playable Level 02–05, require its own creator-approved design intake:
1. **Narrative purpose:** chapter goal, reveal, character decision and permanent story consequence.
2. **Map contract:** approved location, navigable geometry, art masters, cover, interactables and hazard rules.
3. **Run contract:** explicit target duration, wave/event timing, XP/Aura/Flex handling, difficulty progression, starting loadout, inventory, rarity and win/defeat policy.
4. **Enemy/boss contract:** stable IDs, telegraphs, pattern clocks, hit rules, stats, loot/rewards, deterministic tests and balance validation.
5. **Selection/progression:** how the player chooses levels, what content unlocks, compatibility with saved records, legacy IDs and existing Ruin Alley replay.
6. **Cross-platform:** Web + Discord scope where applicable, mobile input/layout, gameplay/readability performance.
7. **Art:** creator-approved full environment, character/boss, weapons, combat VFX, HUD and story visual assets.
8. **Release:** separate milestone authorization and no claim of season-wide playable completeness before actual content is verified.

**Candidate order:** 02 Echo District → 03 Shadow Zone → 04 Signal Core → 05 The Last Broadcast. Their names and playable status are proposals. **Crown Court and Toxic Garden are not authorized M0/M1 levels.**

## 6. Release gates / no automatic deployments

| Gate | Can advance when | Must remain blocked otherwise |
| --- | --- | --- |
| Documentation | Narrative creator review; applicable checks green | Do not relabel proposed lore as accepted canon |
| Brand | Exact asset review + clearance | Do not replace current approved runtime wordmark |
| Private website preview | W-01 through W-04 usable; owner sees real page | No public publication |
| Public teaser website | Domain/brand checks, privacy/legal pass, current CTA truth, owner publication approval | No public game link to closed M0 |
| M0 closed playtest | All existing GDD M0 gates / visual signoff pass | No claim of public launch |
| M1 public alpha | GDD M1 backend, feedback, Web + Discord validation and owner release action | Do not confuse narrative website launch with M1 |
| Extra playable map | New gameplay GDD contract, creator art and integration acceptance | No implied M0/M1 expansion |

**CI green ≠ creator art approval ≠ merge authorization ≠ production deployment ≠ public release.**

## 7. Suggested small-task order for limited execution credits

1. **Docs PR (now):** narrative and site specs, GDD crossreferences, no game or website code.
2. **One focused review:** approve chapters 00/01 and precise lore red lines.
3. **Logo exploration:** two candidate lockups, then exact-byte signoff.
4. **Website W-01:** isolated skeleton and one landing screen only.
5. **Website W-02:** implement Chapter 00 narrative and approved hero cards.
6. **Website W-03/W-04:** Archive, polish, private preview and acceptance.
7. **Gameplay G-01:** only if doing so does not displace higher-priority M0 combat/character/UI recovery.
8. **Level 02 intake:** write playable design proposal and balance evidence **after** the current level is proven fun and stable; do not preload four new maps into M0.

## 8. Evidence and ownership

Every PR must declare:
- Base SHA, modified files, current approval level and why it cannot change gameplay.
- Screens/recordings at desktop and mobile breakpoints relevant to scope.
- Tests run, not run and reasons (no fabricated CI/device success).
- Asset manifests and exact hash/provenance for any promoted art.
- Explicit owner review decision and unresolved items.
- Release/publication state independently tracked.

**Open operational decisions:** brand clearance authority and markets; exact public domain; website tech/host and repository; website contact/privacy owner; logo art/version; Chapter 00 publish timing; future season cadence; character-line/localization requirements; consent if optional forms/analytics are ever added.

## 9. Definition of done for this planning phase

- [ ] Creator reviews World Bible and Season 01 arc.
- [ ] Exact accepted narrative version and status recorded in the GDD.
- [ ] Logo direction and tagline decision captured; final logo art separately approved.
- [ ] Chapter 00 content plan accepted; implementation intentionally not started by docs PR.
- [ ] Website release-state and story-vs-game separation explicitly approved.
- [ ] Future Levels 02–05 remain concept-only until separate gameplay specs.
- [ ] A clean documentation PR exists; no merge, code, backend or deployment without follow-up authorization.
