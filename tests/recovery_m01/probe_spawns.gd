extends SceneTree
const World=preload("res://scripts/solo_world_rules.gd")
func _initialize() -> void:
    var rng=RandomNumberGenerator.new();rng.seed=8202
    var invalid:=0
    for i in range(300):
        var p: Vector2=World.spawn_point(Vector2(780,600),rng)
        if not World.walkable(p,48):invalid+=1
    print("LEGACY BOSS SPAWN CLEARANCE: ",invalid," / 300 illegal at actual 48 U radius")
    quit()
