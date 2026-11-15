# Full character atlases — replacement of provisional pose playback

The creator clarified that the heroes were integrated but not finalized, and
requested complete new-style animation atlases. The old Sigma, Cool Kid and
Alpha atlases at Game commit `2298e39ab727a88defd7c421f95969f30a422212` are
**structure/coverage references only**. None of their old character drawings
is copied into the new animation atlases.

The creator authorized the implementation plan and explicitly removed gameplay
testing/visual-proof step 8: **“eu irei fazer os testes”**. Therefore this change
is delivered as a PR for creator testing; no game launch, gameplay tests,
browser journey, performance test, merge or deployment is claimed or performed.

## Deliverables

Six newly drawn RGBA source sheets, each with 64 distinct frames, retain the
approved new Sigma, Cool Kid, Pixel Vixen, Byte Baddie, Alpha Chad and Block Queen
identities. Style authority remains the approved individual source sheets from
`CPK-HERO-SHEETS-INTEGRATION-2026-11-14-01`. New animation drawings are proposed
deliverables for review, not implied approval of every final animation detail.

`source/hero-atlases-v2/{hero}/` retains each original generated PNG and the exact
built-in image-generation prompt. `assets/production/heroes/full-atlases-v2/`
contains the packed runtime atlases and the source/output hash, cell, pivot and
sequence manifest. Source PNGs and prompts are excluded from runtime exports.

| Cells, zero-based | Sequence |
| --- | --- |
| 0–31 | Eight run directions × four alternating contact/passing frames |
| 32–35 | Four front idle drawings |
| 36–39 | Four rear idle drawings |
| 40–43 | Front attack: windup, execution, follow-through, recovery |
| 44–47 | Rear attack: windup, execution, follow-through, recovery |
| 48–49 / 50–51 | Front / rear hurt and recovery |
| 52–53 / 54–55 / 56–57 | Flex windup / execution / recovery |
| 58–63 | Six-stage defeat: stagger, buckle, fall, land, settle, prone rest |

The original concept masters and old atlas files remain untouched as historical
provenance. The active body-rendering route uses only the new v2 atlases. Existing
approved portrait/HUD illustrations are retained.

## Integration

`full_hero_atlases.gd` replaces the provisional 12-pose runtime player. Every run
direction selects its own drawn sequence. There is no static-front substitution
for missing directions, no reflected CPK lettering, and no rotating a standing
cutout to simulate defeat. Animation uses the canonical moving/heading/walk,
idle clock, attack, hurt, Flex and defeat descriptors. A shared fresh descriptor
also retains real weapon anticipation/recovery, rather than losing decorated
presentation timing between the animation and renderer.

The packer crops the real 8×8 source cells, retains their original RGB/alpha
edges at alpha 4/255 or above, discards generator padding at alpha 1–3/255,
removes tiny disconnected alpha specks and adds transparent gutters.
Fully transparent padding has its invisible RGB cleared; visible colors are unchanged.
It uses one per-hero ground anchor derived from the idle drawings and one fixed
world scale per hero. It does not mirror, repaint, interpolate, duplicate poses
or use code transforms to manufacture new animation drawings.

The three canonical kits, attack/Flex events, balance, IDs, RNG, collisions and
save/appearance schema are unchanged. No new characters or mechanics are added.

## Review and testing status

File assembly checks cover RGBA, source/output hashes, 64 nonempty distinct cell
images and in-bounds cell/pivot registration. These are asset-preparation checks,
not game tests or visual acceptance. Existing resource assertions are updated to
read the v2 layout, but are **not executed** in this delivery. The creator owns
in-game review and finalization of the new atlases. The PR remains Draft and is
not merged or deployed.
