extends SceneTree
const Rig=preload("res://scripts/cool_kid_articulated.gd")
const Legacy=preload("res://scripts/full_hero_atlases.gd")
class Sample extends Node2D:
    var rig=Rig.new()
    var legacy=Legacy.new()
    var phase: String
    var context: Dictionary
    var candidate: bool
    func _draw() -> void:
        if candidate:rig.draw(self,Vector2.ZERO,"cool-kid","original",{"state":phase},context)
        else:legacy.draw(self,Vector2.ZERO,"cool-kid","original",{"state":phase},context)
class Board extends Node2D:
    func _draw() -> void:
        draw_rect(Rect2(0,0,1536,900),Color("253342"))
        var names: Array=["idle","run contact","run passing","attack","hurt","flex-in","flex-loop","defeat"]
        for i in range(8):
            var x:=float(i%4)*384
            var y:=float(i/4)*440
            draw_string(ThemeDB.fallback_font,Vector2(x+10,y+28),names[i]+" / legacy | candidate",HORIZONTAL_ALIGNMENT_LEFT,-1,16)
            draw_line(Vector2(x+20,y+390),Vector2(x+364,y+390),Color("93a5b7"))
func _initialize() -> void:call_deferred("capture")
func capture() -> void:
    root.size=Vector2i(1536,900)
    root.content_scale_size=Vector2i(1536,900)
    var board:=Board.new();root.add_child(board)
    var names: Array=["idle","run","run","attack","hurt","flex-in","flex-loop","defeat"]
    for i in range(8):
        var state: String=names[i]
        for b in range(2):
            var sample:=Sample.new()
            sample.phase=state;sample.candidate=b==1
            sample.context={"time":0.5,"walk":0.02 if i==1 else 0.12,"attack":0.12,"hurt":0.1,"flex":2.0,"flex_age":0.15 if state=="flex-in" else 0.6,"defeat":0.5,"moving":state=="run","heading":0.0,"hero_id":"cool-kid","appearance":"original"}
            sample.rig.enabled=true;sample.rig.prepare()
            sample.position=Vector2(float(i%4)*384+96+b*192,float(i/4)*440+390)
            sample.scale=Vector2(3,3);board.add_child(sample)
    await process_frame;await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]);quit()
