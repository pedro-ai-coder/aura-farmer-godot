extends SceneTree
## Controlled Wave 5 A/B: synthetic QA only; production rules never change.
const Canonical=preload("res://scripts/solo_world_rules.gd")
const Expanded=preload("res://qa/expanded_world.gd")
const Expressive=preload("res://qa/expressive_weapon_presentation.gd")
var errors: Array[String]=[]
func check(ok: bool,what: String) -> void:
    if not ok:errors.append(what)
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    # Compare the legal player-centre sample area while leaving cover positions
    # and actor radii identical: wider floor, not smaller enemies/hitboxes.
    var baseline:=0
    var candidate:=0
    for x in range(140,1380,20):
        for y in range(240,1040,20):
            var p:=Vector2(x,y)
            if Canonical.walkable(p,16.0):baseline+=1
            if Expanded.walkable(p,16.0):candidate+=1
    var ratio:=float(candidate)/maxf(1.0,float(baseline))
    check(ratio>=1.18 and ratio<=1.32,"Expanded walkable space approximately +25%%, observed %.3f" % ratio)
    for cover: Dictionary in Canonical.COVERS:
        var centre: Vector2=cover["pos"]
        check(not Expanded.walkable(centre,16),"Original cover collision remains solid")

    var game=load("res://qa/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    game._return_to_menu()
    check(not game._qa_experiment_enabled,"Experiment defaults OFF")

    check(game.start_qa_scenario("wave5","sigma","original","Balanced",451,{},false,false),"Baseline starts")
    check(game._qa_scenario.get("experiment_id")=="canonical_baseline","Baseline metadata")
    check(game.world_rules_script==Canonical,"Baseline uses exact canonical collision")
    check(game.weapon_presentation.get_script()!=Expressive,"Baseline weapon visuals are canonical")
    var original_state:=var_to_bytes([game.rng.state,game.hero,game.weapons,game.passives,game.level,game.run_time,game.hp,game.wave])
    game._return_to_menu()
    check(game.start_qa_scenario("wave5","sigma","original","Balanced",451,{},false,true),"Candidate starts")
    check(game._qa_experiment_enabled and game.world_rules_script==Expanded,"Experimental geometry actually selected")
    check(game.weapon_presentation.get_script()==Expressive,"Expressive cosmetics actually selected")
    check(game._qa_scenario.get("experiment_id")=="wave5-expanded-floor-expressive-feedback-v1","Explicit synthetic experiment label")
    check(var_to_bytes([game.rng.state,game.hero,game.weapons,game.passives,game.level,game.run_time,game.hp,game.wave])==original_state,"Same initial seed, build, HP and canonical wave rules")
    var sample: Array=Expanded.floor_outline()
    check(sample.size()==Canonical.FLOOR.size(),"Same floor polygon vertex order")
    for point: Vector2 in sample:
        check(point.x>0 and point.y>0 and point.x<game.FIELD.size.x and point.y<game.FIELD.size.y,
            "Expanded arena remains inside original art/camera bounds")
    game._return_to_menu()
    check(not game.start_qa_scenario("wave3","sigma","original","Balanced",451,{},false,true),"Experiment rejected outside Wave 5")
    check(game.start_qa_scenario("wave5","sigma","original","Balanced",451,{},false,false),"Canonical baseline resets after experiment")
    check(not game._qa_experiment_enabled and game.world_rules_script==Canonical,"QA baseline cannot inherit experiment")
    game._return_to_menu()
    game.start_run(0)
    check(not game._qa_experiment_enabled and game.world_rules_script==Canonical,"Normal run restores canonical geometry")
    check(game.weapon_presentation.get_script()!=Expressive,"Normal run restores canonical visuals")

    var observer=Expressive.new()
    var model: Dictionary={"id":"no-cap","at":1.2,"direction":Vector2.RIGHT,"primary":true}
    observer.queued(model,1.0,[],true)
    check(is_equal_approx(float(observer.gestures[0]["until"]),1.2+Expressive.GESTURE_POST_LIFE),"Visual-only queued gesture duration")
    var enemy: Dictionary={"id":5,"hp":9.0,"shield":0.0}
    observer.contact("no-cap",enemy,Vector2(200,200),Vector2.RIGHT,10.0,0.0,2.0)
    check(is_equal_approx(float(observer.impacts[0]["until"]),2.0+Expressive.IMPACT_LIFE),"Successful hit gets longer impact")
    observer.contact("no-cap",enemy,Vector2(200,200),Vector2.RIGHT,9.0,0.0,2.1)
    check(observer.impact_cursor==1,"Blocked or unchanged HP cannot create new cosmetic impacts")
    game.queue_free()
    if errors.is_empty():
        print("PASS: QA Wave 5 A/B floor, geometry, provenance, deterministic baseline, normal reset and cosmetic-only lifetimes")
        quit(0)
    else:
        for e in errors:push_error(e)
        quit(1)
