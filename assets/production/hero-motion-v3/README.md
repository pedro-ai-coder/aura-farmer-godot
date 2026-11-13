# Approved six-appearance motion integration

Creator approval and explicit integration authorization were given in this chat
on 2026-11-13. `approval.json` pins each approved source PNG by SHA-256;
`manifest.json` pins the derived runtime resources and frame registration.
Original PNG bytes live under `source/` and are excluded from Godot imports and
browser exports. Earlier CPK/V2 resources remain unchanged for provenance.

`scripts/prepare_approved_motion.py` reproduces the technical alpha isolation
and padding with the existing Pillow/numpy/scipy artwork environment. It never
paints replacement pixels or fabricates poses. All six run cycles contain eight
approved drawings; fixed registration retains the authored airborne offsets.
CanvasTexture applies linear mipmapped sampling only to hero draw calls.

The revised Pixel Vixen portrait supplies her stopped body and HUD identity, so
combat-state selection cannot restore the old chibi body. Only full-body
portraits and running cycles were approved: non-run body states hold the matching
portrait, while the existing weapon/Flex observer continues its canonical VFX.
No new attack, damage or defeat drawings are claimed by this integration.

Canonical hero/appearance keys, gameplay values, clocks, RNG and saves are
unchanged. `scripts/verify_approved_motion.py` validates exact sources, exports
and the six identity pairs; `tests/test_approved_hero_motion.gd` exercises actual
travel, eight-frame playback, facing, stopping and canonical state precedence.
