// Superficie con texturas de detalle en proyección triplanar (alcance §6.2).
//
// Las texturas viven en dos Texture2DArray (shared_assets/textures): detalle de
// color relativo a su media (×0,5) con la rugosidad en alfa, y normales en
// convención OpenGL. El color final es el color por vértice (o el tinte)
// multiplicado por el detalle, así que la paleta de cada modelo se conserva.
//
// Capa elegida por:
// - fixed_layer >= 0: una capa fija (terreno, muros, cajas).
// - fixed_layer < 0: la clase de superficie del modelo, guardada en UV.x por el
//   generador de Blender (capa + 1; 0 = sin textura).
// El terreno añade una capa de pendiente (steep_layer) y otra superpuesta en
// rectángulos con borde irregular (overlay_layer: plaza y caminos).
// La vegetación se mece con el viento (wind_bend > 0): el desplazamiento crece
// con el cuadrado de la altura, así que la base de la mata o el tronco no se
// mueve.
shader_type spatial;

uniform sampler2DArray detail_array : filter_linear_mipmap, repeat_enable;
uniform sampler2DArray normal_array : filter_linear_mipmap, repeat_enable;

// Repeticiones por metro de cada capa del array.
uniform float layer_scale[9];
uniform int fixed_layer = -1;
uniform bool use_vertex_color = true;
// Proyección en coordenadas del mundo (piezas fijas sin girar: terreno, muros)
// en lugar de las del objeto (modelos que se mueven o giran).
uniform bool world_projection = false;
// Los tintes se dan en sRGB, como la paleta de los modelos.
uniform vec4 tint : source_color = vec4(1.0);
uniform float detail_strength : hint_range(0.0, 1.0) = 1.0;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
// Distancia a la cámara a partir de la cual no se leen los mapas de normales
// (su relieve ya no se distingue y ahorra la mitad de las lecturas).
uniform float normal_distance = 35.0;
uniform float plain_roughness : hint_range(0.0, 1.0) = 0.9;
// Rugosidad mínima: tierra, piedra y paja secas de la sierra, sin brillo de
// superficie mojada.
uniform float roughness_floor : hint_range(0.0, 1.0) = 0.78;
// Variación de brillo a gran escala para disimular la repetición.
uniform float macro_strength : hint_range(0.0, 1.0) = 0.0;
uniform float macro_scale = 0.11;

uniform int steep_layer = -1;
uniform vec4 steep_tint : source_color = vec4(1.0);
// Pendiente (normal.y) donde empieza y donde es total la capa de pendiente.
uniform vec2 steep_normal_range = vec2(0.85, 0.65);
// Altura donde empieza y donde es total, aunque no haya pendiente.
uniform vec2 steep_height_range = vec2(1.0, 4.0);

// Viento: flexión por metro² de altura, dirección en planta y ráfaga (0–1)
// que el juego actualiza cada fotograma.
uniform float wind_bend = 0.0;
uniform vec2 wind_direction = vec2(0.8, -0.6);
uniform float wind_gust = 0.0;

uniform int overlay_layer = -1;
uniform vec4 overlay_tint : source_color = vec4(1.0);
// Rectángulos (centro x, centro z, medio ancho x, medio ancho z).
uniform vec4 overlay_rects[8];
uniform int overlay_rect_count = 0;
uniform float overlay_fade = 1.6;

varying vec3 tri_pos;
varying vec3 tri_weights;
varying vec3 world_pos;
varying flat int base_layer;

void vertex() {
	if (wind_bend > 0.0) {
		vec3 origin = MODEL_MATRIX[3].xyz;
		float height = max(VERTEX.y, 0.0);
		// Cada planta oscila con su propia fase; la ráfaga la empuja a favor del
		// viento y acelera el temblor.
		float phase = dot(origin.xz, vec2(0.37, 0.61));
		float sway = sin(TIME * (1.3 + wind_gust) + phase) * 0.55 + sin(TIME * 3.1 + phase * 1.7) * 0.15;
		float bend = wind_bend * height * height * (0.35 + wind_gust * 0.9 + sway);
		vec3 world_offset = vec3(wind_direction.x, 0.0, wind_direction.y) * bend;
		// De mundo a objeto (las plantas solo giran y escalan).
		VERTEX += (vec4(world_offset, 0.0) * MODEL_MATRIX).xyz / max(dot(MODEL_MATRIX[0].xyz, MODEL_MATRIX[0].xyz), 0.0001);
	}
	vec3 n = NORMAL;
	// Base tangente aproximada para cada eje de proyección (como el modo
	// triplanar de StandardMaterial3D).
	TANGENT = normalize(vec3(0.0, 0.0, -1.0) * abs(n.x) + vec3(1.0, 0.0, 0.0) * abs(n.y) + vec3(1.0, 0.0, 0.0) * abs(n.z));
	BINORMAL = normalize(vec3(0.0, 1.0, 0.0) * abs(n.x) + vec3(0.0, 0.0, -1.0) * abs(n.y) + vec3(0.0, 1.0, 0.0) * abs(n.z));
	vec3 weights = pow(abs(n), vec3(4.0));
	tri_weights = weights / max(dot(weights, vec3(1.0)), 0.0001);
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	tri_pos = (world_projection ? world_pos : VERTEX) * vec3(1.0, -1.0, 1.0);
	base_layer = fixed_layer >= 0 ? fixed_layer : int(UV.x + 0.5) - 1;
}

