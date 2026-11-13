extends "res://tests/test_hero_appearance_selection.gd"

func verify() -> void:
    if "--motion-review" in OS.get_cmdline_user_args():
        await capture_motion_review()
        return
    if DisplayServer.get_name()=="headless":push_error("Native renderer required");quit(1);return
    var output:=OS.get_cmdline_user_args()[0]
    DirAccess.make_dir_recursive_absolute(output)
    root.size=Vector2i(1280,720)
    var sheet:=Image.create_empty(900,1080,false,Image.FORMAT_RGBA8)
    var records:Array=[]
    var game:=TestRun.new();root.add_child(game);game.set_process(false)
    if game.art.vixen_isolated_atlas==null:push_error("Verified Vixen atlas required");quit(1);return
    var row:=0
    for appearance in ["original","female"]:
        game.mode="heroes"
        game.select_appearance(appearance)
        for index in range(3):
            game.start_run(index)
            expect(game.hero_appearance==appearance,"Capture requested appearance")
            game.enemies.clear();game.attack_flash=0.2
            game.touch_direction=Vector2.RIGHT
            for step in range(5):
                if step==4:game.touch_direction=Vector2.ZERO;game.attack_flash=0
                game._move_player(1.0/9.0);game.run_time+=1.0/9.0
                game._update_camera(0,true);game._show_ui();game._update_text();game.queue_redraw()
                await process_frame;await process_frame;await RenderingServer.frame_post_draw
                var screenshot:=root.get_texture().get_image()
                var center:Vector2=game.get_global_transform_with_canvas()*game.player_pos
                var region:=Rect2i(Vector2i(center)-Vector2i(90,120),Vector2i(180,180))
                sheet.blit_rect(screenshot,region,Vector2i(step*180,row*180))
                records.append({"hero":game.hero.id,"appearance":appearance,"sample":step,"pose":game.hero_pose()})
                if step==0:screenshot.save_png(output.path_join("gameplay-%s-%s.png" % [game.hero.id,appearance]))
            row+=1
    sheet.save_png(output.path_join("six-heroes-movement.png"))
    for extent in [Vector2i(1280,720),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.presentation._window_changed(true)
        for appearance in ["original","female"]:
            game.mode="heroes"
            game.select_appearance(appearance)
            expect(game.hero_appearance==appearance,"Capture requested selection appearance")
            for index in range(3):
                game.hero_index=index;game.mode="menu";game._show_ui();game._update_text();game.queue_redraw()
                await process_frame;await process_frame;await RenderingServer.frame_post_draw
                root.get_texture().get_image().save_png(output.path_join("selection-%s-%s-%dx%d.png" % [game.HEROES[index].id,appearance,extent.x,extent.y]))
            game.mode="heroes";game._show_ui();game._update_text()
            await process_frame;await process_frame;await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png(output.path_join("hero-cards-%s-%dx%d.png" % [appearance,extent.x,extent.y]))
    var file:=FileAccess.open(output.path_join("poses.json"),FileAccess.WRITE);file.store_string(JSON.stringify(records,"  "));file.close()
    game.queue_free();print("PASS: native six-hero movement samples and 18 selected-hero screens captured");quit()

## Controlled presentation matrix at actual gameplay zoom. Reuses weapon QA;
## synthetic durable targets and explicit damage/Flex setup are not normal play.
func capture_motion_review() -> void:
    if DisplayServer.get_name()=="headless":push_error("Native renderer required");quit(1);return
    var args:=OS.get_cmdline_user_args()
    var output:String=args[0]
    var pair_only:bool="--pair" in args
    DirAccess.make_dir_recursive_absolute(output)
    root.size=Vector2i(1280,720)
    var sheet:=Image.create_empty(1800,360 if pair_only else 1080,false,Image.FORMAT_RGBA8)
    var game:=preload("res://tests/weapon_presence/review_run.gd").new()
    root.add_child(game);game.set_process(false)
    var records:Array=[];var row:=0
    var phases:=["idle","run","diagonal","reverse","stop","moving-attack","stationary-attack","hurt","flex","return"]
    for appearance in ["original","female"]:
        for index in range(1 if pair_only else 3):
            game.fixture(["ratio-blaster","keyboard-warrior","cope-shield"][index],appearance)
            for enemy in game.enemies:enemy.hp=10000;enemy.max=10000;enemy.born=0
            for sample in range(phases.size()):
                game.player_pos=Vector2(770,550)
                game.touch_direction=Vector2.RIGHT if sample in [1,5] else Vector2(1,1).normalized() if sample==2 else Vector2.LEFT if sample==3 else Vector2.ZERO
                game.weapons[0].timer=0.0 if sample in [5,6] else 100.0
                game.weapon_presentation.reset();game.attack_flash=0
                if sample==8:
                    game.aura=100;game.flex_lock=0;game._use_flex()
                if sample==9:
                    # Remove synthetic targets before waiting for the real Flex
                    # completion; a normal-health melee hero must not die
                    # while the fixture waits without player control.
                    game.enemies.clear();game.hostile_shots.clear();game.hazard_zones.clear()
                    for frame in range(200):game._process(1.0/30.0)
                for frame in range(8):game._process(1.0/30.0)
                if sample==7:game._deal_damage_to_player(1.0)
                if sample in [5,6]:
                    # Queue through the real weapon path immediately before
                    # readback so fast ranged execution is captured too.
                    game.weapons[0].timer=0;game._fire_weapons(0.01)
                game._update_camera(0,true);game._show_ui();game._update_text();game.queue_redraw()
                await process_frame;await process_frame;await RenderingServer.frame_post_draw
                var screenshot:=root.get_texture().get_image()
                var center:Vector2=game.get_global_transform_with_canvas()*game.player_pos
                sheet.blit_rect(screenshot,Rect2i(Vector2i(center)-Vector2i(90,120),Vector2i(180,180)),Vector2i(sample*180,row*180))
                records.append({"hero":game.hero.id,"appearance":appearance,"sample":phases[sample],"pose":game.hero_pose(),"time":game.run_time,"mode":game.mode,"enemies":game.enemies.size(),"contacts":game.weapon_presentation.emitted_contacts})
                if sample in [5,7,8]:screenshot.save_png(output.path_join("%s-%s-%s.png" % [game.hero.id,appearance,phases[sample]]))
            row+=1
    sheet.save_png(output.path_join("motion-matrix.png"))
    FileAccess.open(output.path_join("matrix.json"),FileAccess.WRITE).store_string(JSON.stringify(records,"  "))
    game.queue_free();print("PASS: native controlled motion matrix; synthetic setup, canonical combat events, no profile writes");quit()
