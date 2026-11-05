extends RefCounted
## Optional, experimental Level Zero artwork bridge. Never changes simulation state.
## The exact PNGs are not part of this code-only PR. Absent/invalid packs use V3 art.
const PACK_PATH := "res://assets/experimental/level_zero/visual_pack_v1.json"
const BACKGROUND := "res://assets/experimental/level_zero/print_press_arena_candidate.png"
const FOREGROUND := "res://assets/experimental/level_zero/torn_poster_foreground_masked.png"
const IMITATION := "res://assets/experimental/level_zero/hater_imitation_sprite.png"
const SOURCE_HASHES := {
    "background": "0eb3f31bc22d5508c4fb3553335fe3279e3de3ec46566a3581a11d0f8931ed23",
    "foreground": "ceff210f3f642457ae4bd01507b96e9be431728cb0c339b9cbe3847fd1acb76d",
    "boss": "7510fb0805f8ec9afa2ce1148a6ca50e2bb996bbc721bc6a6c4a90d68ae67fcb"
}
var ground_texture: Texture2D
var foreground_texture: Texture2D
var boss_texture: Texture2D
var boss_pivot := Vector2.ZERO
var boss_height := 0.0

func _init() -> void:
    if not FileAccess.file_exists(PACK_PATH):
        return
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PACK_PATH))
    if not parsed is Dictionary:
        return
    var pack: Dictionary = parsed
    if pack.get("schema_version", "") != "level-zero-visual-pack-v1" or pack.get("status", "") != "EXPERIMENTAL_CANDIDATE":
        return
    ground_texture = _texture_if_staged(pack.get("background", {}), BACKGROUND, SOURCE_HASHES["background"])
    var foreground_entry: Dictionary = pack.get("foreground", {})
    # Never draw an opaque concept board over gameplay or hazard telegraphs.
    if foreground_entry.get("combat_safe_mask_reviewed", false) == true:
        foreground_texture = _texture_if_staged(foreground_entry, FOREGROUND, SOURCE_HASHES["foreground"])
    var boss_entry: Dictionary = pack.get("boss", {})
    if boss_entry.get("independent_sprite_master", false) == true:
        var pivot = boss_entry.get("foot_pivot_px", [])
        var height = boss_entry.get("world_height", 0.0)
        if pivot is Array and pivot.size() == 2 and (height is float or height is int) and height > 0.0:
            boss_texture = _texture_if_staged(boss_entry, IMITATION, SOURCE_HASHES["boss"])
            if boss_texture != null:
                boss_pivot = Vector2(float(pivot[0]), float(pivot[1]))
                boss_height = height

func _texture_if_staged(entry: Variant, expected_path: String, source_sha: String) -> Texture2D:
    if not entry is Dictionary:
        return null
    var data: Dictionary = entry
    if data.get("path", "") != expected_path or data.get("source_sha256", "") != source_sha:
        return null
    if data.get("status", "") != "CANDIDATE" or data.get("verified_export_sha256", "") == "":
        return null
    if not ResourceLoader.exists(expected_path, "Texture2D"):
        return null
    return ResourceLoader.load(expected_path, "Texture2D") as Texture2D

static func cover_rect(source_size: Vector2, destination: Rect2) -> Rect2:
    # Preserve the source aspect ratio; crop image sides rather than stretch it.
    if source_size.x <= 0.0 or source_size.y <= 0.0 or destination.size.x <= 0.0 or destination.size.y <= 0.0:
        return Rect2()
    var ratio := maxf(destination.size.x / source_size.x, destination.size.y / source_size.y)
    var visible_size := destination.size / ratio
    return Rect2((source_size - visible_size) * 0.5, visible_size)

func draw_background(canvas: CanvasItem, destination: Rect2) -> bool:
    if ground_texture == null:
        return false
    canvas.draw_texture_rect_region(ground_texture, destination, cover_rect(ground_texture.get_size(), destination))
    return true

func draw_foreground(canvas: CanvasItem, destination: Rect2) -> void:
    if foreground_texture == null:
        return
    # Draw before actors, pickups and hostile telegraphs; no input interception.
    canvas.draw_texture_rect_region(foreground_texture, destination, cover_rect(foreground_texture.get_size(), destination))

func draw_imitation(canvas: CanvasItem, enemy: Dictionary, reaction: Vector2 = Vector2.ZERO, opacity: float = 1.0) -> bool:
    if boss_texture == null or boss_height <= 0.0:
        return false
    var scale := boss_height / maxf(1.0, boss_texture.get_height())
    canvas.draw_set_transform(Vector2(enemy["pos"]) + reaction, 0.0, Vector2.ONE * scale)
    canvas.draw_texture(boss_texture, -boss_pivot, Color(1.0, 1.0, 1.0, clampf(opacity, 0.0, 1.0)))
    canvas.draw_set_transform(Vector2.ZERO)
    return true
