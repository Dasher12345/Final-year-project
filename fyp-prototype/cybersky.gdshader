shader_type spatial;

render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec4 bg_color : source_color = vec4(0.01, 0.02, 0.05, 1.0);
uniform vec4 line_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);

uniform float grid_scale = 5.0;
uniform float line_thickness = 1.2;
uniform float glow_strength = 2.5;

varying vec3 local_pos;

float grid(vec2 p) {
	vec2 f = fract(p);
	vec2 dist = abs(f - 0.5);

	vec2 fw = fwidth(p) * line_thickness;

	vec2 line = smoothstep(fw, vec2(0.0), dist);

	return max(line.x, line.y);
}

void vertex() {
	local_pos = VERTEX;
}

void fragment() {

	vec3 pos = local_pos * grid_scale;

	float gx = grid(pos.xy);
	float gy = grid(pos.yz);
	float gz = grid(pos.xz);

	float g = max(gx, max(gy, gz));

	// softer falloff (important for subtle glow)
	g = smoothstep(0.0, 1.0, g);

	vec3 base = bg_color.rgb;

	// VERY IMPORTANT: keep base visible
	vec3 col = base + line_color.rgb * g * 0.6;

	ALBEDO = col;

	// small emission boost (subtle glow)
	EMISSION = line_color.rgb * g * glow_strength;
}