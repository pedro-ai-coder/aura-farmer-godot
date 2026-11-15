# CODEX — CLUTCHPUNKS COOL KID PRODUCTION-GRADE 2D ARTICULATION PILOT

**Execution brief date:** 2026-11-15
**Creator-approved scope:** `CPK-HERO-MOTION-PILOT-2026-11-15-01`, a Cool Kid-only articulated animation production pilot.
**Priority:** Produce the highest-quality genuinely playable and demonstrably defect-reduced Cool Kid rig possible while preserving the original exact approved character identity and every existing gameplay contract.
**Primary execution environment:** Codex with access to the Canon, Art and Game GitHub repos, local Godot 4.7.2, relevant graphics authoring tools, tests, and a local native + Chromium/Web browser.
**Work autonomously.** Do not delegate analysis, repetitive asset work, QA or cross-repo coordination to the creator. Only stop when an actual creator approval/action is required.

## 0. Roles, source-of-truth and access preflight

Act as a Senior 2D Character Technical Artist, Godot Animator, Gameplay Engineer, Motion Designer, QA Lead and cross-repository provenance custodian. Write all code, repository files, PRs, test reports and external deliverables in English. The creator should receive a concise European Portuguese review summary.

Use read-only inspection first. Confirm the GitHub identity/account is `pedro-ai-coder` and read/write access *before* attempting any branch write; never authenticate using a different account. Resolve permission issues precisely, without modifying account settings. Confirm all three repositories and branches:

1. Canon: `pedro-ai-coder/clutchpunks-canon` — GDD V4.0, exact approvals, decision `CPK-HERO-MOTION-PILOT-2026-11-15-01` (initially on the independent documentation Draft PR; do not assume that PR is merged).
2. Art: `pedro-ai-coder/clutchpunks-art-pipeline` — approved exact art preservation, `production-reference/characters/2026-11-14/ANIMATION_HANDOFF.md`, and the new Cool Kid rig-production brief (initially on its documentation Draft PR).
3. Game: `pedro-ai-coder/aura-farmer-godot` — Godot 4.7.2, actual runtime, this execution brief and current hero renderer.

Read only relevant `AGENTS.md`, Canon GDD/decision, Game `.context-routing/index.md` routes and the targeted art/runtime files. Do not ingest all archives, assets, videos or evidence. Record the *fresh* immutable main/PR base SHAs and confirm the actual renderer and feature flags. The Game has other currently open **stacked Draft PRs #137–#146** for the Garage/UX, combat presentation and environments. Treat those as unmerged and avoid rebasing or editing them without dependency proof.

## 1. Exact art and gameplay invariants — no exceptions

- The approved six source sheets are already approved: `CPK-HERO-SHEETS-INTEGRATION-2026-11-14-01`. Art source commit `52c8618098c68034f42ec469567effc952cfdb27`. Cool Kid exact approved source sheet SHA-256: `d59366663e00e5859129428bfd3499b4f72062ed463f6be5b2ed3e92a4ad9fbb`.
- Approved image used for earlier experimental segmentation: Game `assets/production/heroes/individual-sheets-v1/cool-kid/portrait.png` at merge `a33812548d5936186b99629520ad9fea107632eb`, approved pack SHA-256 `2a88c499d30633f76e2da3861188995c7a4144ad73d062eecee4a91f1b1380a3`.
- Active exact six-hero style target: `CPK-HERO-STYLE-2026-11-14-02`; full-board SHA-256 `f3f46b88f9586662f3dd27644fcfc862b36232e01851a00482790832536c564d`.
- Animation concept references: `CPK-HERO-ANIMATION-REVIEW-2026-11-14-01` are concept/pose references, **not** rigging-ready assets or final animation approval.
- Art Draft PR #29, commit `c377c7729769177cc164ca9a72592e7b468f2254`, is the **defective preliminary HTML slice POC**. Use as failure/feasibility reference, not as a production master, not as proof of animation acceptance.
- Preserve Cool Kid's recognizable face, blue pompom beanie, keyboard, clothing, correct readable CPK logos, silhouette, palette, proportions, expression and prop ownership. Do **not** redraw freely, mirror text or swap equipment.
- Preserve all GDD V4.0 bounded product intent and inherited V3 executable rules: three gameplay kits / six identities, movement speed, equipment, weapons, damage, HP, enemy AI, cooldowns, spawn/waves, Flex behavior and sequencing, clocks, attacks, hitboxes, deterministic RNG, IDs, saves, accessibility/reduced-motion behavior and content compatibility. **No new dash, dodge, knockback or animation-triggered attacks.**
- The **only implementation scope** is cosmetic visual motion and a Cool Kid presentation integration/fallback. Byte Baddie shares the kit but must not accidentally receive a Cool Kid rig.

## 2. Diagnose the original visual defects and define the production rig

