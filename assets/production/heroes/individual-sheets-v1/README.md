# Approved individual character sheets — runtime integration

The creator approved these exact six individual sheets and explicitly instructed:
**“Estes assets estão aprovados. Integra-os no jogo de uma vez por todas!”**
Decision: `CPK-HERO-SHEETS-INTEGRATION-2026-11-14-01`.

The six `approved-source.png` files retain the exact Art source bytes at
`52c8618098c68034f42ec469567effc952cfdb27`. `manifest.json` pins each source
and runtime atlas/portrait/HUD hash, original crop coordinates and foot pivots.
This explicit approval supersedes the previous **DERIVED FOR REVIEW** status
for these exact six sheets. It does not approve arbitrary new artwork.

The import script preserves original RGB pixels, crops poses, flood-masks only
exterior neutral background, removes detached typography and packs transparent
cells. It does not generate, repaint or resize character artwork. A model-view
caption touches several three-quarter drawings; the unused slot 1 and selection
portrait deliberately use the approved idle pose instead of cutting/repainting
heads or shipping caption pixels. That substitution is explicit in the manifest.
There are 12 atlas cells per hero, including this documented duplicate, not 12
new independently authored animation drawings.

Gameplay uses these poses with small presentation transforms for breathing,
locomotion, hurt, existing Flex phases and defeat. Rear/front model views cover
opposite headings without reflecting CPK letters or swapping shield ownership.
Existing animation-state precedence, attack/Flex event timing, hitboxes, kits,
stats, seeded RNG, profile IDs and saves are unchanged. No independently authored
inbetweens or a complete new eight-direction animation set are claimed.

Selection, HUD, results, retry and live gameplay all resolve this pack. Textures
are retained by the renderer cache to avoid white rectangles from freed textures.
The rejected Pixel Vixen CPK v1 atlas remains in repository history/source paths
for provenance, is never loaded by the active renderer and is excluded from
the new Web export. The labeled approved originals are also excluded from exports.

Rebuild: `python scripts/import_approved_hero_sheets.py` (Pillow 13+).
The importer can use either the source Art checkout or the retained originals
in this directory, without network access. Verify before and after export with
`python scripts/verify_approved_hero_sheets.py [path/to/export.pck]`.
