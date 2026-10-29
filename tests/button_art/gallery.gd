extends SceneTree
const Art = preload("res://scripts/hero_clash_button_art.gd")
const Type = preload("res://scripts/clean_cut_typography.gd")
class Tile extends Control:
    var family: String
    var state: String
    func _draw() -> void:
        if family=="selection":
            draw_style_box(panel(),Rect2(5,5,size.x-10,size.y-10))
        Art.draw(self,family,state,Rect2(Vector2.ZERO,size))
        var face: Font=Type.font("button_label")
        var label: String="SELECTED" if state=="selected" else "HERO / ITEM" if family=="selection" else "CONFIRM QUIT" if family=="destructive" else "SETTINGS" if family=="secondary" else "PLAY"
        var point:=Vector2(16,(size.y-face.get_height(20))*0.5+face.get_ascent(20)-3)
        draw_string(face,point,label,HORIZONTAL_ALIGNMENT_CENTER,size.x-32,20,Color("13233a"))
    func panel() -> StyleBoxFlat:
        var p:=StyleBoxFlat.new();p.bg_color=Color("f7edcd");return p
func label(parent: Node,value: String,at: Vector2,pixels: int) -> void:
    var n:=Label.new();parent.add_child(n);n.text=value;n.position=at
    Type.apply(n,"button_label",false,Color("fff9e9"));n.add_theme_font_size_override("font_size",pixels)
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
    root.size=Vector2i(1600,900)
    root.content_scale_size=Vector2i(1600,900)
    var canvas:=Control.new();root.add_child(canvas)
    var bg:=ColorRect.new();bg.color=Color("13233a");bg.size=Vector2(1600,900);canvas.add_child(bg)
    label(canvas,"AURA FARMER / ORIGINAL BUTTON ART CANDIDATES",Vector2(30,24),28)
    label(canvas,"STATIC GODOT RENDER · NO ANIMATION · CREATOR APPROVAL PENDING",Vector2(30,70),18)
    var states: Array=["normal","hover","focus","pressed","selected","disabled"]
    for col in range(6): label(canvas,states[col].to_upper(),Vector2(32+col*260,122),19)
    var families: Array=["primary","secondary","destructive","selection"]
    for row in range(4):
        label(canvas,families[row].to_upper(),Vector2(30,170+row*170),20)
        for col in range(6):
            var tile:=Tile.new();tile.family=families[row];tile.state=states[col]
            tile.position=Vector2(24+col*260,208+row*170);tile.size=Vector2(244,96)
            canvas.add_child(tile)
    await process_frame
    await RenderingServer.frame_post_draw
    var args:=OS.get_cmdline_user_args()
    var path: String=args[0] if args.size() else "user://button-gallery.png"
    assert(root.get_texture().get_image().save_png(path)==OK)
    print("CAPTURE ",path)
    quit()
