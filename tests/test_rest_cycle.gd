extends RefCounted
## Comprueba el descanso: la hora de despertar, el salto de día y la aplicación
## al reloj del mundo (F3.7).


func test_rest_wake_minute() -> bool:
	return RestCycle.wake_minute() == RestCycle.WAKE_HOUR * 60 + RestCycle.WAKE_MINUTE


func test_rest_next_morning_before_wake() -> bool:
	# Antes de la hora de despertar, se duerme hasta la misma mañana.
	var next: Vector2i = RestCycle.next_morning(3, 120)
	return next == Vector2i(3, RestCycle.wake_minute())


func test_rest_next_morning_after_wake() -> bool:
	# Después de despertarse, el descanso pasa al día siguiente.
	var next: Vector2i = RestCycle.next_morning(3, 1200)
	return next == Vector2i(4, RestCycle.wake_minute())


func test_rest_next_morning_exact_wake() -> bool:
	# A la hora exacta de despertar se descansa y se salta al día siguiente.
	var next: Vector2i = RestCycle.next_morning(3, RestCycle.wake_minute())
	return next == Vector2i(4, RestCycle.wake_minute())


func test_rest_applies_to_clock() -> bool:
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.set_time(2, 1380.0)
	var rest: Vector2i = RestCycle.apply(clock)
	var ok: bool = rest == Vector2i(3, RestCycle.wake_minute())
	ok = ok and clock.get_day() == 3
	ok = ok and clock.get_minute_of_day() == RestCycle.wake_minute()
	ok = ok and clock.get_period() == WorldClockService.Period.MORNING
	clock.free()
	return ok
