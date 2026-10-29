extends SceneTree
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("verify")
func expect(ok: bool,message: String) -> void:
    if not ok:failures.append(message)
func verify() -> void:
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        var logical: Vector2i=game.presentation.layout_extent(Vector2(extent),{},false)
        for ratio in [1.0,1.5,2.0,3.0]:
            expect(game.presentation.layout_extent(Vector2(extent)*ratio,{"width":extent.x,"height":extent.y},true)==logical,"Retina layout must retain CSS-sized controls")
        root.size=extent;game.start_run(0);game.touch_device=true
        game.presentation._window_changed(true)
        await process_frame;await process_frame
        var skin=game.clean_cut_skin
        skin.refresh()
        var event:=InputEventScreenTouch.new();event.index=0;event.pressed=true
        event.position=Vector2(210,350)
        root.push_input(event,true)
        await process_frame
        expect(game.touch_active,"Touch starts on clear terrain")
        skin.refresh()
        var layouts: int=skin.layout_count
        var rng: int=game.rng.state
        for i in range(180):
            var drag:=InputEventScreenDrag.new();drag.index=0;drag.position=Vector2(240+sin(i*0.05)*12,355+cos(i*0.05)*12)
            root.push_input(drag,true);skin.refresh()
        expect(game.touch_direction.length()>0,"Drag retains movement")
        expect(skin.joystick_ring.visible and skin.joystick_thumb.visible,"Live joystick artwork remains visible")
        expect(skin.layout_count==layouts,"180 drag updates must not rebuild HUD")
        expect(game.rng.state==rng,"Presentation consumes no gameplay RNG")
        event.pressed=false;root.push_input(event,true);skin.refresh()
        expect(not skin.joystick_ring.visible and not skin.joystick_thumb.visible,"Release hides both joystick sprites")
    game.queue_free()
    if failures.is_empty():print("PASS: Six viewport real touch drag/release, stable HUD layout, unchanged RNG and CSS/DPR target parity");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
