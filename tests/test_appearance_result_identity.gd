extends SceneTree
## Unit-test the presentation route without pretending missing V2 art is playable.
## The marker Texture2D is test-only; no synthetic female screenshot is captured.
class RoutingVisuals extends "res://scripts/approved_visuals.gd":
    var marker: Texture2D=GradientTexture2D.new()
    func cosmetic_portrait(hero_id: String, appearance: String, usage: String="selection") -> Texture2D:
        if hero_id=="sigma" and appearance=="female":return marker
        return super.cosmetic_portrait(hero_id,appearance,usage)
class TestRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var failures: Array[String]=[]
func expect(ok: bool,message: String) -> void:
    if not ok:failures.append(message)
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var game:=TestRun.new();root.add_child(game);game.set_process(false)
    game.art=RoutingVisuals.new()
    for appearance in ["original","female"]:
        for won in [false,true]:
            game.hero_appearance="original";game.start_run(0)
            # Bypass only asset availability for this route test, not a playable
            # feature assertion. Real asset/in-world tests still fail if absent.
            game.hero_appearance=appearance
            game._finish(won)
            game._show_ui();game._update_text();game.clean_cut_skin.refresh()
            await process_frame;await process_frame
            var result=game.clean_cut_skin.auxiliary
            var name: String="PIXEL VIXEN" if appearance=="female" else str(game.hero["name"])
            expect(result.result_hero.text==name,"Result name follows appearance for both outcomes")
            expect(result.result_portrait.texture==game.art.cosmetic_portrait("sigma",appearance),"Result portrait follows the same appearance route as selection")
            expect(game.hero["id"]=="sigma" and game.hero["starter"]=="no-cap" and game.hero["flex"]=="Deadpan Verdict","Result presentation cannot change canonical kit")
            expect(game.profile["results"][-1]["hero"]=="sigma","Result storage retains canonical Sigma ID")
    game.queue_free()
    if failures.is_empty():print("PASS: Original/Pixel Vixen result identity routing, both outcomes and unchanged canonical result IDs (test-only texture marker)");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
