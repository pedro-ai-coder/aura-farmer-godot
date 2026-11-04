# Level Zero local development baseline

This is a local development milestone, not acceptance of proposed Level Zero rules,
narrative or artwork. Operational GDD V3 and approved creator decisions govern.
The creator-selected setting remains the **corrupted-message print factory**;
this checkout still uses the existing environment and prototype placeholders.
No missing candidate images were imported and no asset approval was changed.

## Provenance and targeted inspection

- Candidate: [PR #108](https://github.com/pedro-ai-coder/aura-farmer-godot/pull/108),
  inspected 2026-11-04, open/draft, unmerged, one commit, 12 changed files.
- Exact candidate HEAD: `261481a7dfb62453dea0e2140db3cdbbf4a62c6c`.
- Base/main: `e43236014044533bad41c944222736cce441cf5f`.
- [Godot CI run 41840747863](https://github.com/pedro-ai-coder/aura-farmer-godot/actions/runs/41840747863)
  was **skipped**, not a passing validation of this draft.
- The selected Windows workspace was empty: no pre-existing checkout or local
  changes. A shallow candidate checkout was created, then isolated on local branch
  `codex/level-zero-local-baseline`. Nothing was pushed or deployed.

## Launch on this Windows machine

From PowerShell:

```powershell
Set-Location 'C:\Users\Pedro\Documents\ChatGPT\CLUTCHPUNKS - Game\aura-farmer-godot'
$env:GODOT_BIN = (Resolve-Path '..\.tools\godot-4.7.2\Godot_v4.7.2-stable_win64.exe').Path
python scripts/level_zero.py play
```

The helper verifies the existing art, imports resources, opens Level Zero, and
waits for its window to close. Each invocation prints its log directory under
`reports/level-zero/<UTC timestamp>/`. All logs, commands, engine version/hash,
platform, Git HEAD/status and seeds are recorded there. `play.log` contains engine
output from the interactive session.

Both `play` and `check` use a fresh isolated native user-data directory beneath
that report. This keeps normal-mode tests and the NORMAL RUIN ALLEY button from
writing the user's real profile. Preferences therefore start from defaults in the
helper. The Level Zero adapter itself continues to suppress save/result writes.

Choose a hero/appearance, START RUN, then SKIP / ENTER LEVEL ZERO. WASD/arrows move;
attacks are automatic; E/Space activates Flex when ready; M changes aim mode;
P/Escape pauses. Upgrade cards use pointer or 1–6 followed by explicit confirmation.

To debug in the editor:

```powershell
& $env:GODOT_BIN --editor --path . --scene res://scenes/level_zero.tscn
```

Use **F6** for the open Level Zero scene. **F5** runs the default normal main scene.
Direct engine/editor launches use the normal Godot user-data location unless you
isolate it yourself. The helper is the recommended disposable testing path.

## Prerequisites on another checkout

- Python 3.10+, Git, Node.js 18+ for checks, and exact Godot **4.7.2 stable**, using
  Compatibility. Set `GODOT_BIN` or pass `--godot /path/to/engine`.
- The helper supports Windows and Linux; only Windows was exercised here.
- The portable Windows engine came from the [official 4.7.2 release](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable).
  Archive `Godot_v4.7.2-stable_win64.exe.zip` SHA-256:
  `731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953`.
  Executed engine: `4.7.2.stable.official.ed1daf0bf`.
- No system install or PATH changes were needed. `.tools` is outside the repository.
- Keep the two manifest-hashed `frames.json` files at LF, as `.gitattributes`
  requires. A prior Windows checkout may need those two unchanged files checked
  out again after applying the attributes. Do not edit hashes to accept altered bytes.
- Godot may create untracked `.gd.uid` / `.import` sidecars on first import. These
  generated files are not part of this patch; review them separately from source edits.

## Focused verification

```powershell
python scripts/level_zero.py check
```

The helper checks original and female asset integrity, imports the project, runs
18 focused Godot test scripts, starts both scenes headlessly, runs the existing
Node Web platform contract and four Python tooling regressions. It enforces
timeouts and rejects script/resource errors even if Godot exits zero. It does not
silently turn headless tests into a claim of completed gameplay.

Equivalent individual engine checks, after import:

```powershell
& $env:GODOT_BIN --headless --path . --import
& $env:GODOT_BIN --headless --path . --script res://tests/test_level_zero.gd
& $env:GODOT_BIN --headless --path . --script res://tests/test_level_zero_input.gd
& $env:GODOT_BIN --headless --path . --scene res://scenes/level_zero.tscn --quit-after 10
```

The complete existing Linux suite is `bash scripts/validate.sh` (GNU timeout,
Node and Godot on PATH). It now also includes both Level Zero tests. The full
repository suite was not run for this focused milestone.

## Entry, dependencies and export boundary

| Area | Existing resource |
| --- | --- |
| Level Zero native entry | `scenes/level_zero.tscn` |
| Content adapter/config | `scripts/level_zero/level_zero_run.gd`, `candidate_v1.gd` |
| Normal native entry | `scenes/main.tscn` (project default) |
| Shared gameplay | `scripts/solo_run.gd`; `solo_clock.gd`, `solo_*_rules.gd`, `phaser_rng.gd`, `profile_store.gd` |
| Presentation | `arcade_presentation.gd`, `clean_cut_skin.gd`, `hero_clash_hud.gd` |
| Existing assets | `assets/approved/`, `assets/runtime-icons/`, `assets/runtime-clean-cut/v2/`, existing candidate manifests under `assets/art-candidates/` |
| Cosmetic integrity | `hero_appearance.gd`, `female_appearance_art.gd`, Byte Baddie/Block Queen `v2/frames.json` |
| Browser entry | `/?level_zero=1`; `/` remains normal Ruin Alley |

No dedicated QA Recorder / QA Scenario Mode implementation was found in this exact
candidate's scripts or targeted docs. Existing scene/input tests were reused.
`scripts/performance_probe.gd` exists for optional performance review, excluded
from ordinary Web exports; no replacement recorder or new gameplay scenario
system was introduced.

`export_presets.cfg` has a runnable **Web** preset. This PC had **no export
templates**, so Web export was not attempted. The existing supported Linux build
command is:

```sh
GODOT_BIN=/path/to/godot GODOT_SKIP_TEMPLATE_DOWNLOAD=1 bash scripts/build_web.sh
```

Use that only after installing verified matching 4.7.2 Web templates. It requires
the existing shell utilities and prepares `build/web`; it does not deploy. Do not
infer a new Windows Web build or browser pass from the candidate's earlier Linux
export evidence. This task did not download the 1.28 GB template archive.

## Verified defects and changes

1. **Windows female starts failed.** Git's system `core.autocrlf=true` changed
   geometry JSON bytes. `verify_female_variants.py` reported a SHA-256 mismatch;
   the candidate Level Zero test failed twice and the female-roster test could
   not start. Two exact LF attributes restore the already-versioned bytes without
   changing geometry, manifests, artwork, gameplay or RNG. A real Git checkout
   regression exercises `core.autocrlf=true`.
2. **Intro input was blocked.** The live shared focus ring selected an underlying
   CONFIRM control instead of the intro buttons. Native pointer/Enter attempts
   failed. A small presentation seam lets the adapter supply the intro focus root;
   normal scenes retain the same default root. Real viewport mouse, Enter, Tab,
   touch, menu return and profile-byte checks cover this at 1280×720, 915×412 and
   844×390. Disabling the fix reproduces failure with the new test.
3. **Local verification was hard to repeat.** A Python launch/check helper adds
   explicit engine selection, disposable profiles, time limits and retained
   evidence. It reuses existing tests and adds no game instrumentation.
4. **The old contract could reuse a previous hero after a refused start.** It now
   returns to the menu between selections and verifies actual hero ID, starter
   weapon and seeds 451/468/485 for all six selections.

## Evidence and remaining acceptance

Initial Windows candidate result: import and Level Zero startup succeeded, and
the normal scene loaded in the existing tests;
13/15 targeted Godot tests passed, `test_level_zero` and `test_female_roster`
failed. Approved original assets and the Node Web contract passed. Raw baseline
logs are in `reports/level-zero-baseline/`.

Platform: Windows 11 Home x64, version 10.0.26300; native OpenGL 3.3 Compatibility
on AMD Radeon RX 6800 XT (driver 26.8.1.260806). Native UI inspection confirmed
menu rendering, female selection, Byte Baddie startup and the intro. Computer Use
was stopped by the user with Escape before the repaired intro could be rechecked
interactively. No full ordinary-health playthrough, boss readability, victory,
real-device touch/performance or browser WebGL2 acceptance is claimed.

Consult the final local `reports/level-zero/.../summary.json` for the exact tested
SHA and per-command final results. Automated boss/outcome/replay tests manipulate
time/HP and are synthetic boundary evidence. Headless landscape input tests are
not physical mobile-device validation.

| Priority | Remaining item |
| --- | --- |
| P0 | No remaining execution blocker identified by completed automated checks; interactive recheck remains open. |
| P1 | Human smoke: repaired intro → movement/XP/legal upgrades/Flex → real defeat or victory → replay; then an ordinary-health three-wave/boss run. |
| P1 | Web acceptance: matching templates, local export, actual WebGL2 desktop and mobile-landscape input/outcome/replay, independent normal route and save proof. |
| P1 | Creator decisions/acceptance: proposed three-wave pacing, prototype/narrative, final factory/boss art treatment. Keep existing placeholders until approved verified files exist. |
| P2 | Broader all-kit pacing/readability and physical-device performance after the first successful complete smoke. |

**Next small task:** complete the repaired native smoke with a human, record the
exact SHA/hero/seed and outcome, and fix only the first reproducible blocker.
Do not rebalance or replace art to compensate for an unverified problem.
