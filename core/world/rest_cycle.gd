class_name RestCycle
extends RefCounted
## Descanso: lleva el reloj del mundo a la mañana siguiente.
##
## Es una utilidad de Core y no guarda nada: quién descansa, qué se guarda y
## qué se muestra lo decide el sistema que la llama.

## Se despierta a la misma hora con la que empieza la partida: a las 7:00 el
## ciclo todavía deja la ciudad en penumbra y parece de noche.
const WAKE_HOUR: int = 8
const WAKE_MINUTE: int = 0


## Minuto del día al que se despierta.
static func wake_minute() -> int:
	return WAKE_HOUR * 60 + WAKE_MINUTE


## Día y minuto de la mañana siguiente. Si aún no se ha llegado a la hora de
## despertar, se despierta el mismo día.
static func next_morning(day: int, minute: int) -> Vector2i:
	var wake: int = wake_minute()
	if minute < wake:
		return Vector2i(maxi(day, 1), wake)
	return Vector2i(maxi(day, 1) + 1, wake)


## Aplica el descanso al reloj. Devuelve el día y el minuto resultantes, o
## `Vector2i.ZERO` si no hay reloj.
static func apply(clock: WorldClockService) -> Vector2i:
	if clock == null:
		return Vector2i.ZERO
	var next: Vector2i = next_morning(clock.get_day(), clock.get_minute_of_day())
	clock.set_time(next.x, float(next.y))
	return next
