class_name ApprovedVisuals
extends RefCounted

## Presentation-only adapter for Phaser's exact approved artwork.
## Art is SHA-verified at Web build time. Never modify gameplay or RNG here.

const ROOT := "res://assets/approved/"
const HERO_FRAMES: Dictionary = {"sigma":[[10,5,155,174],[197,6,151,172],[380,7,159,172],[554,6,169,172],[740,5,153,175],[935,4,131,176],[1103,4,143,177],[1287,4,142,177],[19,183,140,180],[210,183,127,180],[386,182,132,181],[562,181,143,182],[758,184,148,178],[943,184,141,178],[1120,184,137,176],[1303,184,127,178],[15,365,164,176],[195,365,161,177],[369,365,164,177],[543,365,159,173],[744,366,133,183],[934,367,137,182],[1120,370,136,175],[1305,367,123,178],[24,544,130,178],[218,545,109,179],[400,545,99,172],[561,544,123,178],[751,550,133,176],[934,550,133,177],[1111,547,135,180],[1303,548,127,178],[18,725,118,176],[168,728,118,172],[314,735,142,164],[454,741,179,162],[638,737,117,166],[775,752,129,152],[915,762,185,142],[1106,771,166,126],[1278,808,164,79],[29,904,142,172],[228,905,138,173],[428,905,155,172],[637,919,159,158],[832,905,190,172],[1078,909,130,168],[1282,905,121,172]],"cool-kid":[[13,8,180,181],[207,7,173,184],[394,8,155,179],[564,10,157,177],[744,7,177,180],[944,7,140,180],[1106,7,150,185],[1272,7,158,187],[13,194,162,192],[212,193,146,197],[385,199,149,191],[560,194,156,196],[751,197,167,193],[938,196,144,192],[1107,198,152,185],[1290,196,150,187],[14,395,172,204],[207,395,156,206],[395,397,156,202],[566,396,152,201],[738,396,167,203],[918,400,159,201],[1093,397,160,196],[1272,398,148,202],[7,610,172,208],[184,612,166,206],[369,612,141,209],[515,612,216,200],[704,637,200,181],[911,612,169,203],[1077,612,181,206],[1262,624,170,194],[10,948,204,112],[216,838,155,217],[387,849,165,206],[559,855,179,198],[735,886,201,164],[938,866,164,181],[1110,843,177,212],[1286,842,152,213]],"alpha":[[17,15,168,158],[212,14,156,158],[403,14,163,158],[588,14,149,159],[754,14,160,155],[934,13,166,163],[1119,13,147,161],[1282,14,157,158],[10,189,177,162],[209,190,166,160],[399,188,167,161],[583,188,165,160],[769,190,164,156],[957,185,148,166],[1129,191,137,159],[1289,193,148,160],[13,365,171,164],[211,366,164,163],[399,367,154,162],[577,365,156,164],[758,366,152,164],[937,365,154,164],[1122,363,146,166],[1287,364,146,165],[15,543,162,161],[209,544,162,164],[394,543,166,163],[578,545,158,162],[765,540,153,167],[945,540,159,166],[1127,546,126,161],[1274,545,162,155],[7,717,151,166],[166,712,164,171],[334,728,196,149],[513,712,199,167],[708,728,200,154],[917,707,162,175],[1091,732,164,148],[1265,746,175,134],[11,979,218,87],[226,886,144,184],[383,905,170,161],[567,892,157,174],[736,922,180,147],[922,930,179,140],[1119,918,155,151],[1291,893,147,173]]}
const REAR_FRAMES: Dictionary = {"alpha":[[44,27,287,321],[418,26,276,305],[763,28,290,320],[1139,29,278,315],[44,374,276,325],[415,373,269,326],[767,371,273,328],[1138,372,270,326],[38,726,290,323],[412,725,261,286],[763,725,290,320],[1127,725,284,313]],"cool-kid":[[67,41,496,644],[614,37,446,644],[1114,38,517,648],[1685,38,467,644]]}
const FLEX_FRAMES: Array = [[50,122,346,286],[534,30,364,377],[1052,55,313,352],[1517,51,327,356],[80,443,278,339],[556,440,308,344],[1022,489,364,293],[1562,437,255,352]]
const RENDERED_HERO_HEIGHT := 70.0

