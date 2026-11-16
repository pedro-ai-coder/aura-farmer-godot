extends SceneTree
## Actual Neon gameplay, seed 468, ordinary health, no injected combat state.
## Two unchanged 60Hz simulation steps per real rendered 30fps evidence frame.
const Review=preload("res://scripts/cool_kid_review.gd")
var game: Node
var stream: StreamPeerTCP
func _initialize() -> void:call_deferred("record")
func record() -> void:
    root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
    var args:=OS.get_cmdline_user_args();var output:=args[0]
    DirAccess.make_dir_recursive_absolute(output)
    if args.has("--raw"):
        stream=StreamPeerTCP.new();stream.connect_to_host("127.0.0.1",9876)
        while stream.get_status()==StreamPeerTCP.STATUS_CONNECTING:
            stream.poll();await process_frame
        if stream.get_status()!=StreamPeerTCP.STATUS_CONNECTED:push_error("Video encoder connection failed");quit(1);return
    game=Review.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.hero_appearance="original";game.start_run(1)
    game.art.cool_kid_rig.enabled=not args.has("--legacy")
    var full:=args.has("--full");var limit:=10800 if full or args.has("--defeat") else 1440
    var start_frame:=0
    for arg in args:
        if arg.begins_with("--start="):start_frame=int(float(arg.trim_prefix("--start="))*60.0)
    if args.has("--ab"):game.art.cool_kid_rig.enabled=false
    var digest:=HashingContext.new();digest.start(HashingContext.HASH_SHA256)
    var events: Array=[];var previous_state:="";var count:=0
    for i in range(limit):
        if game.mode in ["choice","replace","legendary"]:game.pick_upgrade(0);game._confirm_selection()
        if game.mode!="playing":break
        # Same previously exercised normal-run controls, with a short idle lead-in.
        game.touch_direction=Vector2.ZERO if args.has("--defeat") else Vector2.from_angle(float(i/180)*PI/4.0) if full else controls(i)
        if game.aura>=100.0:game._use_flex()
        game._process(1.0/60.0)
        var state: String=game.hero_pose()["state"]
        digest.update(var_to_bytes([game.player_pos,game.hp,game.rng.state,game.enemies,game.kills,game.aura,game.run_time,game.weapons]))
        if state!=previous_state:
            events.append({"frame":i,"time":game.run_time,"state":state,"hp":game.hp,"view":game.art.cool_kid_rig.view})
            previous_state=state
        if args.has("--ab") and i>0 and i%360==0:
            var event:=InputEventKey.new();event.physical_keycode=KEY_F8;event.pressed=true
            game._input(event)
        if i>=start_frame and i%2==0:
            game._review_label();game.clean_cut_skin._process(1.0/30.0);game.queue_redraw()
            await process_frame;await RenderingServer.frame_post_draw
            save_frame(output,count);count+=1
    # Include the canonical loss clock and actual defeat rendering after loss.
    if game.mode=="lost":
        for frame in range(45):
            game._process(1.0/30.0);game._review_label();game.clean_cut_skin._process(1.0/30.0);game.queue_redraw()
            await process_frame;await RenderingServer.frame_post_draw
            save_frame(output,count);count+=1
    if stream!=null:stream.disconnect_from_host()
    var report: Dictionary={"candidate":game.art.cool_kid_rig.enabled,"seed":468,"frames":count,"seconds":game.run_time,"hp":game.hp,"mode":game.mode,"hash":digest.finish().hex_encode(),"events":events,"reach_releases":game.art.cool_kid_rig.reach_releases,"fps":30,"capture_start_seconds":start_frame/60.0,"ab":args.has("--ab"),"source":"actual Neon runtime; automation controls; no invulnerability or injected gameplay events"}
    FileAccess.open(output.path_join("report.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
    print(JSON.stringify(report));game.queue_free();await process_frame;quit()
func controls(frame: int) -> Vector2:
    if frame<90:return Vector2.ZERO
    if frame<930:
        var directions: Array=[0,4,2,6,1,5,3,7]
        return Vector2.from_angle(float(directions[((frame-90)/42)%8])*PI/4)
    if frame<1200:return Vector2.ZERO if (frame/24)%2==0 else Vector2.LEFT
    return Vector2.ZERO

func save_frame(output: String, index: int) -> void:
    var pixels:=root.get_texture().get_image()
    if stream!=null:
        pixels.convert(Image.FORMAT_RGBA8);stream.put_data(pixels.get_data())
    else:pixels.save_png(output.path_join("%05d.png"%index))
