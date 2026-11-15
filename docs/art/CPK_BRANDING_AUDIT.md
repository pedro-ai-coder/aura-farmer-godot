# Player-facing branding audit

**Status:** IMPLEMENTED_REVIEW_CANDIDATE. No production publication in this work package.

## Changed surfaces

| Surface | Result |
|---|---|
| Application window | Garage and existing Solo set the visible title to CLUTCHPUNKS |
| Web document / application metadata | Native Godot custom shell uses CLUTCHPUNKS title and application-name; actual loader/feature detection retained from official Godot 4.7.2 shell |
| Boot splash and favicon | Exact approved 2026-11-13 CPK wordmark/emblem derivatives, no generated logo or crown |
| Legacy live menu fallback | Exact CPK wordmark replaces reconstructed Aura/Farmer drawing and native fallback labels |
| Hero heading | CHOOSE YOUR HERO replaces FARMER wording |
| Web/PWA manifest | CLUTCHPUNKS display names, charcoal/orange identity; stable manifest URL retained |
| Fullscreen guidance | CLUTCHPUNKS Home Screen instruction; functional fullscreen behavior unchanged |
| Export description | CLUTCHPUNKS Solo description; operational Ruin Alley remains the playable run |

## Deliberately preserved compatibility / history

`project.godot` internal `application/config/name="Aura Farmer"` is retained: Godot derives native `user://` directories from this identifier. Renaming it without a migration would hide existing profiles. The visible native window title is overridden separately; Web uses an explicitly branded shell. This is a compatibility identifier, not a player-facing title. A future native package naming/migration requires separate review.

`aura-farmer:profile:v2`, `aura-farmer:profile:v1`, user profile filenames/schema, browser platform/diagnostic globals, manifest filename `aura.webmanifest`, AuraArchivo CSS family, repository URLs, historical node/export paths and approved asset records remain unchanged. The Aura gameplay resource is still canonical; it is not obsolete branding. Historical docs, comments, manifests and prior immutable artwork remain provenance, not active brand authority.

The custom shell preserves the official loader rather than postprocessing a production artifact. The source comes from the installed official 4.7.2 `web_nothreads_release.zip` Godot HTML template under the engine's MIT license. No tracking, external fonts, network service or save namespace is added.

## Website integration boundary

The future site must embed/link an explicitly approved Godot deployment by immutable game SHA, expose the CLUTCHPUNKS title and exact approved Art wordmark, retain the current game's browser storage origin and keys, and never claim Level Zero/default-mode replacement, progression, shops, multiplayer or new art approval. New website copy and publishing remain review gates. A missing/uninitialized website branch does not block local Garage/game work; no repository bootstrap or production change is inferred.

## Validation

Web platform Node tests were executed and passed after copy change. Existing profile storage source remains byte-identical to the production baseline. Focused profile/title/shell checks and the final Web export must confirm runtime and metadata; no physical-device/native-package claim is made by this audit.
