extends "res://scripts/solo_run.gd"
## Isolated local review entry point. Same gameplay, disposable default profile.
var review_status: Label
func _load_profile() -> void:
    profile=ProfileStoreScript.defaults()
func _save_profile() -> void:
    pass
func _ready() -> void:
    super._ready()
    art.cool_kid_rig.enabled=true
    art.cool_kid_rig.prepare()
    print("COOL_KID_REVIEW: ",art.cool_kid_rig.reason," Art=",art.cool_kid_rig.ART_COMMIT)
    var overlay:=CanvasLayer.new();overlay.layer=100;add_child(overlay)
    var panel:=HBoxContainer.new();panel.position=Vector2(8,132);overlay.add_child(panel)
    var toggle:=Button.new();toggle.text="F8: A/B rig";toggle.pressed.connect(_review_toggle);panel.add_child(toggle)
    review_status=Label.new();panel.add_child(review_status)
    _review_label()
func _review_label() -> void:
    if not art.cool_kid_rig.valid:
        review_status.text=" INVALID RIG: legacy fallback"
        return
    review_status.text=" CANDIDATE (front) / legacy fallback" if art.cool_kid_rig.enabled else " LEGACY renderer"
func _review_toggle() -> void:
    art.cool_kid_rig.enabled=not art.cool_kid_rig.enabled
    _review_label();queue_redraw()
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F8:
        _review_toggle();get_viewport().set_input_as_handled();return
    super._input(event)
