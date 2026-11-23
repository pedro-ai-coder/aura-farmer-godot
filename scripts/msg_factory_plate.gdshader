shader_type canvas_item;
render_mode unshaded;

// Coordinates refer to the unchanged 1448 x 1086 V4 plate.
uniform float cycle = 0.0;

float patch(vec2 p, vec2 center, vec2 axes, float slope) {
    vec2 d = p - center;
    d.y -= d.x * slope;
    vec2 local = d / axes;
    return 1.0 - smoothstep(0.10, 1.0, dot(local, local));
}

float panel(vec2 p, vec2 center, vec2 axes, float slope) {
    vec2 d = p - center;
    d.y -= d.x * slope;
    vec2 edge = abs(d) - axes;
    return 1.0 - smoothstep(-3.0, 0.0, max(edge.x, edge.y));
}

void fragment() {
    vec2 p = UV / TEXTURE_PIXEL_SIZE;
    vec2 sample_at = UV;
    vec3 light = vec3(0.0);
    float housing = 0.0;
    if (p.y < 335.0 && p.x > 680.0 && p.x < 1190.0) {
        // Cylindrical rims stay pinned. Broad moving specular bands reveal
        // rotation without translating the painted outline or its axle.
        float upper = panel(p, vec2(1017.0, 34.0), vec2(118.0, 25.0), 0.14);
        float lower = panel(p, vec2(1060.0, 156.0), vec2(39.0, 21.0), 0.17);
        float stripe = 0.5 + 0.5 * sin((p.y - p.x * 0.15) * 0.25 - cycle * TAU * 8.0);
        light += vec3(0.16, 0.073, 0.025) * stripe * (upper + lower);
        // Follow the slant and taper of the existing feed. Pin the paper
        // silhouette and flex the printed surface only inside it.
        float sheet_y = clamp((p.y - 100.0) / 165.0, 0.0, 1.0);
        float sheet_x = mix(981.0, 886.0, sheet_y);
        float sheet_mask = (1.0 - smoothstep(45.0, 64.0, abs(p.x - sheet_x)))
            * smoothstep(109.0, 126.0, p.y) * (1.0 - smoothstep(239.0, 260.0, p.y));
        float feed_phase = cycle * TAU * 4.0;
        vec2 path = vec2(-0.57, 1.0) * TEXTURE_PIXEL_SIZE;
        sample_at -= path * (4.5 * sin(feed_phase)) * sheet_mask;
        float ripple = 0.5 + 0.5 * sin(sheet_y * 12.0 - feed_phase);
        light += vec3(0.045, 0.025, 0.012) * sheet_mask * ripple;
        housing = patch(p, vec2(1017.0, 302.0), vec2(128.0, 31.0), 0.12);
    }
    if (p.x > 1190.0 && p.y > 240.0 && p.y < 564.0) {
        float terminal = panel(p, vec2(1325.0, 323.0), vec2(24.0, 15.0), 0.21);
        float scan = 0.5 + 0.5 * cos((p.y - p.x * 0.21) * 0.37 - cycle * TAU * 4.0);
        light += terminal * scan * vec3(0.018, 0.047, 0.044);
        float spill = patch(p, vec2(1281.0, 487.0), vec2(43.0, 66.0), -0.18);
        light += spill * (0.68 + 0.32 * sin(cycle * TAU * 2.0)) * vec3(0.004, 0.026, 0.035);
    }
    light += housing * (0.65 + 0.35 * sin(cycle * TAU * 6.0)) * vec3(0.052, 0.023, 0.006);
    vec4 source = texture(TEXTURE, sample_at);
    if (p.y > 310.0) {
        // Pavement wear is concentrated around equipment and traffic edges.
        // The center field keeps its original contrast and markings.
        float residue = 0.0;
        if (p.x < 590.0) {
            float violet = patch(p, vec2(257.0, 322.0), vec2(108.0, 37.0), -0.26);
            light += violet * vec3(0.025, 0.007, 0.032);
            residue += patch(p, vec2(442.0, 464.0), vec2(130.0, 26.0), -0.13);
            residue += patch(p, vec2(351.0, 755.0), vec2(121.0, 30.0), 0.09);
        }
        if (p.x > 861.0) {
            residue += patch(p, vec2(1018.0, 477.0), vec2(129.0, 28.0), 0.09);
            residue += patch(p, vec2(1034.0, 767.0), vec2(134.0, 25.0), -0.04);
        }
        if (p.y > 750.0 && p.x < 450.0) {
            float scratch = patch(p, vec2(266.0, 822.0), vec2(107.0, 2.0), -0.28)
                + patch(p, vec2(283.0, 828.0), vec2(83.0, 1.6), -0.28);
            light += scratch * vec3(0.044, 0.041, 0.048);
        }
        source.rgb *= 1.0 - 0.24 * residue;
    }
    COLOR = vec4(source.rgb + light, source.a);
}
