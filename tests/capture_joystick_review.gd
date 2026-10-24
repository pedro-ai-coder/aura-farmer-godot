extends SceneTree
## Staged actual input/render evidence, not a physical-device or balance acceptance run.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile = ProfileStoreScript.defaults()
    func _save_profile() -> void: pass
func _initialize() -> void: call_deferred("capture")
func contact(index: int, at: Vector2, down: bool) -> void:
    var event := InputEventScreenTouch.new()
    event.index=index;event.position=at;event.pressed=down
    root.push_input(event,true)
func capture() -> void:
    var args := OS.get_cmdline_user_args()
    if args.is_empty(): quit(1);return
    DirAccess.make_dir_recursive_absolute(args[0])
    var game := ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    var records: Array=[]
    for extent in [Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent
        game.presentation._window_changed(true)
        for state in ["left","center","right","two_finger","paused","choice","safe_edge"]:
            game.start_run(0)
            game.touch_device=true
            game._spawn_enemy("npc",{"pos":game.player_pos+Vector2(80,0)})
            game.aura=100
            if state=="safe_edge":
                game.web_metrics={"safe":[44,20,16,12],"width":extent.x,"height":extent.y,"touch":true,"fullscreen":false}
            else: game.web_metrics={}
            game.presentation._window_changed(true)
            game._show_ui()
            var field: Rect2=game._touch_playfield()
            var fraction: Vector2=Vector2(0.12,0.5) if state=="left" else Vector2(0.88,0.5) if state=="right" else Vector2(0.5,0.5)
            var at: Vector2=field.position+field.size*fraction
            if state=="safe_edge": at=field.position+Vector2(2,2)
            contact(0,at,true)
            var move := InputEventScreenDrag.new();move.index=0;move.position=at+Vector2(50,-20)
            root.push_input(move,true)
            if state=="two_finger":
                var button: Vector2=game.flex_button.get_global_rect().get_center()
                contact(1,button,true);contact(1,button,false)
            elif state=="paused":game._toggle_pause()
            elif state=="choice":game._gain_xp(100);game._open_choice()
            game._update_text()
            game._update_camera(0,true);game.queue_redraw()
            await process_frame
            await process_frame
            await RenderingServer.frame_post_draw
            var image := root.get_texture().get_image()
            var name: String="%s-%dx%d.jpg" % [state,extent.x,extent.y]
            image.save_jpg(str(args[0]).path_join(name),0.88)
            records.append({"file":name,"requested_pixels":[extent.x,extent.y],"actual_pixels":[image.get_width(),image.get_height()],"mode":game.mode,"pointer_owner":game.touch_index,"axis":[game.touch_direction.x,game.touch_direction.y],"joystick_visible":game.touch_joystick.visible,"outer_radius":game.touch_joystick.OUTER_RADIUS,"thumb_radius":game.touch_joystick.THUMB_RADIUS,"saturation":game.touch_joystick.saturation(),"flex_uses":game.run_metrics["flexes"]})
            print("JOYSTICK CAPTURE ",name)
    var file:=FileAccess.open(str(args[0]).path_join("captures.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify(records,"  ")+"\n")
    quit(0)
