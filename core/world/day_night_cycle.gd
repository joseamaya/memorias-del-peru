class_name DayNightCycle
extends Node
## Ata el sol, el ambiente y la niebla al reloj del mundo.
##
## `WorldClock` marca la hora; este nodo la traduce a luz. Los valores de
## mediodía son los mismos que tenía el blockout aprobado, así que la revisión
## diurna no cambia. La noche y el amanecer son reconstrucción de ambiente (R).
##
## Los interiores no dependen de este nodo: su sala lleva luz propia.

const DAY_MINUTES: float = 1440.0
## Hora a la que el sol cruza el horizonte por la mañana.
const SUNRISE_HOUR: float = 6.0
## Elevación máxima del sol a mediodía, en grados.
const MAX_ELEVATION: float = 70.0
## Azimut fijo del sol: el blockout mira al sureste.
const SUN_AZIMUTH: float = -40.0
## Por debajo de esta elevación el sol deja de iluminar.
const SUN_MIN_ELEVATION: float = -2.0

const DAY_SUN_COLOR: Color = Color(1.0, 0.96, 0.90)
const LOW_SUN_COLOR: Color = Color(1.0, 0.62, 0.35)
const DAY_SUN_ENERGY: float = 1.35

const DAY_AMBIENT_COLOR: Color = Color(0.58, 0.62, 0.68)
const NIGHT_AMBIENT_COLOR: Color = Color(0.10, 0.14, 0.26)
const DAY_AMBIENT_ENERGY: float = 1.2
const NIGHT_AMBIENT_ENERGY: float = 0.35

const DAY_FOG_COLOR: Color = Color(0.66, 0.74, 0.86)
const NIGHT_FOG_COLOR: Color = Color(0.10, 0.13, 0.20)
const DUSK_FOG_COLOR: Color = Color(0.55, 0.42, 0.40)
const DAY_FOG_DENSITY: float = 0.00025
const NIGHT_FOG_DENSITY: float = 0.0009

const DAY_FILL_COLOR: Color = Color(0.72, 0.80, 0.95)
const NIGHT_FILL_COLOR: Color = Color(0.45, 0.55, 0.85)
const DAY_FILL_ENERGY: float = 0.55
const NIGHT_FILL_ENERGY: float = 0.25

var _sun: DirectionalLight3D = null
var _fill: DirectionalLight3D = null
var _environment: Environment = null
var _last_minute: int = -1


func _ready() -> void:
	add_to_group(&"day_night_cycle")
	_apply_from_clock()


func setup(sun: DirectionalLight3D, fill: DirectionalLight3D, environment: Environment) -> void:
	_sun = sun
	_fill = fill
	_environment = environment


func _process(_delta: float) -> void:
	var clock: WorldClockService = WorldClockService.instance()
	if clock == null:
		return
	var minute: int = clock.get_minute_of_day()
	if minute == _last_minute:
		return
	_last_minute = minute
	_apply(minute)


func get_sun() -> DirectionalLight3D:
	return _sun


func get_fill() -> DirectionalLight3D:
	return _fill


func get_environment() -> Environment:
	return _environment


## Aplica la luz de una hora concreta. Público para pruebas y capturas.
func apply_minute(minute: float) -> void:
	_apply(minute)


func _apply_from_clock() -> void:
	var clock: WorldClockService = WorldClockService.instance()
	if clock == null:
		return
	var minute: int = clock.get_minute_of_day()
	_last_minute = minute
	_apply(minute)


## Luz diurna (0–1) de una hora del día. La antorcha del jugador la usa para
## encenderse sola al caer el sol, sin repetir la fórmula del sol.
static func daylight_at(minute: float) -> float:
	var normalized: float = fposmod(minute, DAY_MINUTES) / DAY_MINUTES
	return clampf(sin((normalized - SUNRISE_HOUR / 24.0) * TAU), 0.0, 1.0)


func _apply(minute: float) -> void:
	var normalized: float = fposmod(minute, DAY_MINUTES) / DAY_MINUTES
	# A las 6:00 el sol sale por el horizonte; a las 12:00 está en lo alto.
	var angle: float = (normalized - SUNRISE_HOUR / 24.0) * TAU
	var elevation: float = sin(angle) * MAX_ELEVATION
	var daylight: float = daylight_at(minute)
	var dusk: float = clampf(1.0 - absf(sin(angle)) * 4.0, 0.0, 1.0)
	_apply_sun(elevation, daylight)
	_apply_environment(daylight, dusk)
	_apply_fill(daylight)


func _apply_sun(elevation: float, daylight: float) -> void:
	if _sun == null:
		return
	_sun.rotation_degrees = Vector3(-elevation, SUN_AZIMUTH, 0.0)
	_sun.visible = elevation > SUN_MIN_ELEVATION
	if not _sun.visible:
		_sun.light_energy = 0.0
		return
	# Rampa suave desde el horizonte: sin ella, la energía salta al salir el sol.
	var strength: float = smoothstep(SUN_MIN_ELEVATION, 30.0, elevation)
	_sun.light_energy = DAY_SUN_ENERGY * strength
	_sun.light_color = LOW_SUN_COLOR.lerp(DAY_SUN_COLOR, clampf(daylight * 1.6, 0.0, 1.0))


func _apply_environment(daylight: float, dusk: float) -> void:
	if _environment == null:
		return
	var warmth: float = clampf(dusk, 0.0, 1.0)
	var ambient_color: Color = NIGHT_AMBIENT_COLOR.lerp(DAY_AMBIENT_COLOR, daylight)
	_environment.ambient_light_color = ambient_color
	_environment.ambient_light_energy = lerpf(NIGHT_AMBIENT_ENERGY, DAY_AMBIENT_ENERGY, daylight)
	var fog_color: Color = NIGHT_FOG_COLOR.lerp(DAY_FOG_COLOR, daylight)
	fog_color = fog_color.lerp(DUSK_FOG_COLOR, warmth * 0.55)
	_environment.fog_light_color = fog_color
	_environment.fog_density = lerpf(NIGHT_FOG_DENSITY, DAY_FOG_DENSITY, daylight)


func _apply_fill(daylight: float) -> void:
	if _fill == null:
		return
	_fill.light_color = NIGHT_FILL_COLOR.lerp(DAY_FILL_COLOR, daylight)
	_fill.light_energy = lerpf(NIGHT_FILL_ENERGY, DAY_FILL_ENERGY, daylight)
