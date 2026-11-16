shader_type spatial;
// Cordilleras con volumen: roca y tono pálido de cumbre por altura, luz
// direccional horneada y bruma de distancia. Sin sombreado en tiempo real: las
// montañas quedan fuera del alcance de las sombras y del GI.
render_mode unshaded, cull_back, fog_disabled, depth_draw_opaque;

// Dirección hacia el sol, en coordenadas de mundo.
uniform vec3 sun_direction = vec3(0.3, 0.8, 0.5);
uniform vec4 rock_color : source_color = vec4(0.30, 0.33, 0.38, 1.0);
uniform vec4 pale_color : source_color = vec4(0.55, 0.54, 0.52, 1.0);
uniform float pale_start = 80.0;
uniform float pale_end = 120.0;
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

float hash2(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash2(i);
	float b = hash2(i + vec2(1.0, 0.0));
	float c = hash2(i + vec2(0.0, 1.0));
	float d = hash2(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 normal = normalize(NORMAL);
	vec3 sun = normalize((VIEW_MATRIX * vec4(sun_direction, 0.0)).xyz);
	float light = clamp(dot(normal, sun), -1.0, 1.0) * 0.5 + 0.5;
	float variation = 0.86 + 0.20 * value_noise(world_pos.xz * 0.045)
		+ 0.06 * value_noise(world_pos.xz * 0.35);
	vec3 rock = rock_color.rgb * variation;
	// Estratos: bandas horizontales suaves que rompen el color plano.
	float strata = value_noise(vec2(world_pos.y * 0.10, (world_pos.x + world_pos.z) * 0.012));
	rock *= 1.0 + strata_strength * (strata - 0.5) * 2.0;
	float pale = smoothstep(pale_start, pale_end, world_pos.y) * pale_strength;
	rock = mix(rock, pale_color.rgb, pale);
	// Nieve por encima de una línea irregular; el ruido evita el corte recto.
	float snow_noise = value_noise(world_pos.xz * 0.03);
	float snow_line = (snow_noise - 0.5) * 12.0;
	float snow = smoothstep(snow_start + snow_line, snow_end + snow_line, world_pos.y)
		* snow_strength;
	rock = mix(rock, snow_color.rgb, snow);
	vec3 lit = rock * mix(vec3(0.62, 0.68, 0.78), vec3(1.12, 1.07, 1.00), light);
	float distance = length(world_pos - CAMERA_POSITION_WORLD);
	float haze = smoothstep(haze_start, haze_end, distance) * haze_strength;
	// La base de la montaña se lava más que la cumbre.
	haze = clamp(haze + (1.0 - smoothstep(-6.0, 55.0, world_pos.y)) * 0.20, 0.0, 1.0);
	ALBEDO = mix(lit, haze_color.rgb, haze);
}
