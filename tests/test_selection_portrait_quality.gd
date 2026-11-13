extends "res://tests/test_hero_appearance_selection.gd"

func verify() -> void:
    for extent in [Vector2i(1920,1080),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent
        var game:=TestRun.new();root.add_child(game);game.set_process(false)
        for appearance in ["original","female"]:
            game.select_appearance(appearance)
            for index in range(3):
                game.hero_index=index;game.mode="menu";game._show_ui();game.clean_cut_skin.refresh()
                var skin=game.clean_cut_skin
                var poster:TextureRect=skin.poster_hero
                expect(poster.texture!=null,"Selected hero has approved source")
                expect(poster.texture_filter==CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS,"Smooth portrait sampling")
                expect(poster.size.x<=poster.texture.get_width()*1.5+0.1 and poster.size.y<=poster.texture.get_height()*1.5+0.1,"Portrait enlargement capped")
                expect(poster.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"Full aspect fit")
        game.queue_free();await process_frame
    if failures.is_empty():print("PASS: six portraits, three viewport sizes, aspect fit, linear filtering and bounded enlargement");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
