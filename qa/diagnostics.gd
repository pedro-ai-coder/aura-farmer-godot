extends CanvasLayer
## Visible synthetic flag and optional telemetry. Never modifies authoritative state.
var game
var caption: Label
var detail: Label
var geometry
var refresh_in:=0.0
func install(owner_game) -> void:
    game=owner_game
    layer=99
    caption=Label.new()
    caption.mouse_filter=Control.MOUSE_FILTER_IGNORE
    caption.add_theme_color_override("font_color",Color("f8c45f"))
    caption.add_theme_color_override("font_shadow_color",Color.BLACK)
    caption.add_theme_font_size_override("font_size",17)
    caption.text="QA / SYNTHETIC SCENARIO — NOT A NORMAL RUN"
    add_child(caption)
    detail=Label.new()
    detail.mouse_filter=Control.MOUSE_FILTER_IGNORE
    detail.add_theme_color_override("font_color",Color.WHITE)
    detail.add_theme_color_override("font_shadow_color",Color.BLACK)
    detail.add_theme_font_size_override("font_size",14)
    add_child(detail)
    geometry=load("res://qa/geometry.gd").new()
    geometry.game=game
    game.add_child(geometry)
    refresh()
func _process(delta: float) -> void:
    refresh_in-=delta
    if refresh_in<=0.0:
        refresh_in=0.2
        refresh()
func refresh() -> void:
    if game==null:return
    caption.visible=game._qa_synthetic
    detail.visible=game._qa_synthetic and not game.qa_overlay_flags.is_empty()
    var view: Vector2=game.get_viewport_rect().size
    caption.position=Vector2(12,maxf(30,view.y-57))
    detail.position=Vector2(maxf(8,view.x-220),54)
    if not detail.visible:return
    var rows: Array[String]=[]
    if bool(game.qa_overlay_flags.get("threats",false)):
        var types: Dictionary={}
        var active:=0
        var nearby:=0
        for enemy: Dictionary in game.enemies:
            if game.run_time<float(enemy["born"]):continue
            active+=1
            var kind:=str(enemy["kind"])
            types[kind]=int(types.get(kind,0))+1
            if game.player_pos.distance_squared_to(enemy["pos"])<=67600.0:nearby+=1
        rows.append("ACTIVE %d / NEAR 260U %d" % [active,nearby])
        rows.append("TYPES "+JSON.stringify(types))
    if bool(game.qa_overlay_flags.get("buffs",false)):
        rows.append("HP %.0f/%.0f SHIELD %.0f" % [game.hp,game.max_hp,game.shield])
        rows.append("LV %d XP %.0f AURA %.0f" % [game.level,game.xp,game.aura])
        rows.append("COOK STACKS %d" % game.cook_stacks)
        for key: String in game.passive_timers:
            if key.ends_with("_until") and float(game.passive_timers[key])>game.run_time:
                rows.append("%s %.1fs" % [key,float(game.passive_timers[key])-game.run_time])
    if bool(game.qa_overlay_flags.get("performance",false)):
        rows.append("ENGINE FPS %.0f" % Performance.get_monitor(Performance.TIME_FPS))
        rows.append("RENDER OBJECTS %d" % Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
    if bool(game.qa_overlay_flags.get("hitboxes",false)):
        rows.append("BOUNDARIES: player/enemies/covers")
    detail.text="\n".join(rows)
