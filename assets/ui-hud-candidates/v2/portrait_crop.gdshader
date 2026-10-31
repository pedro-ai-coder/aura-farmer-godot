shader_type canvas_item;
// Crop the existing approved master at runtime; source bytes remain intact.
uniform vec4 source_region = vec4(0.18, 0.07, 0.49, 0.54);
void fragment() {
    vec2 p = UV;
    vec4 ink = texture(TEXTURE, source_region.xy + p * source_region.zw);
    float left = 0.27 * (1.0 - p.y);
    float right = 1.0 - 0.16 * p.y;
    if (p.x < left || p.x > right) ink.a = 0.0;
    COLOR = ink;
}
