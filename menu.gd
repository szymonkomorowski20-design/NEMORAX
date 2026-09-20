extends Node2D
## Ekran startowy — rozszerzenie poza dokument bazowy. NIE resetuje GameFlow —
## postęp gauntletu jest zapisywany na dysk (patrz game_flow.gd), więc menu
## musi wznowić dokładnie tam, gdzie gracz skończył, zamiast czyścić postęp
## przy każdym uruchomieniu.

const TEX_BACKGROUND := preload("res://assets/sprites/menu/menu_background.png")
const TEX_LOGO := preload("res://assets/sprites/menu/nemorax_logo.png")
const LOGO_SIZE := Vector2(480.0, 320.0) ## zachowuje proporcje źródłowego pliku 1536x1024

@onready var background: TextureRect = $Background
@onready var logo: TextureRect = $Logo

func _ready() -> void:
	var vp_size := get_viewport_rect().size
	# expand_mode domyślnie każe kontrolce rosnąć do natywnego rozmiaru
	# tekstury (1536x1024) niezależnie od .size — IGNORE_SIZE to wyłącza,
	# inaczej logo/tło wystają poza ekran zamiast trzymać się zadanych wymiarów.
	background.texture = TEX_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.position = Vector2.ZERO
	background.size = vp_size

	logo.texture = TEX_LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_SCALE
	logo.size = LOGO_SIZE
	logo.position = Vector2((vp_size.x - LOGO_SIZE.x) * 0.5, vp_size.y * 0.28)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file(GameFlow.resume_scene_path())

func _draw() -> void:
	var size := get_viewport_rect().size
	var font := ThemeDB.fallback_font
	var prompt := "Naciśnij Spację, aby rozpocząć"
	var prompt_size := font.get_string_size(prompt, HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
	draw_string(font, Vector2((size.x - prompt_size.x) * 0.5, size.y * 0.68), prompt,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.HIT_FLASH)
