// Mancha de contacto bajo un personaje u objeto apoyado.
// Quad horizontal con degradado radial suave. Sin luz ni sombra propia.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.55);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.12;
uniform float outer_radius : hint_range(0.01, 1.0) = 1.0;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float fade = 1.0 - smoothstep(inner_radius, outer_radius, r);
	ALBEDO = shadow_color.rgb;
	ALPHA = shadow_color.a * fade;
}
