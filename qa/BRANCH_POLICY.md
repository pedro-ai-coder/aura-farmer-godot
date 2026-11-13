# Instrumented QA branch: qa/instrumented-main

Status: **QA ONLY**. This branch is not production, not canonical artwork, and not an approval of any gameplay experiment.

## Source snapshot and ownership

- Game baseline: `main` at `e8a8ebdce6fbdb6fd9a918e2be9d8a71cfa84b0f`.
- QA Recorder source: PR #103, part of the stacked QA history.
- QA Scenario Mode source: PR #105, exact source head `8900fcf9576fce89d75be2b6dd8c69fcb093888a`.
- Provenance: original source commits stay immutable in their existing branches. This branch selectively transplants QA code and intentionally omits historical QA evidence binaries.
- No canonical game rules, stats, seeded RNG, approved art, save format, or production build entry are changed by this overlay. Only QA-specific source, tests, Web review preset, export verifier, workflow rules and validation hooks differ from `main`.
- The ordinary `Web` export excludes `qa/*`; the `Web QA Review` preset explicitly includes QA review code. QA is OFF by default and only enabled in the review build. Never use `QA_REVIEW=1` for production deployment.

## Sync with main (reviewed, on demand)

This is a **manually synchronized tracking branch**, not an autonomous merge bot. Synchronize after accepted changes reach `main`:

```sh
git fetch origin
git switch qa/instrumented-main
git merge --no-ff origin/main
# Resolve any conflicts while keeping canonical gameplay from main.
# Preserve the QA-only overlay; never copy QA changes back to production.
bash scripts/validate.sh
QA_REVIEW=1 bash scripts/build_web.sh
git push origin qa/instrumented-main
```

Use Godot 4.7.2; verify exact SHA, Web QA export, normal Web export exclusion, actual browser recording/download, seed/fixture determinism, and that normal run saves and gameplay are unchanged. Every sync must record source SHA, test commands, actual results and residual risks. If conflicts touch gameplay, stop for explicit review. Do not auto-merge any PR or deploy.

## Usage

- QA Recorder: read `qa/README.md`, select **Start QA**, record external video and export session ZIP.
- Synthetic scenarios: select **QA Scenario** and deliberately enable the synthetic mode.
- A synthetic scenario must always stay labeled `QA / SYNTHETIC SCENARIO`; never treat it as normal human gameplay.
- To build a local QA review export, run `QA_REVIEW=1 bash scripts/build_web.sh`.
- For a protected Vercel preview from this exact branch, the exporter auto-selects the QA review preset. Review previews must never become production.
- Historical evidence retained by source PR commits, not copied into this tracking branch.

## Rollback

Delete the *QA-only branch* after preserving any new evidence, or revert the QA-overlay commit. Do not modify the protected `main` branch. Branch creation alone does not validate the game or approve merges.
