shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(0.42, 0.03, 0.02, 1.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float distance = length(uv * vec2(1.0, 1.25));
	float edge = smoothstep(0.30, 0.80, distance);
	COLOR = vec4(tint.rgb, edge * strength);
}
