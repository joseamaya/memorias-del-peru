shader_type spatial;
// Nubes altas de la llacta: una cúpula grande dibujada por dentro. El cielo
// físico sigue siendo el fondo; esta capa solo aporta nubes y se descarta bajo
// el horizonte. El ruido es procedural, sin texturas externas.
render_mode unshaded, cull_front, depth_draw_never, blend_mix, fog_disabled, shadows_disabled, ambient_light_disabled;

uniform vec4 cloud_light : source_color = vec4(1.0, 0.97, 0.92, 1.0);
uniform vec4 cloud_shadow : source_color = vec4(0.52, 0.58, 0.66, 1.0);
uniform float coverage : hint_range(0.0, 1.0) = 0.38;
uniform float edge_softness : hint_range(0.01, 0.5) = 0.24;
uniform float cloud_scale : hint_range(0.5, 12.0) = 2.4;
uniform float wind_speed : hint_range(0.0, 0.1) = 0.004;
uniform float opacity : hint_range(0.0, 1.0) = 0.62;
// La UV de la esfera puede venir con el polo norte en 0 o en 1; este valor
// deja elegir la mitad superior sin tocar el resto del shader.
uniform bool flip_horizon = false;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 5; i++) {
		value += amplitude * value_noise(p);
		p *= 2.03;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	float v = flip_horizon ? 1.0 - UV.y : UV.y;
	float up = 1.0 - abs(v - 0.5) * 2.0;
	float horizon = smoothstep(0.10, 0.38, up);
	vec2 p = vec2(UV.x * 6.0, v * 3.0);
	float n = fbm(p * cloud_scale + vec2(TIME * wind_speed, 0.0));
	// Detalle fino en el borde: rompe el contorno de las nubes grandes sin
	// añadir otra capa completa de fbm.
	float detail = value_noise(p * cloud_scale * 7.0 + vec2(TIME * wind_speed * 3.0, 0.0));
	float shape = n + (detail - 0.5) * 0.12;
	float mask = smoothstep(coverage, coverage + edge_softness, shape) * horizon;
	float light = smoothstep(0.42, 0.88, n);
	ALBEDO = mix(cloud_shadow.rgb, cloud_light.rgb, light);
	ALPHA = mask * opacity;
}
