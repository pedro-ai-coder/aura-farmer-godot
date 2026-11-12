# Context routing

Select rows using the task, folder path, and description; then read only the
selected CONTEXT.md files and necessary dependencies. Do not open all context
files to choose a route. Folder paths below are relative to the project root;
links are relative to this file.

## Authority and navigation guard

This index provides navigation only; it never approves or supersedes product
decisions, artwork, gameplay behavior or implementation changes. Follow the
existing [agent guidance](../AGENTS.md), operational
[GDD V3](../docs/GDD.md), and
[creator decision register](../docs/GDD_DECISION_REGISTER.md).
The separate `clutchpunks-canon` repository governs canonical approval
provenance. Unmerged proposals, experiments and runtime use do not establish
approval. If sources conflict, stop and report the conflict rather than
changing gameplay or artwork silently.

## Folder routes

Context scope: 1 layer. Creator-selected folder tiers (2026-11-12).
Nested subfolders are included through their parent route; no second-layer context files are selected.

| Folder | What's there | Context file |
|---|---|---|
| `assets/` | Asset provenance and manifests (tier: thin) | [Context](../assets/CONTEXT.md) |
| `docs/` | GDD, creator decisions and history (tier: thin) | [Context](../docs/CONTEXT.md) |
| `scenes/` | Godot scene entry points (tier: standard) | [Context](../scenes/CONTEXT.md) |
| `scripts/` | Runtime contracts and platform/build helpers (tier: deep) | [Context](../scripts/CONTEXT.md) |
| `tests/` | QA tests and fixtures (tier: standard) | [Context](../tests/CONTEXT.md) |
| `web/` | Browser lifecycle/diagnostics (tier: standard) | [Context](../web/CONTEXT.md) |

## Related contexts

Read both when the task crosses a verified interface:

| Context | Related context | Relationship / when to read |
|---|---|---|
| [Scenes](../scenes/CONTEXT.md) | [Scripts](../scripts/CONTEXT.md) | Main scene attaches the solo-run controller |
| [Scripts](../scripts/CONTEXT.md) | [Tests](../tests/CONTEXT.md) | Runtime contracts have targeted QA coverage |
| [Scripts](../scripts/CONTEXT.md) | [Web](../web/CONTEXT.md) | Godot Web export and platform adapters |
| [Scripts](../scripts/CONTEXT.md) | [Assets](../assets/CONTEXT.md) | Runtime art bindings use manifest-tracked resources |

## Maintenance contract

Whenever you add, move, or meaningfully change a covered folder, its behavior,
interfaces, business rules, architecture, integrations, or responsibilities,
update its CONTEXT.md and any affected routing entries in the same change. Add
new context files only after user selection and within the recorded scope.
If an adopted ARCHITECTURE.md is affected, update it in the same change.
Keep verified related-context entries current when their relationships or
context files change; remove stale entries.
Preserve selected tiers and the layer limit; ask before changing them. Remove
or repair stale entries when folders move or disappear.
Keep selected optional skill and specialist maps linked from this index.
