extends Control
## Clip a cached, full-width authored meter face; never scale sample progress.
var face: TextureRect
func install(texture: Texture2D) -> void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    clip_contents=true
    face=TextureRect.new()
    face.texture=texture
    face.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    face.stretch_mode=TextureRect.STRETCH_SCALE
    face.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(face)
func update_meter(track: Rect2, fraction: float) -> void:
    position=track.position
    size=Vector2(track.size.x*clampf(fraction,0,1),track.size.y)
    face.size=track.size
    face.visible=size.x>0.0
