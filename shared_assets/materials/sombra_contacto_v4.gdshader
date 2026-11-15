shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float fade = 1.0 - smoothstep(0.12, 1.0, r);
	ALBEDO = vec3(0.0);
	ALPHA = fade * 0.55;
}
