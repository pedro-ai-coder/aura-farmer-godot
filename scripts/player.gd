extends CharacterBody2D

## Engine smoke test, not final Aura Farmer gameplay logic.

func _physics_process(_delta: float) -> void:
    var keyboard_direction: Vector2 = Vector2(
        float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
        float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
    )
    var arrow_direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction: Vector2 = (keyboard_direction + arrow_direction).limit_length(1.0)
    velocity = direction * GameRules.DEFAULT_MOVE_SPEED
    move_and_slide()

func _draw() -> void:
    draw_circle(Vector2.ZERO, GameRules.PLAYER_COLLISION_RADIUS, Color(0.97, 0.72, 0.24, 1.0))
    draw_arc(Vector2.ZERO, GameRules.PLAYER_COLLISION_RADIUS + 4.0, 0.0, TAU, 32, Color(0.06, 0.10, 0.16, 1.0), 3.0)
    draw_line(Vector2(-6, -5), Vector2(6, -5), Color(0.06, 0.10, 0.16, 1.0), 2.0)
