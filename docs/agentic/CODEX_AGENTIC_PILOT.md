# Codex agentic workflow — repository pilot

**Status:** EXPERIMENTAL. **Scope:** `pedro-ai-coder/aura-farmer-godot` only. This is a proposal, not a new canonical design rule.

## Provenance

- Supplied ZIP: `codex-agentic-system-2026-11-03.zip`, SHA-256 `82437d23a9b2eed810d3a312471823de11b724266fbd2156505c3e2d23d43e68`.
- ZIP metadata: snapshot dated 2026-11-03; 32 payload files in `MANIFEST.json`, each byte count and SHA-256 matched during intake.
- Source was a **user-level Codex configuration export**. Files in this PR are **new, governance-adjusted project-local adaptations**, NOT byte-identical copies of those source files.
- Existing `AGENTS.md`, `docs/GDD.md`, creator register, asset manifests, gameplay/runtime, test fixtures and CI are intentionally untouched.
- Separate Project Context Router candidate: [PR #119](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/119). This pilot has no file or merge dependency on it. Router v2 from the ZIP was **not** installed to avoid having conflicting v1/v2 routers.

## Installed candidates

- `.codex/agents/clutchpunks-reader.toml` — bounded read-only inspection.
- `.codex/agents/clutchpunks-implementer.toml` — implementation after explicit authorization.
- `.codex/agents/clutchpunks-reviewer.toml` — independent read-only review.
- `.codex/agents/clutchpunks-coordinator.toml` — optional task coordinator.
- `.agents/skills/clutchpunks-agentic-workflow/SKILL.md` — planning, bounded delegation, QA, evidence and approval gates.
- `.agents/skills/clutchpunks-acceptance-criteria/SKILL.md` — behavior-based acceptance checks.
- `.agents/skills/clutchpunks-review-fix-verify/SKILL.md` — read-only review by default; repairs only when authorized.

Codex should discover agent definitions under `.codex/agents/` and project skills under `.agents/skills/` **only on a trusted, checked-out project**. Actual discovery must be verified locally.

## Deliberately excluded

- Source `.codex/AGENTS.md`: user-wide instructions would conflict with existing project `AGENTS.md` and creator authority.
- Snapshot model pins `gpt-6-luna` / `gpt-6.1-terra`: account access and compatibility are unverified. These roles inherit the current Codex model.
- Greptile CLI, `greploop`, `check-pr`, Context7 MCP, agent-browser installation, credentials and config changes: external services, permissions, possible costs and branch/PR mutations require separate review and authorization.
- Ponytail redistribution: the source contains a third-party MIT notice, but this pilot does not add or modify the user's existing Ponytail plugin or global installation.
- Project Context Router v2: separate migration/approval required; retain PR #119 without installing duplicate routing policies.
- No autonomous schedule, 24/7 runner, release, deployment, merge or paid service is created.

## Validation plan

1. On a trusted local checkout of this branch, restart Codex. Verify discovery of all four `clutchpunks-*` agents and three `clutchpunks-*` skills; record the actual Codex version.
2. Ask the coordinator to inspect `scripts/` and `tests/` with a single bounded read-only question. Confirm it honors `AGENTS.md` and does not touch files.
3. Draft acceptance criteria for an existing regression without editing the GDD or creating tickets. Verify separation of APPROVED vs PROPOSED.
4. Review a known small change **without** applying fixes. Confirm no commits, pushes, hosted review calls or deployment.
5. For any later authorized implementation, collect exact SHA, commands, test results, RNG seed, relevant GDD and asset manifest versions; require creator review before merge.

## Rollback and risks

Rollback is deletion/revert of the four role TOMLs, three pilot skill directories and this document from the feature branch. Root instructions and runtime remain unchanged. Risks: custom agent discovery varies with Codex version/trust, textual read-only instructions do not enforce OS permissions, and model availability/external tool integration have not been tested. No Godot or browser validation can be claimed from configuration inspection alone.
