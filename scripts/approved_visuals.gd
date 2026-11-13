class_name ApprovedVisuals
extends RefCounted

## Presentation-only adapter for Phaser's exact approved artwork.
## Art is SHA-verified at Web build time. Never modify gameplay or RNG here.

const ROOT := "res://assets/approved/"
const ApprovedMotion = preload("res://scripts/approved_hero_motion.gd")
var motion = ApprovedMotion.new()
const ProposedCPK = preload("res://scripts/proposed_cpk_art.gd")
const SigmaCPK = preload("res://scripts/sigma_cpk_animation.gd")
const SIGMA_CPK_ATLAS_PATH := "res://assets/production/the-sigma/cpk-v1/sigma-cpk-v1-atlas.png"
const SIGMA_CPK_ATLAS_SHA256 := "89e2b2c8a9685aee38b774a0e649da54167c94114fcacc84b5eea16ac2a37f36"
const SIGMA_CPK_RGBA_SHA256 := "d6ff95312425643cc261d71aec83df58a3ada59a192ab14c478a8b08729dd611"
const SIGMA_CPK_PORTRAIT_PATH := "res://assets/production/the-sigma/cpk-v1/sigma-cpk-v1-portrait.png"
var sigma_cpk_atlas: Texture2D = null
const CoolKidCPK = preload("res://scripts/cool_kid_cpk_animation.gd")
const COOL_KID_CPK_ATLAS_PATH := "res://assets/production/cool-kid/cpk-v1/cool-kid-cpk-v1-atlas.png"
const COOL_KID_CPK_ATLAS_SHA256 := "0a190b57982dfd8556da6b8e05cf38aae4f83e392461ef8a6c2bb42c2340925d"
const COOL_KID_CPK_RGBA_SHA256 := "53c297c181a6092508bb18e609d1781e5df3b5ddb76624383c21b4c23de3d012"
const COOL_KID_CPK_PORTRAIT_PATH := "res://assets/production/cool-kid/cpk-v1/cool-kid-cpk-v1-portrait.png"
var cool_kid_cpk_atlas: Texture2D = null
## V2 candidate resources remain isolated from immutable approved hero art.
const VIXEN_V2_ATLAS_PATH := "res://assets/art-candidates/pixel-vixen/v2/pixel-vixen-atlas-v2.png"
const VIXEN_V2_PORTRAIT_PATH := "res://assets/art-candidates/pixel-vixen/v2/pixel-vixen-portrait-v2.png"
const VIXEN_V2_HUD_PATH := "res://assets/art-candidates/pixel-vixen/v2/pixel-vixen-hud-v2.png"
const VixenFrames = preload("res://scripts/pixel_vixen_frames.gd")
## Creator-approved Pixel Vixen CPK atlas is committed in this feature branch.
## Cosmetic-only replacement: unchanged Sigma kit, timing, RNG and save semantics.
## Presentation-only gated resource: never changes Sigma weapon/Flex/stat/ID rules.
const PIXEL_VIXEN_CPK_ATLAS_PATH := "res://assets/production/pixel-vixen/cpk-v1/pixel-vixen-cpk-v1-atlas.png"
const PIXEL_VIXEN_CPK_ATLAS_SHA256 := "4058de734cd81eb29656267bede422756555dbf02d0680f20a91d609f9f05c63"
const PIXEL_VIXEN_CPK_RGBA_SHA256 := "6832e25dfa8dd8bb3389fcb5332b0fe7a0848557ab0882880baee1c5732681e6"
const VIXEN_ISOLATED_PATH := "res://assets/production/pixel-vixen/cpk-v2/atlas.png"
const VIXEN_ISOLATED_SHA := "a96d48d6922f515cbc4fc456b5c658c7916e11765082d6d61e994e0d6dad5d02"
const VIXEN_ISOLATED_RGBA := "3e510eded3e40e0e7c3cd2e63aab322ed266c54076a6c056bb89bc7c1478bae5"
var vixen_isolated_atlas: Texture2D = null
const FemaleArt = preload("res://scripts/female_appearance_art.gd")
const Appearance = preload("res://scripts/hero_appearance.gd")
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
        "enemies-a-v2", "enemies-b-v2", "events-v2", "haters-v2", "enemies"
    ]:
        var path: String = ROOT + asset_name + ".png"
        if ResourceLoader.exists(path):
            var resource = load(path)
            if resource is Texture2D:
                textures[asset_name] = resource
    if ResourceLoader.exists(COOL_KID_CPK_ATLAS_PATH):
        # Exported packs contain the imported texture, not the original PNG.
        # Verify decoded RGBA bytes in both environments, and source bytes when
        # present. Pinning both prevents a silent fallback in exported builds.
        var candidate := load(COOL_KID_CPK_ATLAS_PATH) as Texture2D
        var source_ok := not FileAccess.file_exists(COOL_KID_CPK_ATLAS_PATH) or FileAccess.get_sha256(COOL_KID_CPK_ATLAS_PATH) == COOL_KID_CPK_ATLAS_SHA256
        if source_ok and _cool_kid_texture_valid(candidate):
            cool_kid_cpk_atlas = candidate
            textures["cool-kid"] = load(COOL_KID_CPK_PORTRAIT_PATH) as Texture2D
        else:
            push_error("Cool Kid CPK atlas checksum mismatch; retaining legacy approved art.")
    sigma_cpk_atlas = _verified_cpk_texture(SIGMA_CPK_ATLAS_PATH, SIGMA_CPK_ATLAS_SHA256, SIGMA_CPK_RGBA_SHA256, Vector2(1008,1008))
    if sigma_cpk_atlas != null:
        textures["sigma"] = load(SIGMA_CPK_PORTRAIT_PATH) as Texture2D
    pixel_vixen_cpk_atlas = _verified_cpk_texture(PIXEL_VIXEN_CPK_ATLAS_PATH, PIXEL_VIXEN_CPK_ATLAS_SHA256, PIXEL_VIXEN_CPK_RGBA_SHA256, Vector2(672,672))
    vixen_isolated_atlas = _verified_cpk_texture(VIXEN_ISOLATED_PATH,VIXEN_ISOLATED_SHA,VIXEN_ISOLATED_RGBA,Vector2(1008,1008))
    var frame_path := "res://assets/approved-enemy-frames.json"
    if FileAccess.file_exists(frame_path):
        var parsed = JSON.parse_string(FileAccess.get_file_as_string(frame_path))
        if parsed is Dictionary:
            enemy_rows = parsed
        else:
            push_error("Invalid approved enemy atlas frame data")
    else:
        push_error("Missing approved enemy atlas frame data")

