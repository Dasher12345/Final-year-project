shader_type canvas_item;

uniform float radius = 0.25;     // corner roundness
uniform float softness = 0.08;   // edge fade softness
uniform float shadow_strength = 0.35;

void fragment() {
    vec2 uv = UV;

    // distance from edges
    vec2 d = min(uv, 1.0 - uv);
    float edge = min(d.x, d.y);

    // rounded alpha mask (soft corners)
    float alpha_mask = smoothstep(0.0, softness, edge - radius);

    vec4 col = texture(TEXTURE, UV);

    // fake "shadow at edges" (darken + fade)
    float shadow = smoothstep(radius + 0.15, radius, edge);
    col.rgb *= (1.0 - shadow * shadow_strength);

    col.a *= alpha_mask;

    COLOR = col;
}