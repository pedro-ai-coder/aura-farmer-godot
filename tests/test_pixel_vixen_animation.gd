extends SceneTree

const Appearance = preload("res://scripts/hero_appearance.gd")
const VixenPose = preload("res://scripts/pixel_vixen_animation.gd")
const Visuals = preload("res://scripts/approved_visuals.gd")
var failures: Array[String] = []

func expect(ok: bool, message: String) -> void:
    if not ok: failures.append(message)

func _initialize() -> void:
    call_deferred("_verify")

func _verify() -> void:
    var asset := "res://assets/art-candidates/pixel-vixen/v1/atlas.png"
    expect(ResourceLoader.exists(asset), "Review candidate atlas imports as a real Web/Godot texture")
    var visuals := Visuals.new()
    var portrait: Texture2D = visuals.cosmetic_portrait("sigma", "female")
    expect(portrait != null and portrait.get_width() == 36 and portrait.get_height() == 40, "Pixel Vixen real frame supplies a 36x40 portrait")
    expect(visuals.cosmetic_portrait("cool-kid", "female") == null, "Byte Baddie cannot masquerade as a male placeholder")
    expect(visuals.cosmetic_portrait("alpha", "female") == null, "Block Queen cannot masquerade as a male placeholder")
    expect(visuals.cosmetic_portrait("sigma", "original") == visuals.texture("sigma"), "Original Sigma portrait bytes are unchanged")
    expect(Appearance.can_start("female", "sigma"), "Only Sigma's female appearance is newly playable")
    expect(not Appearance.can_start("female", "cool-kid") and not Appearance.can_start("female", "alpha"), "Other female kits remain art-gated")
    var state := {"time":0.0,"walk":0.0,"defeat":0.0,"lost":false,"hurt":0.0,"flex":0.0,"flex_age":0.0,"attack":0.0,"heading":0.0,"moving":false,"facing":0.0}
    for situation in ["idle", "run", "attack", "hurt", "flex", "defeat"]:
        var input := state.duplicate()
        match situation:
            "run":
                input["moving"] = true
                input["walk"] = 0.5
            "attack": input["attack"] = 0.15
            "hurt": input["hurt"] = 0.15
            "flex":
                input["flex"] = 4.0
                input["flex_age"] = 0.5
            "defeat":
                input["lost"] = true
                input["defeat"] = 0.2
        var pose: Dictionary = VixenPose.pose(input)
        expect(str(pose.get("sheet","")) == "pixel-vixen", situation + " comes from real candidate atlas")
        expect(int(pose["frame"]) >= 0 and int(pose["frame"]) < 49, situation + " uses a valid V2 atlas cell")
        expect(int(pose["legacy_frame"]) >= 0 and int(pose["legacy_frame"]) < 20, situation + " remains valid for legacy fallback")
        var original: Dictionary = preload("res://scripts/hero_animation.gd").pose("sigma",input)
        expect(str(pose["state"]) == str(original["state"]), situation + " shares canonical Sigma pose timing")
    var main = load("res://scenes/main.tscn").instantiate()
    root.add_child(main)
    main.hero_appearance = "female"
    main.start_run(0)
    expect(main.mode == "playing" and main.hero["id"] == "sigma", "Pixel Vixen plays the exact Sigma gameplay kit")
    expect(main.hero_pose()["sheet"] == "pixel-vixen", "Live gameplay renders the female appearance")
    expect(main.hero["starter"] == "no-cap" and main.hero["flex"] == "Deadpan Verdict", "No Cap and Deadpan Verdict stay canonical")
    main.queue_free()
    if ResourceLoader.exists(Visuals.VIXEN_V2_ATLAS_PATH):
        expect(ResourceLoader.exists(Visuals.VIXEN_V2_PORTRAIT_PATH), "V2 atlas and portrait must be paired")
        var atlas: Texture2D = load(Visuals.VIXEN_V2_ATLAS_PATH)
        expect(atlas.get_width() == 896 and atlas.get_height() == 672, "V2 atlas must have 49 128x96 cells")
    if failures.is_empty():
        print("PASS: Pixel Vixen atlas import, cosmetic gate, pure poses, and original Sigma art isolation")
        quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
