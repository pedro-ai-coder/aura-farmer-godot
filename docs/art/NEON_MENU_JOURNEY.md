> **Current status — 2026-11-15:** The creator accepted the exact reviewed Neon version and authorized main integration and production publication under [CPK-NEON-PRODUCTION-2026-11-15-01](CREATOR_NEON_PRODUCTION_APPROVAL_2026-11-15.md). Earlier candidate/no-release wording below is historical. The exact integrated Garage background is now approved for this use; its missing older reference is still unrecovered. Gameplay, hero pixels and approved wordmark remain unchanged.

# Neon menu journey continuation

This presentation-only candidate continues PR #146 at exact base `b8de1ff6d2676a823ce75011d81eefcabf4e0903`. The creator approved the Neon Punk Arcade direction and requested missing-menu implementation. It does not authorize merge, deployment, new art, balance or expanded Canon approval. Existing bounded Canon provenance and immutable sources remain documented in [NEON_PUNK_ARCADE.md](NEON_PUNK_ARCADE.md).

## Video audit

Original attachment: `20261115-2001-46.9695792.mp4`, recovered from the referenced chat's local attachment, rather than its unavailable `/mnt/data` alias. SHA-256 `3e16f44add71cbefa24e441003ee97e8c748e0b7a70655b9db961e94935e17e3`. H.264, 1900×922, 30 fps, duration 30.77 seconds. Inspected a one-second frame contact sheet and targeted native captures. Times are approximate video offsets, not game time.

| Video interval | Observation | Decision |
|---|---|---|
| 00–06s | Six identities already use the Neon selection/showcase | Preserve the existing art and behavior |
| 07–08s | Settings still has a cream sheet and illustrated gold controls | Reuse the Neon panel, text and action states |
| 09–11s | Garage already has the approved directional hierarchy | Keep this PR stacked on the existing frontend |
| 14–15s, 23s | Pause returns to the cream/gold language | Dark angular pause shell, lime Resume, existing run frozen |
| 24–25s | Exit confirmation displays a large cream surface | Dark shell, explicit consequence text, lime Stay, magenta quit outline |
| Gameplay intervals | Existing world, heroes and HUD | Preserve gameplay and HUD art; HUD redesign is outside this menu request |

Code inspection found the same older shell in Build, save import/export, victory/defeat and choice/replacement/Legendary screens. These additional states are repository findings, not scenes claimed to be present in this short video.

## Implementation decisions

- All eleven secondary/choice modes reuse `neon_arcade.gd`: ink panels, white readable text, lime primary action, magenta accents, native focus/disabled states. Rarity colors and canonical item text/icons remain intact; category strips use magenta/lime.
- The actual signal-bound Button, save editor, slider, scroll containers and state transitions remain input/data owners. No fake controls or delayed activation. Confirming an upgrade remains a separate action; abandoning a run still requires explicit confirmation.
- `neon_menu_backdrop.gd` draws the dark diagonal shell and bounded 240 ms eased edge reveal. Existing Neon button feedback adds interruptible 120 ms accents inside fixed hitboxes. Reduced motion settles the shell immediately; hidden/completed entries stop processing. No RNG, audio, background service or new artwork.
- The paused battlefield remains visible under its existing dimmer. Other menus receive an opaque code-drawn backdrop. Results reuse the approved portrait and actual run metrics. Three weapon and five passive positions remain unchanged.
- Compact Settings shortens its heading to `SETTINGS` to avoid the Back target. Final action labels fit the actual responsive rectangles; the editor stays rectangular for readable/saveable text. Scroll areas remain available for long content.
- The trusted browser fullscreen action receives matching CSS colors, focus/hover/pressed states. It retains its real user-gesture and safe-bounds contract; immediate states need no animation preference bridge. Existing build-copied legacy fullscreen face files remain unused for compatibility.
- Existing tests that explicitly required the obsolete `ClashButtonFeedback` implementation were updated to check the new Neon secondary family. Input, HUD geometry and simulation assertions were retained.

## Validation and evidence

Executed with official Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility, Windows; native screenshots use AMD Radeon RX 6800 XT. The new isolated suite covers eleven modes at 1920×1080, 1600×900, 1280×720, 915×412, 844×390 and 390×844, with optional native captures. It checks contrast, 48px action height, full label fit, title/Back separation, dark editable save field, held card input without commit, no rendering-driven changes to time/RNG/inventory/profile/selection and live reduced-motion interruption. This is synthetic QA, not a physical-device playthrough or performance benchmark.

Relevant commands from repository root:

```text
godot --headless --path . --script res://tests/test_neon_menu_journey.gd
godot --path . --script res://tests/test_neon_menu_journey.gd -- ABSOLUTE_CAPTURE_DIRECTORY
godot --headless --path . --script res://tests/test_clean_cut_secondary_input.gd
godot --headless --path . --script res://tests/ui_cohesion/test_cohesion.gd
godot --headless --path . --script res://tests/ui_final_polish/test_polish.gd
godot --headless --path . --script res://tests/test_card_keyboard.gd
godot --headless --path . --script res://tests/test_neon_frontend.gd
godot --headless --path . --script res://tests/test_phaser_rng.gd
node tests/test_web_platform.cjs
node tests/test_performance_web.cjs
python scripts/verify_cpk_garage_assets.py
python scripts/verify_approved_hero_sheets.py
python scripts/verify_full_hero_atlases.py
```

Review contact sheets are in [evidence/neon-menu-journey](evidence/neon-menu-journey). Full captures, commands/logs, exact tested/exported SHA and build checksums are retained in the local `neon-menu-review` sibling directory and reported with the PR. Screenshots are excluded from the runtime export by the inherited `tests/*` exclusion and the added evidence exclusion. Passing checks do not establish artistic acceptance.

## Boundaries and rollback

No gameplay controller/rules, asset/font bytes, hero manifests, scene bindings, stable IDs, save schema, InputMap or existing Garage/hero animations are changed. The inherited Garage background remains PROPOSED. Physical touch devices, controller hardware, Safari and final visual acceptance remain unverified. No performance improvement is claimed. Full historical validation is separate from this targeted menu regression set. Revert this continuation commit to return to PR #146; do not revert or merge its dependencies automatically.
