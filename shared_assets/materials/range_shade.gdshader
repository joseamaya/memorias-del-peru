shader_type spatial;
// Cordilleras con volumen: roca y nieve por altura, luz direccional horneada y
// bruma de distancia. El detalle de roca se calcula por vértice (una variación
// suave) para no pagar ruido en cada píxel: las montañas cubren mucha pantalla
// y el Cusco tiene poco margen de FPS.
render_mode unshaded, cull_back, fog_disabled, depth_draw_opaque;

// Dirección hacia el sol, en coordenadas de mundo.
uniform vec3 sun_direction = vec3(0.3, 0.8, 0.5);
uniform vec4 rock_color : source_color = vec4(0.35, 0.38, 0.43, 1.0);
uniform vec4 pale_color : source_color = vec4(0.55, 0.54, 0.52, 1.0);
uniform float pale_start = 45.0;
uniform float pale_end = 100.0;
uniform float pale_strength : hint_range(0.0, 0.5) = 0.08;
uniform vec4 snow_color : source_color = vec4(0.88, 0.89, 0.90, 1.0);
uniform float snow_start = 999.0;
uniform float snow_end = 999.0;
uniform float snow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float strata_strength : hint_range(0.0, 0.4) = 0.10;
uniform vec4 haze_color : source_color = vec4(0.58, 0.65, 0.73, 1.0);
uniform float haze_start = 130.0;
uniform float haze_end = 520.0;
uniform float haze_strength : hint_range(0.0, 1.0) = 0.30;

varying vec3 world_pos;
varying float vertex_detail;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	// Variación suave por vértice: dos senos baratos en lugar de ruido de valor.
	vertex_detail = 0.5 + 0.5 * sin(VERTEX.x * 0.045 + sin(VERTEX.z * 0.037) * 2.0);
}

void fragment() {
	vec3 normal = normalize(NORMAL);
	vec3 sun = normalize((VIEW_MATRIX * vec4(sun_direction, 0.0)).xyz);
	float light = clamp(dot(normal, sun), -1.0, 1.0) * 0.5 + 0.5;
	float variation = 0.86 + 0.20 * vertex_detail;
	vec3 rock = rock_color.rgb * variation;
	// Estratos: bandas horizontales suaves que rompen el color plano.
	float strata = sin(world_pos.y * 0.28 + (world_pos.x + world_pos.z) * 0.012);
	rock *= 1.0 + strata_strength * strata;
	float pale = smoothstep(pale_start, pale_end, world_pos.y) * pale_strength;
	rock = mix(rock, pale_color.rgb, pale);
	// Nieve por encima de una línea irregular; el seno evita el corte recto.
	if (snow_strength > 0.001) {
		float snow_line = sin(world_pos.x * 0.05 + world_pos.z * 0.031) * 6.0;
		float snow = smoothstep(snow_start + snow_line, snow_end + snow_line, world_pos.y)
			* snow_strength;
		rock = mix(rock, snow_color.rgb, snow);
	}
	vec3 lit = rock * mix(vec3(0.62, 0.68, 0.78), vec3(1.12, 1.07, 1.00), light);
	float distance = length(world_pos - CAMERA_POSITION_WORLD);
	float haze = smoothstep(haze_start, haze_end, distance) * haze_strength;
	// La base de la montaña se lava más que la cumbre.
	haze = clamp(haze + (1.0 - smoothstep(-6.0, 55.0, world_pos.y)) * 0.20, 0.0, 1.0);
	ALBEDO = mix(lit, haze_color.rgb, haze);
}
