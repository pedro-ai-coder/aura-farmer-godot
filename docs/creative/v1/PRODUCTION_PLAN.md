# Production plan — direction to reviewed implementation

**Planning estimates, not dates or delivery commitments.** One focused artist/designer and one engineer as needed; creator review latency excluded. No downstream work is implicitly authorized by this plan.

## Order and gates

| Step | Deliverable and owner | Effort estimate | Dependency / exit evidence |
| --- | --- | --- | --- |
| 1 / Direction decision | Creator selects one logo route and editorial premise | One focused review | Exact board/revision recorded; remaining routes archived |
| 2 / Lettering reconstruction | Designer draws custom curves, emblem and mono master | 2–4 person-days | Font-free editable SVG; optical spacing; 16/32/64 px emblem and 240/320 px name tests |
| 3 / Brand proof | Designer applies selected exact art to existing approved heroes and title composition | 1–2 person-days | Desktop/mobile contact sheets; contrast, crop and silhouette review; hashes |
| 4 / Editorial freeze | Narrative lead revises Chapter 00 and Season 01 after decisions | 1–2 person-days | Approved copy revision; spoiler inventory; present/future labels |
| 5 / Website structure | Engineer builds isolated static content and truthful CTA logic | 2–3 person-days | Build and links; no backend; no closed-build URL in public output |
| 6 / Website composition | Designer/engineer integrate approved art and paired appearance controls | 2–4 person-days | 1440×900 and 390×844 plus landscape; keyboard/no-JS/reduced-motion evidence |
| 7 / Private review | QA performs story, accessibility, source and availability review | 1–2 person-days | Actual protected preview only after separate authorization; no public release |
| 8 / In-game proposal | Game engineer scopes optional approved title/intro/result presentation | Separate estimate | M0 priorities protected; event binding and gameplay parity contract |
| 9 / Future chapter intake | Product/design write one new level contract at a time | Separate estimate | GDD decision for mechanics/map/boss/assets before implementation |

Steps 2–4 may share review materials but should not multiply logo variants indefinitely. Select one route, resolve its core geometry, then compose. A more polished poster cannot fix weak lettering.

## Work breakdown and scope ownership

**Docs only:** brand specification, proposed season outline, Chapter 00 script, decision ledger and spoiler policy. The canonical GDD changes only after a concrete owner decision requires it. This package adds companion documents instead of rewriting gameplay authority.

**Visual prototypes:** three boards, selected-route applications, reconstruction tests and source manifests. Keep review art outside runtime paths and export inclusion. Preserve exact approved character bytes. Generated illustrative approximations must never be promoted as existing hero art.

**Website work:** separate scoped PRs for structure/content, approved art/controls, and validation. Select repository placement/host during architecture review. Default to static content; no CMS or backend is needed. A functional site should be built through the website workflow only when commissioned, not smuggled into a creative-documentation PR.

**Later game presentation:** a narrow Godot PR may propose a new title wordmark, optional intro and true-victory sting. It must specify approved hashes, preserve existing controls, bind to actual events, and prove save/result behavior unchanged. No mandatory dialogue during combat and no replacement of M0 combat recovery priorities.

## Review decisions that unblock work

1. Select A, B or C. Recommended: A, with one intervention and an emblem less dependent on a generic CP monogram.
2. Accept or revise “Keep your shape” and the physical-comment opening.
3. Accept the proposed attention/memory rules, unseen finale operator and Crown Court hook as editorial direction, without approving new gameplay.
4. After reconstruction, approve exact master/export hashes separately from the overall direction.
5. Authorize website implementation and protected preview separately; public teaser publication is a later gate.

## Quality gates

| Gate | Pass evidence | A pass does not mean |
| --- | --- | --- |
| Creative review | Creator selects exact route/revision and copy | New art is production approved |
| Asset readiness | Editable curves, accurate spelling, mono/min-size proof, source provenance | Trademark exclusivity or runtime acceptance |
| Name/mark review | Documented collision research and qualified clearance as appropriate for intended markets | Domain ownership or publication authorization |
| Website QA | Real links, accessible controls, valid release state, approved source art | Game publicly launched |
| Runtime integration | Applicable CI and real Godot/Web evidence, unchanged gameplay/save behavior | New map or balance approval |
| Publication | Owner authorizes exact site/build after release checks | Automatic future deployments |

## Branch and review strategy

This package starts from the PR #100 head `f7d1794fa64253422806ebbb1351342bba88b93f` on `docs/clutchpunks-creative-direction-v1`. Target the foundation branch in a stacked draft PR so the creative diff is reviewable without duplicating the eight foundation documents. Keep PR #100 untouched. Once the foundation is approved and merged, rebase/retarget with authorization under the repository workflow; do not merge either PR automatically.

The existing Godot CI does not target this foundation branch and skips ordinary drafts. Record that as **not run**, never green. No workflow edits or paid runs are needed to manufacture validation for a documentation/art package. Before eventual merge, retargeting and applicable repository checks remain required.

## Risks and mitigations

- **Logo looks technological rather than characterful:** test mono lettering beside exact approved characters before refinement is accepted.
- **Generated mark changes between applications:** treat application boards as composition proposals; reuse one reconstructed master in real production.
- **Narrative overwhelms current scope:** every chapter row has status; only Ruin Alley maps to current gameplay.
- **Spoilers leak through implementation:** audit static data and share metadata, not just rendered views.
- **Brand work distracts from M0:** reserve game implementation for a later scoped task after combat/character/UI priorities.
- **Six portraits imply six classes:** group the two appearances under each canonical kit everywhere.
