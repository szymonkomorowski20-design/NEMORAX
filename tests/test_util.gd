class_name NemoraxTest
extends RefCounted
## Malutki zamiennik asercji zamiast wciągania GUT — projekt celowo trzyma się
## czystego GDScript bez zależności zewnętrznych (patrz README). GDScript nie
## ma wyjątków, więc zamiast try/except na niepowodzenie testu używamy flagi
## last_failed, resetowanej przed KAŻDYM testem przez test_runner.gd.

static var last_failed: bool = false

static func reset() -> void:
	last_failed = false

static func assert_true(condition: bool, msg: String) -> void:
	if not condition:
		last_failed = true
		push_error("assert_true nie powiodło się: %s" % msg)

static func assert_eq(actual, expected, msg: String) -> void:
	if actual != expected:
		last_failed = true
		push_error("assert_eq nie powiodło się (%s): oczekiwano %s, jest %s" % [msg, expected, actual])

static func assert_almost_eq(actual: float, expected: float, tolerance: float, msg: String) -> void:
	if absf(actual - expected) > tolerance:
		last_failed = true
		push_error("assert_almost_eq nie powiodło się (%s): oczekiwano ~%s (tolerancja %s), jest %s" % [msg, expected, tolerance, actual])
