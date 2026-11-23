# MSG Factory environment art V2 — PROPOSED

This candidate is based on PR #152 commit `acf547c8f17d7ddc0674eeb2701b7804640f992c`. It changes MSG Factory presentation only. The six original scene files, `maps.json`, cover radii/centers, player spawn, camera and Solo rules remain unchanged.

## Art construction

- `arena-plate-proposed.png`: one illustrated industrial arena plate, 1448×1086. The base edit used PR #152's MSG Factory overview for floor silhouette and the creator-uploaded experimental Level Zero print-press art as a style reference. Two targeted edits removed the preview marker and baked cover objects. The resulting plate has an open floor and perimeter machinery.
- `press-housing-proposed.png`: one transparent overhead press housing, 1254×1254. Godot reuses it at each of the four original cover centers and scales the visible machine footprint to each original radius.
- `environment_art.gd`: only style 0 now draws these two image assets. Styles 1–5 retain the PR #152 drawing path.

The plate is fitted to the world with a cosmetic drawing transform; it does not define collision. The prop sprites are placed from `data.covers`, so their centers follow the original geometry. The authored map assets have strong illustrated material treatment, with quiet central combat space and visual structures around the perimeter.

## Provenance and status

Both PNGs are new built-in image generation outputs and remain **PROPOSED, NOT CREATOR APPROVED**. The style reference was itself an experimental candidate, not approved production art. This branch neither promotes nor modifies that source. See `manifest.json` for exact SHA-256 hashes and source lineage. No external proprietary game artwork was used.

Run `godot --path . --script res://experiments/feedverse/capture_msg_factory_v2.gd` with a desktop renderer to produce the review captures in `evidence/feedverse/msg-factory-v2/`. The combat capture starts the existing Solo preview and stages five ordinary enemies through its existing spawn function. It is an in-engine visual sample, not a normal-run balance result.

## Remaining review

The creator should inspect the perimeter and cover fit during actual movement, plus visual readability under denser combat and small Web viewports. The baked plate is intentionally static. New artwork and this placement do not imply approved hazards, machine functions, campaign rules or final art acceptance.
