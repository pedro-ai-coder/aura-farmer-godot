extends "res://scripts/passive_feedback.gd"
## Keep the existing HUD and other passive families. Replace just the legacy burst ring.
func ring(game, center: Vector2, radius: float, id: String) -> void:
    if id != "six-to-seven":
        super.ring(game, center, radius, id)