## Exact frame masks from Phaser; cache clipped image textures per enemy animation frame.
## Rendering is presentation-only and never consumes gameplay RNG.
var textures: Dictionary = {}
var enemy_rows: Dictionary = {}
var enemy_images: Dictionary = {}
var enemy_frame_cache: Dictionary = {}

func _init() -> void:
    for asset_name in [
        "ruin-alley", "main-menu", "sigma", "cool-kid", "alpha",
        "phone-guy", "hater", "big-hater", "sigma-atlas", "cool-kid-atlas",
        "alpha-atlas", "cool-kid-flex-v2", "cool-kid-rear-v2", "alpha-rear-v2",
        "enemies-a-v2", "enemies-b-v2", "events-v2", "haters-v2"
    ]:
        var path: String = ROOT + asset_name + ".png"
        if ResourceLoader.exists(path):
            var resource = load(path)
            if resource is Texture2D:
                textures[asset_name] = resource
    var frame_path := "res://assets/approved-enemy-frames.json"
    if FileAccess.file_exists(frame_path):
        var parsed = JSON.parse_string(FileAccess.get_file_as_string(frame_path))
        if parsed is Dictionary:
            enemy_rows = parsed
        else:
            push_error("Invalid approved enemy atlas frame data")
    else:
        push_error("Missing approved enemy atlas frame data")

func texture(name: String) -> Texture2D:
    return textures.get(name) as Texture2D

func has(name: String) -> bool:
    return textures.has(name)

func draw_backdrop(canvas: CanvasItem, name: String, rect: Rect2) -> bool:
    var image: Texture2D = texture(name)
    if image == null:
        return false
    canvas.draw_texture_rect(image, rect, false)
    return true

func _frame(canvas: CanvasItem, atlas: Texture2D, info: Array, destination: Vector2, display_height: float, flip: bool) -> void:
    if atlas == null or info.size() < 4:
        return
    var width: float = float(info[2])
    var height: float = float(info[3])
    var ratio: float = display_height / maxf(1.0, height)
    canvas.draw_set_transform(destination, 0.0, Vector2(-1.0, 1.0) if flip else Vector2.ONE)
    canvas.draw_texture_rect_region(atlas,
        Rect2(-width * ratio * 0.5, -height * ratio * 0.90, width * ratio, height * ratio),
        Rect2(float(info[0]), float(info[1]), width, height))
    canvas.draw_set_transform(Vector2.ZERO)

func draw_hero(canvas: CanvasItem, pos: Vector2, hero_id: String, time: float, movement: Vector2, active_flex: bool, attacking: bool) -> bool:
    var atlas: Texture2D = texture(hero_id + "-atlas")
    if atlas == null or not HERO_FRAMES.has(hero_id):
        return false
    var frames: Array = HERO_FRAMES[hero_id]
    var facing_left := movement.x < -0.15
    var step := int(time * 9.0) % 4
    var moving := movement.length_squared() > 0.05
    if active_flex and hero_id == "cool-kid" and has("cool-kid-flex-v2"):
        var flex_index := 2 + (step if moving else 0)
        _frame(canvas, texture("cool-kid-flex-v2"), FLEX_FRAMES[flex_index], pos, 86.0, facing_left)
        return true
    if active_flex and hero_id != "cool-kid":
        var flex_index := 43 + int(time * 8.0) % 4
        _frame(canvas, atlas, frames[flex_index], pos, RENDERED_HERO_HEIGHT, facing_left)
        return true
    if attacking:
        var attack_start := 26 if hero_id == "cool-kid" else 34
        _frame(canvas, atlas, frames[attack_start + int(time * 12.0) % 3], pos, RENDERED_HERO_HEIGHT, facing_left)
        return true
    if moving:
        var heading := int(round(movement.angle() / (PI / 4.0)))
        var direction := posmod(heading, 8)
        if hero_id == "alpha" and direction >= 5 and has("alpha-rear-v2"):
            var row: int = int([8, 4, 0][direction - 5])
            _frame(canvas, texture("alpha-rear-v2"), REAR_FRAMES["alpha"][row + step], pos, RENDERED_HERO_HEIGHT, false)
            return true
        if hero_id == "cool-kid" and direction == 6 and has("cool-kid-rear-v2"):
            _frame(canvas, texture("cool-kid-rear-v2"), REAR_FRAMES["cool-kid"][step], pos, RENDERED_HERO_HEIGHT, false)
            return true
        var groups: Array = [0, 4, 8, 12, 16, 20, 24, 28]
        if hero_id == "cool-kid":
            groups = [0, 4, 8, 12, 0, 16, 0, 20]
        elif hero_id == "alpha":
            groups = [0, 8, 16, 24, 0, 0, 0, 0]
        var mirror := (hero_id != "sigma" and direction == 4) or (hero_id == "sigma" and direction == 5)
        _frame(canvas, atlas, frames[int(groups[direction]) + step], pos, RENDERED_HERO_HEIGHT, mirror)
        return true
    var idle_index := (24 if hero_id == "cool-kid" else 32) + int(time * 2.0) % 2
    _frame(canvas, atlas, frames[idle_index], pos, RENDERED_HERO_HEIGHT, facing_left)
    return true

