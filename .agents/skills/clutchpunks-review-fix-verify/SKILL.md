---
name: clutchpunks-review-fix-verify
description: Independently review authorized CLUTCHPUNKS changes, verify concrete findings, and conditionally repair with tests while preserving canonical governance.
---

# Review, fix and verify

- Capture the exact SHA, changed files, task criteria, affected gameplay/contracts, and relevant source of truth before reviewing.
- Prefer a fresh `clutchpunks-reviewer` with isolated context; otherwise explicitly disclose that independent review is unavailable. The reviewer is read-only and should examine connected callers, persistence, RNG, assets and tests, not only the diff.
- Record only findings with an actual failing case or objective risk; give severity, file location, minimal remedy and impact.
- A review request alone does not authorize fixes. Repair only within the creator-authorized scope, on a dedicated branch, for a maximum of three bounded rounds. Re-review if the snapshot changes.
- Run appropriate tests, never fabricate results. Distinguish manual gameplay, automated normal runs, synthetic QA scenarios and performance fixtures.
- External Greptile/Context7/browser requests, installation, authentication, comments and PR pushes are opt-in and subject to project governance; never auto-start hosted review loops.
- Finish with findings, exact verification evidence, untested dimensions, risks and decisions awaiting creator approval. No automatic merge or deployment.
