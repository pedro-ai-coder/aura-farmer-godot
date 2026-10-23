class_name SpotlightComponents
extends RefCounted

## Live layout primitives. Never creates illustration masters or gameplay state.
const Style = preload("res://scripts/arcade_theme.gd")

static func action(caption: String, primary: bool = false) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(0,64)
    Style.button(button,primary)
    return button

static func ink_panel(dark: bool = true) -> PanelContainer:
    var panel := PanelContainer.new()
    panel.add_theme_stylebox_override("panel",Style.box(Style.DEEP if dark else Style.PAPER,Style.SKY if dark else Style.INK,16,6))
    return panel

static func label(caption: String, role: String = "body", pixels: int = 20, dark: bool = false) -> Label:
    var node := Label.new()
    node.text = caption
    node.add_theme_font_override("font",Style.font(role))
    node.add_theme_font_size_override("font_size",pixels)
    node.add_theme_color_override("font_color",Style.CARD if dark else Style.INK)
    node.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return node

static func status_plate(caption: String) -> PanelContainer:
    var plate := ink_panel()
    plate.add_child(label(caption,"numbers",20,true))
    return plate

static func icon_slot() -> PanelContainer:
    var slot := ink_panel(false)
    slot.custom_minimum_size = Vector2(48,48)
    return slot

static func modal_shell() -> PanelContainer:
    var modal := ink_panel(false)
    modal.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    return modal
