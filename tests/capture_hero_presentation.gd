extends "res://tests/test_hero_appearance_selection.gd"

func verify() -> void:
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
            game.select_appearance(appearance)
            for index in range(3):
                game.hero_index=index;game.mode="menu";game._show_ui();game._update_text();game.queue_redraw()
                await process_frame;await process_frame;await RenderingServer.frame_post_draw
                root.get_texture().get_image().save_png(output.path_join("selection-%s-%s-%dx%d.png" % [game.HEROES[index].id,appearance,extent.x,extent.y]))
    var file:=FileAccess.open(output.path_join("poses.json"),FileAccess.WRITE);file.store_string(JSON.stringify(records,"  "));file.close()
    game.queue_free();print("PASS: native six-hero movement samples and 18 selected-hero screens captured");quit()
