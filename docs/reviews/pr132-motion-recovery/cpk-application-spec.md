# Exact CPK application — blocked implementation specification

Status: **BLOCKED, no art promoted or replaced**. This is separately reviewable
from the motion engineering diff. No downstream character application is approved
by this specification. GDD V3 and the decision register remain operational.

## Immutable authority and availability

- Canon brand decision `CPK-BRAND-2026-11-09-01`, read at Canon main
  `a6e7bd420e7cda7cd1da2ed78c6b099d9b6d4d1f`:
  `decisions/CREATOR_FINAL_CPK_BRAND_IDENTITY_2026-11-09.md`.
- Exact approved board: `painel_de_identidade_clutchpunks_cpk.png`, SHA-256
  `c86b6d519e886bb2e43c861967c352269855914e7cfe1f06100366fd01f4bc1d`,
  1448 x 1086 RGB, 2,868,520 bytes.
- Art main `bd96de0dcb9bfa55337cf1740e9b347d049f3946` and brand branch
  `9d8955d0c18ea12c789b895197cb215329274bf2` contain the approval text and
  manifest, but no binary at `source/brand/cpk/2026-11-09/cpk-approved-identity-board.png`.
  The manifest explicitly records `committed_in_this_repository: false` and
  `binary_source_import: PENDING`. The attachment is absent from this workspace.
- Art PR #19 `81fb725792eda2ce90075a06ac26e9459681088d` contains hero sources,
  not the missing brand master. Canon PR #34
  `bbd290950424379bca086cb221da77af09550a2c` approves their exact design sources;
  it does not supply an isolated approved emblem or approve runtime motion.

## Manifest reconciliation from bytes

The older Art PR #19 manifests say PROPOSED; the later Canon decision
`CPK-ART-THREE-HERO-SOURCES-2026-11-12-01` explicitly supersedes **source design
status**, preserving historical proposal manifests and keeping runtime acceptance
pending. Game manifests already separate these two statuses; no historical hash
or approval record needs overwriting.

Actual PNG bytes from the immutable Art commit match all three Canon hashes:

| Source | SHA-256 |
| --- | --- |
| Byte Baddie | `6307c9fae4476640f7b9afe48414f6a55557a7a45f71dd0c48d3446b0580df3b` |
| Alpha Chad | `e0fcb9b3a8512aa7118c81da160a05e22bb8e0f17a4c7d37063429e321e51d35` |
| Block Queen | `7c832e825a3e261c14149583352dc738322e34c8bbd3e08a6d4143d7d93ffe30` |

The motion package calls Alpha/Queen's framed portraits its `source/portrait.png`:
these are technical derivatives, not different approved originals. The preserved framed portrait hashes are: Alpha
`20eaa3f34a6f0ba92c986b4fb32729172d291e8bc5c19d0300d21a702a3eab7f`,
Queen `65cac41a98866aa4153a8009912fb704f63185fd2e98936526955d914cdcec0c`.
Repeating the crop/contain/pad algorithm in this environment does not reproduce
the historical PNG byte hashes, but decoded RGBA arrays are exactly equal for
both portraits (zero differing pixels). This reconciles the derivative chain
without silently rewriting immutable PNGs; byte-reproducible historical encoding
is not claimed. The preserved hashes identify the existing integration inputs.
Byte's portrait source remains the exact original. Existing downstream hashes
and the November 13 integration record remain unchanged.

## Isolated candidate application plan

Every row is blocked by the same missing exact emblem source. These are proposed
locations for review, not authorization to paint over approved costumes.

| Appearance | Proposed existing surface | Registration / review requirement |
| --- | --- | --- |
| Pixel Vixen | Jacket upper sleeve | Retain sleeve, hair, silhouette and embedded blaster; register through every run cell and portrait |
| Cool Kid | Jacket sleeve panel | Retain existing outfit and held equipment; do not introduce a replacement character or weapon |
| Byte Baddie | Jacket upper sleeve | Preserve pink/black costume and keyboard silhouette; do not obscure hands |
| Alpha Chad | Existing shield plate | Keep shield outline, gauntlets, occlusion and contact geometry |
| Block Queen | Existing shield plate | Preserve shield silhouette and gold/green outfit; no floating badge or generic replacement symbol |

Once exact board bytes are available, fail closed on a SHA mismatch. Isolate the
approved integrated C/P/K geometry and angular broken ring without tracing an
approximate replacement. Preserve `#F3E9DB`, `#FF6A00`, `#9B00FF`. Keep the master
immutable; record crop/mask coordinates, tool versions, source SHA, derivative
SHA and alpha treatment in a versioned export manifest. Seek exact-byte review
for crops/transparent exports before character promotion. Register approved
applications to equipment/clothing in each authored frame, with no silhouette
or gameplay changes; review applied art separately from engineering.

Required checks after that gate: transparent export on light/dark backgrounds;
24/48/96 px emblem crops with all three letters and ring inspectable; actual
70-world-unit body at gameplay zoom; idle/run/left-right views; selection/HUD;
byte hashes and reproducibility. Current 24/48/96 px **exact emblem legibility is
NOT_RUN/BLOCKED**, not passed using a lookalike or existing painted CP/CPK text.

Rollback: this document changes no runtime or art. Any future export/application
must be its own scoped art commit, reversible independently of motion code.
