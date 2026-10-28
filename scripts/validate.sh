#!/usr/bin/env bash
set -euo pipefail

if command -v godot >/dev/null 2>&1; then
  GODOT_BIN="godot"
elif command -v godot4 >/dev/null 2>&1; then
  GODOT_BIN="godot4"
else
  echo "ERROR: Godot 4.7.2 executable not found in PATH." >&2
  exit 2
fi

cd "$(dirname "$0")/.."

# Godot can return 0 while outputting script/resource errors.
log_dir="$(mktemp -d)"
trap 'rm -rf "$log_dir"' EXIT

run_check() {
  local phase="$1"
  shift
  local log_file="$log_dir/$phase.log"

  echo "Validating Godot phase: $phase"
  local limit="30s"
  if [[ "$phase" == "import" || "$phase" == "continuous-run" ]]; then limit="120s"; fi
  if timeout "$limit" "$GODOT_BIN" "$@" 2>&1 | tee "$log_file"; then
    :
  else
    echo "ERROR: Godot $phase process failed." >&2
    return 1
  fi

  if grep -Eiq 'SCRIPT ERROR:|Parse Error:|(^|[[:space:]])ERROR:|Failed to load|Failed to open' "$log_file"; then
    echo "ERROR: Godot $phase reported parsing/loading/runtime errors." >&2
    return 1
  fi
}

bash -n scripts/build_web.sh
node tests/test_web_platform.cjs
python3 scripts/promote_approved_icons.py
python3 scripts/verify_clean_cut_art.py
python3 scripts/verify_typography.py
python3 -m unittest discover -s tests -p test_icon_pipeline.py
run_check import --headless --path . --import
run_check mobile-layout --headless --path . --script res://tests/test_mobile_layout.gd
run_check card-keyboard --headless --path . --script res://tests/test_card_keyboard.gd
run_check spotlight-secondary --headless --path . --script res://tests/test_spotlight_secondary.gd
run_check spotlight-hud --headless --path . --script res://tests/test_spotlight_hud.gd
run_check spotlight-navigation --headless --path . --script res://tests/test_spotlight_navigation.gd
run_check spotlight-theme --headless --path . --script res://tests/test_spotlight_theme.gd
run_check arcade-ui --headless --path . --script res://tests/test_arcade_ui.gd
run_check enemy-navigation --headless --path . --script res://tests/test_enemy_navigation.gd
run_check seeded-rng --headless --path . --script res://tests/test_phaser_rng.gd
run_check hero-animation --headless --path . --script res://tests/test_hero_animation.gd
run_check recovery --headless --path . --script res://tests/test_recovery.gd
run_check survival-review-policy --headless --path . --script res://tests/test_survival_review_policy.gd
run_check camera-cover --headless --path . --script res://tests/test_camera_cover.gd
run_check continuous-run --headless --path . --script res://tests/test_continuous_run.gd
run_check run-acceptance --headless --path . --script res://tests/test_run_acceptance.gd
run_check menu-flow --headless --path . --script res://tests/test_menu_flow.gd
run_check signature-flex --headless --path . --script res://tests/test_signature_flex.gd
run_check hero-combat --headless --path . --script res://tests/test_hero_combat.gd
run_check run-clock --headless --path . --script res://tests/test_run_clock.gd
run_check run-progression --headless --path . --script res://tests/test_run_progression.gd
run_check profile-store --headless --path . --script res://tests/test_profile_store.gd
run_check contracts --headless --path . --script res://tests/test_game_rules.gd
run_check catalog --headless --path . --script res://tests/test_solo_offer_rules.gd
run_check legendary --headless --path . --script res://tests/test_legendary_offer.gd
run_check boss-lifecycle --headless --path . --script res://tests/test_boss_lifecycle.gd
run_check enemy-windows --headless --path . --script res://tests/test_enemy_windows.gd
run_check ranged-sources --headless --path . --script res://tests/test_ranged_sources.gd
run_check bestiary --headless --path . --script res://tests/test_enemy_patterns.gd
run_check ruin-alley --headless --path . --script res://tests/test_solo_world_rules.gd
run_check passive-effects --headless --path . --script res://tests/test_passive_effects.gd
run_check approved-icon-batch --headless --path . --script res://tests/test_approved_icon_batch.gd
run_check icon-registry --headless --path . --script res://tests/test_icon_registry.gd
run_check approved-art --headless --path . --script res://tests/test_approved_visuals.gd
run_check combat-feedback --headless --path . --script res://tests/test_combat_feedback.gd
run_check clean-cut-typography --headless --path . --script res://tests/test_clean_cut_typography.gd
run_check hero-clash-ui-candidate --headless --path . --script res://tests/test_hero_clash_ui.gd
run_check weapon-vfx --headless --path . --script res://tests/test_weapon_visuals.gd
run_check legendary-combat --headless --path . --script res://tests/test_legendary_combat.gd
run_check weapon-timing --headless --path . --script res://tests/test_weapon_timing.gd
run_check player-projectiles --headless --path . --script res://tests/test_player_projectiles.gd
run_check mobile-touch --headless --path . --script res://tests/test_mobile_joystick.gd
run_check flex-readability --headless --path . --script res://tests/test_flex_readability.gd
run_check playable --headless --path . --script res://tests/test_playable_slice.gd
run_check scene --headless --path . --quit-after 10

run_check approved-clean-cut-runtime --headless --path . --script res://tests/test_clean_cut_runtime.gd
run_check clean-cut-pointer-input --headless --path . --script res://tests/test_clean_cut_pointer_input.gd
run_check clean-cut-secondary-input --headless --path . --script res://tests/test_clean_cut_secondary_input.gd
run_check clean-cut-deferred-legendary --headless --path . --script res://tests/test_clean_cut_deferred_legendary.gd
run_check candidate-bindings --headless --path . --script res://tests/review_clean_cut_candidates.gd -- user://clean-cut-review --check
run_check candidate-navigation --headless --path . --script res://tests/test_clean_cut_review.gd

echo "PASS: Godot import, GDD rule contracts, and main scene smoke test."

run_check hero-clash-review --headless --path . --script res://tests/review_hero_clash/test_review.gd
