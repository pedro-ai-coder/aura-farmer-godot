# Aura Farmer — Godot contributor guidance

## Product specification

The complete canonical `docs/GDD.md` is the sole product, gameplay and visual specification. Never derive new rules from a migration plan.

## Working rules

- All code, tests, technical documents, commit messages and PR descriptions must be in English.
- Use Godot 4.7.2, GDScript and the Compatibility renderer. **Current approved milestone scope:** M0 restricted Web, M1 public alpha on Web and Discord with backend and in-game feedback; native platform expansion is for evaluation at M2+. Refer to the 25 October amendment of `docs/GDD.md` and `docs/GDD_DECISION_REGISTER.md`.
- Keep the existing Phaser repository intact; migrate incrementally and preserve IDs and saves.
- One scoped implementation PR at a time; report actual validation rather than assumed pass.
- M0/M1 PR acceptance requires applicable mandatory checks/tests to pass and owner approval of each scoped PR. A passing check does not automatically authorize merge, deployment, public alpha launch or visual sign-off. New product decisions still require owner input.
- Do not add paid CI, paid services, automatic releases, new artwork or credentials.
- Reuse only inventoried and approved assets; no new characters in this foundation.
- Runtime validation cannot be claimed unless Godot was actually executed.
