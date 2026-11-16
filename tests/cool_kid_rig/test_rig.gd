extends SceneTree
const Rig=preload("res://scripts/cool_kid_articulated.gd")
var failures: Array[String]=[]
func check(value: bool, label: String) -> void:
    if not value: failures.append(label)
func _initialize() -> void:
    var rig:=Rig.new()
    if not rig.prepare():
        push_error("Invalid pinned package: "+rig.reason);quit(1);return
    rig.enabled=true
    check(rig.supports("cool-kid","original","attack",{}),"Cool Kid attack")
    check(not rig.supports("cool-kid","female","idle",{}),"Byte Baddie exclusion")
    check(not rig.supports("sigma","original","idle",{}),"other kit exclusion")
    check(not rig.supports("cool-kid","original","idle",{"reduced_motion":true}),"reduced motion fallback")
    check(rig.supports("cool-kid","original","run",{"moving":true,"heading":-PI/2}),"rear candidate coverage")
    check(not rig.supports("cool-kid","original","unknown",{}),"unknown state fallback")
    for state in ["idle","run","attack","hurt","flex-in","flex-loop","flex-out","defeat"]:
        for i in range(60):
            var context: Dictionary={"time":i/60.0,"walk":i/60.0,"attack":0.22-i/300.0,"hurt":0.18-i/400.0,"flex":1.0,"flex_age":i/60.0,"defeat":i/60.0,"moving":state=="run","heading":0.0}
            rig.sample(state,context)
            for transform: Transform2D in rig.transforms.values():check(transform.is_finite(),"finite pose "+state)
            check(rig.transforms["keyboard"]==rig.transforms["fore_l"],"prop inherits forearm exactly")
    check(not rig.prepare("res://missing/"),"missing package rejected")
    check(not rig.valid,"failed prepare invalidates prior cache")
    check(not rig.prepare(Rig.ROOT,"bad"),"bad manifest rejected")
    if failures.is_empty():print("PASS: pinned package, 480 sampled poses, attachments, identity/reduced-motion/direction/state and invalid-package fallback");quit()
    else:
        for f in failures:push_error(f)
        quit(1)
