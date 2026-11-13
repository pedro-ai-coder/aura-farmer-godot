extends "res://tests/test_hero_appearance_selection.gd"

func verify() -> void:
    var game := TestRun.new();root.add_child(game);game.set_process(false)
    for appearance in ["original","female"]:
        game.mode="heroes"
        game.select_appearance(appearance)
        expect(game.hero_appearance==appearance,"Requested appearance selected")
        for index in range(3):
            game.start_run(index)
            game.attack_flash=0.2
            game.touch_direction=Vector2.RIGHT
            var frames := {}
            for step in range(12):
                game._move_player(1.0/30.0)
                var pose: Dictionary=game.hero_pose()
                expect(pose.state=="run","Moving auto-attacker retains locomotion: "+str(index)+appearance)
                frames[pose.frame]=true
            expect(frames.size()>1,"Travel advances movement frames")
            game.touch_direction=Vector2.ZERO;game._move_player(0.1);game.attack_flash=0
            expect(game.hero_pose().state=="idle","Stopping returns to idle")
            game.hurt_timer=0.1
            expect(game.hero_pose().state=="hurt","Damage precedence preserved")
    game.queue_free()
    if failures.is_empty():print("PASS: six runtime locomotion routes, auto-attack, advancing gait, idle, hurt and approved authored cycles");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
