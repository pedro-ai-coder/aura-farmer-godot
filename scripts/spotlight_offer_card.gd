class_name SpotlightOfferCard
extends RefCounted

## Live V5 hierarchy with approved texture slots and honest glyph fallback.
const UI = preload("res://scripts/spotlight_components.gd")
const Style = preload("res://scripts/arcade_theme.gd")

static func install(button: Button) -> Dictionary:
    var parts := {}
    for key in ["band","icon_frame"]:
        var panel := Panel.new()
        panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        button.add_child(panel)
        parts[key] = panel
    for key in ["meta","icon","name","category","body","comparison","state"]:
        var label := UI.label("","body",18)
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.add_child(label)
        parts[key] = label
    var image := TextureRect.new()
    image.mouse_filter = Control.MOUSE_FILTER_IGNORE
    image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    button.add_child(image)
    parts["image"] = image
    return parts

static func _place(control: Control, rect: Rect2) -> void:
    control.position = rect.position
    control.size = rect.size
    if control is Label: control.set_deferred("size",rect.size)

static func layout(parts: Dictionary, extent: Vector2, legendary: bool, rarity: String, category: String, level_caption: String) -> void:
    var width := extent.x
    var height := extent.y
    var rim: Color = Style.RARITY.get(rarity,Style.INK)
    parts["band"].add_theme_stylebox_override("panel",Style.box(rim,Color.TRANSPARENT,8,0))
    _place(parts["band"],Rect2(7,7,width-14,28))
    parts["meta"].text = rarity.to_upper()
    parts["meta"].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    parts["meta"].add_theme_font_override("font",Style.BLACK)
    parts["meta"].add_theme_font_size_override("font_size",14)
    parts["meta"].add_theme_color_override("font_color",Style.INK)
    _place(parts["meta"],Rect2(14,10,width-28,22))
    parts["icon_frame"].add_theme_stylebox_override("panel",Style.box(Style.BLUE.lightened(0.7),Style.INK,10,0))
    var icon_rect := Rect2(16,46,66,66) if legendary else Rect2((width-64)/2,44,64,64)
    _place(parts["icon_frame"],icon_rect)
    parts["icon"].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    parts["icon"].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    parts["icon"].autowrap_mode = TextServer.AUTOWRAP_OFF
    parts["icon"].add_theme_font_override("font",Style.font("body"))
    parts["icon"].add_theme_font_size_override("font_size",34)
    _place(parts["icon"],icon_rect)
    _place(parts["image"],icon_rect.grow(-4))
    parts["name"].add_theme_font_override("font",Style.BLACK)
    parts["name"].add_theme_font_size_override("font_size",20 if legendary else 22)
    parts["name"].horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if legendary else HORIZONTAL_ALIGNMENT_CENTER
    _place(parts["name"],Rect2(94,44,width-110,48) if legendary else Rect2(16,114,width-32,56))
    parts["category"].text = category.to_upper() + ("" if legendary else "  /  " + level_caption)
    parts["category"].add_theme_font_override("font",Style.NUMBERS)
    parts["category"].add_theme_font_size_override("font_size",13)
    parts["category"].horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if legendary else HORIZONTAL_ALIGNMENT_CENTER
    _place(parts["category"],Rect2(94,94,width-110,22) if legendary else Rect2(16,174,width-32,22))
    parts["body"].add_theme_font_size_override("font_size",16 if legendary else 18)
    parts["body"].horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if legendary else HORIZONTAL_ALIGNMENT_CENTER
    _place(parts["body"],Rect2(16,118,width-32,height-154) if legendary else Rect2(16,202,width-32,height-292))
    parts["comparison"].visible = not legendary
    parts["comparison"].add_theme_font_override("font",Style.NUMBERS)
    parts["comparison"].add_theme_font_size_override("font_size",14)
    parts["comparison"].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _place(parts["comparison"],Rect2(16,height-84,width-32,48))
    parts["state"].add_theme_font_override("font",Style.BLACK)
    parts["state"].add_theme_font_size_override("font_size",12)
    parts["state"].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _place(parts["state"],Rect2(12,height-29,width-24,22))

    if not legendary and height < 400:
        # Compact landscape keeps comparison and confirmation visible together.
        _place(parts["icon_frame"],Rect2(16,44,48,48))
        _place(parts["icon"],Rect2(16,44,48,48))
        _place(parts["image"],Rect2(20,48,40,40))
        parts["icon"].add_theme_font_size_override("font_size",28)
        parts["name"].horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        parts["name"].add_theme_font_size_override("font_size",20)
        _place(parts["name"],Rect2(76,42,width-92,52))
        _place(parts["category"],Rect2(16,98,width-32,20))
        parts["body"].add_theme_font_size_override("font_size",16)
        _place(parts["body"],Rect2(16,124,width-32,height-208))
