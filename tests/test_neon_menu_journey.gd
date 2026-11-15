extends "res://tests/test_clean_cut_pointer_input.gd"
## Isolated presentation matrix; optional native screenshots, never player saves.
const Design=preload("res://scripts/neon_arcade.gd")
const Base=preload("res://scripts/cpk_design_system.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass

func verify() -> void:
    var args:=OS.get_cmdline_user_args()
    var output: String=args[0] if args.size()>0 else ""
    if not output.is_empty():DirAccess.make_dir_recursive_absolute(output)
    var extents: Array=[Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]
    if args.size()>2:extents=[Vector2i(int(args[1]),int(args[2]))]
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false)
    var skin=game.clean_cut_skin
    for extent in extents:
        root.size=extent;game.touch_device=extent.x<1000
        for mode in ["paused","options","build","confirm_exit","profile_import","profile_export","choice","replace","legendary","won","lost"]:
            game.start_run(1)
            game.profile["settings"]["reducedMotion"]=true
            if mode=="paused":game._toggle_pause()
            elif mode=="options":game._return_to_menu();game.presentation.open_settings("menu")
            elif mode=="build":game._toggle_pause();game.presentation.open_build()
            elif mode=="confirm_exit":game._toggle_pause();game._request_return_to_menu()
            elif mode=="profile_import":game._return_to_menu();game._open_profile_import()
            elif mode=="profile_export":game._return_to_menu();game._open_profile_export()
            elif mode=="choice":game._gain_xp(100);game._open_choice()
            elif mode=="replace":
                game.weapons.append({"id":"no-cap","level":1,"rarity":"common","timer":0.0})
                game.weapons.append({"id":"personal-space","level":1,"rarity":"common","timer":0.0})
                game._replace_target({"id":"ratio-blaster","type":"weapon","rarity":"common","level":1})
            elif mode=="legendary":game.run_time=360;game._open_legendary()
            else:game._finish(mode=="won")
            game.presentation._window_changed(true);game._show_ui();game._update_text()
            await process_frame;await process_frame
            skin.refresh()
            expect(game.mode==mode,"Actual menu transition: "+mode)
            var rng: int=game.rng.state
            var time: float=game.run_time
            var inventory: Array=game.weapons.duplicate(true)
            var profile: Dictionary=game.profile.duplicate(true)
            var selected: int=game.selected_card_index
            for i in range(4):skin.refresh();skin.neon_backdrop._process(.1)
            expect(game.rng.state==rng and game.run_time==time and game.weapons==inventory and game.profile==profile and game.selected_card_index==selected,"Rendering preserves simulation/save/selection: "+mode)
            expect(not skin.neon_backdrop.is_processing(),"Reduced motion stops entry animation: "+mode)
            expect(not skin.background.visible,"No legacy full-screen illustration: "+mode)
            expect(Base.contrast(skin.heading.get_theme_color("font_color"),Design.PANEL)>=4.5,"Legible menu heading: "+mode)
            if mode=="options":
                expect(not skin.heading.get_global_rect().intersects(game.presentation.back_button.get_global_rect()),"Settings title and Back remain separate")
            if mode in ["profile_import","profile_export"]:
                var field: StyleBox=game.profile_text.get_theme_stylebox("normal")
                expect(field is StyleBoxFlat and field.bg_color==Design.PANEL,"Save editor keeps the Neon background after native refresh")
                expect(Base.contrast(game.profile_text.get_theme_color("font_color"),Design.PANEL)>=4.5,"Editable save text stays legible")
            var buttons: Array=[game.confirm_button,game.restart_button,game.retry_button,game.defer_button,game.sound_button,game.motion_button,game.import_button,game.export_button,skin.auxiliary.fullscreen_button]
            buttons.append_array(skin.auxiliary.actions)
            for button: Button in buttons:
                if not button.is_visible_in_tree():continue
                expect(button.size.y>=48,"Touch height: "+button.text)
                var text_width: float=button.get_theme_font("font").get_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,button.get_theme_font_size("font_size")).x
                expect(text_width<=button.size.x-48,"Complete action label fits its hitbox: "+button.text)
                var style: StyleBox=button.get_theme_stylebox("normal")
                expect(style is StyleBoxFlat,"Native Neon action face: "+button.text)
                if style is StyleBoxFlat:expect(Base.contrast(button.get_theme_color("font_color"),style.bg_color)>=4.5,"Readable action: "+button.text)
            if mode=="choice":
                expect(game.confirm_button.disabled,"Upgrade requires explicit selection")
                await click(game.offer_buttons[0])
                expect(game.selected_card_index==0 and game.weapons==inventory,"Real held click selects without committing")
            if not output.is_empty() and DisplayServer.get_name()!="headless":
                await RenderingServer.frame_post_draw
                var path: String=output.path_join("%s-%dx%d.png" % [mode,extent.x,extent.y])
                expect(root.get_texture().get_image().save_png(path)==OK,"Native capture: "+path)
        # Motion can restart after rapid screen changes and freezes immediately on preference change.
        game.profile["settings"]["reducedMotion"]=false
        game.mode="options";skin.layout_key="";skin.refresh()
        skin.neon_backdrop._process(.05)
        expect(skin.neon_backdrop.age>0 and skin.neon_backdrop.age<Design.ENTER,"Bounded screen entry advances")
        game.profile["settings"]["reducedMotion"]=true
        skin.neon_backdrop._process(.01)
        expect(not skin.neon_backdrop.is_processing() and skin.neon_backdrop.age==Design.ENTER,"Live reduced-motion change cancels entry")
    game.queue_free();await process_frame
    if failures.is_empty():print("PASS: Eleven Neon menus, six viewports, contrast/touch targets, real card input, immutable simulation/profile and interruptible reduced motion")
    else:
        for failure in failures:push_error(failure)
    quit(0 if failures.is_empty() else 1)
