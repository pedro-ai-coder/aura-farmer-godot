extends "res://tests/test_hero_appearance_selection.gd"
const Motion = preload("res://scripts/approved_hero_motion.gd")

func verify() -> void:
    var game:=TestRun.new();root.add_child(game);game.set_process(false)
    var count:=0
    for appearance in ["original","female"]:
        game.mode="heroes";game.select_appearance(appearance)
        for hero_index in range(3):
            game.start_run(hero_index)
            var id:String=game.hero.id
            var name:=Motion.slug(id,appearance)
            expect(game.mode=="playing" and game.hero_appearance==appearance,"Requested identity starts a run")
            expect(game.art.motion.prepare(id,appearance),"Registered textures available for "+name)
            expect(game.hero_pose().sheet==Motion.SHEET and game.hero_pose().slug==name,"One approved adapter owns "+name)
            var atlas:Texture2D=game.art.motion.texture(name,"run")
            var image:=atlas.get_image()
            var hashes:Dictionary={}
            for frame in range(8):
                var cell:=image.get_region(Rect2i(frame%4*512,int(frame/4)*512,512,512))
                var used:=cell.get_used_rect()
                expect(used.has_area() and used.position.x>0 and used.position.y>0 and used.end.x<512 and used.end.y<512,"One padded pose per cell "+name+str(frame))
                hashes[cell.get_data().hex_encode().sha256_text()]=true
            expect(hashes.size()==8,"Eight distinct authored poses "+name)
            game.attack_flash=0.2;game.touch_direction=Vector2.RIGHT
            var frames:Dictionary={}
            for step in range(24):
                game._move_player(1.0/36.0)
                var pose:Dictionary=game.hero_pose()
                expect(pose.state=="run" and pose.frame>=0 and pose.frame<8,"Actual travel routes to approved gait during auto-attacks")
                frames[pose.frame]=true
            expect(frames.size()==8,"Actual movement visits the complete eight-frame cycle "+name)
            for heading in [0.0,PI]:
                game.player_pos=Vector2(724,540);game.touch_direction=Vector2.from_angle(heading)
                game._move_player(0.01)
                expect(game.hero_pose().flip==(heading==PI),"Facing follows travel")
            game.touch_direction=Vector2.ZERO;game._move_player(0.01);game.attack_flash=0
            expect(game.hero_pose().state=="idle" and game.hero_pose().frame==-1,"Stopping uses the matching portrait identity")
            for state in [{"hurt":0.1},{"flex":1.0,"flex_age":0.6},{"lost":true,"defeat":0.5},{"attack":0.1}]:
                var posed:=Motion.pose(id,appearance,state)
                expect(posed.slug==name and posed.sheet==Motion.SHEET,"Combat states never swap to an obsolete body")
                expect(posed.state==Motion.Canonical.pose(id,state).state,"Canonical state precedence preserved")
            var portrait:Texture2D=game.art.cosmetic_portrait(id,appearance)
            expect(portrait.resource_path==Motion.ROOT+name+"/portrait.png","Selection uses matching approved portrait")
            count+=1
    expect(count==6,"All six appearances verified")
    expect(game.find_children("*","Sprite2D",true,false).is_empty(),"No additional sprite layers")
    game.queue_free()
    if failures.is_empty():print("PASS: six approved identities, 48 isolated distinct poses, full gait, facing, canonical states and portraits");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
