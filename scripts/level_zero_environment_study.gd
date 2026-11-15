extends Node2D
## Explicit environmental shotboard/navigation study, not a new Solo ruleset.
## Reuses existing experimental source-space floor and exact factory artwork.
const Design=preload("res://scripts/cpk_design_system.gd")
const HeroAtlas=preload("res://scripts/full_hero_atlases.gd")
const Solo=preload("res://scripts/solo_run.gd")
const BACKDROP=preload("res://assets/experimental/cpk-level-zero-study/factory-backdrop.png")
const UNDERLAY=preload("res://assets/experimental/cpk-level-zero-study/factory-underlay.png")
const WORDMARK=preload("res://assets/production/cpk-brand-2026-11-13-v1/cpk-wordmark-color-1024.png")
const SOURCE_SIZE=Vector2(1672,941)
# Preserved source-pixel landmarks from 7b0bf708, never applied to Ruin Alley.
const FLOOR=[Vector2(218,500),Vector2(245,430),Vector2(300,385),Vector2(390,371),Vector2(460,380),Vector2(540,385),Vector2(620,418),Vector2(827,420),Vector2(900,370),Vector2(1020,366),Vector2(1190,367),Vector2(1248,381),Vector2(1340,425),Vector2(1452,480),Vector2(1453,775),Vector2(1380,895),Vector2(1245,916),Vector2(450,916),Vector2(280,895),Vector2(209,780)]
static var polygon:=PackedVector2Array(FLOOR)
@export_range(0,2) var hero_index:=0
@export_enum("original","female") var appearance: String="original"
var atlases=HeroAtlas.new()
var player:=Vector2(836,850)
var facing: float=-PI*.5
var walk:=0.0
var moving:=false
var phase: String="rear_entry"
var age:=0.0
var camera: Camera2D
var heading: Label
var countdown: Label
var hint: Label
@export var reduced_motion:=false
var touch_index: int=-1
var touch_origin:=Vector2.ZERO
var touch_direction:=Vector2.ZERO

static func walkable(point: Vector2,radius: float=16) -> bool:
    if not Geometry2D.is_point_in_polygon(point,polygon):return false
    for i in range(FLOOR.size()):
        var a: Vector2=FLOOR[i];var b: Vector2=FLOOR[(i+1)%FLOOR.size()]
        if Geometry2D.get_closest_point_to_segment(point,a,b).distance_to(point)<radius:return false
    return true

static func move_feet(point: Vector2,delta: Vector2) -> Vector2:
    var steps: int=maxi(1,ceili(delta.length()/8.0));var current:=point
    for i in range(steps):
        var next:=current+Vector2(delta.x/steps,0)
        if walkable(next):current=next
        next=current+Vector2(0,delta.y/steps)
        if walkable(next):current=next
    return current

func _ready() -> void:
    reduced_motion=reduced_motion or OS.get_cmdline_user_args().has("--reduced-motion")
    get_window().title="CLUTCHPUNKS / Level Zero environment study"
    atlases.prepare(Solo.HEROES[hero_index]["id"],appearance)
    camera=Camera2D.new();camera.position=SOURCE_SIZE*.5;add_child(camera)
    var layer:=CanvasLayer.new();add_child(layer)
    heading=Label.new();heading.text="LEVEL ZERO / ENVIRONMENT STUDY";Design.label(heading,"small");heading.position=Vector2(20,18);layer.add_child(heading)
    countdown=Label.new();Design.label(countdown,"display");countdown.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;layer.add_child(countdown)
    hint=Label.new();Design.label(hint,"small");hint.text="Candidate shotboard · no combat rules, rewards or saves";hint.position=Vector2(20,48);layer.add_child(hint)
    get_viewport().size_changed.connect(_resize);_resize()

func _resize() -> void:
    if camera==null:return
    var size: Vector2=get_viewport_rect().size
    var fit: float=minf(size.x/SOURCE_SIZE.x,size.y/SOURCE_SIZE.y)
    camera.zoom=Vector2.ONE*fit
    countdown.position=Vector2(0,size.y*.28);countdown.size=Vector2(size.x,90)

func _process(delta: float) -> void:
    advance_presentation(delta)
    queue_redraw()

func advance_presentation(delta: float) -> void:
    age+=delta
    var direction:=Vector2.ZERO
    if phase=="rear_entry":
        direction=Vector2.UP
        if age>=1.0:phase="camera";age=0
    elif phase=="camera":
        if age>=.6:phase="countdown";age=0
    elif phase=="countdown":
        countdown.text=str(maxi(1,3-int(age)))
        if age>=3.0:phase="traversal";age=0;countdown.text="";hint.text="WASD / arrows · touch drag · Escape returns to Garage"
    elif phase=="traversal":
        direction=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
        var keyboard:=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
        if keyboard.length_squared()>0:direction=keyboard.normalized()
        if touch_index>=0:direction=touch_direction
    var before:=player
    player=move_feet(player,direction*float(Solo.HEROES[hero_index]["speed"])*delta)
    var travelled: float=player.distance_to(before);moving=travelled>.001
    if moving:facing=direction.angle();walk+=travelled/54.0
    if camera!=null:
        var extent: Vector2=get_viewport_rect().size
        var fit: float=minf(extent.x/SOURCE_SIZE.x,extent.y/SOURCE_SIZE.y)
        var extra: float=0 if reduced_motion else .04*(1.0-clampf(age/.6,0,1)) if phase=="camera" else .04 if phase=="rear_entry" else 0
        camera.zoom=Vector2.ONE*fit*(1+extra)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
        get_tree().change_scene_to_file("res://scenes/signal_breaker_garage.tscn")
    elif event is InputEventScreenTouch:
        if event.pressed and touch_index<0:touch_index=event.index;touch_origin=event.position;touch_direction=Vector2.ZERO
        elif event.index==touch_index and (not event.pressed or event.canceled):touch_index=-1;touch_direction=Vector2.ZERO
    elif event is InputEventScreenDrag and event.index==touch_index:
        touch_direction=(event.position-touch_origin).limit_length(70)/70.0

func _draw() -> void:
    draw_texture_rect(BACKDROP,Rect2(Vector2.ZERO,SOURCE_SIZE),false)
    draw_texture_rect(UNDERLAY,Rect2(Vector2.ZERO,SOURCE_SIZE),false)
    # Independent brand sign layer on the wall, outside candidate traversable floor.
    draw_rect(Rect2(1010,128,280,82),Design.INK)
    draw_texture_rect(WORDMARK,Rect2(1022,142,256,54),false)
    draw_set_transform(player,0,Vector2(1,.3));draw_circle(Vector2.ZERO,27,Color(Design.INK,.45));draw_set_transform(Vector2.ZERO)
    atlases.draw(self,player,Solo.HEROES[hero_index]["id"],appearance,{"state":"run" if moving else "idle"},{"walk":walk,"facing":facing,"moving":moving})
