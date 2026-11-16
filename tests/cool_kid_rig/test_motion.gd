extends SceneTree
const Rig=preload("res://scripts/cool_kid_articulated.gd")
var failures: Array[String]=[]
func check(ok: bool, label: String) -> void:
    if not ok and label not in failures:failures.append(label)
func _initialize() -> void:
    var rig:=Rig.new();rig.enabled=true
    if not rig.prepare():push_error(rig.reason);quit(1);return
    var states: Array=["idle","run","attack","hurt","flex-in","flex-loop","flex-out","defeat"]
    var count:=0
    var max_wrist_error:=0.0
    for direction in range(8):
        for state: String in states:
            for frame in range(90):
                var age:=frame/120.0
                var context: Dictionary={"time":age,"walk":age,"moving":true,"heading":direction*PI/4,"facing":direction*PI/4,"attack":0.22-age,"hurt":0.18-age,"flex_age":age,"flex":0.75-age,"defeat":age}
                check(rig.supports("cool-kid","original",state,context),"supported state/view")
                rig.sample(state,context)
                for matrix: Transform2D in rig.transforms.values():check(matrix.is_finite(),"finite transforms")
                check(rig.transforms["keyboard"]==rig.transforms["fore_l"] and rig.transforms["hand"]==rig.transforms["fore_l"],"grip chain")
                var wrist: Vector2=rig.pivots["fore_l"]
                max_wrist_error=maxf(max_wrist_error,(rig.transforms["fore_r"]*wrist).distance_to(rig.transforms["fore_l"]*wrist))
                if state!="defeat":
                    for side in ["l","r"]:
                        var knee: Vector2=rig.pivots["shin_"+side];var ankle: Vector2=rig.pivots["foot_"+side]
                        check((rig.transforms["thigh_"+side]*knee).distance_to(rig.transforms["shin_"+side]*knee)<0.001,"continuous knee joint")
                        check((rig.transforms["shin_"+side]*ankle).distance_to(rig.transforms["foot_"+side]*ankle)<0.001,"continuous ankle joint")
                count+=1
    check(max_wrist_error<3.0,"right wrist remains inside authored palm overlap (6px radius)")
    print("Maximum wrist constraint error=",max_wrist_error)
    # A real interrupted-Flex recovery must not snap back to the hold pose.
    rig.update_action("flex-loop",{"time":10.0,"flex_age":1.0,"flex":2.0})
    rig.update_action("flex-loop",{"time":10.1,"flex_age":1.1,"flex":1.9})
    var hit:=rig.update_action("hurt",{"time":10.2,"hurt":0.18})
    check(hit==rig.Motion.action("hurt",{"hurt":0.18}),"hurt remains immediate")
    var recovery:=rig.update_action("flex-loop",{"time":10.38,"flex_age":1.38,"flex":1.62})
    check(recovery.distance_to(hit)<0.001,"interrupted action recovery starts continuously")
    var held:=rig.update_action("flex-loop",{"time":10.45,"flex_age":1.45,"flex":1.55})
    check(held.distance_to(rig.Motion.action("flex-loop",{"flex_age":1.45,"flex":1.55}))<0.001,"recovery reaches canonical hold without changing its clock")
    var locked:=0
    for direction in range(8):
        var releases_before:=rig.reach_releases
        rig.contact_valid.fill(false);rig.contact_phases.fill(false)
        var prior: Array=[Vector2.ZERO,Vector2.ZERO];var was_valid: Array=[false,false]
        for frame in range(180):
            var age:=frame/60.0;var axis:=Vector2.from_angle(direction*PI/4)
            rig.actor_position=axis*age*190.0
            rig.sample("run",{"time":age,"walk":age,"moving":true,"heading":direction*PI/4},direction,1.0,true)
            for k in range(2):
                var world: Vector2=rig.actor_position+(rig.contact_targets[k]-Rig.ORIGIN)*Rig.SCALE
                if was_valid[k] and rig.contact_valid[k] and rig.contact_phases[k]:
                    # Phase wrap is an intentional new contact, not a planted interval.
                    var phase:=fposmod(age*190.0/Rig.STRIDE+k*0.5,1.0)
                    if phase>190.0/Rig.STRIDE/60.0:
                        check(prior[k].distance_to(world)<0.001,"world-space planted foot constraint");locked+=1
                prior[k]=world;was_valid[k]=rig.contact_valid[k]
        print("View ",direction," reach releases=",rig.reach_releases-releases_before)
    print("Motion samples=",count," stable contact comparisons=",locked," reach releases=",rig.reach_releases," (numerical constraints, NOT visual acceptance)")
    if failures.is_empty():print("PASS: eight-view state coverage, finite poses, joint continuity, grip and planted world contacts");quit()
    else:
        for message in failures:push_error(message)
        quit(1)
