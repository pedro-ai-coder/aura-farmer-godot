# CLUTCHPUNKS — Chapter 00 Website Experience v0.1

**Working title:** THE INCIDENT
**Status:** Narrative/UX implementation specification for creator review; **not an authorization to deploy or publicly publish**.
**Date:** 1 November 2026
**Narrative:** [Season 01 Bible](../narrative/SEASON_01_THE_FEED_IS_BROKEN_V0_1.md).
**Brand:** [Visual Direction](../brand/CLUTCHPUNKS_BRAND_DIRECTION_V0_1.md).
**Canonical game:** [GDD V3.0](../GDD.md).
**Delivery concept:** A public-facing standalone static-first narrative website, not a replacement for the existing Godot Web application.

## 1. Experience north star

A visitor opens what appears to be a neighborhood live feed. The feed becomes increasingly unreliable, turning into an original short visual mystery. The visitor meets the selectable hero identities, discovers why Ruin Alley matters and receives one honest call to action appropriate to the game's actual rollout state.

**Primary goal:** communicate the game's world and character personality clearly enough to make the visitor want to follow and eventually play.
**Secondary goals:** provide lore accessibility, optional Archive, responsive marketing home for future seasons, and separation of narrative publication from game milestones.
**Not goals (v1):** player accounts, in-game persistent quests, battle pass, seasonal rewards, fake livestream user counts, monetization, comment posting, hidden data collection, real-time chat, simulated social proof, or new backend.

## 2. Visitor flow

**Landing -> Incident reveal -> Meet the heroes -> Ruin Alley -> Intercepted signal -> Correct CTA -> Archive/return**.

Suggested starting sections:

1. **Global masthead:** CLUTCHPUNKS logo (candidate until exact asset approved), "SEASON 01 / THE FEED IS BROKEN", chapter indicator and accessible navigation.
2. **Hero / first signal:** Strong original illustration of the city and an English headline: "THE WORLD WENT VIRAL. THEN IT WENT WRONG." Visible "Explore the Incident" action.
3. **Feed fragments:** Three short clearly fictional posts with dates/times in an in-world design, evolving from mundane to impossible. No impersonation of existing platforms or real accounts.
4. **First interruption:** A static/glitch-composition reveal, conveying text even with motion disabled: "THE SIGNAL IS COMPROMISED."
5. **Meet the Clutchpunks:** Three **canonical gameplay kit cards**, each with original/female appearance previews; starter weapons and Flex names must match the GDD; selected presentation can switch without implying six game kits.
6. **Ruin Alley:** Approved background/setting identity, short survival hook; avoid promising a multi-map world in M0/M1.
7. **Intercepted transmission:** A short, accessible story beat. Do not spoil the Chapter 01 Big Hater outcome or Season 01 Crown Court reveal.
8. **Call to action:** Show the **actual** authorized public play / private test / future availability state. Never implement an inactive "Join" or "Play" button that looks functional.
9. **Archive:** Optional curated reading area for already-public chapters, with clear spoiler levels and no account requirement.
10. **Footer:** project/game name, legal/privacy/contact entries when published and actual verified platform links.

## 3. Proposed v1 original English script

### Opening

**Eyebrow:** "SEASON 01 / CHAPTER 00 — THE INCIDENT"
**H1:** "THE WORLD WENT VIRAL. THEN IT WENT WRONG."
**Body:** "In Ruin Alley, posts don't stay on screen. Comments hit back. People remember different versions of the same street. And the Feed keeps insisting everything is fine."
**CTA:** "INTERCEPT THE SIGNAL"

### Feed card one — quiet anomaly

**Category:** "LOCAL UPDATE / RUIN ALLEY"
**Headline:** "One clip. Two timestamps."
**Body:** "A routine street camera uploaded the same moment twice. The second upload shows something standing where nothing was."

### Feed card two — impossible reaction

