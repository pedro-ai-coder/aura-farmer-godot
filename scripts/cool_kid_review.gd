extends "res://scripts/solo_run.gd"
## Isolated local review entry point. Same gameplay, disposable default profile.
var review_status: Label
var review_overlay: CanvasLayer
func _load_profile() -> void:
    profile=ProfileStoreScript.defaults()
func _save_profile() -> void:
    pass
func _ready() -> void:
    super._ready()
    art.cool_kid_rig.enabled=true
    art.cool_kid_rig.prepare()
    print("COOL_KID_REVIEW: ",art.cool_kid_rig.reason," Art=",art.cool_kid_rig.ART_COMMIT)
    review_overlay=CanvasLayer.new();review_overlay.layer=100;add_child(review_overlay)
    var panel:=HBoxContainer.new();panel.position=Vector2(8,132);review_overlay.add_child(panel)
    var toggle:=Button.new();toggle.text="F8: A/B rig";toggle.pressed.connect(_review_toggle);panel.add_child(toggle)
    review_status=Label.new();panel.add_child(review_status)
    _review_label()
func _review_label() -> void:
    if not art.cool_kid_rig.valid:
        review_status.text=" INVALID RIG: legacy fallback"
        return
    var context:=hero_animation_state()
    context["reduced_motion"]=bool(profile["settings"]["reducedMotion"])
    var state:=str(hero_pose().get("state","idle")) if hero.has("id") else "idle"
    var why: String=art.cool_kid_rig.fallback_reason(str(hero.get("id","cool-kid")),hero_appearance,state,context)
    review_status.text=(" CANDIDATE v2 / view %d / %s" % [art.cool_kid_rig.view,art.cool_kid_rig.displayed_state]) if why.is_empty() else " FALLBACK: "+why
func _process(delta: float) -> void:
    super._process(delta)
    if is_instance_valid(review_status):_review_label()
func _review_toggle() -> void:
    art.cool_kid_rig.enabled=not art.cool_kid_rig.enabled
    _review_label();queue_redraw()
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F8:
        _review_toggle();get_viewport().set_input_as_handled();return
    super._input(event)