static func _verified_cpk_texture(path: String, source_sha: String, rgba_sha: String, dimensions: Vector2) -> Texture2D:
    if not ResourceLoader.exists(path): return null
    var candidate := load(path) as Texture2D
    var source_ok := not FileAccess.file_exists(path) or FileAccess.get_sha256(path) == source_sha
    if candidate == null or candidate.get_size() != dimensions or not source_ok:
        push_error("CPK source/geometry mismatch: " + path)
        return null
    var pixels := candidate.get_image()
    if pixels == null: return null
    if pixels.is_compressed() and pixels.decompress() != OK: return null
    pixels.convert(Image.FORMAT_RGBA8)
    var hash := HashingContext.new()
    hash.start(HashingContext.HASH_SHA256)
    hash.update(pixels.get_data())
    if hash.finish().hex_encode() != rgba_sha:
        push_error("CPK imported pixels mismatch: " + path)
        return null
    return candidate

static func _cool_kid_texture_valid(candidate: Texture2D) -> bool:
    if candidate == null or candidate.get_size() != Vector2(1008,1008): return false
    var pixels := candidate.get_image()
    if pixels == null: return false
    if pixels.is_compressed() and pixels.decompress() != OK: return false
    pixels.convert(Image.FORMAT_RGBA8)
    var hash := HashingContext.new()
    hash.start(HashingContext.HASH_SHA256)
    hash.update(pixels.get_data())
    return hash.finish().hex_encode() == COOL_KID_CPK_RGBA_SHA256

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