**Category:** "UNVERIFIED REPORT"
**Headline:** "A comment left a mark."
**Body:** "Witnesses say an argument turned physical. Not the people in it — the words."

### Feed card three — missing record

**Category:** "ARCHIVE ERROR"
**Headline:** "This street was here yesterday."
**Body:** "The city map says the block never existed. Residents disagree. The Feed has marked the case as resolved."

### Incident break

**Eyebrow:** "SIGNAL INTERRUPTED"
**Title:** "THE FEED IS BROKEN."
**Body:** "Every reaction makes the noise louder. Someone has to break the loop."

### Heroes introduction

**H2:** "THREE WAYS TO BREAK THE FEED."
**Intro:** "Pick your style. Keep your identity. Don't play by their rules."
**Three cards:**
- "THE SIGMA / PIXEL VIXEN" — "Ranged / No Cap / Deadpan Verdict" — "Find the pattern. End the argument."
- "COOL KID / BYTE BADDIE" — "Melee / Keyboard Warrior / CTRL + CHAOS" — "Change the rules faster than they can rewrite them."
- "ALPHA CHAD / BLOCK QUEEN" — "Tank / Cope Shield / Giga Chad Rampage" — "Hold the line. Give everyone else a chance."

All values are **descriptive** only; do not invent distinct female stats, unlocks or abilities.

### Final interception

**System line:** "LOCAL FEED: UNSTABLE."
**Unknown transmission:** "Ruin Alley is still transmitting. If you can hear this, don't trust what comes next."
**Closing headline:** "SOMEONE JUST WENT LIVE."

### Gated call to action: three truthful variants

- **Pre-public-play (website is public; only restricted M0 testing):** "THE SIGNAL ISN'T OPEN YET" with optional "ABOUT THE GAME" or an actually managed contact/announcement route. Do **not** surface invite-only game builds or fabricate a waitlist.
- **Authorized restricted access flow:** "OPEN YOUR TEST INVITATION" only when a genuine private authorized URL and access policy exists; public visitors see the non-play variant.
- **M1 public Web launch explicitly authorized:** "ENTER RUIN ALLEY" using verified URL; offer separate Discord entry only after SDK/back-end approval, live QA and actual public access.

**No backend by default:** If announcement subscription cannot be delivered privately and compliantly with approved infrastructure, provide simple real external channels or no subscription control at all.

## 4. Interaction requirements

- **All content accessible without JS:** main narrative appears in reading order, server/static HTML. Enhancements may decorate but must not gate facts.
- **Motion opt-in/equivalent:** CSS transitions optional, restrained, and disabled via reduced-motion. The "incident" text still appears in the default reading experience.
- **Appearance selector:** one of three gameplay kits remains selected, with a two-option visual toggle on each kit or a six-option gallery that visibly groups the paired kits. No unlabeled icon-only control.
- **No forced scroll-jacking, no autoplay sound, no fake live interaction, no manipulative countdown, no invisible navigation, no fake player stats.**
- **Keyboard/touch:** real focus states, sensible touch hit areas, semantic links and accessible buttons; gesture alternatives.
- **Localization-ready:** English copy in structured content records rather than baked into composite images, with future translations possible.
- **Privacy:** no analytics, tracking pixels, remote fonts or third-party embeds by default; any optional measurement requires explicit privacy/cost approval.
- **Safety and accuracy:** posts are clearly fictional in-world material; do not use real platform brands/trademarks/identities as if they endorse the game.

## 5. Information architecture — MVP vs growth

| URL route (illustrative) | MVP content | Later content / gate |
| --- | --- | --- |
| `/` | Hero, Chapter 00 story, CTA | Dynamic current-season feature after approvals |
| `/story` | Season 01 Chapter 00 reading page | New public chapter releases with spoiler tags |
| `/heroes` | Three kits / six appearances, canonical skill labels | More hero content only when GDD rollout approves it |
| `/world/ruin-alley` | Approved setting, safe non-spoiler context | Expanded lore/media after owner review |
| `/archive` | Published in-world transmissions, chronology | Future chapters and past seasons |
| `/play` | Real availability explanation and only authorized URL | Public game + Discord links after M1 gates |
| `/legal` | Required disclosures and accurate policies | Platform-specific requirements as launch evolves |

