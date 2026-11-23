extends Sprite2D

const Maps = preload("res://scripts/solo_maps.gd")
const PlateMaterial = preload("res://scripts/msg_factory_plate.gdshader")
const PERIOD := 12.0
static var contact_shadow := make_contact_shadow()

static func make_contact_shadow() -> GradientTexture2D:
    var gradient := Gradient.new()
    gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
    gradient.colors = PackedColorArray([
        Color(0.045, 0.05, 0.11, 0.56),
        Color(0.05, 0.06, 0.13, 0.36),
        Color(0.07, 0.08, 0.16, 0.0),
    ])
    var shadow := GradientTexture2D.new()
    shadow.width = 64
    shadow.height = 32
    shadow.fill = GradientTexture2D.FILL_RADIAL
    shadow.fill_from = Vector2(0.5, 0.5)
    shadow.fill_to = Vector2(1.0, 0.5)
    shadow.gradient = gradient
    return shadow

func _init() -> void:
    centered = false
    show_behind_parent = true
    texture = Maps.FACTORY_ARENA
    material = ShaderMaterial.new()
    material.shader = PlateMaterial

func update_clock(run_time: float, reduced_motion: bool) -> void:
    material.set_shader_parameter("cycle", 0.0 if reduced_motion else fposmod(run_time, PERIOD) / PERIOD)

static func draw_machine_detail(canvas: Node2D, detail: StringName, clock: float) -> void:
    # Highlights sit on the existing cover pixels and share their depth pass.
    # Use a bounded deterministic phase for the vent and control-box pulse.
    if detail == &"vent":
        var vent := Vector2(495, 288)
        for blade in range(3):
            var spoke := Vector2.from_angle(clock * TAU * (4.0 / PERIOD) + blade * TAU / 3.0)
            spoke *= Vector2(13.5, 4.5)
            canvas.draw_line(vent + spoke * 0.31, vent + spoke, Color(0.97, 0.72, 0.46, 0.39), 1.2, true)
    elif detail == &"indicator":
        var pulse := 0.46 + 0.20 * sin(clock * TAU * 0.5)
        canvas.draw_circle(Vector2(1110, 412), 2.25, Color(0.99, 0.68, 0.34, pulse), true, -1.0, true)
