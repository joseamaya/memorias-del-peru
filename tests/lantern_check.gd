extends SceneTree
## Comprueba la antorcha de mano: apagada de día, encendida de noche y sin
## saltos al atardecer.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 300
const NOON_MINUTE: float = 720.0
const NIGHT_MINUTE: float = 1320.0
const DUSK_START_MINUTE: float = 1020.0
const DUSK_END_MINUTE: float = 1140.0
const SAMPLE_STEP_MINUTES: float = 5.0
## El parpadeo mueve el nivel un 7 %; el escalón admite ese ruido y detecta un
## encendido a golpe.
const MAX_LEVEL_STEP: float = 0.25
const NIGHT_MIN_ENERGY: float = 0.9
const MIN_RANGE: float = 8.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("LANTERN_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	var player: PlayerFPS = null
	for _i: int in SETTLE_FRAMES:
		await process_frame
		player = world.get_player()
		if player != null:
			break
	var lantern: PlayerLantern = null
	if player != null:
		lantern = player.get_node_or_null("Head/Camera3D/Lantern") as PlayerLantern
	var clock: WorldClockService = WorldClockService.instance()
	var ok: bool = player != null and lantern != null and clock != null
	if not ok:
		printerr("LANTERN_FAIL sin jugador, antorcha o reloj")
		world.queue_free()
		await process_frame
		quit(1)
		return
	clock.set_paused(true)

	# La antorcha y el sol comparten la misma fórmula: si cambia una, cambia la
	# otra, y no hay dos relojes que se contradigan.
	ok = ok and absf(DayNightCycle.daylight_at(NOON_MINUTE) - 1.0) <= 0.01
	ok = ok and DayNightCycle.daylight_at(0.0) <= 0.01
	ok = ok and DayNightCycle.daylight_at(360.0) <= 0.05
	ok = ok and absf(DayNightCycle.daylight_at(480.0) - 0.5) <= 0.02

	# Mediodía: apagada y sin gastar luz.
	clock.set_time(1, NOON_MINUTE)
	await _settle()
	ok = ok and lantern.get_level() <= 0.01
	ok = ok and not lantern.visible
	ok = ok and lantern.get_light().light_energy <= 0.01

	# Noche: encendida, cálida, sin sombras y con alcance de calle.
	clock.set_time(1, NIGHT_MINUTE)
	await _settle()
	var light: OmniLight3D = lantern.get_light()
	var night_level: float = lantern.get_level()
	var night_energy: float = light.light_energy
	ok = ok and lantern.visible and night_level > 0.8
	ok = ok and light.light_energy >= NIGHT_MIN_ENERGY
	ok = ok and light.omni_range >= MIN_RANGE
	ok = ok and not light.shadow_enabled
	ok = ok and light.light_color.r > light.light_color.b

	# Del sol a la noche el nivel sube sin saltos.
	var previous: float = -1.0
	var minute: float = DUSK_START_MINUTE
	while minute <= DUSK_END_MINUTE:
		clock.set_time(1, minute)
		await process_frame
		await process_frame
		var level: float = lantern.get_level()
		if previous >= 0.0 and absf(level - previous) > MAX_LEVEL_STEP:
			printerr("LANTERN_FAIL salto en el minuto ", minute, ": ", previous, " -> ", level)
			ok = false
		previous = level
		minute += SAMPLE_STEP_MINUTES

	# Y se apaga al volver el día: no se queda encendida.
	clock.set_time(1, NOON_MINUTE)
	await _settle()
	ok = ok and not lantern.visible
	ok = ok and lantern.get_light().light_energy <= 0.01

	print(
		"LANTERN noche=",
		snappedf(night_level, 0.01),
		" energia=",
		snappedf(night_energy, 0.01),
		" alcance=",
		snappedf(light.omni_range, 0.1)
	)
	world.queue_free()
	await process_frame
	if ok:
		print("LANTERN_OK")
	else:
		printerr("LANTERN_FAIL")
	quit(0 if ok else 1)


func _settle() -> void:
	for _i: int in 3:
		await process_frame
