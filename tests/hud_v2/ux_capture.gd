extends SceneTree
## Matched synthetic UX fixtures; isolated saves, no human-run or balance claim.
const Run=preload("res://tests/passive_feedback/review_run.gd")
func _initialize() -> void:call_deferred("capture")
func capture() -> void:
    var args:=OS.get_cmdline_user_args()
    root.size=Vector2i(int(args[0]),int(args[1]))
    var output: String=args[2]
    DirAccess.make_dir_recursive_absolute(output)
    var game:=Run.new();root.add_child(game);game.set_process(false)
    game.clean_cut_skin.set_process(false)
    game.touch_device=root.size.x<1000
    game.profile.settings.reducedMotion=true
    for state in ["normal","dense","semantics","miniboss","cards"]:
        game.prepare("dense" if state=="dense" else "timed-active" if state=="semantics" else "acquired")
        if state in ["normal","dense"]:
            game.equip("no-cap-streak")
            game.passive_feedback.reset()
            game.passive_feedback.notify(game,"no-cap-streak","No Cap Streak","Fifth activation · +10% damage")
        if state=="semantics":
            game._spawn_enemy("doomscroll-prime",{"pos":game.player_pos+Vector2(280,0)})
            var enemy: Dictionary=game.enemies[-1]
            game._schedule_hazard(game.player_pos+Vector2(100,0),80,0.8,3,18,"circle",Vector2.LEFT,enemy)
            game._schedule_hazard(game.player_pos+Vector2(-120,-50),65,0,3,18,"circle",Vector2.RIGHT,enemy)
            game._fire_weapons(0.2)
        if state=="miniboss":
            game.run_time=135;game.wave=2
            game._spawn_enemy("reply-guy",{"pos":game.player_pos+Vector2(200,0),"telegraph":true})
            game.passive_feedback.reset()
        if state=="cards":
            game.selection.assign([
                {"type":"passive","id":"w-wifi","rarity":"rare","level":1},
                {"type":"passive","id":"homie-check","rarity":"rare","level":1},
                {"type":"passive","id":"no-cap-streak","rarity":"rare","level":1}])
            game.mode="choice";game.pending_choices=1;game.selected_card_index=-1
        game.presentation._window_changed(true);game._show_ui();game._update_text();game._update_camera(0,true)
        game.passive_feedback.synchronize(game)
        game.clean_cut_skin.layout_key="";game.clean_cut_skin._process(0);game.queue_redraw()
        await process_frame;await process_frame;await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(output.path_join("%s-%dx%d.png" % [state,root.size.x,root.size.y]))
        print("CAPTURE ",state," ",root.size)
    game.queue_free();quit()