func enemy_frame(kind: String, frame_index: int) -> Texture2D:
    if not enemy_rows.has(kind):
        return null
    var cache_key := kind + ":" + str(frame_index)
    if enemy_frame_cache.has(cache_key):
        return enemy_frame_cache[cache_key]["texture"] as Texture2D
    var row: Dictionary = enemy_rows[kind]
    var index := posmod(frame_index, int(row["sourceFrames"].size()))
    var source_name: String = row["source"]
    var source_texture: Texture2D = texture(source_name)
    if source_texture == null:
        return null
    if not enemy_images.has(source_name):
        var source_image := source_texture.get_image()
        if source_image == null:
            return null
        source_image.convert(Image.FORMAT_RGBA8)
        enemy_images[source_name] = source_image
    var src: Image = enemy_images[source_name]
    var region: Array = row["sourceFrames"][index]
    var w := int(region[2])
    var h := int(region[3])
    var image := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
    image.fill(Color.TRANSPARENT)
    for clip: Array in row["masks"][index]:
        var x := int(clip[0])
        var y := int(clip[1])
        var clip_w := int(clip[2])
        var clip_h := int(clip[3])
        image.blit_rect(src, Rect2i(int(region[0]) + x, int(region[1]) + y, clip_w, clip_h), Vector2i(x, y))
    var frame_texture := ImageTexture.create_from_image(image)
    var pivot: Array = row["frames"][index]
    enemy_frame_cache[cache_key] = {
        "texture": frame_texture, "pivot": Vector2(float(pivot[0]), float(pivot[1])),
        "height": float(row["height"])
    }
    return frame_texture

func draw_enemy(canvas: CanvasItem, enemy: Dictionary, animation_time: float = 0.0) -> bool:
    var kind: String = enemy.get("kind", "npc")
    if kind == "boss" and animation_time >= 1080.0:
        kind = "boss-berserk"
    if not enemy_rows.has(kind):
        return false
    var frame_index := int(animation_time * 7.0) % 4
    var phase := str(enemy.get("phase", ""))
    if phase == "warning" or phase == "charge-warning":
        frame_index = 4
    elif phase == "charging":
        frame_index = 5
    elif animation_time - float(enemy.get("hurt_at", -100.0)) < 0.16:
        frame_index = 6
    elif float(enemy.get("speed", 0.0)) < 0.01:
        frame_index = 0
    var image: Texture2D = enemy_frame(kind, frame_index)
    if image == null:
        return false
    var cache_key := kind + ":" + str(frame_index)
    var data: Dictionary = enemy_frame_cache[cache_key]
    var scale: float = maxf(52.0, float(enemy.get("radius", 15.0)) * (2.6 if kind == "boss" or kind == "boss-berserk" else 3.1)) / maxf(1.0, float(data["height"]))
    var pivot: Vector2 = data["pivot"]
    var position: Vector2 = enemy["pos"]
    var face_left: bool = Vector2(enemy.get("locked_direction", Vector2.RIGHT)).x < -0.05
    canvas.draw_set_transform(position, 0.0, Vector2(-1.0, 1.0) if face_left else Vector2.ONE)
    canvas.draw_texture_rect(image, Rect2(-pivot * scale, image.get_size() * scale), false)
    canvas.draw_set_transform(Vector2.ZERO)
    return true
