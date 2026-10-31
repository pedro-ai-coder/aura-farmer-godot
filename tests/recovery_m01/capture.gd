extends SceneTree
const Audit=preload("res://tests/recovery_m01/layout_audit.gd")
## Real Godot output: staged states only, not Web/device playtime or human QA.
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void: profile=ProfileStoreScript.defaults()
    func _save_profile() -> void: pass

func _initialize() -> void:
    call_deferred("capture")

func capture() -> void:
    var args: PackedStringArray=OS.get_cmdline_user_args()
    var width: int=int(args[0]) if args.size()>0 else 1280
    var height: int=int(args[1]) if args.size()>1 else 720
    var output: String=args[2] if args.size()>2 else "user://m0-creator-feedback"
    root.size=Vector2i(width,height)
    DirAccess.make_dir_recursive_absolute(output)
    var game=ReviewRun.new()
    root.add_child(game)
    game.set_process(false)
    game.touch_device=width<1000
    game.profile["settings"]["reducedMotion"]=true
    var skin=game.clean_cut_skin
    skin.set_process(false)
    var measurements: Array=[]
    for state in ["hero-menu","hero-selection","wave1","dense","cover-left","cover-right","playing-shield","ready","boss","choice-selected","legendary-selected","paused","build","settings","confirm-exit","won","lost"]:
        if args.size()>3 and args[3] in ["hero-details","hero-selection"] and state!="hero-selection":continue
        seed(801)
        game.start_run(2)
        if state=="hero-menu" or state=="play-pressed":
            game._return_to_menu()
            game.presentation.select_hero(1)
        elif state=="choice-selected":
            game._gain_xp(100.0)
            game._open_choice()
            game._show_ui()
            game.pick_upgrade(0)
        elif state=="legendary-selected":
            game.run_time=360.0
            game._open_legendary()
            game._show_ui()
            game.pick_upgrade(0)
        elif state=="hero-selection":
            game.presentation.open_heroes()
            game.presentation.select_hero(1)
        elif state in ["wave1","dense","cover-left","cover-right","boss"]:
            game.player_pos=Vector2(780,600)
            game.run_time=625.0 if state=="boss" else 500.0 if state=="dense" else 10.0
            game.wave=5 if state=="dense" else 1
            game.boss_spawned=state=="boss"
            if state=="boss":game._spawn_enemy("boss",{"pos":Vector2(800,520)})
            else:
                for i in range(100 if state=="dense" else 8):
                    game._spawn_enemy("npc",{"pos":Vector2(550,490)+Vector2(i%10,i/10)*Vector2(28,35)})
        elif state=="build":
            game._toggle_pause();game.presentation.open_build()
        elif state=="settings":
            game._toggle_pause();game.presentation.open_settings("paused")
        elif state in ["won","lost"]:
            game._finish(state=="won")
        elif state=="playing-shield":
            game.hp=70.0
            game.shield=40.0
            game.aura=38.0
        elif state=="ready":
            game.shield=50.0
            game.aura=100.0
            game.flex_lock=0.0
        elif state=="paused":
            game._toggle_pause()
        elif state=="confirm-exit":
            game._toggle_pause()
            game._request_return_to_menu()
        game._show_ui()
        game._update_text()
        game._update_camera(0.0,true)
        game.queue_redraw()
        await process_frame
        await process_frame
        skin.layout_key=""
        skin.refresh()
        if state=="play-pressed":
            # Staged visual fixture only; this is not a synthetic gameplay click.
            game.presentation.play_button.button_down.emit()
        await process_frame
        await process_frame
        if args.size()>3 and args[3]=="hero-details":
            skin.hero_scroll.scroll_vertical=250
            await process_frame
        await RenderingServer.frame_post_draw
        var file: String=output.path_join("m0-%s-%dx%d.png" % ["hero-details" if args.size()>3 and args[3]=="hero-details" else state,width,height])
        if root.get_texture().get_image().save_png(file)!=OK:
            push_error("Screenshot failed: "+file)
            quit(1)
            return
        if state=="play-pressed":
            game.presentation.play_button.button_up.emit()
        measurements.append(Audit.report(game))
        measurements.append({
            "state":state,"pixels":[width,height],"logical_view":str(skin.view),
            "selected_hero":game.HEROES[game.hero_index]["id"],
            "current_hero":game.hero.get("id",""),
            "portrait_visible":skin.poster_hero.visible if state=="hero-menu" else skin.hero_parts[1]["portrait"].visible if state=="hero-selection" else skin.portrait.visible,
            "shield":game.shield,"shield_track":str(skin.shield_track.get_rect()),
            "shield_fill":str(skin.shield_fill.get_rect()),
            "hp":str(skin.hp.get_rect()),
            "shield_text":str(skin.shield_label.get_rect()),
            "flex":str(game.flex_button.get_rect()),
            "confirmation_parent":str(game.confirm_button.get_parent().name)
        })
    var report:=FileAccess.open(output.path_join("m0-%dx%d.json" % [width,height]),FileAccess.WRITE)
    report.store_string(JSON.stringify(measurements,"  "))
    game.queue_free()
    quit(0)
