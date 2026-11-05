# Level Zero experimental visual binding — implementation candidate

**Status:** EXPERIMENTAL / NOT ART APPROVED / private review only. Operational GDD V3 is unchanged.

## Result of this focused PR

The base Godot controller now exposes **presentation-only** seams for world backdrop,
decorative foreground and actor sprites. Default methods continue to draw exact Ruin Alley
visuals, including its existing Beta Bot and defeated actors. Only the Level Zero adapter
uses the optional candidate-asset bridge. This change does not touch input, gameplay state,
encounter schedule, RNG, save format, collision, world size, camera logic or content IDs.

**No art PNGs are present in this PR.** If the optional pack is absent, the game
continues to look like normal Ruin Alley, with the Beta Bot visual. This is intentional
fail-closed behavior, not proof that final visual integration has happened.

## Exact sources and separation

The creator selected the **corrupted-message print factory** setting direction, not the
exact final image bytes. The three original candidate sources are tracked as metadata in
[Art Pipeline PR #6](https://github.com/pedro-ai-coder/clutchpunks-art-pipeline/pull/6):

| Source | Recorded SHA-256 | Dimensions | Runtime treatment |
| --- | --- | --- | --- |
| `print_press_arena_candidate.png` | `0eb3f31bc22d5508c4fb3553335fe3279e3de3ec46566a3581a11d0f8931ed23` | 1672×941 | Optional ground backdrop after byte verification |
| `torn_poster_foreground_candidate.png` | `ceff210f3f642457ae4bd01507b96e9be431728cb0c339b9cbe3847fd1acb76d` | 1672×941 | Source for a separately masked, transparent foreground (NOT the raw concept board) |
| `big_hater_imitation_candidate.png` | `7510fb0805f8ec9afa2ce1148a6ca50e2bb996bbc721bc6a6c4a90d68ae67fcb` | 1312×1199 | Concept only: needs independent transparent sprite, documented foot pivot/scale |

New derived PNGs receive **new export hashes** and cannot claim the source concept hash as
their own. No candidate becomes APPROVED through runtime use.

## Optional versioned staging

After actual Art Pipeline source recovery, stage an **experimental-only** content pack
under `assets/experimental/level_zero/`, with the exact names defined in
`scripts/level_zero/visual_assets_v1.gd` and a `visual_pack_v1.json` manifest.
Do not commit a synthetic replacement. Example shape:

```json
{
  "schema_version": "level-zero-visual-pack-v1",
  "status": "EXPERIMENTAL_CANDIDATE",
  "source_commit": "PINNED_ART_PIPELINE_SHA",
  "background": {
    "path": "res://assets/experimental/level_zero/print_press_arena_candidate.png",
    "status": "CANDIDATE",
    "source_sha256": "0eb3f31bc22d5508c4fb3553335fe3279e3de3ec46566a3581a11d0f8931ed23",
    "verified_export_sha256": "ACTUAL_SHA256_OF_EXPORTED_PNG",
    "dimensions_px": [1672, 941]
  }
}
```

The foreground and boss use the same path/status/hash/dimensions contract, plus:
`combat_safe_mask_reviewed: true` for an actual transparent foreground export;
`independent_sprite_master: true`, `foot_pivot_px: [x,y]`, and a verified
`world_height` for the transparent boss sprite. **These review values are not
supplied or invented by this PR.**

A manifest alone is not proof of genuine source bytes: first verify the original
Art Pipeline source SHA(s), then verify each staged export PNG and dimensions using:

```sh
python3 scripts/verify_level_zero_visual_pack.py
python3 -m unittest discover -s tests -p test_level_zero_visual_pack.py
godot --headless --path . --import
godot --headless --path . --script res://tests/test_level_zero_visual_bindings.gd
```

The optional visual-pack checker is also called by `scripts/build_web.sh` to fail
a Web export if a staged pack contains missing files or mismatched export hashes.
Absent art is allowed, and explicitly means **placeholder visual state**.

## Rendering and review boundaries

- Background uses aspect-preserving center crop into the existing Ruin Alley-sized
  visual rectangle. It is **not** new geometry. A 1672×941 source cropped into
  1448×1086 can lose left/right content; require camera/viewport approval.
- Foreground is drawn before character sprites, pickups and hazard cues. It cannot
  intercept input or obscure actual damage indicators. Only a specifically
  masked/reviewed foreground is eligible.
- The boss uses a standalone sprite with a declared foot pivot and world height;
  the original multi-element concept board must not be loaded as a combat sprite.
  HP bars and telegraphs remain drawn by the existing simulation renderer.
- Normal `/` Ruin Alley, all approved art, deterministic seeds 451/468/485,
  profiles and exported normal save paths remain unchanged.

## Remaining acceptance (NOT RUN)

1. Recover original three PNGs and exact source byte hashes in Art Pipeline.
2. Produce independently usable and transparent foreground/boss sprite exports.
3. Record actual pivot, scale, review provenance, export SHA-256s and manifest.
4. Run exact Godot 4.7.2 imports/tests on Codex-patched local baseline and verify
   intro, selection, player movement, all three waves, boss visual/reaction/hazards,
   defeat/victory/replay and normal Ruin Alley parity.
5. Validate desktop 1920×1080 and 1280×720; mobile landscape 844×390 and 915×412.
6. Record source SHA, manifest, GDD V3 baseline, test commands/platform and results.

**No Web preview, merge, canon change, artist approval or release is authorized.**
