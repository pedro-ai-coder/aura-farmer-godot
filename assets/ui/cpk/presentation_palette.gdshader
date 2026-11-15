shader_type canvas_item;
// Decorative UI only. Never assign to characters, item icons or world art.
void fragment() {
    vec4 sample_color=texture(TEXTURE,UV)*COLOR;
    vec3 c=sample_color.rgb;
    if(c.r>.67 && c.g>.48 && c.b<.42) c=vec3(1.,.415686,0.);
    else if(c.b>c.r*1.22 && c.g<.48 && c.r<.4) c=vec3(.141176,.129412,.168627);
    else if(c.r>.8 && c.g>.74 && c.b>.58) c=vec3(.952941,.913725,.858824);
    COLOR=vec4(c,sample_color.a);
}
