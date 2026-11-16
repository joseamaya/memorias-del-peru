shader_type spatial;
// Nubes altas: una cúpula grande dibujada por dentro. El cielo físico sigue
// siendo el fondo; esta capa solo aporta nubes y se descarta bajo el horizonte.
// El ruido es procedural, sin texturas externas.
//
// El muestreo es por dirección de mundo, no por UV: la UV de la esfera
// envuelve en un meridiano y dejaba una costura vertical visible en el cielo.
// Con la dirección del rayo desde la cámara el patrón es continuo en toda la
// cúpula y además no se estira en los polos.
render_mode unshaded, cull_front, depth_draw_never, blend_mix, fog_disabled, shadows_disabled, ambient_light_disabled;

uniform vec4 cloud_light : source_color = vec4(0.97, 0.96, 0.94, 1.0);
uniform vec4 cloud_shadow : source_color = vec4(0.60, 0.65, 0.72, 1.0);
uniform float coverage : hint_range(0.0, 1.0) = 0.50;
uniform float edge_softness : hint_range(0.01, 0.6) = 0.40;
uniform float cloud_scale : hint_range(0.5, 12.0) = 1.7;
uniform float wind_speed : hint_range(0.0, 0.1) = 0.003;
uniform float opacity : hint_range(0.0, 1.0) = 0.38;
// Invierte la mitad de la cúpula que se pinta, por si la esfera cambia de
// orientación.
uniform bool flip_horizon = false;

float hash13(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

float value_noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float n000 = hash13(i);
	float n100 = hash13(i + vec3(1.0, 0.0, 0.0));
	float n010 = hash13(i + vec3(0.0, 1.0, 0.0));
	float n110 = hash13(i + vec3(1.0, 1.0, 0.0));
	float n001 = hash13(i + vec3(0.0, 0.0, 1.0));
	float n101 = hash13(i + vec3(1.0, 0.0, 1.0));
	float n011 = hash13(i + vec3(0.0, 1.0, 1.0));
	float n111 = hash13(i + vec3(1.0, 1.0, 1.0));
	return mix(
		mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
		mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y),
		f.z);
}

float fbm(vec3 p) {
	// Tres octavas bastan para nubes altas: la quinta solo añadía grano que se
	// pierde a la distancia de la cúpula y encarecía todo el cielo.
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 3; i++) {
		value += amplitude * value_noise(p);
		p *= 2.03;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 dir = normalize(world - CAMERA_POSITION_WORLD);
	float up = flip_horizon ? -dir.y : dir.y;
	// Las nubes solo viven por encima de las crestas: si empiezan antes, se
	// cortan contra las montañas y parecen jirones pegados al cielo.
	float horizon = smoothstep(0.30, 0.70, up);
	vec3 p = dir * cloud_scale * 2.0;
	p.x += TIME * wind_speed * 12.0;
	p.z += TIME * wind_speed * 4.0;
	float n = fbm(p);
	// Detalle fino en el borde: rompe el contorno de las nubes grandes sin
	// añadir otra capa completa de fbm.
	float detail = value_noise(p * 7.0 + vec3(TIME * wind_speed * 30.0, 0.0, 0.0));
	float shape = n + (detail - 0.5) * 0.05;
	float mask = smoothstep(coverage, coverage + edge_softness, shape) * horizon;
	// Funde también el borde interior: sin esto la nube conserva un contorno
	// de recorte duro cuando el ruido baja de golpe.
	mask *= smoothstep(0.0, 0.30, shape);
	float light = smoothstep(0.36, 0.86, n);
	ALBEDO = mix(cloud_shadow.rgb, cloud_light.rgb, light);
	ALPHA = mask * opacity;
}
