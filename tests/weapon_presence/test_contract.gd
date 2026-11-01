extends SceneTree
const ReviewRun=preload("res://tests/weapon_presence/review_run.gd")
const Presentation=preload("res://scripts/weapon_presentation.gd")
const Attach=preload("res://scripts/weapon_attachments.gd")
const IDS=["no-cap","ratio-blaster","brainrot-feed","keyboard-warrior","ban-hammer","touch-grass","cope-shield","chad-hands","personal-space"]
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("verify")
func expect(ok: bool, message: String) -> void:
    if not ok:failures.append(message)
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    for id in IDS:
        expect(Presentation.Art.TEXTURES.has(id),"Exact approved weapon prop exists: "+id)
        expect(Presentation.Art.TEXTURES[id]==Presentation.Art.TEXTURES[id],"Cached immutable texture: "+id)
    expect(Presentation.Art.TEXTURES.size()==9,"Only nine canonical weapon identities")
    for hero in ["sigma","cool-kid","alpha"]:
        for appearance in ["original","female"]:
            for phase in range(4):
                var right:=Attach.grip(hero,appearance,phase,false)
                var left:=Attach.grip(hero,appearance,phase,true)
                expect(left==Vector2(-right.x,right.y),"Foot-pivot attachment mirrors once without reversing a text asset")
                expect(right.y<=-12 and right.y>=-52 and absf(right.x)<=28,"Hand anchor stays below head and within authored reach")
    # No decorative success before authoritative delayed damage, including misses.
    for id in ["ban-hammer","brainrot-feed"]:
        game.fixture(id,"female")
        var enemy: Dictionary=game.enemies[0]
        enemy["hp"]=10000;enemy["max"]=10000;enemy["born"]=0
        game._fire_weapons(0.2)
        expect(game.weapon_presentation.emitted_contacts==0,"No early hit for queued "+id)
        var area: Dictionary=game.weapon_areas[0]
        var deadline: float=area.at
        var event: Dictionary=game.weapon_presentation.current(game.run_time)
        expect(Presentation.stage(event,game.run_time)==1,"Anticipation uses actual delayed activation")
        game.enemies.clear();game.run_time=deadline;game._step_weapon_areas()
        expect(game.weapon_presentation.emitted_contacts==0,"A real area miss never emits an impact")
    game.fixture("brainrot-feed","original");game._fire_weapons(0.2)
    game.weapon_areas.clear()
    game.weapon_presentation.synchronize(game.weapon_areas,game.player_shots,game.run_time)
    expect(game.weapon_presentation.current(game.run_time).is_empty(),"Cancelled queued area cannot become a cosmetic attack")
    game.fixture("no-cap","original")
    game._fire_weapons(0.2)
    expect(game.weapon_presentation.emitted_contacts==0 and game.player_shots.size()==1,"A launched cap is not an instant hit")
    game._step_player_shots(0.01)
    expect(game.weapon_presentation.emitted_contacts==0,"Travel before collision has no hit feedback")
    game.fixture("ratio-blaster","original")
    game.aim_point=game.player_pos+Vector2(-400,0)
    game._fire_weapons(0.2)
    var canonical_facing: float=game.visual_facing
    expect(game.hero_pose()["flip"] and canonical_facing==game.visual_facing,"Manual aim drives the visible prop/body without changing canonical Flex facing")
    for protected in ["lost","hurt","flex"]:
        var state:={"lost":false,"hurt":0.0,"flex":0.0,"facing":0.4,"attack":0.0}
        state[protected]=true if protected=="lost" else 0.2
        game.weapon_presentation.decorate_pose(state,game.run_time)
        expect(state["facing"]==0.4 and state["attack"]==0.0,"Defeat/hurt/Flex keep the canonical animation precedence and facing")
    game.fixture("keyboard-warrior","female")
    for enemy in game.enemies:enemy["born"]=0;enemy["hp"]=10000;enemy["max"]=10000
    game._fire_weapons(0.2)
    var first: int=game.weapon_presentation.emitted_contacts
    game.run_time=0.12;game._step_weapon_areas()
    expect(first>0 and game.weapon_presentation.emitted_contacts>first,"Keyboard's second strike follows the real 0.12s hit")
    var enemy: Dictionary=game.enemies[0]
    var before: Vector2=enemy.pos
    var reaction:=game.weapon_presentation.reaction(enemy,game.run_time,false)
    expect(reaction.length()<=2.501 and enemy.pos==before,"Reaction is a small presentation offset, never knockback")
    expect(game.weapon_presentation.reaction(enemy,game.run_time,true)==Vector2.ZERO,"Reduced Motion disables reaction offset")
    var stamp: float=game.run_time
    game._toggle_pause();game._process(0.25)
    expect(game.run_time==stamp,"Pause freezes presentation with simulation")
    game._toggle_pause()
    var rng_before: int=game.rng.state
    var pool=game.weapon_presentation
    var dummy:={"id":999,"hp":9.0,"shield":0.0,"phase":"chasing","kind":"npc"}
    for i in range(500):
        dummy["id"]=i+1000
        pool.contact("ratio-blaster",dummy,Vector2(i,50),Vector2.RIGHT,10.0,0.0,0.0)
    expect(pool.impacts.size()==48 and pool.reactions.size()<=48 and pool.replaced_cues.size()<=48,"Dense impact/reaction resources are bounded")
    expect(game.rng.state==rng_before,"Presentation consumes no gameplay RNG")
    var contacts: int=pool.emitted_contacts
    pool.contact("ratio-blaster",dummy,Vector2.ZERO,Vector2.RIGHT,9.0,0.0,0.1)
    expect(pool.emitted_contacts==contacts,"Unchanged HP/Shield cannot create a success")
    dummy["shield"]=3.0
    pool.contact("cope-shield",dummy,Vector2.ZERO,Vector2.RIGHT,9.0,5.0,0.1)
    expect(pool.impacts[(pool.impact_cursor+47)%48].blocked,"Shield absorption is a deflection, not fabricated HP damage")
    game.start_run(0)
    expect(pool.emitted_contacts==0 and pool.reactions.is_empty() and pool.current(0).is_empty(),"Retry clears all independent presentation state")
    game.queue_free()
    if failures.is_empty():print("PASS: nine weapon resources, six attachment profiles, authoritative launch/paired/delayed/miss/blocked impacts, bounded pools, pause/retry, Reduced Motion and RNG");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
