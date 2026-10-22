# Aura Farmer — Godot contributor guidance

## Product specification

The complete canonical `docs/GDD.md` is the sole product, gameplay and visual specification. Never derive new rules from a migration plan.

## Working rules

- All code, tests, technical documents, commit messages and PR descriptions must be in English.
- Target Godot 4.7.2, GDScript and Compatibility renderer for Web/Android/iOS.
- Keep the existing Phaser repository intact; migrate incrementally and preserve IDs and saves.
- One scoped implementation PR at a time; report actual validation rather than assumed pass.
- Owner authorization on 22 October 2026 permits implementation and integration of already approved GDD behavior after all required automated checks pass. Visual validation is explicitly deferred to a later owner review; do not claim visual acceptance. New product decisions still require owner input.
- Do not add paid CI, paid services, automatic releases, new artwork or credentials.
- Reuse only inventoried and approved assets; no new characters in this foundation.
- Runtime validation cannot be claimed unless Godot was actually executed.
