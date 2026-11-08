extends SceneTree

const Motion = preload("res://scripts/motion_language.gd")
const Bestiary = preload("res://scripts/solo_enemy_rules.gd")
var failures: Array[String] = []

func _initialize() -> void: call_deferred("_verify")

func check(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func bounded(motion: Dictionary) -> bool:
    var offset: Vector2 = motion["offset"]
    var scale: Vector2 = motion["scale"]
    return offset.length() <= 4.0 and scale.x >= 0.9 and scale.x <= 1.1 and scale.y >= 0.9 and scale.y <= 1.1 and absf(float(motion["rotation"])) <= 0.16

func _verify() -> void:
    for id in ["sigma","cool-kid","alpha"]:
        for phase in ["idle","run","attack","hurt","flex-in","flex-loop","flex-out","defeat"]:
            var pose := {"state":phase,"flip":false}
            var original := pose.duplicate(true)
            var motion: Dictionary = Motion.hero_motion(id,pose,1.25,0.65,false)
            check(bounded(motion),"Bounded hero: %s %s" % [id,phase])
            check(motion == Motion.hero_motion(id,pose,1.25,0.65,false),"Deterministic hero: %s %s" % [id,phase])
            check(Motion.hero_motion(id,pose,1.25,0.65,true) == Motion.neutral(),"Reduced motion hero: %s %s" % [id,phase])
            check(pose == original,"Hero state mutated: %s %s" % [id,phase])
    for kind in Bestiary.DATA.keys():
        for phase in ["idle","moving","warning","charge-warning","charging","attack","hurt","defeated"]:
            var enemy := {"kind":kind,"id":17,"radius":Bestiary.DATA[kind]["radius"],
                "phase":phase,"anim_moving":phase=="moving","anim_walk":1.25,
                "hurt_at":0.95 if phase=="hurt" else -100.0,"stagger_until":-1.0,
                "attack_pose":{"start":1.0,"impact":1.2,"end":1.6,"angle":0.0} if phase=="attack" else {}}
            var original := enemy.duplicate(true)
            var age: float = 0.2 if phase=="defeated" else -1.0
            var motion: Dictionary = Motion.enemy_motion(enemy,1.0,age,false)
            check(bounded(motion),"Bounded enemy: %s %s" % [kind,phase])
            check(motion == Motion.enemy_motion(enemy,1.0,age,false),"Deterministic enemy: %s %s" % [kind,phase])
            check(Motion.enemy_motion(enemy,1.0,age,true)==Motion.neutral(),"Reduced motion enemy: %s %s" % [kind,phase])
            if phase in ["warning","charge-warning","charging","defeated"] or kind=="terminal":
                check(motion == Motion.neutral(),"Danger or static actor moved: %s %s" % [kind,phase])
            check(enemy == original,"Enemy state mutated: %s %s" % [kind,phase])
    # The pilot must create a meaningful start/stop/turn change for both
    # appearances without affecting other kits or authoritative state.
    for appearance in ["original","female"]:
        var run_pose := {"state":"run","flip":false}
        var started: Dictionary = Motion.hero_motion("sigma",run_pose,2.0,0.35,false,
            {"start_age":0.0,"turn_age":1000.0,"heading":0.0,"appearance":appearance})
        var steady: Dictionary = Motion.hero_motion("sigma",run_pose,2.0,0.35,false,
            {"start_age":1.0,"turn_age":1000.0,"heading":0.0,"appearance":appearance})
        var turning: Dictionary = Motion.hero_motion("sigma",run_pose,2.0,0.35,false,
            {"start_age":1.0,"turn_age":0.0,"turn_sign":1.0,"heading":0.0,"appearance":appearance})
        check(bounded(started) and bounded(steady) and bounded(turning),"Ranged bounds: "+appearance)
        check(started!=steady,"Ranged startup has a distinct silhouette: "+appearance)
        check(steady!=turning,"Ranged direction change is expressive: "+appearance)
        var idle_pose := {"state":"idle","flip":false}
        var stopping: Dictionary = Motion.hero_motion("sigma",idle_pose,2.0,0.35,false,
            {"stop_age":0.0,"appearance":appearance})
        var resting: Dictionary = Motion.hero_motion("sigma",idle_pose,2.0,0.35,false,
            {"stop_age":1.0,"appearance":appearance})
        check(stopping!=resting,"Ranged stop has a visible settle: "+appearance)
        check(Motion.hero_motion("sigma",run_pose,2.0,0.35,true,
            {"start_age":0.0,"appearance":appearance})==Motion.neutral(),"Reduced motion pilot: "+appearance)
    if failures.is_empty():
        print("PASS: All 3 canonical hero kits (6 appearances) and 17 enemy kinds use bounded, deterministic cosmetic motion")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
