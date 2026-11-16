extends "res://scripts/signal_breaker_garage.gd"
## Preview-only coordinator: current Neon menus plus save-free Cool Kid rig run.
const ReviewRun=preload("res://scripts/cool_kid_review.gd")
func _create_run() -> Node:
    return ReviewRun.new()
func _ready() -> void:
    super._ready()
    game.review_overlay.hide()
    select_identity(1)
func _process(delta: float) -> void:
    super._process(delta)
    game.review_overlay.visible=not active and game.mode!="options"
