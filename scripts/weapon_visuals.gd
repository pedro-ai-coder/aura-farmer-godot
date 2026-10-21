class_name WeaponVisuals
extends RefCounted

## Presentation-only Option A weapon motifs ported from Phaser combat-vfx.ts.
## Every effect marks an actual completed Godot weapon activation; it is not a
## projectile, an additional area, a hitbox or an independent damage source.
const MOTIFS: Dictionary = {
    "ratio-blaster": "dart",
    "no-cap": "cap",
    "brainrot-feed": "phone",
    "keyboard-warrior": "keyboard",
    "ban-hammer": "hammer",
    "touch-grass": "leaf",
    "cope-shield": "shield",
    "chad-hands": "fists",
    "personal-space": "segments"
}
const INK := Color("#253449")
const PAPER := Color("#f7edcd")
const AURA := Color("#f8c45f")
const TEAL := Color("#6eaab0")

static func motif(weapon_id: String) -> String:
    return str(MOTIFS.get(weapon_id, ""))

static func _triangle(canvas: CanvasItem, a: Vector2, b: Vector2, c: Vector2, color: Color) -> void:
    canvas.draw_colored_polygon(PackedVector2Array([a, b, c]), color)

static func draw_attack(canvas: CanvasItem, effect: Dictionary) -> void:
    var id := str(effect.get("id", ""))
    var type := motif(id)
    if type.is_empty():
        return
    var life := clampf(float(effect.get("life", 0.0)) / 0.18, 0.0, 1.0)
    if life <= 0.0:
        return
    var origin: Vector2 = effect.get("origin", Vector2.ZERO)
    var target: Vector2 = effect.get("target", origin)
    var forward := (target - origin).normalized()
    if forward.length_squared() < 0.01:
        forward = Vector2.RIGHT
    var sideways := Vector2(-forward.y, forward.x)
    var ink := Color(INK, life)
    var paper := Color(PAPER, life)
    var aura := Color(AURA, life)
    var teal := Color(TEAL, life)
    match type:
        "dart":
            _triangle(canvas, target + forward * 14.0,
                target - forward * 10.0 + sideways * 8.0,
                target - forward * 10.0 - sideways * 8.0, ink)
            _triangle(canvas, target + forward * 10.0,
                target - forward * 7.0 + sideways * 5.0,
                target - forward * 7.0 - sideways * 5.0, aura)
            canvas.draw_line(target - forward * 12.0, target - forward * 24.0, paper, 2.0)
        "cap":
            # No Cap has a real directional line hit; show its travel language
            # only as a fleeting ink-stroke connecting actual origin and target.
            canvas.draw_line(origin, target, ink, 4.0)
            canvas.draw_line(origin, target, aura, 2.0)
            canvas.draw_set_transform(target, forward.angle(), Vector2.ONE)
            canvas.draw_circle(Vector2(-2, -2), 11.0, ink)
            canvas.draw_circle(Vector2(-2, -2), 7.5, aura)
            canvas.draw_line(Vector2(5, -10), Vector2(17, -10), ink, 5.0)
            canvas.draw_set_transform(Vector2.ZERO)
        "phone":
            canvas.draw_rect(Rect2(target - Vector2(13, 18), Vector2(26, 36)), ink)
            canvas.draw_rect(Rect2(target - Vector2(9, 13), Vector2(18, 24)), paper)
            canvas.draw_line(target + Vector2(-5, -5), target + Vector2(5, -5), aura, 2.0)
            canvas.draw_line(target + Vector2(-5, 1), target + Vector2(3, 1), aura, 2.0)
        "keyboard":
            for i in range(4):
                var offset := (float(i) - 1.5) * 7.0
                var middle := target + sideways * offset
                canvas.draw_line(middle - forward * 15.0, middle + forward * 15.0, ink, 5.0)
                canvas.draw_line(middle - forward * 13.0, middle + forward * 13.0, aura, 2.0)
        "hammer":
            canvas.draw_line(target - forward * 20.0, target + forward * 8.0, ink, 5.0)
            canvas.draw_line(target + forward * 7.0 - sideways * 18.0,
                target + forward * 7.0 + sideways * 18.0, ink, 10.0)
            canvas.draw_line(target + forward * 7.0 - sideways * 15.0,
                target + forward * 7.0 + sideways * 15.0, aura, 4.0)
        "leaf":
            canvas.draw_line(target - forward * 24.0, target + forward * 13.0, teal, 5.0)
            _triangle(canvas, target + sideways * 13.0, target + forward * 10.0,
                target - forward * 8.0, teal)
            _triangle(canvas, target - sideways * 13.0, target + forward * 8.0,
                target - forward * 12.0, teal)
        "shield":
            var peak := target + forward * 17.0
            var left := target - forward * 8.0 + sideways * 17.0
            var right := target - forward * 8.0 - sideways * 17.0
            _triangle(canvas, peak, left, right, ink)
            canvas.draw_line(peak - forward * 4.0, target + sideways * 10.0, teal, 3.0)
            canvas.draw_line(peak - forward * 4.0, target - sideways * 10.0, teal, 3.0)
        "fists":
            for sign_value in [-1.0, 1.0]:
                var center: Vector2 = target + sideways * float(sign_value) * 13.0
                canvas.draw_rect(Rect2(center - Vector2(9, 9), Vector2(18, 18)), ink)
                canvas.draw_rect(Rect2(center - Vector2(6, 6), Vector2(12, 12)), aura)
        "segments":
            # Small identity accent inside Personal Space's real pulse radius.
            for i in range(8):
                var angle := float(i) * TAU / 8.0
                canvas.draw_arc(origin, 38.0, angle + 0.10, angle + 0.44, 5, teal, 4.0)
