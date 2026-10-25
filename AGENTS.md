# Aura Farmer — Godot contributor guidance

## Product specification

The complete canonical `docs/GDD.md` is the sole product, gameplay and visual specification. Never derive new rules from a migration plan.

## Working rules

- All code, tests, technical documents, commit messages and PR descriptions must be in English.
- Use Godot 4.7.2, GDScript and the Compatibility renderer. **Current approved milestone scope:** M0 **fully polished closed Web (no backend)**, M1 **public alpha on Web and Discord Activity with operational backend and in-game requests for tester feedback**; native expansion is for evaluation at M2+. Refer to `docs/GDD.md` **V3** and `docs/GDD_DECISION_REGISTER.md`.
- Keep the existing Phaser repository intact; migrate incrementally and preserve IDs and saves.
- One scoped implementation PR at a time; report actual validation rather than assumed pass.
- M0/M1 PR acceptance requires applicable mandatory checks/tests to pass and owner approval of each scoped PR. A passing check does not automatically authorize merge, deployment, M0 visual-polish acceptance or public-alpha launch. New product decisions still require owner input.
- Do not add paid CI, paid services, automatic releases, new artwork or credentials.
- Reuse only inventoried and approved assets; no new characters in this foundation.
- Runtime validation cannot be claimed unless Godot was actually executed.
