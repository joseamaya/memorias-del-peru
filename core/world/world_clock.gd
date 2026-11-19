class_name WorldClockService
extends Node
## Reloj de mundo: día, hora y franja.
##
## Es un sistema de Core: no conoce campañas. Avanza en `_process`, se puede
## pausar y se serializa para el guardado. Las franjas se usan para horarios de
## NPC, luz y eventos; la escala por defecto hace un día de juego en 48 minutos
## reales (1 hora de juego = 2 minutos reales).
##
## Las pruebas pueden instanciarlo directamente, poner `autostart = false` y
## llamar a `advance()` sin depender de fotogramas.

signal time_changed(day: int, minute: int)
signal day_changed(day: int)
signal period_changed(period: int)
signal paused_changed(paused: bool)

enum Period {
	DAWN,
	MORNING,
	MIDDAY,
	AFTERNOON,
	EVENING,
	NIGHT,
}

const MINUTES_PER_DAY: int = 1440
const MINUTES_PER_HOUR: int = 60

@export_range(1.0, 3600.0, 1.0) var real_seconds_per_game_hour: float = 120.0
@export var start_day: int = 1
@export var start_minute: int = 360
@export var autostart: bool = true

var _day: int = 1
var _minute: float = 360.0
var _period: int = Period.MORNING
var _paused: bool = false


## Devuelve el autoload, o `null` si no existe.
static func instance() -> WorldClockService:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("WorldClock") as WorldClockService


func _ready() -> void:
	set_process(autostart)
	_period = get_period()


func _process(delta: float) -> void:
	advance(delta)


## Avanza el reloj [param delta] segundos reales.
##
## No hace nada si está pausado o si [param delta] no es positivo. Emite
## `day_changed` por cada día cruzado, `time_changed` cuando cambia el minuto
## entero y `period_changed` cuando cambia la franja.
func advance(delta: float) -> void:
	if _paused or delta <= 0.0:
		return
	var old_day: int = _day
	var old_minute: int = get_minute_of_day()
	_minute += delta * (MINUTES_PER_HOUR / real_seconds_per_game_hour)
	while _minute >= float(MINUTES_PER_DAY):
		_minute -= float(MINUTES_PER_DAY)
		_day += 1
		day_changed.emit(_day)
	var new_minute: int = get_minute_of_day()
	if _day != old_day or new_minute != old_minute:
		time_changed.emit(_day, new_minute)
		var new_period: int = get_period()
		if new_period != _period:
			_period = new_period
			period_changed.emit(_period)


## Fija día y minuto. El minuto se envuelve en el día si hace falta.
func set_time(day: int, minute: float) -> void:
	var safe_day: int = maxi(1, day)
	var safe_minute: float = maxf(0.0, minute)
	while safe_minute >= float(MINUTES_PER_DAY):
		safe_minute -= float(MINUTES_PER_DAY)
		safe_day += 1
	var changed_day: bool = safe_day != _day
	var changed_minute: bool = int(safe_minute) != get_minute_of_day()
	_day = safe_day
	_minute = safe_minute
	if changed_day:
		day_changed.emit(_day)
	if changed_day or changed_minute:
		time_changed.emit(_day, get_minute_of_day())
	var new_period: int = get_period()
	if new_period != _period:
		_period = new_period
		period_changed.emit(_period)


## Vuelve al inicio configurado y reanuda el reloj.
func reset() -> void:
	var was_paused: bool = _paused
	_paused = false
	set_time(start_day, float(start_minute))
	_period = get_period()
	set_process(autostart)
	if was_paused:
		paused_changed.emit(false)


## Pausa o reanuda el avance automático.
func set_paused(paused: bool) -> void:
	if _paused == paused:
		return
	_paused = paused
	set_process(not _paused and autostart)
	paused_changed.emit(_paused)


## Indica si el reloj está pausado.
func is_paused() -> bool:
	return _paused


## Día actual, empezando en 1.
func get_day() -> int:
	return _day


## Minuto exacto dentro del día, de 0.0 a 1439.99.
func get_minute() -> float:
	return _minute


## Minuto entero dentro del día, de 0 a 1439.
func get_minute_of_day() -> int:
	return int(_minute)


## Hora entera, de 0 a 23.
func get_hour() -> int:
	# División entera intencionada: hora completa del día.
	return get_minute_of_day() / MINUTES_PER_HOUR


## Minuto dentro de la hora, de 0 a 59.
func get_minute_of_hour() -> int:
	return get_minute_of_day() % MINUTES_PER_HOUR


## Franja actual.
func get_period() -> int:
	var hour: int = get_hour()
	if hour >= 5 and hour < 7:
		return Period.DAWN
	if hour >= 7 and hour < 11:
		return Period.MORNING
	if hour >= 11 and hour < 14:
		return Period.MIDDAY
	if hour >= 14 and hour < 17:
		return Period.AFTERNOON
	if hour >= 17 and hour < 20:
		return Period.EVENING
	return Period.NIGHT


## Indica si es de noche.
func is_night() -> bool:
	return get_period() == Period.NIGHT


## Minutos de juego que faltan para la hora indicada, dentro de las próximas
## 24 horas. Devuelve 0 si ya es esa hora exacta.
func minutes_until(hour: int, minute: int = 0) -> int:
	var current: int = get_minute_of_day()
	var target: int = clampi(hour, 0, 23) * MINUTES_PER_HOUR + clampi(minute, 0, 59)
	if target < current:
		target += MINUTES_PER_DAY
	return target - current


## Hora en formato `HH:MM`, para depuración y UI.
func format_time() -> String:
	return "%02d:%02d" % [get_hour(), get_minute_of_hour()]


## Estado serializable del reloj.
func to_dict() -> Dictionary:
	return {
		"day": _day,
		"minute": _minute,
		"paused": _paused,
	}


## Restaura el estado. Devuelve `false` si los datos no son válidos.
func from_dict(data: Dictionary) -> bool:
	var day_value: Variant = data.get("day", 1)
	var minute_value: Variant = data.get("minute", 0.0)
	if not _is_number(day_value) or not _is_number(minute_value):
		return false
	set_time(_to_int(day_value), _to_float(minute_value))
	var paused_value: Variant = data.get("paused", false)
	if not (paused_value is bool):
		return false
	set_paused(str(paused_value) == "true")
	return true


func _is_number(value: Variant) -> bool:
	return value is int or value is float


func _to_int(value: Variant) -> int:
	return int(str(value).to_float())


func _to_float(value: Variant) -> float:
	return str(value).to_float()
