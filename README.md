# Aura Farmer — Godot

**Status: repository foundation / engine smoke test, not a playable game port.**

A new Godot project targeting **Web, Android and iOS** equally, with shared game rules. The original TypeScript/Phaser project remains at https://github.com/pedro-ai-coder/aura-farmer and is unchanged.

## Stack

- Godot 4.7.2 with GDScript (not C#)
- Compatibility renderer for Web support
- No runtime dependencies, new artworks or paid services

## Run locally

1. Install the matching Godot editor.
2. Import `project.godot`.
3. Run the main scene. Move the placeholder with **WASD** / **arrow keys**.
4. Execute `./scripts/validate.sh` for the headless smoke tests.

The grid and circle are diagnostic placeholders, **not** approved art. This initial project does not yet include combat, the actual Ruin Alley map, enemies, weapons, upgrade UI, native builds or imported art.

## Source of truth

The complete GDD is committed at `docs/GDD.md`, preserved byte-for-byte from a pinned revision of the original repository. Provenance is documented in `docs/GDD_SOURCE.md`.

The owner's newer decision is to treat Web, Android and iOS as equal target platforms. That decision still needs to be integrated into the GDD; external plans cannot silently change gameplay rules.

## Development workflow

Read `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/MIGRATION_PLAN.md` and `docs/CI_SETUP.md`. Every iteration uses a scoped PR. The CI workflow is configured for non-draft PRs but the account billing limit must be verified before enabling runner usage. Do not claim green tests before a real run; do not automatically deploy or release.

**Validation status:** GitHub repository content committed; Godot editor import, headless checks, browser export and device tests have not yet run in this environment.
