extends SceneTree

## Integration gate for the exact Pixel Vixen clean-cut production sprite atlas.
## This test intentionally FAILS while the source PNG is absent from the PR.
## It is not a simulation of real gameplay or creator art approval.
const Visuals = preload("res://scripts/approved_visuals.gd")
const VixenPose = preload("res://scripts/pixel_vixen_animation.gd")
const Sigma = preload("res://scripts/hero_animation.gd")

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var path: String = Visuals.PIXEL_VIXEN_CPK_ATLAS_PATH
    if not ResourceLoader.exists(path):
        push_error("BLOCKED: exact approved-brand Pixel Vixen atlas has not been imported into the game branch.")
        quit(2)
        return
    if FileAccess.get_sha256(path) != Visuals.PIXEL_VIXEN_CPK_ATLAS_SHA256:
        push_error("BLOCKED: the Pixel Vixen atlas bytes do not match the source SHA-256.")
        quit(2)
        return
    var tex: Texture2D = load(path)
    if tex == null or tex.get_size() != Vector2(672,672):
        push_error("BLOCKED: Pixel Vixen source atlas geometry must be 7x7 cells at 96x96.")
        quit(2)
        return
    var visuals := Visuals.new()
    if visuals.pixel_vixen_cpk_atlas == null:
        push_error("BLOCKED: renderer did not load verified production art.")
        quit(2)
        return
    var state := {"time":0.0,"walk":0.0,"defeat":0.0,"lost":false,"hurt":0.0,
        "flex":0.0,"flex_age":0.0,"attack":0.0,"heading":0.0,"moving":false,"facing":0.0}
    for event in ["idle","run","attack","hurt","flex","defeat"]:
        var s: Dictionary = state.duplicate()
        match event:
            "run": s["moving"] = true
            "attack": s["attack"] = 0.15
            "hurt": s["hurt"] = 0.15
            "flex": s["flex"] = 5.0
            "defeat": s["lost"] = true
        var pose: Dictionary = VixenPose.pose(s)
        if str(pose["sheet"]) != "pixel-vixen" or int(pose["frame"]) < 0 or int(pose["frame"]) >= 49:
            push_error("Pixel Vixen animation state changed canonical frame mapping: " + event)
            quit(1)
            return
        if str(pose["state"]) != str(Sigma.pose("sigma",s)["state"]):
            push_error("Pixel Vixen changed Sigma combat presentation state: " + event)
            quit(1)
            return
    print("PASS: exact atlas import, state mapping and unchanged Sigma kit animation sequencing.")
    print("NOTE: not a gameplay/browser/visual art approval test.")
    quit(0)
