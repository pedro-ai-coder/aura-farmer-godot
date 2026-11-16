extends SceneTree
## Synthetic diagnostic, explicitly not ordinary gameplay evidence.
const Rig=preload("res://scripts/cool_kid_articulated.gd")
const Legacy=preload("res://scripts/full_hero_atlases.gd")
class Board extends Node2D:
    var rig=Rig.new()
    var legacy=Legacy.new()
    var time:=0.0
    var context: Dictionary={}
    var state:="idle"
    var direction:=0
    var joints:=true
    func _ready() -> void:rig.enabled=true;rig.prepare()
    func _draw() -> void:
        draw_rect(Rect2(0,0,1280,720),Color("253342"))
        draw_string(ThemeDB.fallback_font,Vector2(24,30),"CANDIDATE v2 / SYNTHETIC RIG INSPECTION / NOT GAMEPLAY PROOF",HORIZONTAL_ALIGNMENT_LEFT,-1,20)
        draw_string(ThemeDB.fallback_font,Vector2(24,60),"View %d | %s | eight source views, no mirroring | orange: joints, cyan: ankle targets" % [direction,state],HORIZONTAL_ALIGNMENT_LEFT,-1,18)
        draw_string(ThemeDB.fallback_font,Vector2(55,180),"LEGACY / normal scale",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
        draw_string(ThemeDB.fallback_font,Vector2(310,180),"CANDIDATE / normal scale",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
        legacy.draw(self,Vector2(160,330),"cool-kid","original",{"state":state},context)
        rig.sample(state,context,direction)
        var small:=Transform2D(0.0,Vector2(Rig.SCALE,Rig.SCALE),0.0,Vector2(420,330)-Rig.ORIGIN*Rig.SCALE)
        rig._draw_parts(self,small,1.0)
        draw_set_transform_matrix(Transform2D.IDENTITY)
        draw_line(Vector2(40,330),Vector2(550,330),Color("91a1ad"))
        var base:=Transform2D(0.0,Vector2.ONE*Rig.SCALE*5.0,0.0,Vector2(910,640)-Rig.ORIGIN*Rig.SCALE*5.0)
        rig._draw_parts(self,base,1.0)
        draw_set_transform_matrix(Transform2D.IDENTITY)
        if joints:
            for part in rig.parts:
                var id: String=part["name"]
                var at: Vector2=base*(rig.transforms[id]*rig.pivots[id])
                draw_circle(at,3.0,Color("ff982a"))
            for target in rig.contact_targets:draw_circle(base*target,4.0,Color("55e4e4"),false,2.0)
        draw_string(ThemeDB.fallback_font,Vector2(24,690),"Two-second diagnostic windows; curves use canonical clocks. Candidate art and motion are NOT APPROVED.",HORIZONTAL_ALIGNMENT_LEFT,-1,17)
var board: Board
func _initialize() -> void:call_deferred("record")
func record() -> void:
    root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
    board=Board.new();root.add_child(board)
    var args:=OS.get_cmdline_user_args();var output:=args[0] if not args.is_empty() else ""
    var stream: StreamPeerTCP
    if not output.is_empty():
        DirAccess.make_dir_recursive_absolute(output)
        if args.has("--raw"):
            stream=StreamPeerTCP.new();stream.connect_to_host("127.0.0.1",9876)
            while stream.get_status()==StreamPeerTCP.STATUS_CONNECTING:
                stream.poll();await process_frame
            if stream.get_status()!=StreamPeerTCP.STATUS_CONNECTED:push_error("Video encoder connection failed");quit(1);return
    var states: Array=["idle","run","attack","hurt","flex-in","flex-loop","flex-out","defeat"]
    for frame in range(30*32):
        var time:=frame/30.0
        var direction:=mini(7,int(time/2.0)) if time<16.0 else posmod(int(time),8)
        var state: String="run" if time<16.0 else str(states[mini(7,int((time-16.0)/2.0))])
        var age:=fmod(time,2.0)
        var context: Dictionary={"time":time,"walk":time,"heading":direction*PI/4,"facing":direction*PI/4,"moving":state in ["run","attack","hurt"],"hero_id":"cool-kid","appearance":"original","attack":maxf(0,0.22-fmod(age,0.8)),"hurt":maxf(0,0.18-fmod(age,0.8)),"flex_age":age if state=="flex-in" else 1.0,"flex":maxf(0,0.25-age) if state=="flex-out" else 2.0,"defeat":age}
        board.time=time;board.direction=direction;board.state=state;board.context=context;board.queue_redraw()
        await process_frame;await RenderingServer.frame_post_draw
        if stream!=null:
            var pixels:=root.get_texture().get_image();pixels.convert(Image.FORMAT_RGBA8);stream.put_data(pixels.get_data())
        elif not output.is_empty():root.get_texture().get_image().save_png(output.path_join("%05d.png"%frame))
    if stream!=null:stream.disconnect_from_host()
    quit()
