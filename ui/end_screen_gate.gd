extends RefCounted
class_name EndScreenGate
## Drugi audyt (C4): ekrany śmierci/zwycięstwa przyjmowały klawisze w tej samej
## klatce, w której się pojawiły. Enter pomijający ostatni dialog epilogu od razu
## startował nową próbę, a S — też klawisz ruchu w dół — był sprawdzany jako
## TRZYMANY: gracz idący w dół w chwili śmierci/zwycięstwa natychmiast
## restartował próbę bez zobaczenia podsumowania. Bramka: krótkie odczekanie na
## przeczytanie wyniku, a S dopiero po puszczeniu klawisza od chwili pokazania.

const ARM_DELAY := 1.2 ## s, zanim ekran końca przyjmie jakikolwiek wybór

var _ready_at_msec: int = 0
var _s_released: bool = false

func arm() -> void:
	_ready_at_msec = Time.get_ticks_msec() + int(ARM_DELAY * 1000.0)
	_s_released = not Input.is_physical_key_pressed(KEY_S)

func is_ready() -> bool:
	return Time.get_ticks_msec() >= _ready_at_msec

func accept_pressed() -> bool:
	return is_ready() and Input.is_action_just_pressed("ui_accept")

func cancel_pressed() -> bool:
	return is_ready() and Input.is_action_just_pressed("ui_cancel")

## S = ta sama próba (to samo ziarno) — tylko świeże wciśnięcie.
func same_seed_pressed() -> bool:
	var down := Input.is_physical_key_pressed(KEY_S)
	if not down:
		_s_released = true
		return false
	return is_ready() and _s_released
