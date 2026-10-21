# Phaser → Godot migration backlog

This is an implementation plan, not a replacement for `docs/GDD.md`.

| ID | Scope | Acceptance gate |
| --- | --- | --- |
| G0.1 | Bootstrap project, import pinned GDD | Godot import, smoke test, committed files |
| G0.2 | Audit original assets, saves, character IDs and source PRs | Verified migration inventory |
| G1.1 | Migrate typed gameplay catalogs and caps/slots | Catalog contract tests |
| G1.2 | Deterministic simulation clock and state | Replay and pause tests |
| G1.3 | First solo combat slice, approved rules only | Source / Godot comparison |
| G2.1 | Ruin Alley, camera and collision | World traversal tests |
| G2.2 | Approved characters, enemies, combat animations | Timing and runtime screenshots |
| G2.3 | HUD, upgrades, responsive input and accessibility | Desktop/mobile viewport tests |
| G3.1 | Full waves, events, Big Hater and results | Automated full-run gameplay |
| G3.2 | Approved drops, difficulty and survivability | Seeded balance matrix |
| G4.1 | Web export and QA | Playable Web demo |
| G4.2 | Android export and native device QA | Real device test |
| G4.3 | iOS export and native device QA | Signed iOS test build |
| G5.1 | Performance and release readiness | Green required gates across all platforms |

One scoped task per PR; do not generate new characters or art during foundation. Check original PR #102 before carrying over the expanded Ruin Alley. No paid infrastructure or autonomous release.
