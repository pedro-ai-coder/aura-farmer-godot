extends SceneTree
## Regression of audit findings using the actual movement/resource integration.
const Sheets=preload("res://scripts/full_hero_atlases.gd")
const Visuals=preload("res://scripts/approved_visuals.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var failures: Array[String]=[]
func expect(value: bool,message: String) -> void:
    if not value:failures.append(message)
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var art:=Visuals.new()
    for historical in Visuals.HISTORICAL_TEXTURES:
        expect(not art.textures.has(historical),"Historical atlas must not be eagerly resident: "+historical)
    expect(art.prepare_appearance("cool-kid","original"),"Current Cool Kid resources prepare")
    expect(art.texture("sigma-atlas")!=null,"Historical inspection remains available on demand")
    for hero_id in ["sigma","cool-kid","alpha"]:
        for appearance in ["original","female"]:
            var identity: String=Sheets.slug(hero_id,appearance)
            expect(art.prepare_appearance(hero_id,appearance),"Roster composition resources: "+identity)
            var height: float=art.hero_sheets.manifest[identity]["cell_size"][1]
            for facing in [PI/2.0,-PI/2.0]:
                for phase in ["attack","flex-in","flex-loop","flex-out"]:
                    var indices: Dictionary={}
                    for step in range(4):
                        var context: Dictionary={"moving":true,"walk":float(step)/9.0+0.001,"facing":facing}
                        var layers: Dictionary=Sheets.composition(identity,phase,context)
                        var index: int=layers["lower_frame"]
                        var rear: bool=phase=="attack" and facing<0
                        expect(index in range(24,28) if rear else index in range(8,12),"Leg view agrees with authored torso, including frontal Flex: "+identity)
                        expect(float(layers["seam"])>0 and float(layers["seam"])<height,"Registered seam stays inside source cell: "+identity)
                        indices[index]=true
                    expect(indices.size()==4,"Action preserves all four distance-driven strides: "+identity)
            for phase in ["idle","run","hurt","defeat"]:
                expect(Sheets.composition(identity,phase,{"moving":true}).is_empty(),"Lifecycle priority remains full-body: "+phase)
            expect(Sheets.composition(identity,"attack",{"moving":false}).is_empty(),"Stationary attack retains authored stance")
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.start_run(0);game.enemies.clear();game.weapons.clear();game.spawn_timer=INF
    game.player_pos=Vector2(340,600);game.touch_direction=Vector2.RIGHT
    var reached_wall:=false
    for i in range(900):
        var before: Vector2=game.player_pos
        game._process(1.0/60.0)
        if game.player_pos==before:
            reached_wall=true
            expect(not game.visual_moving,"Blocked input selects a stationary visual state")
            expect(game.hero_pose().state=="idle","Blocked input cannot freeze an intermediate run pose")
            break
    expect(reached_wall,"Fixture reaches the real world boundary")
    game.touch_direction=Vector2.LEFT;game._process(1.0/60.0)
    expect(game.visual_moving and game.hero_pose().state=="run","Leaving the obstacle resumes locomotion immediately")
    for facing in [PI/2.0,-PI/2.0]:
        var context: Dictionary={"hero_id":"sigma","appearance":"original","attack":0.1,"facing":facing}
        var released:=Sheets.frame_index("attack",context)
        expect(released in [43,47],"Released body drawing cannot include another airborne cap")
        context["attack"]=0.22
        expect(Sheets.frame_index("attack",context) in [40,44],"Actual windup retains the held-cap drawing")
    game.queue_free()
    if failures.is_empty():print("PASS: six-identity action locomotion, lifecycle priority, resolved-motion state, single-cap body playback and lazy historical resource loading");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
