# M0 UI cohesion review

Base: `fix/m0-navigation-ui-recovery` at `f94282f01b366e2c8f585435df917c1f32a18e15`, verified against the deployed `/build.json`. `main` was independently verified at `bc69061`; this PR is a scoped delta against the reviewed integration, not a historical-stack promotion into main. No source-art manifest or font bytes changed.

| Required evidence | Actual Godot capture |
| --- | --- |
| Normal Wave / MAX LV 25 | [HUD](evidence/hud-normal.jpg) |
| Centered Big Hater / Berserk | [HUD](evidence/hud-boss.jpg) |
| Build inspection | [Before / after](evidence/build-before-after.jpg) |
| Settings | [Before / after](evidence/settings-before-after.jpg) |
| Victory | [Before / after](evidence/victory-before-after.jpg) |
| Run Over | [Final](evidence/defeat.jpg) |
| Mobile landscape | [Before / after](evidence/mobile-before-after.jpg) |

The boss module is centered directly below Wave, with separate live HP and phase rows. Normal XP progression disappears at 25; `MAX LV 25` remains. An existing bounded feedback cue appears only after effective canonical post-cap healing. Its formula, support scaling and 20-second gate are unchanged. Thin passive joins connect the existing bottom modules within their prior boundary; Flex and contextual Safe Spot behavior are preserved.

Build reuses the existing formatter, eight slots, approved icon registry and item metadata. Three desktop columns fit the full build without scrolling; constrained views scroll internally. Settings use a centered maximum width, compact controls and the same callbacks/persistence. The browser fullscreen action retains the original trusted DOM event path and retry/help behavior, and follows its live, unclipped settings row. It reuses the approved secondary button PNG and exact existing Archivo Black font/OFL, copied during export. Native captures show the actual native fullscreen action; they do not prove browser permission behavior.

Results retain the original selected hero and all ten real statistics: four primary blocks (time, kills, level, damage), six supporting values, and original menu/retry actions. Boss-clear copy requires a supported boss outcome. These screens share the existing frozen-arena dim surface and palette; no decorative asset pack or new gameplay system was added.

[Targeted results](evidence/targeted-checks.json) · [24 layout cases](evidence/layout-checks.json) · [Matched fixture data](evidence/fixtures.json) · [Validation/provenance](evidence/validation.json)

The six canonical sizes are covered by automated layout/state checks, including asymmetric safe insets. Visual evidence is limited to native 1600×900 and 844×390 (843×390 readback). Before/after build/settings/victory data are identical. Profiles are isolated from player saves. The five referenced creator screenshots were not attached in this message, so the baseline was captured from the verified deployed source. Native fixtures and Node browser-contract tests are not physical Android or human playtesting. Final CI, Web export and supported-browser status are recorded on the PR; creator visual acceptance remains pending.

Changed source files: `hero_clash_hud.gd` (boss/MAX/joins), `solo_run.gd` (effective-heal presentation cue only), `clean_cut_secondary.gd` (reused screen components), `clean_cut_skin.gd` (heading ownership and mode sync), `web/platform.js` (existing fullscreen placement), `build_web.sh` (exact approved browser face/font/license), `tests/hud_v2/test_hud.gd`, `tests/test_web_platform.cjs`, `tests/ui_cohesion/{test_cohesion,capture}.gd`, `scripts/validate.sh` and the Draft CI allowlist.

Reproduce: `godot --path . --rendering-driver opengl3 --script res://tests/ui_cohesion/capture.gd -- 1600 900 /tmp/ui-review max-level,boss,build,options,won,lost`. Use `844 390` and `build` for the mobile comparison. Review images are ignored by Godot and excluded from production exports. Do not merge or publish production without a new owner instruction.
