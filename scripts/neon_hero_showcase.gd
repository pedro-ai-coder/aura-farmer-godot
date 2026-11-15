extends Node
## Menu-only high-resolution approved pose playback; no rig or pixel deformation.
const Atlases=preload("res://scripts/approved_hero_sheets.gd")
const Design=preload("res://scripts/neon_arcade.gd")
var library:=Atlases.new()
var cache: Dictionary={}
var target: TextureRect
var frames: Array[AtlasTexture]=[]
var home:=Rect2()
var age:=0.0
var entry_offset:=0.0
var low_motion:=false
var enabled:=true
var transition: Tween
var current_frame: int=-1
var identity: String=""
const POSES=[4,8,10,0] # Idle, anticipation, recovery, front stance.

func configure(view: TextureRect,hero_id: String,appearance: String,reduced: bool) -> void:
    target=view;low_motion=reduced
    identity=Atlases.slug(hero_id,appearance)
    if not cache.has(identity):
        var entry: Dictionary=library.manifest[identity]
        var atlas: Texture2D=library.texture(hero_id,appearance,"atlas")
        # Approved individual poses retain twice the detail of the combat cells.
        # Shared original-pixel crop and foot pivot avoid size/position jitter.
        var crop_size:=Vector2.ZERO
        for index in POSES:
            var rect: Array=entry["frames"][index]["source_rect"]
            crop_size.x=maxf(crop_size.x,float(rect[2]))
            crop_size.y=maxf(crop_size.y,float(rect[3]))
        var crop:=Rect2(Vector2(192-floorf(crop_size.x*.5),330-crop_size.y),crop_size)
        var result: Array[AtlasTexture]=[]
        for index in POSES:
            var cell: Array=entry["frames"][index]["cell_rect"]
            var frame:=AtlasTexture.new();frame.atlas=atlas
            frame.region=Rect2(Vector2(cell[0],cell[1])+crop.position,crop.size)
            frame.filter_clip=true;result.append(frame)
        cache[identity]=result
    frames.assign(cache[identity]);age=0.0;current_frame=-1
    target.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    _show_frame(0 if low_motion else 1)
    enter()

func set_home(rect: Rect2) -> void:
    home=rect
    if target!=null:target.position=home.position+Vector2(entry_offset,0);target.size=home.size

func enter() -> void:
    if transition!=null:transition.kill()
    entry_offset=0.0 if low_motion else 28.0
    if not low_motion:
        transition=create_tween()
        transition.tween_property(self,"entry_offset",0.0,Design.ENTER).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    if target!=null:target.position=home.position+Vector2(entry_offset,0)

func _show_frame(index: int) -> void:
    if index==current_frame or frames.is_empty():return
    current_frame=index;target.texture=frames[index]

func _process(delta: float) -> void:
    if not enabled or target==null or not target.is_visible_in_tree():return
    if low_motion:
        entry_offset=0.0;target.rotation=0.0;_show_frame(0)
    else:
        age=fmod(age+delta,90.0)
        # Short anticipation/recovery, then occasional high-resolution stance changes.
        var frame: int=1 if age<.16 else 2 if age<.34 else 3 if fmod(age,9.0)>5.5 else 0
        _show_frame(frame)
        target.pivot_offset=Vector2(target.size.x*.5,target.size.y)
        target.rotation=sin(age*1.7)*deg_to_rad(.45)
    target.position=home.position+Vector2(entry_offset,0)

func _exit_tree() -> void:
    if transition!=null:transition.kill()
