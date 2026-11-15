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

## Deployment result

- State: **READY**, Preview (API target omitted/null; no production promotion).
- Deployment: `dpl_EFWQZsRusWpCWaYT3HbRWjXaXEMq`.
- URL: https://aura-farmer-godot-bkdbpalpi-pedroestrela6-8110.vercel.app/.
- Deployed commit: `42d27548a22dc658134b513423d80a2a65b7acf4`.
- Server build: standard 2-core / 8-GB machine, about two minutes; remote
  candidate/approved resource and PCK checks passed.
- Authenticated Vercel fetch: HTTP 200 for `/` (CLUTCHPUNKS loader) and
  `/build.json`, which confirms that exact commit and Godot 4.7.2.
- Local Chromium: Neon Garage -> real Cool Kid play -> F8 A/B -> pause,
  no JavaScript/console runtime errors. RNG and canonical-clock tests also passed.
- Remote interactive browser: NOT_RUN, navigation failed with
  `net::ERR_TUNNEL_CONNECTION_FAILED` from the managed environment. This is
  distinct from the successful remote HTTP/metadata checks and local Wasm test.
- Existing Vercel authentication protection was retained. A temporary share URL
  was created for the creator; its access parameter is not committed here.
- Independent Draft: https://github.com/pedro-ai-coder/aura-farmer-godot/pull/151.

This documentation receipt is later than the deployed commit and does not
change the deployed runtime. Main and the production deployment were not merged
or promoted by this work.
