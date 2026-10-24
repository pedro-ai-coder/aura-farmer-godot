extends SceneTree
## Isolated candidate UI contracts; never an artwork approval.
const CandidateSkin=preload("res://tests/clean_cut_review/skin.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var failures: Array[String]=[]
func check(value: bool, description: String) -> void:
    if not value:failures.append(description)
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    var skin:=CandidateSkin.new();skin.install(game,ProjectSettings.globalize_path("res://"));skin.set_process(false)
    for extent in [Vector2i(1600,900),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.presentation._window_changed(true)
        game._return_to_menu();skin.refresh()
        game.presentation.home.hero_destination.pressed.emit();skin.refresh()
        check(game.mode=="heroes","Real hero destination survives reparenting")
        for i in range(3):
            game.menu_buttons[i].pressed.emit();skin.refresh()
            check(game.hero_index==i and game.mode=="heroes","Hero selection remains distinct from starting")
        game.presentation.home.start_button.pressed.emit();skin.refresh()
        check(game.mode=="playing" and game.hero["id"]=="alpha","Start uses selected real hero")
        game._gain_xp(40);game._open_choice();game._show_ui();game._update_text();skin.refresh()
        check(game.mode=="choice" and game.selection.size()==3,"Three actual upgrade offers")
        game.offer_buttons[0].pressed.emit();skin.refresh()
        check(game.mode=="choice" and not game.confirm_button.disabled,"Selection requires separate confirmation")
        game.confirm_button.pressed.emit();skin.refresh()
        check(game.mode=="playing","Native confirm applies upgrade")
        game.run_time=360;game._open_legendary();game._update_text();skin.refresh()
        var offers:=JSON.stringify(game.legendary_offers)
        check(game.legendary_offers.size()==6,"Six actual legendary offers")
        game.defer_button.pressed.emit();skin.refresh()
        check(game.mode=="playing" and not game.legendary_spent,"Defer preserves legendary allowance")
        game._open_legendary();game._update_text();skin.refresh()
        check(JSON.stringify(game.legendary_offers)==offers,"Reopen preserves cached six offers")
        game.offer_buttons[5].pressed.emit();skin.refresh()
        game.confirm_button.pressed.emit();skin.refresh()
        check(game.legendary_spent and game.mode=="playing","Sixth card confirms through original signal")
        game.pause_button.pressed.emit();skin.refresh()
        check(game.mode=="paused" and game.pause_button.get_parent()==game.presentation,"Secondary fallback restores pause button")
        game.pause_button.pressed.emit();skin.refresh()
        check(game.mode=="playing","Resume returns to candidate HUD")
    if failures.is_empty():print("PASS: Candidate real hero/start, three-card confirmation, six-card defer/cache/pick and pause/resume at three viewports");quit(0)
    else:
        for failure in failures:push_error(failure)
        quit(1)
