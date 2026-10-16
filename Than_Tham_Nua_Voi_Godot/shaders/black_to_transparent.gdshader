shader_type canvas_item;

uniform float threshold : hint_range(0.0, 0.2) = 0.04;
uniform float softness : hint_range(0.0, 0.2) = 0.05;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float max_c = max(tex.r, max(tex.g, tex.b));
	float a = smoothstep(threshold, threshold + softness, max_c);
	COLOR = vec4(tex.rgb * tint.rgb, tex.a * a * tint.a * COLOR.a);
}
