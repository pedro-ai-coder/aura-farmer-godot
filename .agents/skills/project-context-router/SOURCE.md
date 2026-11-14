# Project Context Router — Pilot source provenance

Status: EXPERIMENTAL, unapproved for merge.

- Source: creator-provided `project-context-router.zip`, received 2026-11-06.
- Source ZIP SHA-256: `ba50e8316d2485645e042f179d98443b8f2482adeb97bfacc60facf996da4c9c`.
- Scope: repository-local Codex skill in `.agents/skills/project-context-router/`.
- This folder includes the complete human-readable skill package (instructions,
  two helper scripts, five references and two test modules), excluding macOS
  metadata, temporary files and bytecode.
- Each installed source file's Git blob SHA is checked against the exact
  uploaded source during draft preparation.
- Source ownership and redistribution license have not been independently
  established; confirm before merging into a public repository.
- No automatic setup command, GitHub Action, network access, deployment or
  gameplay changes are introduced by this pilot.

Local source checks before this draft: Python 3.13.5,
`python -B -m unittest discover -s tests -v` => 83 tests,
0 failures, 1 skipped. This does not validate the Godot game or future
Codex discovery.

Run from repository root after checkout:
```sh
python3 .agents/skills/project-context-router/scripts/validate.py .
python3 -B -m unittest discover -s .agents/skills/project-context-router/tests -v
```
