extends SceneTree
## Controlled native execution reel, not human input, Web QA or a normal run.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile=ProfileStoreScript.defaults()
    func _save_profile() -> void: pass
func _initialize() -> void: call_deferred("record")
func record() -> void:
    root.size=Vector2i(1280,720)
    var game=ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    var args:=OS.get_cmdline_user_args()
    var output:=args[0] if not args.is_empty() else "user://combat-review"
    DirAccess.make_dir_recursive_absolute(output)
    var ids := ["no-cap","ratio-blaster","brainrot-feed","keyboard-warrior","ban-hammer","touch-grass","cope-shield","chad-hands","personal-space"]
    var title:=Label.new()
    title.position=Vector2(390,110)
    title.add_theme_font_size_override("font_size",18)
    title.add_theme_color_override("font_color",Color.WHITE)
    title.add_theme_constant_override("outline_size",5)
    game.layer.add_child(title)
    for i in range(ids.size()):
        game.start_run(int(i/3))
        game.weapons.assign([{"id":ids[i],"level":1,"rarity":"common","timer":0.0}])
        game.player_pos=Vector2(780,590)
        game.spawn_timer=INF
        game.manual_aim=true
        game.aim_point=game.player_pos+Vector2(200,0)
        title.text="CONTROLLED NATIVE / "+ids[i].to_upper()
        for frame in range(120):
            if frame%40==0:
                game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(75,-12)})
                game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(90,24)})
            game.touch_direction=Vector2(0,sin(frame/30.0)*0.25)
            game._process(1.0/30.0)
            game.clean_cut_skin.refresh()
            await process_frame
            await RenderingServer.frame_post_draw
            if frame in [8,18,48]:
                root.get_texture().get_image().save_png(output+"/"+ids[i]+"-"+str(frame)+".png")
    game.queue_free()
    quit()
