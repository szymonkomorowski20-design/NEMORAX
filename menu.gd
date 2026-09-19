extends Node2D
## Ekran startowy — rozszerzenie poza dokument bazowy. NIE resetuje GameFlow —
## postęp gauntletu jest zapisywany na dysk (patrz game_flow.gd), więc menu
## musi wznowić dokładnie tam, gdzie gracz skończył, zamiast czyścić postęp
## przy każdym uruchomieniu.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file(GameFlow.resume_scene_path())

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Palette.BACKGROUND, true)

	var font := ThemeDB.fallback_font
	var title := "NEMORAX"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 64)
	draw_string(font, Vector2((size.x - title_size.x) * 0.5, size.y * 0.4), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 64, Palette.PLAYER_BODY)

	var prompt := "Naciśnij Spację, aby rozpocząć"
	var prompt_size := font.get_string_size(prompt, HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
	draw_string(font, Vector2((size.x - prompt_size.x) * 0.5, size.y * 0.4 + 50.0), prompt,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.HIT_FLASH)
