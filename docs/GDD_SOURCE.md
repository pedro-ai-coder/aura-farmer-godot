# Canonical GDD provenance and amendment history

The initial complete `docs/GDD.md` was imported verbatim from the prior Phaser repository, then amended in the Godot repository with the owner's **21 October 2026** cross-platform decision.

- Canonical Godot edition specification: `docs/GDD.md` in this repository (including **§23**)
- Original reference: https://github.com/pedro-ai-coder/aura-farmer/blob/fdbc67b9d79b1d2bfbbcaad40305da1677bc626f/docs/GDD.md
- Original reference commit: `fdbc67b9d79b1d2bfbbcaad40305da1677bc626f`
- Original reference Git blob SHA: `10beed151c045944811e42aead6533b94df77d3a`
- **Important:** The new `docs/GDD.md` intentionally no longer matches the original blob SHA after the cross-platform amendment. The original hash remains a provenance baseline, not the checksum for future Godot revisions.

`scripts/bootstrap_gdd.sh` is for reconstructing the original pinned upstream document in a **fresh folder only**; it refuses to overwrite the amended Godot GDD. Never run it as an update mechanism.

All future design changes must be approved and recorded in the Godot edition's `docs/GDD.md`. Architectural or audit notes cannot supersede it.