const HERO_MATTES := {"cool-kid":{27:[0,12],28:[28,0],29:[0,4],30:[4,0]},"alpha":{34:[0,8],35:[20,5],36:[5,0]}}
var hero_frame_cache: Dictionary = {}
var pixel_vixen_cpk_atlas: Texture2D = null
var female_art = FemaleArt.new()

func has_vixen_v2() -> bool:
    return female_art.has_assets("sigma")

func _vixen_atlas() -> Texture2D:
    return female_art.texture("sigma","atlas")

func prepare_appearance(hero_id: String, appearance: String) -> bool:
    return motion.prepare(hero_id,appearance)

func cosmetic_portrait(hero_id: String, appearance: String, usage: String = "selection") -> Texture2D:
    var name: String=ApprovedMotion.slug(hero_id,appearance)
    if usage!="hud": return motion.texture(name,"portrait")
    if name=="pixel-vixen": return motion.texture(name,"hud")
    if not ProposedCPK.slug(hero_id,appearance).is_empty():
        return ProposedCPK.portrait(hero_id,appearance,usage)
    if hero_id == "sigma" and appearance == "female" and pixel_vixen_cpk_atlas != null:
        return load("res://assets/production/pixel-vixen/cpk-v1/selection-portrait.png") as Texture2D
    return female_art.texture(hero_id,usage) if appearance == "female" else texture(hero_id)

