extends SceneTree
const Nav=preload("res://scripts/enemy_navigation.gd")
const World=preload("res://scripts/solo_world_rules.gd")
func _initialize() -> void:
    var rng=RandomNumberGenerator.new();rng.seed=8201
    var bad: Array=[]
    for i in range(220):
        var radius: float=[12.0,15.0,21.0,25.2,48.0][i%5]
        var start: Vector2=World.spawn_point(Vector2(720,600),rng)
        while not World.walkable(start,radius):start=World.spawn_point(Vector2(720,600),rng)
        var target: Vector2=World.spawn_point(start,rng)
        var pos:=start;var state: Dictionary={};var speed: float=75.0
        for step in range(1200):
            pos=Nav.move(pos,target,speed/60.0,radius,state)
            if pos.distance_to(target)<radius+20:break
        if pos.distance_to(target)>radius+20:
            bad.append({"radius":radius,"start":[start.x,start.y],"target":[target.x,target.y],"end":[pos.x,pos.y],"waypoint":str(state.get("navigation_waypoint")),"side":state.get("navigation_side")})
    print("PROBE ",JSON.stringify(bad))
    print("FAILED ROUTES ",bad.size()," / 220")
    quit()
