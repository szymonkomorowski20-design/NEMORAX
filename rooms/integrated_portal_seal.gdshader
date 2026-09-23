shader_type canvas_item;

uniform float open_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float violet = smoothstep(0.025, 0.16, min(tex.r - tex.g, tex.b - tex.g));
	float closed = 1.0 - open_amount;
	float grey = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	tex.rgb = mix(tex.rgb, vec3(grey * 0.18), violet * closed * 0.94);
	COLOR = tex;
}
