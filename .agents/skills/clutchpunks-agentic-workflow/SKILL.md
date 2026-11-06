---
name: clutchpunks-agentic-workflow
description: Coordinate a bounded CLUTCHPUNKS coding task through evidence-based planning, optional delegated implementation, and independent review without changing canonical design or merging.
---

# CLUTCHPUNKS agentic workflow (EXPERIMENTAL pilot)

Use this workflow only for an explicitly authorized task in this repository. This is a project-local adaptation of the user-supplied `codex-agentic-system-2026-11-03.zip`, not a byte-for-byte installation of its global user profile.

## Authority and scope

1. Read root `AGENTS.md` first, then only the relevant runtime files and sections of `docs/GDD.md`, `docs/GDD_DECISION_REGISTER.md`, and approved provenance as needed. The canonical `clutchpunks-canon` repository and explicit creator decisions control design approval; runtime documentation and this skill do not grant approvals. Until GDD V4 is explicitly approved, GDD V3 remains operational.
2. Distinguish APPROVED, PROPOSED, EXPERIMENTAL, UNRESOLVED, and SUPERSEDED. Never invent mechanics, tuning, artwork approval, source hashes, or canonical rules.
3. Default to a read-only inspection. Explicitly identify the affected repository, task scope, acceptance criteria, dependent contracts, regression risks, and rollback before changing files.
4. For authorized implementation, create a dedicated branch and one reviewable PR; never directly modify protected branches, merge, deploy, release, add paid services, or use external hosted review services without distinct creator authorization.
5. Keep canonical IDs, save compatibility, deterministic RNG, approved asset provenance, and gameplay unchanged unless an explicit approved decision says otherwise.

## Smallest complete workflow

- **Plan**: State the objective, evidence, known requirements, exclusions, and unresolved decisions. Prefer reusing established code and existing QA Recorder/Scenario Mode instrumentation rather than new frameworks.
- **Acceptance**: Define a few observable, pass/fail criteria grounded in the existing behavior. Mark anything not decided as UNRESOLVED. Never turn a test fixture or proposal into a product rule.
- **Read**: If parallelism is genuinely useful, delegate a bounded read-only question to `clutchpunks-reader`. Otherwise inspect the smallest relevant files directly.
- **Implement**: Only after change authorization, delegate a bounded change to `clutchpunks-implementer` or implement it directly. Keep workers' file ownership non-overlapping. Workers must not recursively delegate.
- **Review**: Request a fresh independent, read-only `clutchpunks-reviewer` for material changes when available. Review the exact diff, associated callers, tests, assets and acceptance criteria; verify findings, not review scores.
- **Verify**: Run only relevant checks, record exact branch/commit, commands, result, environment, RNG seed and manifest versions when applicable. Never claim Godot/browser tests ran without actual execution.
- **Report**: Distinguish verified changes, actual test outcomes, pending checks, risks, blocked dependencies, and creator decisions. A passing check does not authorize merge.

At most three bounded repair cycles when already authorized. Stop earlier for no progress or missing dependencies. Any edits after the last review require fresh review or a stated coverage gap.

## Model and external-tool policy

Use the parent Codex model and existing approved tool permissions. This pilot does not request specific Luna/Terra model IDs; do not assume those snapshot IDs are available. Subagents are optional and inherit parent permissions. Textual read-only role instructions are **not** an enforceable sandbox: keep actual permission settings restrictive.

Do not automatically install or authenticate Context7, Greptile, Ponytail, agent-browser or other tools; do not invoke hosted Greptile, PR-comment loops, push or mutation tools just because the source ZIP mentions them. No continuous background agent or 24/7 orchestration is provided.

## Pilot validation

After PR integration into a trusted local checkout, restart Codex, inspect the discovered project skill and four agent names, run a bounded read-only task, and inspect the output. Do not use the result to certify gameplay, release readiness, or art approval. See `docs/agentic/CODEX_AGENTIC_PILOT.md`.
