shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
// Llama estilizada para el fuego comunal. No usa textura: dibuja la silueta
// con UV y la anima con TIME. Es autoría propia y sustituye el cono plano.

uniform vec4 core_color : source_color = vec4(1.0, 0.86, 0.42, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.30, 0.06, 1.0);
uniform float intensity = 1.5;

void vertex() {
	// Billboarding: la llama mira siempre a la cámara.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]);
}

void fragment() {
	// QuadMesh trae la UV con el origen arriba; se invierte para que la base
	// de la llama quede en y = 0.
	float y = 1.0 - UV.y;
	float x = (UV.x - 0.5) * 2.0;
	float sway = sin(TIME * 2.6 + y * 7.0) * 0.07 * y;
	float taper = 1.0 - smoothstep(0.15, 1.0, y) * 0.82;
	float width = 0.62 * taper;
	float body = 1.0 - smoothstep(width * 0.35, width, abs(x + sway));
	float base = smoothstep(0.0, 0.08, y);
	float tip = 1.0 - smoothstep(0.62, 1.0, y);
	float flicker = 0.9 + 0.1 * sin(TIME * 9.0 + y * 5.0);
	float flame = body * base * tip * flicker;
	vec3 color = mix(edge_color.rgb, core_color.rgb,
		smoothstep(0.15, 0.75, flame));
	ALBEDO = color * intensity;
	ALPHA = flame;
}
