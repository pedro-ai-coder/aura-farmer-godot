extends SceneTree
const Guide=preload("res://scripts/melee_readability.gd")
const Solo=preload("res://scripts/solo_run.gd")
class ReviewRun extends Solo:
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    for kit in [0,1,2]:
        game.start_run(kit);game.enemies.clear()
        var reach: float=game.WEAPONS[game.hero["starter"]]["range"]
        game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(reach+1,0)})
        var enemy: Dictionary=game.enemies[0];enemy["born"]=game.run_time
        var before: int=game.rng.state
        var cue:=Guide.snapshot(game)
        if kit==0:assert(cue.is_empty());continue
        assert(not cue.is_empty() and not cue["in_reach"])
        assert(cue["reach"]==reach)
        enemy["pos"]=game.player_pos+Vector2(reach,0)
        assert(Guide.snapshot(game)["in_reach"])
        enemy["born"]=game.run_time+1
        assert(Guide.snapshot(game).is_empty())
        enemy["born"]=game.run_time;enemy["hp"]=0
        assert(Guide.snapshot(game).is_empty())
        assert(game.rng.state==before)
    game.queue_free();await process_frame
    print("PASS: Actual melee starter threshold, exact inside/outside range, future/dead target rejection, ranged exclusion and RNG isolation")
    quit()
