extends SceneTree
const Design=preload("res://scripts/cpk_design_system.gd")
func _initialize() -> void:
    call_deferred("check")
func check() -> void:
    assert(Design.contrast(Design.PAPER,Design.PANEL)>=7.0)
    assert(Design.contrast(Design.INK,Design.ORANGE)>=4.5)
    var button:=Button.new();root.add_child(button)
    Design.button(button,true)
    assert(button.theme==Design.theme())
    assert(button.focus_mode==Control.FOCUS_ALL)
    assert(button.custom_minimum_size.y>=48)
    for state in ["normal","hover","pressed","disabled","focus"]:
        assert(button.get_theme_stylebox(state)!=null)
    assert(button.get_theme_stylebox("normal")!=button.get_theme_stylebox("disabled"))
    assert(button.get_theme_stylebox("normal").bg_color.is_equal_approx(Design.ORANGE))
    Design.card(button,true)
    assert(button.get_theme_stylebox("normal").border_color==Design.ORANGE)
    button.queue_free()
    print("PASS: Shared native CPK Theme, readable contrast, distinct states, keyboard focus, touch size and selected card")
    quit()
