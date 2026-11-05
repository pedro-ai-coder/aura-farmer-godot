# Level Zero — WebGL2 browser preflight

**Status:** EXPERIMENTAL QA aid, not gameplay approval or completed acceptance.

This scope is separate from Level Zero intro/input fixes made on another workstation. It does not modify `solo_run.gd`, `level_zero_run.gd`, combat, profiles, RNG, art, or canonical rules.

The normal Web route (`/`) is unaffected. When opening `/?level_zero=1` in a new Web export, a separate disposable canvas checks whether the browser can create a WebGL2 context; the Godot gameplay canvas is never used for this probe.

- WebGL2 available: no visual overlay; `window.__clutchpunksLevelZeroPreflight.webgl2_available` is `true`.
- WebGL2 unavailable or blocked: show an accessible explanatory notice; the same flag is `false`.
- This flag only records browser capability. It is NOT evidence of Godot initialization, actual rendering, controls, a real playthrough, victory, replay, or performance.
- No network calls, gameplay state changes, localStorage writes, telemetry or persistent identifiers are added.

The HTML injector fails closed if the Godot export structure is unexpected. No binary artwork or new export templates are introduced.

## Focused checks

```sh
node tests/test_level_zero_web_preflight.cjs
python3 -m unittest discover -s tests -p test_level_zero_web_preflight.py
bash -n scripts/build_web.sh
```

A full Godot Web export and physical-browser acceptance still need to be performed separately. A build success must not be represented as a WebGL2 gameplay pass.

The draft-only branch explicitly disables Git-triggered Vercel deployment for its own branch in `vercel.json`. Before any future merge, confirm the target branch's deployment policy separately. This change does not authorize a release.
