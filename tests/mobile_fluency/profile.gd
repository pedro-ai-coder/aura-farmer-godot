extends SceneTree
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func stats(values: Array) -> Dictionary:
    values.sort();return {"median_us":values[values.size()/2],"p95_us":values[int(values.size()*0.95)],"max_us":values.back()}
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.start_run(0);game.hp=100000
    var cold: Array=[];var warm: Array=[]
    for kind in game.art.enemy_rows:
        for frame in range(8):
            var start:=Time.get_ticks_usec();game.art.enemy_frame(kind,frame);cold.append(Time.get_ticks_usec()-start)
            start=Time.get_ticks_usec();game.art.enemy_frame(kind,frame);warm.append(Time.get_ticks_usec()-start)
    print("FRAME CACHE ",JSON.stringify({"cold":stats(cold),"warm":stats(warm)}))
    for count in [20,100]:
        game.start_run(0);game.hp=100000
        for i in range(count):game._spawn_enemy("npc")
        var samples: Array=[]
        for i in range(180):
            var start:=Time.get_ticks_usec();game._step_enemies(1.0/60.0);samples.append(Time.get_ticks_usec()-start)
        print("AI ",count," ",JSON.stringify(stats(samples)))
    var samples: Array=[];var layouts: int=game.clean_cut_skin.layout_count
    for i in range(180):
        game.touch_direction=Vector2.from_angle(i*0.01)
        var start:=Time.get_ticks_usec();game.clean_cut_skin.refresh();samples.append(Time.get_ticks_usec()-start)
    print("HUD DRAG ",JSON.stringify(stats(samples))," layouts=",game.clean_cut_skin.layout_count-layouts)
    game.queue_free();quit()
