extends SceneTree
## Native Movie Maker fixture. The normal game does all presentation and combat.
## Start at 9:59, then prime a finishing hit for a short review recording.
var game
var age := 0.0
var primed := false
var reduced := false

func _initialize() -> void:
    call_deferred("_start")

func _start() -> void:
    reduced = "--reduced-motion" in OS.get_cmdline_user_args()
    game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.six_to_seven_qa = true
    game.profile.settings.reducedMotion = reduced
    game.profile.settings.sound = true
    game.profile.settings.masterVolume = 1.0
    game._apply_preferences()
    game.start_run(1)
    # The existing QA guard suppresses profile writes. Use the ordinary starter kit.
    game.passives.clear()
    game.run_time = 598.9
    game.wave = 5
    game.event_index = game.SoloEnemyRulesScript.EVENT_SCHEDULE.size()
    game.spawn_timer = 3.0
    game.legendary_spent = true
    var badge_layer := CanvasLayer.new()
    badge_layer.layer = 9
    root.add_child(badge_layer)
    var badge := Label.new()
    badge.position = Vector2(12, root.size.y - 44)
    badge.add_theme_stylebox_override("normal", _badge_style())
    badge.add_theme_font_size_override("font_size", 16)
    badge.text = "SYNTHETIC QA   |   9:59 START   |   FINISHING HP PRESET"
    if reduced:
        badge.text += "   |   REDUCED MOTION"
    badge_layer.add_child(badge)
    process_frame.connect(_direct)

func _badge_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color("17111f")
    style.content_margin_left = 8.0
    style.content_margin_right = 8.0
    style.content_margin_top = 4.0
    style.content_margin_bottom = 4.0
    return style

func _direct() -> void:
    age += root.get_process_delta_time()
    if game.mode == "playing":
        game.touch_direction = Vector2.ZERO
        if game.run_time > 603.1 and game.run_time < 603.85:
            game.touch_direction = Vector2.RIGHT
        if game.run_time > 606.70 and game.run_time < 607.42:
            game.touch_direction = Vector2.LEFT
        if game.run_time > 609.2 and not primed:
            for enemy: Dictionary in game.enemies:
                if enemy["kind"] == "boss":
                    enemy["hp"] = minf(1.0, float(enemy["hp"]))
                    primed = true
                    break
    elif game.mode == "won" and game.finish_visual_age > 3.0:
        print("PASS: Synthetic Big Hater run reached victory at %.2fs via normal damage resolver" % game.run_time)
        quit()
    if age > 25.0:
        push_error("Capture fixture did not reach victory")
        quit(1)
