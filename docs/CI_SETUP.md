# Godot CI and branch protection

This document describes the lightweight pull-request validation configured in the **public** Aura Farmer Godot repository. The only authority for gameplay and product decisions is `docs/GDD.md`.

## Implemented CI

- Workflow: `.github/workflows/godot-ci.yml`; runs on PRs targeting `main` when opened, updated, reopened, or marked Ready for review. Draft PRs skip the job.
- Job name: **`godot-validation`** (workflow name: **Godot CI**).
- One Linux GitHub-hosted runner, eight-minute job timeout, cancel superseded runs, no deployment, no export templates or platform matrix.
- Read-only GitHub token and pinned GitHub Action commit IDs.
- Godot 4.7.2 GDScript editor import, essential GDD rule contracts, and main-scene headless smoke test.
- First verified green run: https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/39604186885 (attempt 2).
- CI setup merged in PR #3: https://github.com/pedro-ai-coder/aura-farmer-godot/pull/3.

A successfully booted scene is **not** a complete playable game or Web/Android/iOS export. Future acceptance must include a full solo run, measured performance, mobile input, exports, persistence and real hardware testing.

## GitHub Actions cost model

This repository is **public**. Standard GitHub-hosted runner minutes for public repositories are free on GitHub Actions. The old private-repository minutes exhaustion no longer blocks the confirmed CI run. **Do not** adopt larger paid runners, third-party billed services or paid release automation without explicit owner approval. If repository visibility changes back to private, review account minutes and billing caps first.

The eight-minute timeout limits runaway individual jobs; it is not a spending limit for other paid services. This repository does not include paid services or secrets in its workflow.

## Enforce checks on main — manual owner step

The GitHub connector can merge pull requests and inspect rulesets, but it **cannot create or change repository branch rulesets**. These settings require the repository owner's GitHub web UI.

1. Open https://github.com/pedro-ai-coder/aura-farmer-godot/settings/rules and choose **New ruleset → New branch ruleset**.
2. Ruleset name: `Protect main`. Enforcement: **Active**.
3. Under **Target branches**, target the repository default branch (`main`).
4. Under **Branch protections**, enable **Require a pull request before merging**.
5. Enable **Require status checks to pass before merging**, add exactly **`godot-validation`** (provider GitHub Actions), then confirm/add that check.
6. Enable **Block force pushes** and **Restrict deletions**.
7. Avoid granting unnecessary bypass permissions; save/create the ruleset.
8. Verify on GitHub that the ruleset is active and targets `main`. Then confirm from the GitHub API that `main` is protected and a `godot-validation` check is required on future PRs.

For a single-owner repository, **requiring an additional reviewer's approval** can make merging impossible; keep required approvals at zero unless an independent reviewer is available. The PR rule still requires every change to be proposed via PR. Do not enable `Require branches to be up to date` until the workflow/rebase policy is tested.

The public repository supports GitHub Free rulesets; there is no reason to make the repository private or buy an upgrade for these protections. Until an active ruleset is configured, **CI is advisory and GitHub may allow a merge that bypasses failed checks**.

## Local reproduction

```bash
bash scripts/validate.sh
```

Requires the Godot 4.7.2 editor binary installed on the PATH as `godot` or `godot4`. Fails for command errors or parser/runtime errors emitted in logs.

## Project boundaries

- No automatic merging or releases.
- No new characters, art or gameplay rules from CI work.
- Original Phaser repository stays intact.
- Future Web, Android and iOS proof must be obtained independently of this lightweight job.
