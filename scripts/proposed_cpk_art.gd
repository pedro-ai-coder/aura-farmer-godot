extends RefCounted

## Preview-only cutout candidates. Original kits, state precedence and RNG stay intact.
const Canonical = preload("res://scripts/hero_animation.gd")
const Female = preload("res://scripts/female_hero_animation.gd")
# Canvas draw commands are deferred; retain resources until the frame renders.
static var atlases: Dictionary = {}
const ROOT := "res://assets/art-candidates/"
static func slug(hero_id: String, appearance: String) -> String:
    if hero_id == "alpha": return "block-queen" if appearance == "female" else "alpha-chad"
    return "byte-baddie" if hero_id == "cool-kid" and appearance == "female" else ""

static func portrait(hero_id: String, appearance: String, usage: String) -> Texture2D:
    var name := slug(hero_id,appearance)
    if name.is_empty(): return null
    # The legacy Byte Baddie portrait derivative contains only the upper body.
    # Its approved master already contains both boots; use those exact bytes
    # for selection/home/results while preserving the HUD resource.
    if name == "byte-baddie" and usage != "hud":
        return load(ROOT+name+"/cpk-v1-proposed/selection-source.png") as Texture2D
    return load(ROOT+name+"/cpk-v1-proposed/"+("hud" if usage == "hud" else "portrait")+".png") as Texture2D

static func pose(hero_id: String, appearance: String, state: Dictionary) -> Dictionary:
    var result: Dictionary = Female.pose(hero_id,state)
    result["sheet"] = slug(hero_id,appearance)+"-proposed"
    if result["state"] == "run":
        result["flip"] = cos(float(state.get("heading",0.0))) < 0.0
        result["gait"] = float(state.get("walk",0.0))*TAU*2.25
    return result

static func gait_vertex(point: Vector2, phase: float) -> Vector2:
    # Articulated cutout, using only existing source pixels. Opposite feet lift
    # and travel around fixed hips instead of translating the entire idle pose.
    var leg := clampf((point.y-132.0)/84.0,0.0,1.0)
    var side := clampf((point.x-128.0)/24.0,-1.0,1.0)
    var stride := sin(phase)*side
    return point+Vector2(stride*22.0*leg, -maxf(0.0,stride)*15.0*leg-absf(sin(phase))*2.0*(1.0-leg))

static func draw_gait(canvas: CanvasItem, atlas: Texture2D, factor: float, phase: float) -> void:
    # A continuous mesh prevents seams between the two legs. UVs select one
    # isolated standing cell; no new raster art or neighboring frames are used.
    var vertices := PackedVector2Array()
    var uvs := PackedVector2Array()
    var indices := PackedInt32Array()
    const GRID := 12
    for y in range(GRID+1):
        for x in range(GRID+1):
            var point := Vector2(x,y)*256.0/GRID
            vertices.append((gait_vertex(point,phase)-Vector2(128,216))*factor)
            uvs.append(point/Vector2(atlas.get_size()))
    for y in range(GRID):
        for x in range(GRID):
            var a := y*(GRID+1)+x
            indices.append_array(PackedInt32Array([a,a+1,a+GRID+1,a+1,a+GRID+2,a+GRID+1]))
    canvas.draw_mesh(gait_mesh(vertices,uvs,indices),atlas)

# Retain the mesh until deferred canvas commands have rendered it.
static var gait_meshes: Array[ArrayMesh] = []
static var gait_cursor := 0
static func gait_mesh(vertices: PackedVector2Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> ArrayMesh:
    if gait_meshes.size()<16: gait_meshes.append(ArrayMesh.new())
    gait_cursor = (gait_cursor+1)%gait_meshes.size()
    var mesh := gait_meshes[gait_cursor]
    mesh.clear_surfaces()
    var arrays := []; arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uvs;arrays[Mesh.ARRAY_INDEX]=indices
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays,[],{},Mesh.ARRAY_FLAG_USE_2D_VERTICES)
    return mesh

static func draw(canvas: CanvasItem, pos: Vector2, hero_id: String, pose_data: Dictionary) -> bool:
    var name := str(pose_data.get("sheet",""))
    if not name.ends_with("-proposed"): return false
    name = name.trim_suffix("-proposed")
    if name not in ["byte-baddie","alpha-chad","block-queen"]: return false
    if not atlases.has(name):
        atlases[name] = load(ROOT+name+"/cpk-v1-proposed/atlas.png") as Texture2D
    var atlas: Texture2D = atlases[name]
    if atlas == null: return false
    var index := clampi(int(pose_data["frame"]),0,23)
    var factor := 0.34 if hero_id == "alpha" else 0.32
    canvas.draw_set_transform(pos,0.0,Vector2(-1,1) if bool(pose_data["flip"]) else Vector2.ONE)
    if pose_data.has("gait"):
        draw_gait(canvas,atlas,factor,float(pose_data["gait"]))
    else:
        canvas.draw_texture_rect_region(atlas,Rect2(Vector2(-128,-216)*factor,Vector2(256,256)*factor),Rect2((index%4)*256,int(index/4)*256,256,256))
    canvas.draw_set_transform(Vector2.ZERO)
    return true
