# Six-character CPK mobile preview — PROPOSED

Continues the existing combined review branch. Exact unmodified new sources and SHA-256 manifests: Art PR https://github.com/pedro-ai-coder/clutchpunks-art-pipeline/pull/19 at 81fb725792eda2ce90075a06ac26e9459681088d. All three new candidates are PROPOSED, PREVIEW_ONLY and pending creator approval.

Byte Baddie, Alpha Chad and Block Queen each use one newly generated illustration. Runtime derivatives in assets/art-candidates/{hero}/cpk-v1-proposed provide 24 transformed cutout frames across idle/run/attack/hurt/Flex/defeat, selection portraits and HUD portraits. These are cutout animations, not separately drawn poses. Selection cards identify them as PROPOSED. The Sigma, Cool Kid and Pixel Vixen keep their existing exact CPK resources and playback. Gameplay kits, balance, RNG, saves, weapons and Flex mechanics remain unchanged.

One local Web export and the relevant PCK resource checks also passed.

Actual checks: approved Sigma SHA-256, 49 padded poses, Godot 4.7.2 import/startup, exact existing CPK hashes, and six real touch selections/run starts at 844×390 PASS. No long simulation, screenshots, videos, benchmark or browser matrix was run. Creator mobile and artistic acceptance remain pending.

The previous remote Sigma derivative upload blocker is resolved in the existing review branch. The original Sigma PNG remains omitted as previously requested.

Source SHA-256: `cde14c7dbaadf1d4a04842f91623ebe01302b346ce89939a3063007b0c2a4561`; computed Git blob: `1030a2c597bbd1649a84226ed59cb1b77728d16b`; approval: `CPK-ART-SIGMA-2026-11-10-01`. No source import commit exists. Exact derivative hashes and pivots are in `assets/production/the-sigma/cpk-v1/manifest.json`.

Only an existing-project Vercel Preview is authorized. No merge, production deployment or new service is included.
