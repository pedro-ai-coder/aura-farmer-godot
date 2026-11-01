extends SceneTree
const Visuals=preload("res://scripts/pickup_visuals.gd")
class Sheet extends Node2D:
    const Type=preload("res://scripts/clean_cut_typography.gd")
    func text(at: Vector2, value: String, size: int=22, color: Color=Color("fff9e9")) -> void:
        draw_string(Type.font("hud_secondary"),at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
    func _draw() -> void:
        draw_rect(Rect2(0,0,1280,720),Color("102233"))
        text(Vector2(32,48),"PICKUP REFRESH / CREATOR REVIEW CANDIDATES",29)
        for i in range(3):
            var kind: String=["aura","snack","magnet"][i]
            var x:=32.0+float(i)*416.0
            var image: Texture2D=Visuals.texture(kind)
            draw_rect(Rect2(x,72,392,604),Color("1c3445"))
            text(Vector2(x+20,107),Visuals.LABELS[kind],26)
            text(Vector2(x+20,140),"PNG / native 128 px",17,Color("a7c8ce"))
            draw_texture_rect(image,Rect2(x+132,154,128,128),false)
            var extent:=32.0 if kind=="aura" else 40.0
            text(Vector2(x+20,320),"Gameplay / %d U at 1 px per U" % int(extent),17,Color("a7c8ce"))
            Visuals.draw(self,{"kind":kind,"pos":Vector2(x+196,350)},0,true)
            text(Vector2(x+20,398),"Artwork / 2x enlarged",17,Color("a7c8ce"))
            draw_texture_rect(image,Rect2(x+68,408,256,256),false)
        text(Vector2(32,706),"Original editable SVGs + transparent PNGs. Canonical kinds: aura / snack / magnet. Approval pending.",16,Color("a7c8ce"))
func _initialize() -> void:call_deferred("capture")
func capture() -> void:
    if DisplayServer.get_name()=="headless":push_error("Rendered display required");quit(1);return
    root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
    var sheet:=Sheet.new();root.add_child(sheet)
    await process_frame;await process_frame;await RenderingServer.frame_post_draw
    if root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0])!=OK:quit(1);return
    print("CAPTURE pickup component sheet 1280x720");quit()
