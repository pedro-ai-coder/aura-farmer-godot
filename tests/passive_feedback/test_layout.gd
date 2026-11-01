extends SceneTree
const Run=preload("res://tests/passive_feedback/review_run.gd")
var failures: Array[String]=[]
func expect(ok: bool, message: String) -> void:
    if not ok:failures.append(message)
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var game:=Run.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.touch_device=extent.x<1000
        game.prepare("acquired");game.presentation._window_changed(true)
        await process_frame;await process_frame
        var skin=game.clean_cut_skin;var view=skin.passive_feedback_view
        game.passive_feedback.synchronize(game);skin._process(0)
        expect(Rect2(Vector2.ZERO,skin.view).encloses(view.plate.get_rect()),"Notice fits "+str(extent))
        for id in ["TopLeftHeroStatus","TopCenterWaveTimer","TopCenterBossStatus","TopRightPause","BottomRightFlex","BottomCenterEquipment"]:
            expect(not view.plate.get_rect().intersects(skin.gameplay_hud.modules[id].get_rect()),"Notice avoids critical HUD "+id+" "+str(extent))
        for id: String in game.PASSIVES:
            var observer=game.passive_feedback;observer.reset()
            game.passives.clear();game.equip(id,int(game.CAP_LEVELS[game.SoloOfferRulesScript.PASSIVE_DATA[id].rarity]))
            observer.notify(game,id,observer.name_for(id),"LEVEL UP · COMMON · LV 4\n"+observer.brief(id,4) if id in ["main-character","terminally-online","caught-4k","big-meme"] else "ACQUIRED · LEGENDARY · LV 1\n"+observer.brief(id,1) if id in ["absolute-cinema","w-squad","too-sigma","no-u"] else "Effect activated · actual gameplay event","upgrade")
            observer.synchronize(game);skin.layout_key="";skin._process(0)
            await process_frame
            var font: Font=view.heading.get_theme_font("font")
            var font_size: int=view.heading.get_theme_font_size("font_size")
            expect(font.get_string_size(view.heading.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x<=view.heading.size.x+1,"Full identity fits "+id+" "+str(extent))
            expect(view.detail.get_line_count()<=2,"At most two readable body lines "+id+" "+str(extent))
        game.prepare("acquired");game.passive_feedback.reset();game.passives.clear()
        for id in ["main-character","thick-skin","caught-4k","big-meme","certified-w"]:game.equip(id)
        game._apply_card({"type":"passive","id":"w-squad","rarity":"legendary","level":1},"main-character")
        game.passive_feedback.synchronize(game);skin._process(0)
        await process_frame
        expect(view.detail.get_line_count()<=2,"Legendary replacement never clips its confirmation "+str(extent))
        game.prepare("build");game.mode="build";game._show_ui();skin.layout_key="";skin._process(0)
        for i in range(3,8):
            var label: Label=skin.auxiliary.build_parts[i].details
            expect(label.get_line_count()*label.get_line_height()<=label.size.y+2,"Inspection values wrap without clipping "+str(extent)+" "+label.text)
    game.queue_free()
    if failures.is_empty():print("PASS: 23 full names and notifications, inspection descriptions, input-free HUD placement across all six GDD viewports");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
