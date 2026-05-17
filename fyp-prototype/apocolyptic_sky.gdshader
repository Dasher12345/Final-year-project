shader_type spatial;

render_mode unshaded, blend_mix, cull_disabled;

uniform sampler2D cloud_tex;
uniform sampler2D detail_tex;

uniform vec2 speed_main = vec2(0.005, 0.002);
uniform vec2 speed_detail = vec2(-0.01, 0.004);

uniform float scale_main = 2.0;
uniform float scale_detail = 6.0;

void fragment() {

    // 🌤 main layer
    vec2 uv = UV * scale_main;
    uv += speed_main * TIME;

    float cloud = texture(cloud_tex, uv).r;

    // 🌫 detail layer
    vec2 uv2 = UV * scale_detail;
    uv2 += speed_detail * TIME;

    float detail = texture(detail_tex, uv2).r;

    // combine
    float c = mix(cloud, detail, 0.5);

    // shape clouds (safe range)
    c = smoothstep(0.25, 0.75, c);

    // prevent full disappearance
    c = max(c, 0.15);

    ALBEDO = vec3(0.02);
    ALPHA = c;
}