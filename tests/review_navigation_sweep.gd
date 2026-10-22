extends SceneTree
const Navigation = preload("res://scripts/enemy_navigation.gd")
const World = preload("res://scripts/solo_world_rules.gd")
func _initialize() -> void: call_deferred("_scan")
func _scan() -> void:
    var failures: Array[Dictionary] = []
    var tested := 0
    for radius in [12.0,15.0,21.0,38.0]:
        for center: Vector2 in [Vector2(600,550),Vector2(940,680)]:
            for side in range(16):
                var start: Vector2 = center+Vector2.from_angle(side*TAU/16)*(30+radius+1)
                for target_side in range(16):
                    var target := center+Vector2.from_angle(target_side*TAU/16)*180
                    if not World.walkable(start,radius) or not World.walkable(target,16): continue
                    tested += 1
                    var position: Vector2 = start
                    var state: Dictionary = {}
                    var last: Vector2 = start
                    var window_travel := 0.0
                    for step in range(720):
                        if position.distance_to(target) <= radius+19: break
                        var destination := Navigation.move(position,target,1.25,radius,state)
                        window_travel += destination.distance_to(position)
                        position = destination
                        if step%120 == 119:
                            if position.distance_to(last) < 2 and position.distance_to(target)>radius+19:
                                if failures.size()<8: failures.append({"radius":radius,"start":[start.x,start.y],"target":[target.x,target.y],"stuck":[position.x,position.y],"active_seconds":(step+1)/60.0,"travel_in_2s":window_travel})
                                break
                            last = position
                            window_travel = 0.0
    print("NAVIGATION SWEEP ",JSON.stringify({"tested":tested,"reproductions":failures}))
    quit(0 if failures.is_empty() else 1)
