extends Node2D
## Read-only outline marking the exact experimental world polygon.
const Expanded=preload("res://qa/expanded_world.gd")
const Canonical=preload("res://scripts/solo_world_rules.gd")
var game
func _process(_delta: float) -> void:
    var show: bool=game!=null and game._qa_experiment_enabled and game._qa_synthetic and game.mode in ["playing","paused","choice","legendary","replace"]
    if visible!=show:visible=show
    if show:queue_redraw()
func _draw() -> void:
    if game==null or not game._qa_experiment_enabled:return
    var points: PackedVector2Array=Expanded.floor_outline()
    var closed:=PackedVector2Array(points)
    closed.append(points[0])
    draw_polyline(closed,Color(0.18,1.0,0.75,0.9),3.0,true)
    var original:=PackedVector2Array(Canonical.FLOOR)
    original.append(original[0])
    draw_polyline(original,Color(1.0,0.76,0.25,0.35),1.5,true)