func draw_hero_pose(canvas: CanvasItem, pos: Vector2, hero_id: String, pose: Dictionary) -> bool:
    if pose.get("sheet","")==ApprovedMotion.SHEET:
        return motion.draw(canvas,pos,hero_id,pose)
    if str(pose.get("sheet","")).ends_with("-proposed"):
        return ProposedCPK.draw(canvas,pos,hero_id,pose)
    var sheet: String = pose["sheet"]
    if sheet == SigmaCPK.SHEET:
        if hero_id != "sigma" or sigma_cpk_atlas == null: return false
        var factor: float = SigmaCPK.DISPLAY_SCALE
        canvas.draw_set_transform(pos,0.0,Vector2(-1,1) if bool(pose["flip"]) else Vector2.ONE)
        canvas.draw_texture_rect_region(sigma_cpk_atlas,
            Rect2(-SigmaCPK.ORIGIN*factor,Vector2.ONE*SigmaCPK.CELL*factor),
            SigmaCPK.source_rect(int(pose["frame"])))
        canvas.draw_set_transform(Vector2.ZERO)
        return true
    if sheet == CoolKidCPK.SHEET:
        if hero_id != "cool-kid" or cool_kid_cpk_atlas == null:
            return false
        var factor: float = CoolKidCPK.DISPLAY_SCALE
        canvas.draw_set_transform(pos,0.0,Vector2(-1,1) if bool(pose["flip"]) else Vector2.ONE)
        canvas.draw_texture_rect_region(cool_kid_cpk_atlas,
            Rect2(-CoolKidCPK.ORIGIN*factor,Vector2.ONE*CoolKidCPK.CELL*factor),
            CoolKidCPK.source_rect(int(pose["frame"])))
        canvas.draw_set_transform(Vector2.ZERO)
        return true
    if sheet == "pixel-vixen":
        if hero_id != "sigma":
            return false
        # V1's equal-cell extraction baked neighboring feet/bodies into each
        # frame. Use the existing source-segmented derivative, not extra layers
        # or another draw over the contaminated pixels. Legacy PNG stays intact.
        if vixen_isolated_atlas != null:
            var slot: int = clampi(int(pose.get("frame",0)),0,48)
            var source := Rect2(float(slot % 7 * 144),float(int(slot / 7) * 144),144.0,144.0)
            canvas.draw_set_transform(pos,0.0,Vector2(-1.0,1.0) if bool(pose.get("flip",false)) else Vector2.ONE)
            canvas.draw_texture_rect_region(vixen_isolated_atlas,Rect2(Vector2(-72,-120)*0.75,Vector2(144,144)*0.75),source)
            canvas.draw_set_transform(Vector2.ZERO)
            return true
        var atlas: Texture2D = _vixen_atlas()
        if atlas == null:
            return false
        var source: Rect2 = VixenFrames.source_rect(int(pose["frame"]))
        var factor: float = float(pose.get("scale",64.0/96.0))
        canvas.draw_set_transform(pos,0.0,Vector2(-1.0,1.0) if pose["flip"] else Vector2.ONE)
        canvas.draw_texture_rect_region(atlas,Rect2(-source.size*Vector2(0.5,0.9)*factor,source.size*factor),source)
        canvas.draw_set_transform(Vector2.ZERO)
        return true
    if hero_id != "sigma" and not sheet.is_empty() and sheet == Appearance.asset_slug(hero_id):
        var frame: Dictionary = female_art.frame(hero_id,int(pose["frame"]))
        if frame.is_empty(): return false
        var image: Texture2D = frame["texture"]
        var scale: float = frame["scale"]
        canvas.draw_set_transform(pos,0.0,Vector2(-1,1) if pose["flip"] else Vector2.ONE)
        canvas.draw_texture_rect(image,Rect2(-Vector2(frame["pivot"])*scale,image.get_size()*scale),false)
        canvas.draw_set_transform(Vector2.ZERO)
        return true
    var atlas := texture(hero_id+"-atlas" if sheet == "atlas" else hero_id+"-"+sheet)
    if atlas == null: return false
    var frames: Array = HERO_FRAMES[hero_id] if sheet == "atlas" else FLEX_FRAMES if sheet == "flex-v2" else REAR_FRAMES[hero_id]
    var index := int(pose["frame"])
    var info: Array = frames[index]
    var ratio: float = pose["scale"]
    var source := Rect2(float(info[0]),float(info[1]),float(info[2]),float(info[3]))
    if sheet == "atlas" and HERO_MATTES.get(hero_id,{}).has(index):
        var key := hero_id+str(index)
        if not hero_frame_cache.has(key):
            var image := atlas.get_image().get_region(Rect2i(source))
            image.convert(Image.FORMAT_RGBA8)
            var edges: Array = HERO_MATTES[hero_id][index]
            if int(edges[0]) > 0: image.fill_rect(Rect2i(0,0,int(edges[0]),image.get_height()),Color.TRANSPARENT)
            if int(edges[1]) > 0: image.fill_rect(Rect2i(image.get_width()-int(edges[1]),0,int(edges[1]),image.get_height()),Color.TRANSPARENT)
            hero_frame_cache[key] = ImageTexture.create_from_image(image)
        atlas = hero_frame_cache[key]
        source.position = Vector2.ZERO
    canvas.draw_set_transform(pos,0.0,Vector2(-1,1) if pose["flip"] else Vector2.ONE)
    canvas.draw_texture_rect_region(atlas,Rect2(-source.size*Vector2(0.5,0.9)*ratio,source.size*ratio),source)
    canvas.draw_set_transform(Vector2.ZERO)
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

static func enemy_pose_frame(enemy: Dictionary, time: float, death_age: float = -1.0) -> int:
    if death_age >= 0: return 6 if death_age < 0.16 else 7
    if time < float(enemy.get("stagger_until",0.0)): return 6
    var attack: Dictionary = enemy.get("attack_pose",{})
    if not attack.is_empty() and time >= float(attack["start"]) and time < float(attack["end"]):
        return 4 if time < float(attack["impact"]) else 5 if time < float(attack["end"])-0.22 else 0
    if time-float(enemy.get("hurt_at",-100.0)) < 0.16: return 6
    return int(float(enemy.get("anim_walk",0.0)))%4 if enemy.get("anim_moving",false) else 0

