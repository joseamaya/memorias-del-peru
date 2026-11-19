extends RefCounted
## Comprueba el reloj de mundo (F1.6).


func test_world_clock_advance() -> bool:
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.real_seconds_per_game_hour = 60.0
	clock.set_time(1, 360.0)
	var ok: bool = clock.get_day() == 1 and clock.get_minute_of_day() == 360
	clock.advance(60.0)
	ok = ok and clock.get_minute_of_day() == 420
	clock.set_time(1, 1430.0)
	clock.advance(20.0)
	ok = ok and clock.get_day() == 2 and clock.get_minute_of_day() == 10
	clock.free()
	return ok


func test_world_clock_pause() -> bool:
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.real_seconds_per_game_hour = 60.0
	clock.set_time(1, 360.0)
	clock.set_paused(true)
	clock.advance(60.0)
	var ok: bool = clock.get_minute_of_day() == 360
	clock.set_paused(false)
	clock.advance(60.0)
	ok = ok and clock.get_minute_of_day() == 420
	clock.free()
	return ok


func test_world_clock_periods() -> bool:
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.set_time(1, 0.0)
	var ok: bool = clock.get_period() == WorldClockService.Period.NIGHT
	clock.set_time(1, 360.0)
	ok = ok and clock.get_period() == WorldClockService.Period.DAWN
	clock.set_time(1, 480.0)
	ok = ok and clock.get_period() == WorldClockService.Period.MORNING
	clock.set_time(1, 720.0)
	ok = ok and clock.get_period() == WorldClockService.Period.MIDDAY
	clock.set_time(1, 900.0)
	ok = ok and clock.get_period() == WorldClockService.Period.AFTERNOON
	clock.set_time(1, 1080.0)
	ok = ok and clock.get_period() == WorldClockService.Period.EVENING
	clock.set_time(1, 1260.0)
	ok = ok and clock.get_period() == WorldClockService.Period.NIGHT
	clock.free()
	return ok


func test_world_clock_round_trip() -> bool:
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.set_time(3, 500.0)
	clock.set_paused(true)
	var data: Dictionary = clock.to_dict()
	var restored: WorldClockService = WorldClockService.new()
	restored.autostart = false
	var ok: bool = restored.from_dict(data)
	ok = ok and restored.get_day() == 3
	ok = ok and restored.get_minute_of_day() == 500
	ok = ok and restored.is_paused()
	ok = ok and not restored.from_dict({"day": "malo", "minute": 0.0})
	clock.free()
	restored.free()
	return ok


func test_world_clock_minutes_until() -> bool:
	var clock: WorldClockService = WorldClockService.new()
	clock.autostart = false
	clock.set_time(1, 360.0)
	var ok: bool = clock.minutes_until(7, 0) == 60
	ok = ok and clock.minutes_until(6, 0) == 0
	ok = ok and clock.minutes_until(5, 0) == 1380
	clock.free()
	return ok
