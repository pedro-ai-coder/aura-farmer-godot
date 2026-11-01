extends RefCounted
## Preview artwork only. Gameplay kinds, collection and RNG belong to solo_run.
## Preloaded once: three 128px RGBA textures, no generated images or particle nodes.
const TEXTURES := {
    "aura": preload("res://assets/art-candidates/pickups/v1/xp-orb.png"),
    "snack": preload("res://assets/art-candidates/pickups/v1/street-snack.png"),
    "magnet": preload("res://assets/art-candidates/pickups/v1/aura-magnet.png")
}
const LABELS := {"aura":"XP Orb", "snack":"Street Snack", "magnet":"Aura Magnet"}

static func texture(kind: String) -> Texture2D:
    return TEXTURES.get(kind)

static func bounds(drop: Dictionary, clock: float, reduced_motion: bool) -> Rect2:
    var point: Vector2=drop["pos"]
    var kind: String=drop["kind"]
    var extent:=40.0
    if kind=="aura":
        extent=34.0 if drop.has("phase") else 32.0
        # Keep the existing inexpensive XP idle pulse and Reduced Motion behavior.
        if not reduced_motion: extent*=1.0+0.08*sin(clock*5.0+point.x*0.05)
    return Rect2(point-Vector2.ONE*extent*0.5,Vector2.ONE*extent)

static func draw(canvas: CanvasItem, drop: Dictionary, clock: float, reduced_motion: bool) -> void:
    var image:=texture(str(drop["kind"]))
    if image==null:return # Unknown gameplay kinds are never relabelled as XP.
    if drop["kind"]=="aura" and drop.has("phase"):
        # Existing phase reward distinction; no new reward, effect or RNG sample.
        canvas.draw_arc(drop["pos"],19.0,0,TAU,24,Color("f8c45f"),3.0)
    canvas.draw_texture_rect(image,bounds(drop,clock,reduced_motion),false)

static func feedback_text(feedback: Dictionary) -> String:
    # Preserve the historical event payload for seeded replay/state compatibility.
    # Only the player-facing presentation adopts the creator's XP Orb decision.
    var text: String=feedback["text"]
    return text.replace("XP CRYSTAL","XP ORB") if feedback["kind"]=="phase" else text
