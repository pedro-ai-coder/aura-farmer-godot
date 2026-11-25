# No U Reverse Impact V2 — append-only AI action audit

Status: EXPERIMENTAL — NOT CANONICAL — NOT APPROVED FOR PRODUCTION.

## 2026-11-25 · inspection and implementation

- Read the creator brief, contributor guidance, relevant routing contexts, canonical V3 No U table, creator Six → Seven V3 approval, passive VFX audit/style/architecture, V1 source/tests/capture/export tooling, and Draft PR #162. Authenticated connector login: `pedro-ai-coder`. Git author and committer: `pestrela@proton.me`.
- Clean V1 `be7f478946f21fa190efd34bc3107603ef209ddf`; production baseline `1c2ec76cd06d6f1485a79fbbee97ccfac70ac5c8`. Created separate worktree/branch `experiment/no-u-reverse-impact-v2`. Existing worktrees and V1 evidence preserved. No dedicated local art/animation/token-efficiency skill maps were found in the available catalog/routing. Used existing native renderers and QA infrastructure, plus the Vercel deployment skill.
- Implemented review-only positive HP-loss/survival hook, initially ready acquisition, 15 s successful-activation cooldown, reentrancy/time guards, actual damage/weaken snapshots, directional incoming wedge, paired reversal chevrons, exact 200 U edge, effective HP-loss X, broken-attack/down-arrow weaken marks, expiry, and ready/recharge caption. No art assets, dependencies, paid services or RNG calls added.
- Garage A/B/C selection plus Normal/Dense and Live/HP/Shield/Simultaneous/Recharge/Fatal/Environment input fixtures. Scripted inputs call real combat systems and are explicitly QA-only. Ordinary saves and result writes retain the existing review isolation.
- Environmental eligibility is experimental: source-less hazards and enemy-sourced hazards qualify when they remove HP and the player survives. The production resolver supplies `hazard` for only certain sustained hazards; it is not a reliable general environment classifier and is not used as an eligibility filter.
- Preserved future-born discrepancy: damage rejects unborn enemies while weaken can apply before birth. Marker first appears at birth if still active. No unrelated fix made.
- Failures/retries: initial PowerShell brace-glob parse error and Windows wildcard `rg` paths; retried with explicit paths. `gh` absent from PATH; used authenticated GitHub connector. First PR connector call used wrong schema property; corrected to `repo_full_name`. First V2 test called zero-argument hazard step with an argument; corrected. Next test wrongly assumed fixture enemy IDs restarted after prior spawning and that lethal combat never advances RNG; corrected test reset and retained full deterministic-state comparison. The aborted test process was stopped by its specific process ID. Logs retained outside checkout.
- Executed Godot 4.7.2: V1 1,440 paired frames passed; V2 45 assertions/4,800 identical-input paired frames passed. Actual native pilot rendered on RX 6800 XT; V2 first activated on real incoming damage at 3.0333 s, unlike V1's 1.25 s fixture clock. Native captures are real Solo gameplay, not animation mockups.

## 2026-11-25 · regression and packaging

- Production baseline versus V2 ordinary run matched 1,320 exact authoritative frames, both maps, including weaken damage boundary samples 9/10 and 8/10. V1 1,440 paired frames and Six to Seven ordinary/V2 integration 390 paired frames passed.
- Godot exported actual ordinary and review PCKs. Both packaging verifiers passed: approved V3 present, tests/QA resources absent, all four No U scripts excluded from ordinary and included only in explicit review.
- Added cancellation of further attacker actions after the reactive pulse kills it during the incoming-contact callback; gated to reactive review. Existing enemy-loop membership guards already skip other victims removed by that pulse.
- Preserved context documents byte-for-byte before appending navigation entries: inherited tests/docs context use non-UTF8 bytes; initial Python default/UTF8 decoding attempts failed. Retried using original Git bytes plus ASCII append.
- A long shell write was rejected by command policy before execution; completed the same bounded file edits using apply_patch. No permission exception requested.
- Deployment API schema discovery initially lacked requestBody. A premature Preview request before branch publication failed with incorrect_git_source_info; no deployment was created. Retry is deferred until the verified branch is pushed. Existing project/team is Hobby and Vercel Authentication is enabled for Preview. Production aliases/settings are untouched.
