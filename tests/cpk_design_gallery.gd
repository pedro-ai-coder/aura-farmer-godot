extends SceneTree
const Design=preload("res://scripts/cpk_design_system.gd")
func _initialize() -> void:call_deferred("render")
func render() -> void:
    root.size=Vector2i(1280,720)
    var canvas:=Control.new();canvas.theme=Design.theme();canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);root.add_child(canvas)
    var background:=ColorRect.new();background.color=Design.INK;background.size=Vector2(1280,720);canvas.add_child(background)
    var stack:=VBoxContainer.new();stack.position=Vector2(48,36);stack.size=Vector2(1184,650);stack.add_theme_constant_override("separation",20);canvas.add_child(stack)
    for text in ["CLUTCHPUNKS / COMPONENT REVIEW","CPK palette · shared native Theme · candidate application"]:
        var label:=Label.new();Design.label(label,"display" if text.begins_with("CLUTCH") else "body");label.text=text;stack.add_child(label)
    var palette:=HBoxContainer.new();stack.add_child(palette)
    for value in [["OFF-WHITE / F3E9DB",Design.PAPER],["ORANGE / FF6A00",Design.ORANGE],["VIOLET / 9B00FF",Design.VIOLET],["CHARCOAL",Design.PANEL]]:
        var column:=VBoxContainer.new();column.custom_minimum_size.x=280;palette.add_child(column)
        var color:=ColorRect.new();color.color=value[1];color.custom_minimum_size=Vector2(280,58);column.add_child(color)
        var label:=Label.new();label.text=value[0];Design.label(label,"micro");column.add_child(label)
    var row:=HBoxContainer.new();stack.add_child(row)
    for text in ["PLAY","HERO SELECT","DISABLED","KEYBOARD FOCUS"]:
        var button:=Button.new();button.text=text;Design.button(button,text=="PLAY");button.custom_minimum_size=Vector2(280,60);row.add_child(button)
        button.disabled=text=="DISABLED"
        if text=="KEYBOARD FOCUS":button.grab_focus()
    var cards:=HBoxContainer.new();stack.add_child(cards)
    for i in range(3):
        var card:=Button.new();Design.card(card,i==1);card.custom_minimum_size=Vector2(380,190);cards.add_child(card)
        var content:=VBoxContainer.new();content.mouse_filter=Control.MOUSE_FILTER_IGNORE;content.position=Vector2(24,22);content.size=Vector2(332,140);card.add_child(content)
        for text in [["SELECTED" if i==1 else "NATIVE CARD","micro"],["Clear hierarchy","title"],["Real controls. Stable hitboxes.\nReadable contrast and touch targets.","body"]]:
            var label:=Label.new();label.text=text[0];Design.label(label,text[1]);content.add_child(label)
    var footer:=Label.new();footer.text="Presentation review · no gameplay, RNG, save or balance changes";Design.label(footer,"small");stack.add_child(footer)
    await process_frame;await process_frame;await RenderingServer.frame_post_draw
    var args:=OS.get_cmdline_user_args()
    if args.size()>0:root.get_texture().get_image().save_png(args[0])
    quit()
