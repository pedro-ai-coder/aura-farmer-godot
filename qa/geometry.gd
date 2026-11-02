extends Node2D
## Draw only authoritative world collision bounds; not additional physics shapes.
var game
func _process(_delta: float) -> void:
    if game==null:return
    visible=game._qa_synthetic and bool(game.qa_overlay_flags.get("hitboxes",false))
    if visible:queue_redraw()
func _draw() -> void:
    if game==null or not game._qa_synthetic or not bool(game.qa_overlay_flags.get("hitboxes",false)):return
    draw_arc(game.player_pos,18.0,0.0,TAU,36,Color(0.1,1,0.8,0.9),2.0)
    for enemy: Dictionary in game.enemies:
        if game.run_time<float(enemy["born"]):continue
        draw_arc(Vector2(enemy["pos"]),float(enemy["radius"]),0.0,TAU,24,Color(1,0.45,0.25,0.9),1.6)
    for cover: Dictionary in game.SoloWorldRulesScript.COVERS:
        draw_arc(Vector2(cover["pos"]),float(cover["radius"]),0.0,TAU,32,Color(0.9,0.8,0.2,0.8),2.0)
