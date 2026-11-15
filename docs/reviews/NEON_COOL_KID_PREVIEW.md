# Neon menus + Cool Kid articulated preview

Requested combination of current main `2f7cfab5d0b498a2d7dade97ec1adf38e58fda50`
and the candidate implementation from Game #150 (`c0956bfe6b9229f969111bc93af5760a7057bfc1`).
This branch preserves the current Neon Garage/menu coordinator and injects its
existing run factory with the disposable-profile rig review run. It defaults
to original Cool Kid. Other identities retain the current renderer. F8 switches
candidate/legacy in gameplay without modifying simulation. Art is still an
experimental front/three-quarter candidate; #150's direction, leg and action-pose
limitations remain. No candidate artistic approval is inferred.

Normal production entry and export keep the current Neon menus and exclude the
candidate art. Explicit `COOL_KID_RIG_REVIEW=1 bash scripts/build_web.sh` selects
the combined review feature/preset, retaining the current branded Web loader.
Candidate PNG/decoded-RGBA validation now uses Python's standard library so the
existing Vercel build image needs no new package installation.

Validation executed with Godot 4.7.2:
- Headless import and actual Web export passed; candidate and approved PCK assets verified.
- `tests/cool_kid_rig/test_neon_preview.gd`: current Garage, six identities, default Cool Kid, gameplay entry, pure A/B and Byte Baddie exclusion passed.
- `tests/cool_kid_rig/test_rig.gd`: pinned package, 480 sampled poses and fallback passed.
- `tests/test_neon_frontend.gd`: current presentation/state/reduced-motion/RNG contracts passed.
- `tests/test_neon_menu_journey.gd`: eleven menus, six viewports and immutable simulation/profile passed.
- Actual Chromium/Wasm opened the Neon Garage and validated the pinned rig; no browser runtime errors in that check.

Deployment target is the existing `aura-farmer-godot` project
`prj_3LaQVHHdexAvm7ZFwAgOYdpu20jM`, Hobby team
`team_Qboo9LMxLe3dsTikfNtyDtIw`, Preview only. Automatic Git deployment remains
disabled. No production promotion, main merge, paid feature or account-setting
change is part of this request. Deployment ID/URL and final remote verification
are recorded after creation.

Rollback: use F8 inside the preview, or return to the current production URL.
Closing this unmerged branch/PR does not alter production.
