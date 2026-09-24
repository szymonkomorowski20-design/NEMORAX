shader_type canvas_item;
// Audyt nagrania 24.09 (P0.1): ciemna sylwetka gracza ginie na ciemnej
// podłodze i na ciele dużego wroga. Cienki obrys po krawędzi alfy (stały,
// subtelny) + krótkie podbicie jasności przy nakładaniu na dużego wroga.
// Obrys leży POZA sylwetką — nie zmienia jej rysunku ani hitboxa.

uniform vec4 outline_color : source_color = vec4(0.62, 0.86, 0.82, 1.0);
uniform float outline_texels = 16.0; // grubość w tekselach tekstury (sprite_scale 0.10 → ~1,6 px)
uniform float outline_strength : hint_range(0.0, 1.0) = 0.35;
uniform float lift : hint_range(0.0, 0.6) = 0.0; // rozjaśnienie cieni sylwetki

varying vec4 vertex_modulate;

void vertex() {
	vertex_modulate = COLOR; // modulate węzła (mruganie nietykalności itd.) — w fragment() COLOR ma już w sobie teksturę
}

void fragment() {
	vec4 base = vertex_modulate;
	vec4 c = texture(TEXTURE, UV);
	vec2 step_uv = TEXTURE_PIXEL_SIZE * outline_texels;
	float around = 0.0;
	for (int i = 0; i < 12; i++) {
		float ang = float(i) * 0.52359878;
		around = max(around, texture(TEXTURE, UV + vec2(cos(ang), sin(ang)) * step_uv).a);
	}
	c.rgb = c.rgb * (1.0 + lift) + vec3(0.06) * lift;
	float edge = clamp(around - c.a, 0.0, 1.0) * outline_strength;
	vec4 result;
	result.a = max(c.a, edge);
	result.rgb = result.a > 0.0 ? (c.rgb * c.a + outline_color.rgb * edge * (1.0 - c.a)) / result.a : c.rgb;
	COLOR = result * base;
}
