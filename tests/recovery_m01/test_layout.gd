extends SceneTree
const Audit=preload("res://tests/recovery_m01/layout_audit.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var failures: Array[String]=[]
var reports: Array=[]
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent
        for mode in ["menu","heroes","playing","choice","legendary","replace","paused","build","options","confirm_exit","profile_import","profile_export","won","lost"]:
            game.start_run(2)
            if mode=="menu":game._return_to_menu()
            elif mode=="heroes":game.presentation.open_heroes()
            elif mode=="playing":
                game.run_time=625.0;game.hp=0;game.shield=56
                game.boss_spawned=true;game._spawn_enemy("boss",{"pos":Vector2(1100,750)})
                game.aura=100;game.flex_lock=0
            elif mode=="choice":game._gain_xp(100);game._open_choice()
            elif mode=="legendary":game.run_time=360;game._open_legendary()
            elif mode=="replace":
                game.weapons.assign([{"id":"cope-shield","rarity":"common","level":1,"timer":0},{"id":"chad-hands","rarity":"common","level":1,"timer":0},{"id":"personal-space","rarity":"common","level":1,"timer":0}])
                game._replace_target({"type":"weapon","id":"cope-shield","rarity":"rare","level":1})
            elif mode in ["paused","build","options","confirm_exit"]:
                game._toggle_pause()
                if mode=="build":
                    game.passives=[{"id":"terminally-online","rarity":"common","level":4},{"id":"built-different","rarity":"common","level":4},{"id":"cope-harder","rarity":"common","level":4},{"id":"caught-4k","rarity":"common","level":4},{"id":"certified-w","rarity":"common","level":4}]
                    game.presentation.open_build()
                elif mode=="options":game.presentation.open_settings("paused")
                elif mode=="confirm_exit":game._request_return_to_menu()
            elif mode=="profile_import":game._return_to_menu();game._open_profile_import()
            elif mode=="profile_export":game._return_to_menu();game._open_profile_export()
            elif mode in ["won","lost"]:
                game.run_metrics["damage"]=12345678;game.run_metrics["protection"]=999999
                game.kills=99999;game._finish(mode=="won")
            game._show_ui();game._update_text();game.presentation._window_changed(true)
            await process_frame;await process_frame
            game.clean_cut_skin.layout_key="";game.clean_cut_skin.refresh()
            await process_frame;await process_frame
            var report: Dictionary=Audit.report(game)
            reports.append(report)
            for issue in report["issues"]:
                if failures.size()<25:failures.append(str(extent)+" "+mode+" "+JSON.stringify(issue))
            if mode=="legendary":
                game.clean_cut_skin.offers_scroll.scroll_vertical=10000
                await process_frame
                if not game.offer_buttons[5].visible:failures.append("Sixth legendary unavailable")
            if mode in ["choice","legendary"]:
                for i in range(3 if mode=="choice" else 6):
                    var body: Label=game.clean_cut_skin.offer_parts[i]["body"]
                    if body.get_minimum_size().y>body.size.y+1:failures.append("Description clipped "+str(extent))
    var args:=OS.get_cmdline_user_args()
    if not args.is_empty():
        var file:=FileAccess.open(args[0],FileAccess.WRITE);file.store_string(JSON.stringify(reports))
    game.queue_free()
    if failures.is_empty():print("PASS: Actual Controls, six viewport bounds/peer overlaps, boss HUD, dynamic text, full build and modal rows");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
