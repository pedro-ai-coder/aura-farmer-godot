# Canonical GDD provenance and consolidation history

The original source specification was imported from the Phaser reference repository, then amended over time in the Godot repository. **The current authoritative project specification is [`docs/GDD.md`](GDD.md)**. Older versions are historical records, not alternate live gameplay or milestone rulebooks.

## Source lineage

| Edition / period | Role and evidence |
| --- | --- |
| Original Phaser GDD | Historical design baseline, [source reference](https://github.com/pedro-ai-coder/aura-farmer/blob/fdbc67b9d79b1d2bfbbcaad40305da1677bc626f/docs/GDD.md), commit `fdbc67b9d79b1d2bfbbcaad40305da1677bc626f`, original Git blob SHA `10beed151c045944811e42aead6533b94df77d3a` |
| Godot GDD V2.0 through 25 October 2026 | Exact preserved file [`GDD_V2_ARCHIVE.md`](GDD_V2_ARCHIVE.md), Git blob SHA `8a932be607add8b3c3cd646e168467f027cf0f6a`. Includes historical Phaser work, older 15-minute/180-second schedule, previous platform and art approvals plus subsequent amendments. |
| Current Godot consolidated **GDD V3.0** (prepared 25 October 2026) | [`docs/GDD.md`](GDD.md), with approved shorter-run mechanics, Clean Cut art, and owner-approved **M0 fully polished restricted Web/no backend**, **M1 public Web + Discord Activity with backend and in-game tester feedback**, **M2+ native evaluation**. Its source of truth becomes operative upon owner PR approval and merge. |
| Owner decisions | [Owner decision register](GDD_DECISION_REGISTER.md) records latest supersession, statuses and exact approved art ledgers. No independent Work implementation or migration note may change gameplay or milestone commitments. |

## Preservation and authority

- Old GDD V2.0 is archived **byte-for-byte** to avoid losing design history, early gameplay details or asset provenance. The original file's SHA must not be mistaken for the SHA of the consolidated live document.
- New V3.0 is an **editorial/structural consolidation**, not an authorization for combat balance, gameplay, art bytes, save migration, Phaser changes, paid services or actual release.
- All code, technical documents, PR descriptions and external deliverables must be in English. Current authoritative runtime is Godot 4.7.2 with GDScript and Compatibility renderer.
- Source asset manifests/approval ledgers retain exact owner-signed identities. The V3 GDD references them; it does not reissue approval by description.

## Legacy bootstrap guard

`scripts/bootstrap_gdd.sh` exists only to reproduce the pinned original upstream document **in a fresh folder**. It refuses to overwrite the amended Godot GDD. **Never run it to restore an older canonical design.** Future owner-approved GDD revisions must be made against the current Godot version, with explicit supersession and scoped PR evidence.
