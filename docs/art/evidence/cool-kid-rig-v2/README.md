# Cool Kid v2 evidence — CANDIDATE_NOT_APPROVED

Source/runtime, immutable dependencies, commands and actual results are in
[the review](../../../COOL_KID_ARTICULATED_REVIEW_2026-11-16.md).

`artifacts.json` pins the local movies/ZIPs and input recording. Movies and raw
PNGs are not imported into Git. WebP images are compressed previews of actual
Godot/Chromium capture frames, not pixel-identical fixtures. `inspection` is
synthetic; normal A/B/Flex/death are real gameplay, with a labelled live-clock
QA inset on the unchanged results screen.

`validate.log` and `main-historical-gate.log` are FAIL records.
`validate-main-control.log` is the supplemental 86-phase PASS against the
untouched current-main control, never a replacement historical baseline.
`performance-isolated.json` records three alternating pairs without capture or
browser concurrency. Older exploratory performance files are not delivery.

This entire directory is `.gdignore`d and explicitly excluded from all PCKs.
