extends SceneTree
## Clean Cut Flex presentation uses live Aura data and never intercepts touch.
var failures: Array[String] = []

func check(value: bool, message: String) -> void:
    if not value:
        failures.append(message)

func _initialize() -> void:
    call_deferred("verify")

func verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    var skin = game.clean_cut_skin
    skin.set_process(false)
    for viewport_size in [Vector2i(1600,900),Vector2i(915,412),Vector2i(390,844)]:
        root.size = viewport_size
        game.presentation._window_changed(true)
        game.start_run(0)
        game.aura = 42.0
        game.flex_lock = 0.0
        game.flex_time = 0.0
        skin.refresh()
        check(skin.flex_status.text == "AURA 42%","Charging Flex reports live Aura at %s" % viewport_size)
        check(skin.flex_badge.mouse_filter == Control.MOUSE_FILTER_IGNORE,"Flex badge does not capture gameplay touches")
        game.aura = 100.0
        game._update_text()
        skin.refresh()
        check(skin.flex_status.text == "FLEX READY","Ready Flex is explicitly legible at %s" % viewport_size)
        check(skin.aura_arc.visual_state == "ready","Ready Flex has a full high-contrast Aura ring")
        var safe_screen := Rect2(Vector2.ZERO,game.presentation.view).grow(0.5)
        check(safe_screen.encloses(skin.flex_badge.get_rect()),"Flex state badge fits useful viewport at %s" % viewport_size)
        check(safe_screen.encloses(game.flex_button.get_rect()),"Actual Flex action remains on-screen at %s" % viewport_size)
        check(game.flex_button.visible and not game.flex_button.disabled,"Full Aura keeps actual Flex action tappable")
        game.flex_time = 3.0
        game.flex_lock = 27.0
        game.aura = 0.0
        skin.refresh()
        check(skin.flex_status.text.begins_with("ACTIVE ") and skin.flex_status.text.ends_with("S"),"Active Flex shows remaining canonical duration")
        check(skin.aura_arc.visual_state == "active","Active Flex receives distinct high-contrast ring")
        game.flex_time = 0.0
        skin.refresh()
        check(skin.flex_status.text.begins_with("RECOVERY"),"Recovery is clearly distinct from READY")
        game.flex_lock = 0.0
        skin.refresh()
        check(skin.flex_status.text == "AURA 0%","Empty Aura reverts to charging state")
    game.queue_free()
    if failures.is_empty():
        print("PASS: Flex clarity, readiness, active/recovery display and touch-safe layout across desktop/mobile")
        quit(0)
    else:
        for message in failures:
            push_error(message)
        quit(1)
