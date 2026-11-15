extends SceneTree
## Real approved pose playback, rapid switching, reduced motion and input safety.
const Smoke=preload("res://tests/test_signal_breaker_garage.gd")
const Design=preload("res://scripts/neon_arcade.gd")
const Base=preload("res://scripts/cpk_design_system.gd")
var failures: Array[String]=[]
func expect(ok: bool,message: String) -> void:
    if not ok:failures.append(message)
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    root.size=Vector2i(1280,720)
    var garage:=Smoke.IsolatedGarage.new();root.add_child(garage)
    await process_frame;await process_frame
    var rng: int=garage.game.rng.state
    expect(Design.theme()!=Base.theme(),"Frontend Theme must not mutate the gameplay Theme")
    expect(Base.contrast(Design.LIME,Design.INK)>7.0,"Primary text high contrast")
    expect(Base.contrast(Design.WHITE,Design.PANEL)>7.0,"Secondary text high contrast")
    for variant in ["CpkPrimary","CpkSecondary"]:
        for state in ["normal","hover","pressed","focus","disabled"]:
            expect(Design.theme().has_stylebox(state,variant),"Every interactive state is explicit")
    var output:=OS.get_cmdline_user_args()
    for i in range(6):
        garage.select_identity(i);garage.set_selection(true)
        await process_frame
        var showcase=garage.showcase
        expect(showcase.frames.size()==4,"Four approved high-resolution poses per identity")
        expect(garage.hero_art.texture==showcase.frames[1],"One current hero texture, no overlapping sprite layer")
        var first: Texture2D=garage.hero_art.texture
        showcase._process(.26)
        expect(garage.hero_art.texture!=first,"Selection reaction visibly advances")
        var ratio: float=showcase.frames[0].region.size.aspect()
        for frame in showcase.frames:
            expect(is_equal_approx(frame.region.size.aspect(),ratio),"Poses retain a shared registration crop and aspect")
        if output.size()>0 and DisplayServer.get_name()!="headless":
            showcase.entry_offset=0;showcase.set_home(showcase.home)
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png(output[0]+"/hero-%d.png" % i)
    garage.hero_cards[3].grab_focus()
    var accept:=InputEventJoypadButton.new();accept.button_index=JOY_BUTTON_A;accept.pressed=true
    Input.parse_input_event(accept);Input.flush_buffered_events();await process_frame
    accept=InputEventJoypadButton.new();accept.button_index=JOY_BUTTON_A;accept.pressed=false
    Input.parse_input_event(accept);Input.flush_buffered_events();await process_frame
    expect(garage.selected_slot==3,"Native controller accept selects the focused identity")
    var back:=InputEventJoypadButton.new();back.button_index=JOY_BUTTON_B;back.pressed=true
    Input.parse_input_event(back);Input.flush_buffered_events();await process_frame
    expect(not garage.selection_open,"Controller cancel returns to Garage navigation")
    garage.set_selection(true);garage.hero_cards[0].grab_focus()
    var right:=InputEventJoypadButton.new();right.button_index=JOY_BUTTON_DPAD_RIGHT;right.pressed=true
    Input.parse_input_event(right);Input.flush_buffered_events();await process_frame
    right=InputEventJoypadButton.new();right.button_index=JOY_BUTTON_DPAD_RIGHT;right.pressed=false
    Input.parse_input_event(right);Input.flush_buffered_events();await process_frame
    expect(root.gui_get_focus_owner()==garage.hero_cards[1],"Controller D-pad follows the visible grid")
    for i in range(48):garage.select_identity(i%6)
    await process_frame
    expect(garage.selected_slot==5 and garage.showcase.identity=="block-queen","Rapid navigation keeps last identity, texture and label consistent")
    expect(garage.showcase.cache.size()==6,"Pose textures are cached per identity")
    garage.game.profile["settings"]["reducedMotion"]=true;garage._refresh_identity();garage._layout()
    var fixed: Texture2D=garage.hero_art.texture;var phase: float=garage.environment.age
    garage.showcase._process(1.0);garage.environment._process(1.0)
    expect(garage.hero_art.texture==fixed and garage.showcase.entry_offset==0,"Reduced motion freezes idle and entry translation")
    expect(garage.environment.age==phase,"Reduced motion freezes ambient phase")
    expect(garage.game.rng.state==rng and garage.game.run_time==0,"Motion never consumes gameplay RNG or advances simulation")
    garage.set_selection(false);garage.select_identity(4);garage.start_selected()
    expect(not garage.active and garage.game.mode=="playing","Start is immediate, even during an active entry transition")
    expect(garage.game.hero.id=="cool-kid" and garage.game.hero_appearance=="female","Selected identity/kit survives the transition")
    expect(not garage.showcase.enabled,"Showcase pauses during gameplay")
    garage.game._return_to_menu();await process_frame;await process_frame
    expect(garage.active and garage.showcase.enabled,"Returning restores the showcase")
    garage.queue_free();await process_frame
    if failures.is_empty():print("PASS: Neon contrast/states, six high-resolution pose reactions, cached registration, rapid switching, reduced motion, RNG isolation, immediate start and return")
    else:
        for failure in failures:push_error(failure)
    quit(0 if failures.is_empty() else 1)
