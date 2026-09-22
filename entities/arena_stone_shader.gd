class_name ArenaStoneShader
extends RefCounted
## Priorytet 1 (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): "jasna szara podłoga
## z fioletowymi pęknięciami wygląda jak osobna arena sci-fi, nie jak
## kulminacja świata NEMORAXA... zachować tylko przygaszony fiolet jako akcent
## otchłani, bez jasnej futurystycznej siatki pęknięć... spokojniejszy środek,
## pęknięcia i detale odsunięte ku krawędziom".
##
## Bez nowej grafiki: FLOOR_TEXTURE (altar_floor.png, placeholder używany
## dotąd w arena.gd) ma jasnoszary kamień z siecią pęknięć w KAŻDYM z kilku
## kolorów (czerwony/pomarańcz/niebieski/fiolet) — dokładnie to, co dokument
## każe naprawić. Zamiast prosić o kolejną turę grafiki (nemorax_arena_floor.png
## w folderze grafik ma ten sam problem, tylko z pęknięciami zbiegającymi się
## do ŚRODKA zamiast do krawędzi — odwrotnie niż chce dokument), przerabia się
## to shaderem: (1) ciemna, obsydianowo-fioletowa baza zamiast jasnego szarego
## kamienia, (2) WSZYSTKIE kolorowe pęknięcia (wysoka saturacja pikseli)
## przemalowane na JEDEN przygaszony fiolet, (3) winieta w lokalnej przestrzeni
## sprite'a (VERTEX, nie UV — UV tutaj się kafelkuje przez texture_repeat,
## więc nie nadaje się do liczenia odległości od środka areny, patrz ten sam
## trik w entities/vision_overlay.gd) przyciemniająca poświatę pęknięć bliżej
## środka areny, zostawiając ją czytelną bliżej krawędzi/ścian.

const SHADER_CODE := """
shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.11, 0.08, 0.16, 1.0);
uniform vec4 accent_color : source_color = vec4(0.40, 0.24, 0.60, 1.0);
uniform vec2 center_local;
uniform float vignette_radius = 320.0;
uniform float vignette_softness = 220.0;
uniform float calm_center_glow = 0.16;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float luminance = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	float saturation = max(tex.r, max(tex.g, tex.b)) - min(tex.r, min(tex.g, tex.b));
	float is_crack = smoothstep(0.10, 0.32, saturation);

	vec3 base = mix(tex.rgb * 0.32, tint_color.rgb, 0.68);
	vec3 crack_color = accent_color.rgb * clamp(luminance * 1.5, 0.0, 1.0);
	vec3 with_cracks = mix(base, crack_color, is_crack);

	float dist = distance(local_pos, center_local);
	float glow_mask = smoothstep(vignette_radius - vignette_softness, vignette_radius, dist);
	vec3 result = mix(base, with_cracks, mix(calm_center_glow, 1.0, glow_mask));

	COLOR = vec4(result, tex.a);
}
"""

## `rect` to ARENA_RECT (świat) — środek liczony WZGLĘDEM sprite'a podłogi
## (Walls.build_floor ustawia sprite.position = rect.position, centered=false),
## więc lokalny środek to po prostu połowa rozmiaru, nie środek w świecie.
static func build_floor_material(rect: Rect2) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = SHADER_CODE
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("center_local", rect.size * 0.5)
	mat.set_shader_parameter("vignette_radius", min(rect.size.x, rect.size.y) * 0.55)
	mat.set_shader_parameter("vignette_softness", min(rect.size.x, rect.size.y) * 0.38)
	return mat