Inspect existing Game `scripts/approved_hero_sheets.gd`, `scripts/hero_animation.gd` and the actual call chain/render path. Cross-check real `idle`, directional `run`, `attack`, `hurt`, `flex-in`, `flex-loop`, `flex-out`, `defeat` and home/selection states and existing clocks. Do not assume these files are directly called without tracing.

The POC's defects include edge tearing, missing anatomy under other layers, duplicate source pixels, awkward keyboard-to-hand coupling, incorrect z-order, cardboard/paper motion, foot sliding, pivots that don't respect volume, poor anticipation/recovery and no verified in-game motion quality. Establish an **actual baseline** with native game-scale screenshots/playback and close-ups for the existing approved Cool Kid. Do not claim previously uploaded MP4 analysis unless inspected as actual input.

Build a **versioned, editable rig-ready master in Art**. Start from the exact approved source pixels and approved style. Distinguish preserved original regions from new painted/reconstructed hidden surfaces. Author concealed body/clothing regions, elbow/shoulder/neck/waist/knee connectors, independent hands/feet and keyboard sockets, overlap patches and needed directional poses. A naive PNG cutting script or multiplying full-body crops is not sufficient. Keep newly authored pixels clearly marked CANDIDATE until explicit art sign-off.

Make a rig hierarchy with parent-child transform logic, actual knee/elbow joints where visible, stable feet, a correctly attached keyboard, beanie pompom secondary motion and robust occlusion ordering. Compare a minimal `Node2D` + `AnimationPlayer` solution against `Skeleton2D`/`Bone2D`/`AnimationTree` **only as much as needed** to pick the simplest maintainable option that yields high-quality results. Do not purchase Spine or introduce a new paid service.

Use a new versioned Art output path, e.g. `production/characters/cool-kid/articulated-rig-v1/`, containing editable master, transparent PNG pieces, explicit pivots, joint hierarchy, draw-order/attachment mapping, stable asset IDs, exact input hash refs, each derived asset SHA-256, source-vs-authored region provenance, transparent-export validation and preview. Include a deterministic generator/export contract where practical. No overwriting or silent replacement of approved art.

## 3. Author movement like animation, not like randomized wobble

Create motion for the **actual existing states** and their real timing:

- Idle: believable breath/posture, subtle head and arms, delayed pompom, menu personality.
- Run/walk: alternating contacts and passing poses, upper-body counter-rotation, pelvis weight transfer, foot plant, start/stop settling and correct speed/direction mapping. Avoid foot sliding.
- Turning/directions: front/rear/side consistency, no awkward mirroring of CPK text, no pose teleportation at direction switches; document directions supported vs currently missing.
- Attack: clear anticipation, canonical keyboard/arm action and recovery aligned with existing *visual* attack state; do not change attack events/cooldowns or apply any simulated gameplay effects.
- Hurt: visible reaction without corrupting gameplay time/state priority.
- Flex: respect current canonical states/event precedence and transitions without changing timers.
- Defeat: compatible defeat playback and cleanup.
- Home/selection idle: same visual identity at correct menu scale, with reduced-motion fallback.

Use deliberate key poses, arcs, easing and follow-through, with small procedural secondary motion where effective. No uncontrolled perpetual jitter, no independent animation simulation RNG and no timing guessed from `delta` when deterministic state data exists. The keyboard must remain anchored correctly across all applicable states.

## 4. Implement a safe cosmetic Godot adapter

In Game, create a **focused Draft PR** that consumes a **specific immutable Art candidate commit + manifest SHA**, not Art `main` or an unmerged branch name. Keep an isolated visual presentation component and the existing gameplay/renderer separation. Reuse existing state precedence and reduced-motion settings; do not duplicate or rewrite combat controllers.

Requirements:
- The articulated renderer is enabled only for the intended Cool Kid identity by an explicit **review/experimental toggle**.
- Existing approved `approved_hero_sheets.gd` rendering remains the fallback on a missing rig, bad manifest, unsupported direction/state, validation failure or toggle off.
- Unapproved art is not silently promoted to production; review build/resource inclusion must be explicit, with existing export/allowlist rules respected.
- Fit existing game visual sizes, texture filtering and scaling; prevent blur/pixelation and white rectangles; keep cached textures and deterministic layer ordering.
- Preserve correct player position/selection/HUD semantics, rear-facing direction where needed and visual layering over floor/weapon effects.
- Avoid code import cycles, runtime per-frame texture loads, repeated allocations and accidental coupling to combat updates.
- Include a renderer-side A/B toggle or diagnostic route suitable for QA. No public production deploy.

## 5. Validation and playable evidence — actually execute

First discover the repository's exact supported validation commands rather than inventing successful output. Use the pinned Godot 4.7.2/toolchain. Execute what is possible and report actual command, exit code, source SHA, platform and raw evidence reference.

