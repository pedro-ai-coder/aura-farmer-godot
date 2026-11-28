extends SceneTree
const Garage=preload("res://scripts/signal_breaker_garage.gd")
const Solo=preload("res://scripts/solo_run.gd")
class IsolatedRun extends Solo:
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
class IsolatedGarage extends Garage:
    func _create_run() -> Node:return IsolatedRun.new()
var failures: Array[String]=[]
func expect(ok: bool,text: String) -> void:
    if not ok:failures.append(text)
func _initialize() -> void:call_deferred("verify")
func click(at: Vector2) -> void:
    var event:=InputEventMouseButton.new();event.position=at;event.global_position=at;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true
    Input.parse_input_event(event);Input.flush_buffered_events();await process_frame
    event=InputEventMouseButton.new();event.position=at;event.global_position=at;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=false
    Input.parse_input_event(event);Input.flush_buffered_events();await process_frame
func tap(at: Vector2,index: int=0) -> void:
    var event:=InputEventScreenTouch.new();event.index=index;event.position=at;event.pressed=true
    Input.parse_input_event(event);Input.flush_buffered_events()
    event=InputEventScreenTouch.new();event.index=index;event.position=at;event.pressed=false
    Input.parse_input_event(event);Input.flush_buffered_events()
func verify() -> void:
    var garage:=IsolatedGarage.new();root.add_child(garage)
    await process_frame;await process_frame
    expect(garage.active and garage.game.mode=="menu","Garage owns initial entry without advancing a run")
    var initial_rng: int=garage.game.rng.state
    var captures:=OS.get_cmdline_user_args()
    for dimensions in [Vector2i(1280,720),Vector2i(915,412),Vector2i(390,844),Vector2i(1920,1080),Vector2i(1600,900),Vector2i(844,390)]:
        root.size=dimensions;garage.game.presentation._window_changed()
        await process_frame;garage._layout();await process_frame
        for selected in [false,true]:
            garage.set_selection(selected);await process_frame
            var rect:=Rect2(garage.ui.position,garage.view)
            var buttons: Array=[garage.select_button,garage.play_button,garage.settings_button]
            if selected:buttons.append_array(garage.hero_cards)
            for i in range(buttons.size()):
                var button: Button=buttons[i]
                var extent:=button.get_global_rect()
                expect(rect.grow(1).encloses(extent),"Garage button in safe view %s / %s / %s" % [dimensions,selected,button.name])
                expect(extent.size.y>=48,"Touch target at least 48 logical units")
                for j in range(i):expect(not extent.intersects(buttons[j].get_global_rect()),"Separate hitboxes %s / %s" % [button.name,buttons[j].name])
            if captures.size()>0 and dimensions in [Vector2i(1280,720),Vector2i(915,412),Vector2i(390,844)] and DisplayServer.get_name()!="headless":
                await RenderingServer.frame_post_draw
                root.get_texture().get_image().save_png(captures[0]+"/garage-%dx%d-%s.png" % [dimensions.x,dimensions.y,"heroes" if selected else "home"])
    root.size=Vector2i(1280,720);garage.game.presentation._window_changed();await process_frame;garage._layout()
    garage.set_selection(true);await process_frame
    for i in range(6):
        await click(garage.hero_cards[i].get_global_rect().get_center())
        var data: Array=garage.IDENTITIES[i]
        expect(garage.game.hero_index==data[0] and garage.game.hero_appearance==data[1],"All six identities map to correct existing kit")
        expect(garage.hero_name.text==data[2],"Correct visible identity name")
        expect(garage.hero_art.texture!=null,"Exact approved portrait available")
        expect(garage.starter_label.text.contains(garage.game.WEAPONS[garage.game.HEROES[data[0]]["starter"]]["name"]),"Actual starter information")
    expect(initial_rng==garage.game.rng.state and garage.game.run_time==0,"Menu selection never consumes gameplay RNG or advances simulation")
    garage.hero_cards[2].grab_focus()
    var accept:=InputEventKey.new();accept.keycode=KEY_ENTER;accept.physical_keycode=KEY_ENTER;accept.pressed=true
    Input.parse_input_event(accept);Input.flush_buffered_events();await process_frame
    accept=InputEventKey.new();accept.keycode=KEY_ENTER;accept.physical_keycode=KEY_ENTER;accept.pressed=false
    Input.parse_input_event(accept);Input.flush_buffered_events();await process_frame
    expect(garage.selected_slot==2 and garage.active,"Keyboard accept selects focused identity without starting a previous hero")
    var first: Button=garage.hero_cards[0]
    tap(first.get_global_rect().get_center());await process_frame
    expect(garage.selected_slot==0,"Real touchscreen press/release selects hero")
    await click(garage.play_button.get_global_rect().get_center())
    expect(not garage.active and garage.game.mode=="maps","PLAY opens the map selector")
    await click(garage.game.map_select.choices[garage.game.SoloMaps.RUIN_ALLEY].get_global_rect().get_center())
    await click(garage.game.map_select.start.get_global_rect().get_center())
    expect(garage.game.mode=="entrance","Confirming the map stages the selected hero")
    await click(garage.game.hero_entrance.skip.get_global_rect().get_center())
    expect(garage.game.mode=="playing","Skip starts genuine existing Solo")
    if garage.game.mode != "playing":
        for failure in failures: push_error(failure)
        quit(1)
        return
    expect(garage.game.hero.id=="sigma" and garage.game.weapons[0].id=="no-cap","Existing kit/starter unchanged")
    garage.game._toggle_pause();expect(garage.game.mode=="paused","Existing pause remains functional")
    garage.game._return_to_menu();await process_frame;await process_frame
    expect(garage.active and not garage.game.layer.visible,"Returning to menu reopens Garage")
    garage.open_settings();await process_frame
    expect(garage.game.mode=="options","Existing settings preserved")
    garage.game.presentation.close_auxiliary();await process_frame;await process_frame
    expect(garage.active,"Settings return to Garage")
    garage.queue_free();await process_frame
    if failures.is_empty():print("PASS: Actual Garage entry, six identities/three kits, six viewport safe hitboxes, touch selection, unchanged menu RNG, legitimate run, pause, return and settings")
    else:
        for failure in failures:push_error(failure)
    quit(0 if failures.is_empty() else 1)
