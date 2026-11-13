extends "res://tests/test_hero_appearance_selection.gd"

func verify() -> void:
    var game:=TestRun.new();root.add_child(game);game.set_process(false)
    var art=game.art
    expect(art.vixen_isolated_atlas!=null,"Source and imported RGBA hashes match isolated atlas")
    var image:Image=art.vixen_isolated_atlas.get_image()
    for slot in range(49):
        var cell:=image.get_region(Rect2i(slot%7*144,int(slot/7)*144,144,144))
        var bounds:=cell.get_used_rect()
        expect(bounds.has_area(),"Nonempty Vixen pose "+str(slot))
        expect(bounds.position.x>0 and bounds.position.y>0 and bounds.end.x<144 and bounds.end.y<144,"Pose isolated from neighboring cells "+str(slot))
    game.select_appearance("female");game.start_run(0)
    expect(game.mode=="playing" and game.hero.id=="sigma" and game.hero_appearance=="female","Pixel Vixen start flow preserves kit and appearance")
    expect(game.hero_pose().sheet=="pixel-vixen","One Vixen gameplay adapter")
    expect(game.find_children("*","Sprite2D",true,false).is_empty(),"No duplicate sprite nodes")
    game.queue_free()
    if failures.is_empty():print("PASS: verified isolated Vixen atlas, 49 padded poses, single adapter and female Sigma run start");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
