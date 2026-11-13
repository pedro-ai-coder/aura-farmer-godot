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
                expect(pose.state=="attack" and pose.locomotion=="run" and pose.attack_active,"Moving auto-attacker retains attack and locomotion: "+str(index)+appearance)
                frames[pose.frame]=true
            expect(frames.size()>1,"Travel advances movement frames")
            game.touch_direction=Vector2.ZERO;game._move_player(0.1);game.attack_flash=0
            expect(game.hero_pose().state=="idle","Stopping returns to idle")
            game.hurt_timer=0.1
            expect(game.hero_pose().state=="hurt","Damage precedence preserved")
            game.player_pos=Vector2(724,540);game.touch_direction=Vector2.RIGHT
            game._move_player(0.02)
            expect(game.hero_pose().state=="hurt" and game.hero_pose().frame>=0,"Damage does not substitute a standing body during travel")
            game.hurt_timer=0;game.flex_time=1;game.flex_age=0.6
            expect(game.hero_pose().state.begins_with("flex") and game.hero_pose().frame>=0,"Flex layers over continuous travel")
            game.flex_time=0;game.attack_flash=0
            game.player_pos=Vector2(646.1,550);game.touch_direction=Vector2.LEFT
            var before:Vector2=game.player_pos
            var gait:float=game.visual_walk
            game._move_player(1.0/60.0)
            expect(game.player_pos==before and not game.visual_moving and game.visual_walk==gait,"Blocked input cannot advance gait")
            game.touch_direction=Vector2(-1,1).normalized();game._move_player(1.0/60.0)
            expect(is_equal_approx(game.visual_heading,PI/2),"Sliding along cover faces actual travel, not blocked input")
            game.visual_body_flip=true;game.touch_direction=Vector2.DOWN
            game._move_player(0.01)
            expect(game.hero_pose().flip,"Vertical travel retains the last horizontal body orientation")
            for heading in range(8):
                game.player_pos=Vector2(724,540)
                game.touch_direction=Vector2.from_angle(heading*PI/4.0)
                var previous_phase:float=game.visual_walk
                game._move_player(1.0/60.0)
                expect(absf(angle_difference(game.visual_heading,heading*PI/4.0))<0.001,"Eight-heading actual-displacement presentation")
                expect(game.visual_walk>previous_phase,"Direction changes retain an advancing distance phase")
            var phases:Array=[]
            for hz in [30,60,120]:
                game.start_run(index);game.player_pos=Vector2(724,540);game.touch_direction=Vector2.RIGHT
                for step in range(hz/2):game._move_player(1.0/hz)
                phases.append(game.visual_walk)
            expect(absf(phases[0]-phases[1])<0.0001 and absf(phases[1]-phases[2])<0.0001,"Distance phase is independent of update rate")
    # Reuse the existing real combat fixture: no synthetic attack timers.
    var combat:=preload("res://tests/weapon_presence/review_run.gd").new()
    root.add_child(combat);combat.set_process(false)
    for appearance in ["original","female"]:
        for id in ["ratio-blaster","keyboard-warrior","chad-hands"]:
            combat.fixture(id,appearance)
            combat.touch_direction=Vector2.RIGHT;combat._move_player(0.01)
            combat.aim_point=combat.player_pos+Vector2(-400,0)
            combat._fire_weapons(0.2)
            var pose:Dictionary=combat.hero_pose()
            expect(pose.attack_active and pose.locomotion=="run" and pose.frame>=0,"Real activation retains body attack and gait: "+id+appearance)
            expect(pose.flip,"Combat aim can oppose actual locomotion without changing movement")
            expect(pose.attack_stage>0 and not pose.torso.is_zero_approx(),"Torso follows real weapon phase")
            var event:Dictionary=combat.weapon_presentation.current(combat.run_time)
            var at:float=event.model.at
            combat.run_time=at+0.05
            # Melee impact becomes visible only after authoritative resolution.
            combat._step_weapon_areas()
            expect(combat.hero_pose().attack_stage==2,"Execution uses the actual activation deadline")
            combat.run_time=at+0.20
            expect(combat.hero_pose().attack_stage==3,"Recovery follows the same attack clock")
            combat.profile.settings.reducedMotion=true
            expect(combat.hero_pose().torso==Vector2.ZERO,"Reduced Motion disables body displacement")
            combat.profile.settings.reducedMotion=false
            combat.touch_direction=Vector2.ZERO;combat._move_player(0.01)
            expect(combat.hero_pose().frame==-1 and combat.hero_pose().attack_active,"Stationary attack keeps approved resting identity and active combat")
    # Expired recovery must not turn a stationary body back toward stale input.
    for hz in [30,60,120]:
        combat.fixture("ratio-blaster","female")
        combat.touch_direction=Vector2.ZERO;combat._move_player(1.0/hz)
        combat.aim_point=combat.player_pos+Vector2(-400,0)
        combat._fire_weapons(0.2)
        expect(combat.hero_pose().flip,"Stationary Vixen faces the real shot")
        var last:Dictionary=combat.weapon_presentation.current(combat.run_time)
        combat.run_time=float(last.until)+1.0
        expect(combat.hero_pose().flip,"Expired attack preserves stationary facing at "+str(hz)+" Hz")
        combat.touch_direction=Vector2.DOWN;combat._move_player(1.0/hz)
        expect(combat.hero_pose().flip,"Vertical travel preserves the latest horizontal bearing")
        combat.touch_direction=Vector2.RIGHT;combat._move_player(1.0/hz)
        combat.touch_direction=Vector2.ZERO;combat._move_player(1.0/hz)
        expect(not combat.hero_pose().flip,"Later horizontal travel replaces the expired shot bearing")
        combat.weapon_presentation.reset()
        expect(not combat.hero_pose().flip,"Retry/reset cannot retain previous attack history")
    # Cancellation cannot supply an idle bearing; secondary melee cannot own it.
    var observer=preload("res://scripts/weapon_presentation.gd").new()
    observer.queued({"id":"ratio-blaster","at":1.0,"direction":Vector2.LEFT},0.0,[],true)
    observer.synchronize([],[],0.5)
    expect(not observer.resting_flip(false),"Cancelled queued shot cannot change resting orientation")
    observer.queued({"id":"chad-hands","at":1.0,"facing":Vector2.LEFT,"primary":false},0.0,[],false)
    expect(not observer.resting_flip(false),"Secondary melee does not replace primary orientation")
    # Attach effects to the actual embedded equipment, including mesh deformation.
    var motion=preload("res://scripts/approved_hero_motion.gd")
    for appearance in ["original","female"]:
        for id in ["sigma","cool-kid"]:
            var weapon: String="ratio-blaster" if id=="sigma" else "keyboard-warrior"
            for moving in [false,true]:
                var descriptor:Dictionary=motion.pose(id,appearance,{"moving":moving,"walk":0.1,"body_flip":false})
                var anchor:Vector2=motion.embedded_anchor(descriptor,weapon)
                expect(anchor.y< -25 and anchor.length()<80,"Embedded cue stays on the gameplay-scale upper body")
                descriptor.flip=true
                var reflected:Vector2=motion.embedded_anchor(descriptor,weapon)
                expect(reflected.is_equal_approx(Vector2(-anchor.x,anchor.y)),"Embedded cue mirrors once with the body")
                descriptor.flip=false;descriptor.torso=Vector2(2,1)
                var reacted:Vector2=motion.embedded_anchor(descriptor,weapon)
                expect((reacted-anchor).length()>0 and (reacted-anchor).length()<=Vector2(2,1).length()+0.001,"Cue follows bounded torso mesh influence")
                expect(motion.embedded_anchor(descriptor,"ban-hammer")==null,"Independent props retain their existing attachment contract")
    combat.queue_free()
    game.queue_free()
    if failures.is_empty():print("PASS: six runtime locomotion routes, auto-attack, advancing gait, idle, hurt and approved authored cycles");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
