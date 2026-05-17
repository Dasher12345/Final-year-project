shader_type spatial;

render_mode unshaded, cull_back, depth_draw_never;

uniform vec4 bg_color : source_color = vec4(0.01, 0.02, 0.05, 1.0);
uniform vec4 line_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);

uniform float grid_scale = 10.0;
uniform float line_thickness = 1.0;
uniform float glow_strength = 2.5;

float grid(vec2 p) {
	vec2 f = fract(p);
	vec2 dist = abs(f - 0.5);

	vec2 fw = fwidth(p) * line_thickness;

	vec2 line = smoothstep(fw, vec2(0.0), dist);

	return max(line.x, line.y);
}

void fragment() {

	// ✅ use plane coordinates only
	vec2 pos = UV * grid_scale;

	float g = grid(pos);

	// soften lines
	g = smoothstep(0.0, 1.0, g);

	vec3 col = bg_color.rgb + line_color.rgb * g;

	ALBEDO = col;
	EMISSION = line_color.rgb * g * glow_strength;
}