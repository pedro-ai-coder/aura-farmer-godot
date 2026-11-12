# Six-hero mobile review — draft, remote PNG upload blocked

Based on Cool Kid game PR #124 (`e84af3c5a7ad1a369fae27300a0fd4e1441a01da`); reuses Art PR #17 exports and the existing Pixel Vixen CPK atlas. GDD V3 and all three gameplay kits remain unchanged. Motion PR #122 and Level Zero PR #121 are not incorporated.

Local implementation: Sigma approved-source normalization and playback; Pixel Vixen imported-pixel verification and matching CPK portrait; preserved Cool Kid integration. Byte Baddie, Alpha Chad and Block Queen retain their existing artwork. New CPK candidates remain pending because reliable binary transfer is unavailable; no generation credits were used.

One local Web export and the relevant PCK resource checks also passed.

Actual checks: approved Sigma SHA-256, 49 padded poses, Godot 4.7.2 import/startup, exact existing CPK hashes, and six real touch selections/run starts at 844×390 PASS. No long simulation, screenshots, videos, benchmark or browser matrix was run. Creator mobile and artistic acceptance remain pending.

**Remote blocker:** the original Sigma PNG is omitted at the creator's explicit request. The connector also rejected the derivative atlas upload because automatic review exceeded its input budget. Both runtime Sigma PNGs are prepared locally but absent from this draft PR. The build verifier intentionally fails when those files are absent; do not claim a ready six-hero CPK deployment.

Source SHA-256: `cde14c7dbaadf1d4a04842f91623ebe01302b346ce89939a3063007b0c2a4561`; computed Git blob: `1030a2c597bbd1649a84226ed59cb1b77728d16b`; approval: `CPK-ART-SIGMA-2026-11-10-01`. No source import commit exists. Exact derivative hashes and pivots are in `assets/production/the-sigma/cpk-v1/manifest.json`.

Finish by importing the two prepared derivative PNGs into this review branch, then create one protected preview in the existing Vercel project. The original source remains local unless the creator authorizes its upload again. No merges, production deployment, protection changes or new services are authorized by this draft.
