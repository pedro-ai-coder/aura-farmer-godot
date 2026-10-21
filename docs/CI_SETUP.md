# Godot CI setup and zero-additional-cost safeguards

This guide describes the lightweight pull-request check for the Godot edition of Aura Farmer. Gameplay and platform decisions are specified only by docs/GDD.md, not by this operational guide.

## What is included

- Workflow: .github/workflows/godot-ci.yml
- Event: pull requests into main; no push, periodic, release, deployment or upload triggers
- Draft PRs: job skipped until Ready for review (which triggers the check)
- Runner: one Ubuntu GitHub-hosted runner, with an 8-minute maximum job duration
- Resource controls: cancel superseded PR runs; download/cache the editor; no export templates or platform build matrix
- Permissions: read-only contents; checkout credentials are not persisted; both third-party actions are pinned to immutable commit SHA values
- Editor: Godot 4.7.2, GDScript-only
- Validation: engine version, canonical GDD presence, Godot resource import, foundational contract tests, and a brief main-scene boot check
- Error handling: reject a failed command or critical Godot parser/runtime errors in its console log
- Required status-check job name: godot-validation (workflow: Godot CI)

The job does not test a finished playthrough, frame-rate targets, exported Web builds, Android installs or iOS installs. These will require later explicit tests, export presets, hardware and separate decisions.

## Before enabling runner usage — owner action

This repository is **private**. A hosted GitHub Actions job consumes account minutes, even if its cost is covered by included quota. An 8-minute timeout alone does NOT guarantee zero extra charges. The connected GitHub integration cannot read or change the account's billing budget.

1. Open https://github.com/settings/billing and review Actions usage, remaining included minutes and account spending budgets.
2. Set a strict zero-additional-spend Actions budget and enable blocking further usage when its budget limit is reached, where available for the current account. If that cannot be verified, leave the CI pull request in **Draft**.
3. Open https://github.com/pedro-ai-coder/aura-farmer-godot/settings/actions and verify actions are allowed, including the two pinned actions used here. Keep the workflow token read-only and avoid allowing secrets in fork PR jobs.
4. Mark the CI PR **Ready for review**; watch the resulting godot-validation check. Investigate failures instead of merging on a pending/skipped check.
5. Review the PR and merge only after the workflow actually succeeds and normal owner review requirements are met.

The CI installation PR intentionally starts as a draft to avoid unreviewed runner consumption. Once merged, this workflow will evaluate future ready-for-review PRs into main. Existing PRs may need a head commit update or reopen before they receive a fresh CI check; never count the absence of a check as success.

## Enforcing green CI on main

Branch protection is distinct from a CI workflow and is not currently writable through the GitHub connection.

1. After at least one successful workflow run, go to https://github.com/pedro-ai-coder/aura-farmer-godot/settings/rules.
2. If account plan and repository visibility support it, add an **active** branch ruleset targeting main.
3. Require pull requests, require the godot-validation status check, block force pushes and deletions, and review bypass permissions.
4. Verify effective enforcement with a test PR. If rule activation is not offered, do not assume merges are blocked.

GitHub Free generally supports rulesets for public repositories, not private repositories. Private ruleset enforcement may require GitHub Pro, Team, or Enterprise. Do not upgrade or make the repository public automatically: both are separate owner decisions. Without enforced rules, CI is advisory and merges must remain a deliberate review action.

## Running checks locally

With Godot 4.7.2 installed on PATH as godot or godot4:

    bash scripts/validate.sh

The script exits nonzero for missing Godot, a failed import/test/scene step or Godot parser/resource/runtime errors in its logs.

## Scope boundaries

- No changes to the original Phaser repository
- No new game mechanics, characters or art
- No recurring tasks or release workflow
- No required secrets
- No automatic merges
- No promised zero-cost guarantee until account-level billing controls have been configured and verified