static func enemy_visual_kind(enemy: Dictionary, animation_time: float) -> String:
    var kind: String=enemy.get("kind","npc")
    if kind=="boss" and animation_time>=preload("res://scripts/solo_clock.gd").BERSERK_AT:
        return "boss-berserk"
    return kind

func draw_enemy(canvas: CanvasItem, enemy: Dictionary, animation_time: float = 0.0, death_age: float = -1.0, reduced_motion: bool = false, draw_offset: Vector2 = Vector2.ZERO) -> bool:
    var kind := enemy_visual_kind(enemy,animation_time)
    if kind == "terminal":
        var atlas := texture("enemies")
        if atlas == null: return false
        var tile := atlas.get_size()/4.0
        var size := float(enemy.get("radius",15))*3.1
        canvas.draw_texture_rect_region(atlas,Rect2(Vector2(enemy["pos"])-Vector2(size/2,size),Vector2.ONE*size),Rect2(Vector2(tile.x,tile.y*3),tile),Color(1,1,1,1.0 if death_age < 0 else maxf(0,1-death_age/0.8)))
        return true
    if not enemy_rows.has(kind):
        return false
    var frame_index := enemy_pose_frame(enemy,animation_time,death_age)
    var phase := str(enemy.get("phase",""))
    var image: Texture2D = enemy_frame(kind, frame_index)
    if image == null:
        return false
    var cache_key := kind + ":" + str(frame_index)
    var data: Dictionary = enemy_frame_cache[cache_key]
    var scale: float = float(enemy.get("radius",15.0))*(2.6 if kind in ["boss","boss-berserk","reply-guy","mod-supremo","ohio-express","doomscroll-prime"] else 3.1) / maxf(1.0, float(data["height"]))
    var pivot: Vector2 = data["pivot"]
    var position: Vector2 = Vector2(enemy["pos"])+draw_offset
    var face_left: bool = cos(float(enemy.get("angle",0.0))) < -0.05
    if phase in ["warning","charge-warning","charging"]: face_left = Vector2(enemy.get("locked_direction",Vector2.RIGHT)).x < -0.05
    var attack: Dictionary = enemy.get("attack_pose",{})
    if not attack.is_empty() and animation_time < float(attack["end"]): face_left = cos(float(attack["angle"])) < -0.05
    var flash := clampf(1.0-(animation_time-float(enemy.get("hurt_at",-100.0)))/0.12,0.0,1.0) if death_age < 0 else 0.0
    var stretch := Vector2.ONE
    if not reduced_motion:
        if death_age >= 0.0:
            stretch = Vector2(1.0+minf(death_age,0.20)*0.5,1.0-minf(death_age,0.20)*0.8)
        else: stretch = Vector2(1.0+flash*0.05,1.0-flash*0.05)
    canvas.draw_set_transform(position, 0.0, stretch * (Vector2(-1.0, 1.0) if face_left else Vector2.ONE))
    canvas.draw_texture_rect(image, Rect2(-pivot * scale, image.get_size() * scale), false,Color(1.0+flash*0.6,1.0+flash*0.6,1.0+flash*0.6,1.0 if death_age < 0 else clampf((0.85-death_age)/0.3,0,1)))
    canvas.draw_set_transform(Vector2.ZERO)
    return true

func cover_region() -> Rect2:
    var atlas := texture("enemies")
    if atlas == null: return Rect2()
    var size := atlas.get_size()
    return Rect2(roundf(size.x * 0.5), roundf(size.y * 0.75), floorf(size.x / 4.0), floorf(size.y / 4.0))

func draw_cover(canvas: CanvasItem, position: Vector2) -> void:
    var atlas := texture("enemies")
    if atlas != null:
        canvas.draw_texture_rect_region(atlas, Rect2(position - Vector2(40,68), Vector2(80,80)), cover_region())