// Los planos con peso casi nulo no se muestrean: en el suelo llano y en los
// muros rectos basta una lectura en lugar de tres. Los pesos que quedan se
// renormalizan para no oscurecer la mezcla.
vec4 triplanar(sampler2DArray tex, vec3 pos, vec3 weights, float layer) {
	vec3 used = step(vec3(0.02), weights) * weights;
	used /= max(dot(used, vec3(1.0)), 0.0001);
	vec4 sampled = vec4(0.0);
	if (used.z > 0.0) {
		sampled += texture(tex, vec3(pos.xy, layer)) * used.z;
	}
	if (used.y > 0.0) {
		sampled += texture(tex, vec3(pos.xz, layer)) * used.y;
	}
	if (used.x > 0.0) {
		sampled += texture(tex, vec3(pos.zy * vec2(-1.0, 1.0), layer)) * used.x;
	}
	return sampled;
}

float rect_mask(vec2 p, vec4 rect, float fade) {
	vec2 outside = max(abs(p - rect.xy) - rect.zw, vec2(0.0));
	return 1.0 - smoothstep(0.0, fade, length(outside));
}

void fragment() {
	vec3 base_color = use_vertex_color ? COLOR.rgb * tint.rgb : tint.rgb;
	if (base_layer < 0 && steep_layer < 0 && overlay_layer < 0) {
		ALBEDO = base_color;
		ROUGHNESS = plain_roughness;
	} else {
		vec3 albedo = base_color;
		float roughness = plain_roughness;
		vec3 normal_map = vec3(0.5, 0.5, 1.0);
		float normal_fade = 1.0 - smoothstep(normal_distance * 0.7, normal_distance, length(VERTEX));
		bool near = normal_fade > 0.0;
		if (base_layer >= 0) {
			vec3 p = tri_pos * layer_scale[base_layer];
			vec4 detail = triplanar(detail_array, p, tri_weights, float(base_layer));
			albedo = base_color * mix(vec3(1.0), detail.rgb * 2.0, detail_strength);
			roughness = detail.a;
			if (near) {
				normal_map = triplanar(normal_array, p, tri_weights, float(base_layer)).rgb;
			}
		}
		if (steep_layer >= 0) {
			float upness = normalize(mat3(INV_VIEW_MATRIX) * NORMAL).y;
			float steep = smoothstep(steep_normal_range.x, steep_normal_range.y, upness);
			steep = max(steep, smoothstep(steep_height_range.x, steep_height_range.y, world_pos.y));
			if (steep > 0.001) {
				vec3 p = tri_pos * layer_scale[steep_layer];
				vec4 detail = triplanar(detail_array, p, tri_weights, float(steep_layer));
				vec3 rock = steep_tint.rgb * mix(vec3(1.0), detail.rgb * 2.0, detail_strength);
				albedo = mix(albedo, rock, steep);
				roughness = mix(roughness, detail.a, steep);
				if (near) {
					normal_map = mix(normal_map, triplanar(normal_array, p, tri_weights, float(steep_layer)).rgb, steep);
				}
			}
		}
		float macro = 1.0;
		if (macro_strength > 0.0 && base_layer >= 0) {
			vec3 macro_detail = triplanar(detail_array, tri_pos * macro_scale, tri_weights, float(base_layer)).rgb * 2.0;
			macro = dot(macro_detail, vec3(0.333));
		}
		if (overlay_layer >= 0 && overlay_rect_count > 0) {
			float cover = 0.0;
			for (int i = 0; i < overlay_rect_count; i++) {
				cover = max(cover, rect_mask(world_pos.xz, overlay_rects[i], overlay_fade));
			}
			// Borde irregular: la variación grande come o adelanta la tierra.
			cover = smoothstep(0.35, 0.65, cover + (macro - 1.0) * 0.8);
			if (cover > 0.001) {
				vec3 p = tri_pos * layer_scale[overlay_layer];
				vec4 detail = triplanar(detail_array, p, tri_weights, float(overlay_layer));
				vec3 dirt = overlay_tint.rgb * mix(vec3(1.0), detail.rgb * 2.0, detail_strength);
				albedo = mix(albedo, dirt, cover);
				roughness = mix(roughness, detail.a, cover);
				if (near) {
					normal_map = mix(normal_map, triplanar(normal_array, p, tri_weights, float(overlay_layer)).rgb, cover);
				}
			}
		}
		ALBEDO = albedo * mix(1.0, macro, macro_strength);
		ROUGHNESS = max(roughness, roughness_floor);
		NORMAL_MAP = normal_map;
		NORMAL_MAP_DEPTH = normal_strength * normal_fade;
	}
}
