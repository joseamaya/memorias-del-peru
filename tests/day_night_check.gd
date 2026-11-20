extends SceneTree
## Comprueba el ciclo día/noche: el reloj mueve el sol, el ambiente y la niebla
## sin saltos, y la noche se distingue del mediodía.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 180
const SAMPLE_STEP_MINUTES: float = 15.0
const MAX_ENERGY_STEP: float = 0.30
const NOON_MINUTE: float = 780.0
const DAWN_MINUTE: float = 420.0
const DUSK_MINUTE: float = 1050.0
const NIGHT_MINUTE: float = 1380.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("DAYNIGHT_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	var cycle: DayNightCycle = null
	for _i: int in SETTLE_FRAMES:
		await process_frame
		cycle = get_first_node_in_group(&"day_night_cycle") as DayNightCycle
		if cycle != null:
			break
	var sun: DirectionalLight3D = cycle.get_sun() if cycle != null else null
	var environment: Environment = cycle.get_environment() if cycle != null else null
	var ok: bool = cycle != null and sun != null and environment != null
	if not ok:
		printerr("DAYNIGHT_FAIL sin ciclo, sol o ambiente")
		world.queue_free()
		await process_frame
		quit(1)
		return

	# El reloj manda: a mediodía la luz coincide con la hora aplicada a mano.
	cycle.apply_minute(NOON_MINUTE)
	var noon_energy: float = sun.light_energy
	var noon_ambient: float = environment.ambient_light_energy
	var noon_fog: float = environment.fog_density
	var clock: WorldClockService = WorldClockService.instance()
	ok = ok and clock != null
	# La partida empieza a las 8:00, con el sol ya alto: a las 6:00 la ciudad
	# amanece a oscuras y la primera impresión es de noche.
	ok = ok and clock.start_minute == 480
	cycle.apply_minute(480.0)
	ok = ok and sun.visible and sun.light_energy > 0.5
	if clock != null:
		clock.set_time(1, NOON_MINUTE)
	await process_frame
	await process_frame
	ok = ok and absf(sun.light_energy - noon_energy) <= 0.01

	cycle.apply_minute(DAWN_MINUTE)
	var dawn_energy: float = sun.light_energy
	var dawn_rotation: float = sun.rotation_degrees.x

	cycle.apply_minute(DUSK_MINUTE)
	var dusk_ambient: float = environment.ambient_light_energy

	cycle.apply_minute(NIGHT_MINUTE)
	var night_energy: float = sun.light_energy
	var night_ambient: float = environment.ambient_light_energy
	var night_fog: float = environment.fog_density
	ok = ok and not sun.visible
	ok = ok and night_energy <= 0.01
	ok = ok and night_ambient < noon_ambient
	ok = ok and night_fog > noon_fog

	cycle.apply_minute(NOON_MINUTE)
	ok = ok and sun.visible
	ok = ok and noon_energy > dawn_energy and dawn_energy > night_energy
	ok = ok and absf(sun.rotation_degrees.x) > absf(dawn_rotation)
	ok = ok and dusk_ambient < noon_ambient and dusk_ambient > night_ambient
	ok = ok and noon_fog < night_fog

	# Sin saltos: muestreo cada 15 minutos durante un día completo.
	var previous: float = -1.0
	var minute: float = 0.0
	while minute <= 1440.0:
		cycle.apply_minute(minute)
		var energy: float = sun.light_energy
		if is_nan(energy) or energy < 0.0 or energy > 2.0:
			ok = false
		if previous >= 0.0 and absf(energy - previous) > MAX_ENERGY_STEP:
			printerr("DAYNIGHT_FAIL salto en el minuto ", minute, ": ", previous, " -> ", energy)
			ok = false
		previous = energy
		minute += SAMPLE_STEP_MINUTES

	print(
		"DAYNIGHT noon=",
		snappedf(noon_energy, 0.01),
		" dawn=",
		snappedf(dawn_energy, 0.01),
		" night=",
		snappedf(night_energy, 0.01),
		" ambient_noon=",
		snappedf(noon_ambient, 0.01),
		" ambient_night=",
		snappedf(night_ambient, 0.01)
	)
	world.queue_free()
	await process_frame
	if ok:
		print("DAYNIGHT_OK")
	else:
		printerr("DAYNIGHT_FAIL")
	quit(0 if ok else 1)
