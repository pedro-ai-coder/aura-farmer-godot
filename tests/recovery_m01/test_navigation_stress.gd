extends SceneTree
const Nav=preload("res://scripts/enemy_navigation.gd")
const World=preload("res://scripts/solo_world_rules.gd")
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("verify")
func expect(ok: bool,message: String) -> void:
    if not ok and failures.size()<20:failures.append(message)
func verify() -> void:
    var rng=RandomNumberGenerator.new();rng.seed=8201
    var failed:=0;var started:=Time.get_ticks_usec()
    for i in range(220):
        var radius: float=[12.0,15.0,21.0,25.2,48.0][i%5]
        var start: Vector2=World.spawn_point(Vector2(720,600),rng)
        while not World.walkable(start,radius):start=World.spawn_point(Vector2(720,600),rng)
        var target: Vector2=World.spawn_point(start,rng)
        var pos:=start;var state: Dictionary={};var speed: float=75.0
        for step in range(1200):
            var old:=pos
            pos=Nav.move(pos,target,speed/60.0,radius,state)
            expect(pos.distance_to(old)<=speed/60.0+0.002,"Movement speed exceeded")
            expect(World.walkable(pos,radius),"Geometry penetration")
            if pos.distance_to(target)<radius+20:break
        if pos.distance_to(target)>radius+20:failed+=1
    var spawn_rng=RandomNumberGenerator.new();spawn_rng.seed=8202
    for radius in [25.2,32.0,36.0,38.0,48.0]:
        for i in range(300):
            var born: Vector2=World.spawn_point(Vector2(780,600),spawn_rng,radius)
            expect(World.walkable(born,radius),"Large actor born inside geometry")
            expect(born.distance_to(Vector2(780,600))>=260.0,"Spawn arrival distance changed")
    expect(failed==0,"Seed 8201 fixed-target failures: "+str(failed))
    # Same 100-enemy cap as ordinary solo waves. Targets switch sides of both
    # covers and move along concave floor regions; no combat RNG is consulted.
    var crowd: Array=[]
    for i in range(100):
        var pos: Vector2=World.spawn_point(Vector2(720,600),rng)
        crowd.append({"id":i,"kind":"npc","phase":"","pos":pos})
    var routes: Array=[Vector2(430,620),Vector2(780,490),Vector2(1100,750),Vector2(830,910),Vector2(300,720)]
    var baseline_seed: int=rng.state
    Nav.diagnostics_enabled=true;Nav.diagnostic_events.clear()
    var dense_start:=Time.get_ticks_usec()
    for frame in range(3600):
        var goal: Vector2=routes[int(frame/720)]
        for i in range(crowd.size()):
            var enemy: Dictionary=crowd[i]
            var radius: float=12.0 if i%3==0 else 25.2 if i%3==1 else 15.0
            # Legal spawn points are sampled at radius 24; keep this subfixture
            # at a legal point before beginning enlarged-radius movement.
            if frame==0 and not World.walkable(enemy["pos"],radius):enemy["pos"]=Vector2(720,600)
            var speed: float=45.0 if i%2 else 125.0
            var old: Vector2=enemy["pos"]
            if old.distance_to(goal)<=radius+20:continue
            enemy["pos"]=Nav.move(old,goal,speed/60.0,radius,enemy)
            Nav.observe(enemy,goal,old,(goal-old).normalized()*speed/60.0,1.0/60.0,frame/60.0,1+int(frame/720))
            expect(Vector2(enemy["pos"]).distance_to(old)<=speed/60.0+0.002,"Dense-wave speed exceeded")
            expect(World.walkable(enemy["pos"],radius),"Dense-wave geometry penetration")
    expect(rng.state==baseline_seed,"Navigation consumed RNG")
    expect(Nav.diagnostic_events.is_empty(),"Unexpected prolonged blocking: "+JSON.stringify(Nav.diagnostic_events.slice(0,3)))
    Nav.diagnostics_enabled=false
    print("NAV BENCH: 100 actors, 3600 frames / five moving-goal segments, ",Time.get_ticks_usec()-dense_start," us; CPU fixture, not FPS")
    print("NAV ROUTES: ",220-failed,"/220 reached; total us=",Time.get_ticks_usec()-started)
    if failures.is_empty():print("PASS: Cover tangents, radii, moving goals, concave approaches, dense-wave legality and RNG");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
