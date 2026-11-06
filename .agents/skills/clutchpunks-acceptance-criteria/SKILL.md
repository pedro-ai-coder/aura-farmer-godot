---
name: clutchpunks-acceptance-criteria
description: Turn an authorized CLUTCHPUNKS change into a compact, testable acceptance contract based only on verified GDD and runtime evidence.
---

# Acceptance criteria for CLUTCHPUNKS

1. Read the exact user task, root `AGENTS.md`, and the smallest relevant approved GDD V3/decision-register passages. Check the canonical decision status; a draft does not establish APPROVED behavior.
2. Write the intended observable outcome in one or two sentences. Separate the existing behavior, explicitly requested change, and proposed behavior.
3. By default provide three to six independent pass/fail criteria. For ambiguous or high-impact work, use Given/When/Then cases for normal behavior, important failure cases, and compatibility boundaries.
4. Preserve stable gameplay IDs, deterministic RNG, saves, asset provenance, and platform contract unless an explicit approved change requires otherwise. Do not invent expected numeric values.
5. Mark unsupported assumptions and creator decisions UNRESOLVED; do not silently promote them through tests or code.
6. State exactly how each criterion could be checked (unit, contract, Godot headless, browser, human review), but never say it passed unless executed evidence exists.
7. No automatic issue creation, external service access, or criteria revision in canonical documents.
