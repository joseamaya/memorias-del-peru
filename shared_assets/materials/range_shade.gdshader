shader_type spatial;
// Cordilleras lejanas: un degradado suave de la base a la cresta da volumen a
// la silueta sin convertir cada capa en una franja plana. La base es más
// oscura (sombra de ladera) y la cresta conserva el color de la roca.
render_mode unshaded, cull_disabled, fog_disabled, depth_draw_opaque;

uniform vec4 ridge_color : source_color = vec4(0.30, 0.34, 0.41, 1.0);
// Cuánto se oscurece la base respecto a la cresta (0 = nada, 1 = negro).
uniform float base_darkness : hint_range(0.0, 0.6) = 0.18;
// Altura de la cresta de esta cordillera, en metros.
uniform float top_height = 62.0;

varying float height_ratio;

void vertex() {
	height_ratio = clamp(VERTEX.y / max(top_height, 1.0), 0.0, 1.0);
}

void fragment() {
	vec3 base_color = ridge_color.rgb * (1.0 - base_darkness);
	ALBEDO = mix(base_color, ridge_color.rgb, smoothstep(0.05, 0.85, height_ratio));
}
