extends Node2D

## Diagnostic grid; deliberately not the approved Ruin Alley artwork.
const DEV_WORLD_RECT: Rect2 = Rect2(-1500.0, -1000.0, 3000.0, 2000.0)
const GRID_STEP: int = 128
const GRID_COLOR: Color = Color(0.16, 0.20, 0.26, 1.0)
const BORDER_COLOR: Color = Color(0.38, 0.47, 0.57, 1.0)

func _draw() -> void:
    for x in range(-1408, 1501, GRID_STEP):
        draw_line(Vector2(x, DEV_WORLD_RECT.position.y), Vector2(x, DEV_WORLD_RECT.end.y), GRID_COLOR, 1.0)
    for y in range(-896, 1001, GRID_STEP):
        draw_line(Vector2(DEV_WORLD_RECT.position.x, y), Vector2(DEV_WORLD_RECT.end.x, y), GRID_COLOR, 1.0)
    draw_rect(DEV_WORLD_RECT, BORDER_COLOR, false, 5.0)