Routes are **proposals**, not live assets or a confirmed domain.

### Content structure for scalable chapters

Store content as versioned records with fields such as:
- `id`, `season_id`, `chapter_id`, `slug`, `title`, `summary`
- `publication_status`: draft/review/approved/published
- `spoiler_level`: none / chapter1 / future / finale
- `canonical_basis`: GDD approved vs editorial proposal
- `blocks`: heading, paragraph, quote, illustration reference, visual interruption
- `art_asset_ref`: approved hash/source where required
- `published_at` only after actual publication, with clear archival dates

**Do not** treat this content schema as a mandate for a CMS, database or user account. A static JSON/Markdown content collection is enough initially.

## 6. Visual direction and responsive wireframe

**Desktop 1440 px:** asymmetrical poster composition; strong logo/masthead; dominant illustrated hero or environment; tight ink typography; editorial feed fragments. The interface must be visually distinct from a web dashboard.

**Mobile 390 px:** one-column reading flow; readable heading, concise copy, no critical item hidden behind scroll effects; hero art cropped only after manual review; buttons easy to tap; reduced decoration under constrained bandwidth.

**Design tokens:** start with canonical Clean Cut style/language and existing approved core palette and source art. Brand exploration may test a fresh CLUTCHPUNKS logo but must not pass off a generated concept as approved runtime art.

**Asset approval:** website art is a separate context. Existing game masters/approved art may be referenced/reused only with proper provenance/license, original identity, accurate hashes and deliberate composition. Proposed new environmental/hero imagery needs explicit source-by-source creator review, even for marketing.

## 7. MVP delivery / acceptance

### Editorial
- Chapter 00 has coherent beginning, escalation and hook, consistent with Season 01 bible.
- Does not spoil Chapter 01 victory or the Crown Court season reveal.
- Three canonical hero kits are accurate, six appearances visibly grouped.
- All current lore proposals visibly remain drafts until the creator signs off.

### Product
- Every visible action performs a real function. The pre-public state does not offer public play.
- All website copy reads in English and is localization-ready.
- Responsive captures at 1440×900, 1280×720, 915×412, 390×844.
- WCAG-aligned semantic document structure, keyboard operation, visible focus and reduced-motion behavior.
- Respect content security policy, secure headers, cache integrity and a browser-safe Web build separation.
- No mandatory account, backend, telemetry, cookie banner theatrics or payment infrastructure.
- Verified domain and trademark clearance is a pre-public-branding checkpoint, not assumed.

### Integration
- Website deployed to separate **protected preview** before any public publication.
- Any game link points to an actual approved accessible Web build; restricted M0 URL never leaked publicly.
- Avoid migrating the game's origin/localStorage key; existing `aura-farmer:profile:v2` and export/import behavior remain untouched unless a separate approved migration guarantees user data preservation.
- New public gameplay exposure remains gated by M1 checks and explicit owner authorization.

## 8. Implementation decisions pending

1. Choose site host and repository placement (separate website repo versus isolated app folder) after architecture review.
2. Choose static rendering stack suitable for performance, accessibility, clear content versioning and deployment workflow.
3. Set public domain, brand/trademark review and email/contact ownership; nothing is assumed available.
4. Define signoff authority, chapter editorial review and approved source-art registry.
5. Approve launch-state CTA wording based on actual M0/M1 status, and no sooner.
6. If new analytics, forms, newsletter, personalized content or remote audio are ever proposed, specify privacy/security/cost/consent before implementation.

**No build, public website, DNS changes, game source edits or production deployments are authorized by this specification alone.**
