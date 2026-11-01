extends SceneTree
## CPU command-submission microbenchmark only; not GPU/FPS or a mobile device.
class Bench extends "res://tests/pickup_refresh/before_run.gd":
    var candidate:=false
    var samples: Array[int]=[]
    var completed:=false
    func _draw() -> void:
        var stamp:=Time.get_ticks_usec()
        for drop in pickups:
            if candidate:PickupVisuals.draw(self,drop,run_time,true)
            else:_draw_pickup(drop)
        samples.append(Time.get_ticks_usec()-stamp)
        completed=true
func _initialize() -> void:call_deferred("measure")
func stats(values: Array[int]) -> Dictionary:
    var sorted:=values.duplicate();sorted.sort()
    return {"samples":sorted.size(),"median_us":sorted[int(sorted.size()*0.5)],"p95_us":sorted[int(sorted.size()*0.95)],"p99_us":sorted[int(sorted.size()*0.99)]}
func measure() -> void:
    root.size=Vector2i(844,390)
    var game:=Bench.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.start_run(0);game.profile["settings"]["reducedMotion"]=true;game.pickups.clear()
    for i in range(240):game.pickups.append({"kind":"aura","pos":Vector2(500+(i%20)*18,350+(i/20)*18),"xp":5.0})
    game.pickups.append({"kind":"aura","pos":Vector2(700,550),"xp":80.0,"phase":2})
    for kind in ["snack","magnet"]:game.pickups.append({"kind":kind,"pos":Vector2(730,550),"xp":0.0})
    var before: Array[int]=[];var after: Array[int]=[]
    # Alternate equally sized blocks to limit temperature/load/order confounding.
    for block in range(6):
        game.candidate=block%2==1
        for frame in range(75):
            game.completed=false;game.queue_redraw()
            await process_frame
            await RenderingServer.frame_post_draw
            if not game.completed:push_error("No draw callback observed");quit(1);return
            if frame>=15:
                if game.candidate:after.append(game.samples[-1])
                else:before.append(game.samples[-1])
    var report:={"scope":"CPU pickup drawing command submission only; no FPS, GPU or physical-device claim","engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"pickups":game.pickups.size(),"before":stats(before),"after":stats(after),"rgba_texture_bytes":3*128*128*4,"new_particles":0,"new_per_frame_resources":0,"ordering":"six alternating A/B blocks, 15 warm-up + 60 retained draw samples each"}
    var file:=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
    print("MEASURE ",JSON.stringify(report));game.queue_free();quit()
