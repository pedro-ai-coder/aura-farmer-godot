extends SceneTree
const Visuals=preload("res://scripts/pickup_visuals.gd")
const ReviewRun=preload("res://tests/pickup_refresh/review_run.gd")
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("verify")
func expect(ok: bool, message: String) -> void:
    if not ok:failures.append(message)
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    for kind in ["aura","snack","magnet"]:
        var slug: String={"aura":"xp-orb","snack":"street-snack","magnet":"aura-magnet"}[kind]
        var image: Texture2D=Visuals.texture(kind)
        expect(image!=null and image.resource_path=="res://assets/art-candidates/pickups/v1/"+slug+".png","Exact artwork for "+kind)
        expect(image==Visuals.texture(kind),"Texture cached for "+kind)
        expect(image.get_size()==Vector2(128,128),"Consistent source dimensions for "+kind)
        expect(image.get_image().get_pixel(0,0).a==0.0,"Transparent corners for "+kind)
    expect(Visuals.texture("new-currency")==null,"Unknown kind cannot fall back to XP")
    expect(Visuals.LABELS["aura"]=="XP Orb","Canonical player-facing XP Orb name")
    var drop:={"kind":"aura","pos":Vector2(700,550),"xp":5.0}
    var original:=drop.duplicate(true)
    for frame in range(200):
        var reduced:=Visuals.bounds(drop,float(frame)/60.0,true)
        var moving:=Visuals.bounds(drop,float(frame)/60.0,false)
        expect(reduced.size==Vector2(32,32),"Reduced Motion freezes orb pulse")
        expect(moving.size.x>=32*0.92-0.001 and moving.size.x<=32*1.08+0.001,"Existing subtle pulse stays bounded")
        expect(reduced.get_center()==drop.pos and moving.get_center().is_equal_approx(drop.pos),"Rendering preserves world position")
    expect(drop==original,"Visual bounds do not mutate pickup data")
    var phase:=drop.duplicate();phase["phase"]=2
    expect(Visuals.bounds(phase,0,true).size==Vector2(34,34),"Phase XP has stronger visual size plus existing gold ring")
    # The center silhouette is an orb rather than the former faceted diamond:
    # diagonal core pixels are opaque, while its transparent corners stay empty.
    var orb:=Visuals.texture("aura").get_image()
    expect(orb.get_pixel(39,39).a>0.95 and orb.get_pixel(0,0).a==0.0,"Orb has a round filled core")
    var feedback:={"kind":"phase","text":"WAVE 2 / +80 XP CRYSTAL"}
    expect(Visuals.feedback_text(feedback)=="WAVE 2 / +80 XP ORB" and feedback.text.ends_with("CRYSTAL"),"Visible name changes without altering replay event payload")

    for kind in ["aura","snack","magnet"]:
        game.start_run(0);game.player_pos=Vector2(700,550);game.hp=20
        var radius: float=game.RecoveryRulesScript.pickup_radius(kind)
        expect(radius=={"aura":45.0,"snack":56.0,"magnet":72.0}[kind],"Canonical pickup radius for "+kind)
        var reward:={"kind":kind,"pos":game.player_pos+Vector2(radius,0),"xp":5.0 if kind=="aura" else 0.0}
        game.pickups.append(reward)
        var state: int=game.rng.state
        game._collect_drops()
        expect(game.pickups.size()==1,"Exact radius boundary remains exclusive for "+kind)
        reward["pos"]=game.player_pos+Vector2(radius-0.01,0)
        game._collect_drops()
        expect(game.pickups.is_empty(),"Collected original disappears for "+kind)
        expect(game.rng.state==state,"Collection consumes no RNG for "+kind)
        if kind=="snack":expect(game.hp==38.0,"Street Snack still heals exactly 18% max HP")
        if kind=="aura":expect(game.total_xp==5.0 and game.aura==0.0,"XP Orb credits existing XP only")

    for wave in range(2,6):
        game.start_run(0);game.wave=wave;game.player_pos=Vector2(700,550)
        var state: int=game.rng.state
        game._spawn_phase_crystal()
        expect(game.pickups.size()==1 and game.pickups[0].xp==40.0*wave and game.pickups[0].phase==wave,"Unchanged phase XP reward")
        expect(game.rng.state==state,"Phase placement consumes no RNG")
        expect(Visuals.feedback_text(game.pickup_feedback[-1]).ends_with("XP ORB"),"Actual phase feedback presents XP Orb")
        game.player_pos=game.pickups[0].pos;game._collect_drops();game._collect_drops()
        expect(game.total_xp==40.0*wave and game.pickups.is_empty() and game.aura==0.0,"Phase XP collects exactly once")

    game.start_run(0);game.player_pos=Vector2(700,550)
    # Magnet first, then both near/far XP and a phase XP in the original snapshot.
    game.pickups.assign([{"kind":"magnet","pos":game.player_pos,"xp":0.0},{"kind":"aura","pos":game.player_pos,"xp":5.0},{"kind":"aura","pos":Vector2(1200,850),"xp":7.0},{"kind":"aura","pos":Vector2(1250,800),"xp":80.0,"phase":2},{"kind":"snack","pos":Vector2(1200,850),"xp":0.0}])
    var rng_before: int=game.rng.state
    game._collect_drops();game._collect_drops()
    expect(game.total_xp==92.0 and game.aura==0.0,"Magnet credits only available XP exactly once, including phase")
    expect(game.pickups.size()==1 and game.pickups[0].kind=="snack","Magnet leaves distant health pickup intact")
    expect(game.recovery_counts["magnets_collected"]==1 and game.rng.state==rng_before,"Magnet feedback/count and RNG unchanged")
    game.queue_free()
    if failures.is_empty():print("PASS: pickup sprite mappings/cache/transparency, Reduced Motion, XP Orb label, exact radii/XP/healing, phase rewards, magnet deduplication and unchanged RNG");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
