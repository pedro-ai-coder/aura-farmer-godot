extends Control
## Exact approved CPK derivative; no reconstructed lettering or generic symbols.
const WORDMARK=preload("res://assets/production/cpk-brand-2026-11-13-v1/cpk-wordmark-color-1024.png")
func _draw() -> void:
    if size.x<1 or size.y<1:return
    var extent: Vector2=WORDMARK.get_size()
    var factor: float=minf(size.x/extent.x,size.y/extent.y)
    var fitted: Vector2=extent*factor
    draw_texture_rect(WORDMARK,Rect2((size-fitted)*.5,fitted),false)