Minimum useful evidence:
1. Validate approval/source hash consistency, layer PNG transparency, deterministic exported asset manifest, skeletal pivots/attachments and missing/bad asset fallback.
2. Headless Godot import / relevant smoke and canonical simulation/contract tests; compare deterministic normal-run outputs against a correctly frozen unchanged base, and **do not rebaseline away a mismatch**.
3. Actual native play in a **normal human-style combat run** and at least one automated normal run; distinguish these from synthetic QA Scenario Mode fixtures.
4. Real Chromium/Web export navigation into Cool Kid play (where browser tools available), movement, attack, hurt/Flex, keyboard/mouse selection, pause/results/retry and no runtime errors; validate production-style PCK/resource inclusion.
5. Visual defect matrix at normal playing scale and diagnostic zoom: idle/run/stop, eight directional headings or actual supported cardinal set, turn, attack anticipation/recovery, hit, Flex, defeat and menu. For every sample, verify no missing neck/armpit/elbow/knee/waist anatomy, doubles, detached keyboard, text reversal, foot sliding, jarring rotation or popping. Document any unavoidable gap.
6. A/B compare legacy vs candidate at comparable camera scale and movement, with consistent seeded runs and settings. Show short true clips/contact sheets if genuinely produced; no fabricated runs or screenshot claims.
7. Measure representative frame pacing, allocations and browser resource loading when possible; state hardware/configuration and raw metrics without invented thresholds.
8. Verify reduced-motion state, unselected Byte Baddie/other characters and saves/RNG/IDs remain unchanged.

Reuse existing QA Recorder and QA Scenario Mode where available; do not duplicate instrumentation. Escalate any blocked check as `NOT_RUN` with exact cause. If required golden hashes mismatch baseline, investigate and report them as unresolved until proven unrelated; no false pass.

## 6. Cross-repository task structure

Keep separate draft scopes, never mutate protected branches:

- **Canon:** The creator's limited pilot direction and constraints belong under `decisions/` and the decision log. Inspect `CPK-HERO-MOTION-PILOT-2026-11-15-01` already proposed in the Canon documentation Draft PR; reconcile rather than duplicate or silently rewrite it. The creator approval concerns **pilot scope only**.
- **Art:** One scoped production **Draft PR** for the Cool Kid *candidate* layered master + manifest + authoring validation + review captures. Existing Art documentation handoff is separate and may be unmerged; read by exact SHA/PR, do not assume main adoption.
- **Game:** One scoped implementation **Draft PR** for Cool Kid-only rig renderer and fallback, with pinned Art assets/manifest, tests and playable evidence. Do not mix it with existing Garage/UI/Level Zero stacked Draft PRs; call out any needed base dependencies instead.
- **QA/Evidence:** Add only necessary, on-demand QA/evidence artifacts in their own appropriate repositories or report exact local outputs with hashes; no bulk dumps, recurring paid CI, or new telemetry.
- **Historical archives:** not modified unless needed to preserve immutable supersession history.

Keep the experimental Art PR #29 separate and unmerged. No automatic merges, force pushes, production deployment, public release, expenses or future hero rollout.

## 7. Completion and handoff to the creator

**Do the work end-to-end, not just a plan.** Use the simplest viable production-quality approach, fix your own defects, run actual checks and submit *reviewable real evidence*. If an external art authoring capability prevents recreating hidden anatomy, do not fake completion: record the exact blocker, keep finished work in Draft PRs and still deliver a verified in-engine motion spike using genuine source pixels clearly marked EXPERIMENTAL.

Prepare a clear delivery report in Portuguese with:
1. **A/B playable review location** (how to run a candidate build without publication) and a concise summary of how much motion improved.
2. Exact **Canon / Art / Game Draft PR URLs, source SHAs and asset manifest/hashes**.
3. Source-art preservation vs NEW candidate painted pixels; known remaining visual defects by state/direction.
4. Godot/Chromium real tests run (commands, environment, outcomes) and separate `NOT_RUN` items.
5. Performance and risks; how to revert/fallback independently.
6. One creator review gate: **approve/reject the exact candidate rig look and motion quality**. Do not ask to reapprove existing source sheets. Merges/deploys remain separately gated.

## Definition of done for this pilot

A candidate is **ready for creator visual review** only when there is a reproducible Art master, a hash-pinned and playable Game integration on a Draft PR, genuine movement/attack/hurt/Flex evidence, reliable fallback and no severe broken seams, floating limbs, keyboard detachment or unnatural foot sliding in the reviewed states. All mandatory contract checks actually run must be recorded truthfully. The candidate is **not approved/released** until explicit creator decisions authorize the relevant subsequent gates.

If full perfection cannot be achieved, deliver the highest verified intermediate result with a precise defect list and do not claim done; partial honest quality is preferable to another polished but broken prototype.
