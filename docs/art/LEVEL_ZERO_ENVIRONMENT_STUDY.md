# Separate Level Zero environment and entry study

**Status:** EXPERIMENTAL / PROPOSED; not operational Solo, final demo or approved entrance timing.

Audited existing prototype `7b0bf708f33f4a5a601e514a1164e714838f39a3`: factory visual pack, source-space floor landmarks and navigation fixes. The exact backdrop was reconstructed from that commit's three base64 source chunks and verified against `0eb3f31bc22d5508c4fb3553335fe3279e3de3ec46566a3581a11d0f8931ed23`. Existing underlay matches `ceff210f3f642457ae4bd01507b96e9be431728cb0c339b9cbe3847fd1acb76d`. Preserved in Art `b4cdd676f9c9de0543e4b62935612228bf0a715a`; no recreation, new approval or boss art import.

`scenes/level_zero_environment_study.tscn` is a real separate Godot scene. It composes backdrop, under-actor paper layer, exact CPK wall sign, contact shadow and approved animated selected hero. It preserves the prior 20 source-pixel floor landmarks and edge clearance with substepped axis sliding. It runs in original 1672×941 source coordinates, avoiding the earlier cropped-world mismatch. The candidate geometry remains isolated; no Ruin Alley geometry is modified.

The review shotboard demonstrates rear-view entry, a restrained camera transition, 3–2–1 and environmental traversal. Exact 1.0s/.6s/countdown timings are PROPOSED review values, not canonical decisions. Reduced-motion mode suppresses the camera zoom. Traversal reads the selected existing kit's canonical movement speed and supports keyboard/touch. Escape returns to the Garage. No enemies, boss ID, phase-stop rules, HP scaling, progression, timer, rewards or save writes are invented. The remaining encounter/demo contract is UNRESOLVED and intentionally not copied from old prototype tuning.

Run locally using Godot 4.7.2 `--path . res://scenes/level_zero_environment_study.tscn`. The configured application entrance remains the Garage and its PLAY still launches operational Ruin Alley. No extra Garage game action is added. A future explicitly approved demo adapter can consume the selected kit/appearance without silently changing current Solo.

Focused checks cover interior/blocked landmarks, boundary tunnelling, entry progression and configured-main isolation. Native capture and exact candidate hashes are recorded with final review evidence. This is a functional environment/shotboard study, not a completed Level Zero combat demo or new artwork acceptance.
