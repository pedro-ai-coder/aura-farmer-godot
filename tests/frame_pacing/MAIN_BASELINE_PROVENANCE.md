# Scoped main-branch simulation parity baseline

`main_a7695eb_windows_states.json` was recorded by executing the unchanged
`state_trace.gd` protocol against the **separate, untouched main checkout**
at `a7695eb86a659fc8b9e065960aee0951ddfdb900`, using Godot 4.7.2 stable on
Windows. The candidate was recorded separately and compared: all three
360-frame state/RNG/event/camera hashes are byte-identical to main.

The former `baseline_states.json` remains unchanged. Its default historical
test was run before changing this gate and fails on untouched main too.
It predates the already merged weapon-presentation, pickup and passive-feedback
changes. It cannot establish whether this asset integration changed simulation.
This change does not regenerate that historical fixture from the candidate or
label the original historical check a pass.

The validation suite now explicitly selects the source-main baseline for this
cosmetic integration. Existing irregular-frame displacement, real keyboard and
touch, release/reversal and pause/resume assertions still run, as do all combat,
RNG, kit, save and original/female simulation-parity tests. The original default
historical comparison remains available as a diagnostic.

This is a platform-specific serialized-state fixture, not a claim of portable
bitwise floating-point identity across every operating system. A different
platform must record and verify its own unchanged source-main control rather
than adopt candidate-generated values.

For this approved-art branch the required GitHub workflow independently checks
out the PR base SHA under an ignored parent, records that unchanged project's
trace on the same Linux runner/engine and supplies `GODOT_STATE_REFERENCE` to
the candidate validator. All simulation comparisons and the other 79 Godot
phases still run. The original historical fixture and default diagnostic remain
unchanged; other branches keep their original validation path.

On 2026-11-15 the creator approved preview `9775d8f75b0a0a00929b55c648d771a17ba16777`
for merge and production. The empty trigger commit `4e3268f966d79294e627980f8f85af8d26aebccd`
preserved its entire tree. Required Linux CI run `43726982367` reached the
historical state comparison and failed against `baseline_states.json`; its
workflow had scoped the same-runner control only to the preceding individual-sheet
branch. The identical control checkout/recording steps now also apply to
`art/full-approved-hero-atlases`, pinning the untouched PR base SHA. No fixture,
assertion, runtime script, source artwork or production asset is changed by this
CI wiring correction. A fresh required run must pass before merge; the failed
historical comparison remains visible in GitHub.

The new CPK presentation review stack (`feat/cpk-*`, the scoped Signal Breaker
Garage branch, `fix/cpk-*`, `build/cpk-*`) also uses the same untouched-PR-base
control when its normal mandatory workflow runs. The 2026-11-15 local aggregate
executed 112 checks and separately compared candidate state/RNG/event/camera
traces against stable production `0007cb62aca84e6af8a1018c82b684199c7e8cdb`.
New review PRs remain Draft; no new Linux CI pass, merge or release is inferred
from this preparation. Historical fixtures and mandatory assertions are retained.
