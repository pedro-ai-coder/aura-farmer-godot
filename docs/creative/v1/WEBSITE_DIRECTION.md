# Chapter 00 — website creative direction

**Design specification only. No site is built or published by this package.** Develops the [PR #100 experience](../../web/CHAPTER_00_WEBSITE_EXPERIENCE_V0_1.md). All copy below is proposed English editorial content.

## The experience

An original illustrated incident dossier interrupts the ordinary account of Ruin Alley. The visitor moves from an impossible detail to a recognizable hero, then to one truthful next action. It must be visibly part of a fictional game world from the opening frame; do not trick visitors into believing a real local emergency is unfolding.

**Opening desktop composition:** shallow masthead with the permanent mark at left, Story / Heroes / Availability at right. Below: approximately 55% typographic space and 45% approved hero/environment art. Offset a single paper witness slip into the image boundary. Avoid a dashboard of equal cards. Keep the CTA in the text region, away from faces and props.

**Mobile composition:** wordmark, season/chapter metadata, headline, concise copy, “Read the Incident,” then artwork. No text baked into background imagery. Hero groups stack in the same reading order. A visitor should understand the premise and current availability before encountering optional decoration.

## Storyboard and copy

| Beat | What the visitor sees | Copy / real action | Visual treatment |
| --- | --- | --- | --- |
| 1 / Arrival | Logo, Season 01 / Chapter 00, fictional-world label | **A COMMENT LEFT A MARK.** “In Ruin Alley, the noise is getting physical. The Feed says nothing happened.” / **Read the Incident** anchors to the story | Open-counter framing; approved art at right |
| 2 / Contradiction | Two conflicting records of one street | **ONE CLIP. TWO TIMESTAMPS.** “The second recording shows something the first one doesn't.” | Paper/ink evidence pair; no platform chrome |
| 3 / Escalation | Witness report and an impossible correction | **THIS STREET WAS HERE YESTERDAY.** “The map disagrees. The people who live there don't.” | A single missing line; whole text also accessible |
| 4 / Interruption | The seasonal statement | **THE FEED IS BROKEN.** “Every reaction makes the noise louder.” | One clean cut; no flicker or forced animation |
| 5 / Response | Three paired kit portraits | **THREE WAYS TO HOLD YOUR GROUND.** “Choose your appearance. Keep your kit.” | Distinct silhouettes with literal class labels |
| 6 / Destination | Ruin Alley identity and current solo scope | **RUIN ALLEY IS STILL TRANSMITTING.** “A solo action-survival run. A street full of trouble. Big Hater waiting at the end.” | Approved environment reference; no new map |
| 7 / Intercept | Unknown transmission | **SOMEONE JUST WENT LIVE.** “Don't trust the first version of the story.” | Quiet final paper strip, no finale spoiler |
| 8 / Availability | Actual release state | Current public-visitor proposal: **Closed playtest. Public access is not available.** / **About the game** | Literal status panel; no misleading disabled play button |

The Chapter 00 arrival copy is a proposed refinement of the longer v0.1 headline. It leads with a concrete impossible event rather than another generic “world went wrong” line. Editorial approval remains open.

## Hero presentation

| Group | Appearance options | Fixed gameplay description |
| --- | --- | --- |
| Ranged | The Sigma / Pixel Vixen | No Cap · Deadpan Verdict |
| Melee | Cool Kid / Byte Baddie | Keyboard Warrior · CTRL + CHAOS |
| Tank | Alpha Chad / Block Queen | Cope Shield · Giga Chad Rampage |

Use a labeled two-option control per kit, with visible selected state and keyboard operation. Static/no-JS fallback shows both named portraits in each group. Switching presentation does not change mechanics, reveal exclusive lore or imply new unlocks. Only approved source art is eligible for actual implementation. The generated application board is a composition concept, not hero source art.

## Availability truth table

| Verified release state | Public visitor | Invited tester | Required evidence before enabling |
| --- | --- | --- | --- |
| Current M0 scope / closed test | About the game; Read the Incident | Test entry only through an actual authorized private invitation flow | Correct restricted URL and access policy, never embedded in public HTML |
| No valid invitation destination | Same informational actions | Explain that invitation access is unavailable | No fake join form or simulated success |
| Public teaser approved, game still closed | Story only, literal closed-test notice | Existing separate private flow | Explicit teaser publication approval |
| M1 public launch authorized | Enter Ruin Alley; Discord only if independently ready | Same public entry | Real live URLs; backend/feedback/Web/Discord validation and owner launch authorization |

The current published build and its access controls were not exercised in this creative task. The proposed CTA follows the GDD's restricted scope, not an assumption of public availability. Reverify the real state at implementation and publication.

## Interaction, accessibility and boundaries

Use semantic static HTML and live copy. Reading order works without JavaScript, sound or motion. Proposed controls have 44 px touch targets, visible focus and descriptive labels. Verify contrast in the finished build; support text enlargement. Do not hide plot information in hover-only elements or force scroll-jacking. Reduced motion displays the final state immediately.

No forms, accounts, analytics, remote fonts, fake chat, counters or paid services are required. “Read” links navigate; they never pretend to join a test. The Archive contains only accepted, published material. Future chapter drafts and finale spoilers stay out of public bundles and metadata.

The website remains separate from the game's runtime and hosting origin. No rename of save keys, repository, project identifiers or game URLs is part of brand presentation. A website preview and a public game release require different approvals.
