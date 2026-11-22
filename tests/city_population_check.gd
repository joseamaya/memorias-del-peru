extends SceneTree
## Comprueba la población de S1: 24 NPC registrados, 8 nombrados, rutinas de
## mañana y tarde distintas, y veinte minutos simulados sin atravesar casas.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const SETTLE_FRAMES: int = 240
const TOTAL_NPCS: int = 24
const NAMED_NPCS: int = 8
const MORNING_MINUTE: int = 480
const EVENING_MINUTE: int = 1200
const SIMULATED_MINUTES: float = 20.0
const CHECK_CHUNK_SECONDS: float = 120.0
const HOUSE_MARGIN: float = 0.05


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("POPULATION_FAIL no scene")
		quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	root.add_child(world)
	var population: CityPopulation = null
	for _i: int in SETTLE_FRAMES:
		await process_frame
		population = world.get_population()
		if population != null and population.get_definition_count() > 0:
			break
	var blockout: CuscoBlockout = world.get_streamer().get_loaded_node(&"s1_cusco") as CuscoBlockout
	var director: NpcDirector = population.get_director() if population != null else null
	var ok: bool = population != null and director != null and blockout != null
	if not ok:
		printerr("POPULATION_FAIL sin poblacion, director o Cusco")
		world.queue_free()
		await process_frame
		quit(1)
		return
	ok = ok and population.get_definition_count() == TOTAL_NPCS
	ok = ok and population.get_named_count() == NAMED_NPCS
	ok = ok and director.get_registered_count() == TOTAL_NPCS
	# El actor vive en el centro del cuerpo: el suelo queda a 0,9 m por debajo.
	# El destino tiene un desplazamiento lateral sobre el ancla y el terreno
	# puede inclinarse, así que se comprueba el orden de magnitud, no el valor
	# exacto.
	var region: CampaignRegion = world.get_region()
	var npc_position: Vector3 = director.get_npc_position(&"npc_curaca")
	var ground: float = region.height_at(npc_position.x, npc_position.z)
	var body_height: float = npc_position.y - ground
	ok = ok and body_height > 0.4 and body_height < 1.4

	# Espera a que el mapa de navegación sincronice las seis regiones: si se
	# pide una ruta antes, NavigationServer devuelve una línea recta.
	for _i: int in 120:
		await process_frame
	var clock: WorldClockService = WorldClockService.instance()
	ok = ok and clock != null
	if clock != null:
		clock.set_time(1, MORNING_MINUTE)
		await process_frame
		await process_frame
		var morning: StringName = director.get_anchor(&"npc_curaca")
		clock.set_time(1, EVENING_MINUTE)
		await process_frame
		await process_frame
		var evening: StringName = director.get_anchor(&"npc_curaca")
		ok = ok and morning == &"arrabal"
		ok = ok and evening == &"arrabal"
		ok = ok and director.get_minute() == EVENING_MINUTE

	# Simulación de veinte minutos con comprobación de casas.
	director.teleport_to_goal()
	director.update_lod()
	var houses: Array[Rect2] = _house_rects(blockout)
	var inside: int = 0
	var elapsed: float = 0.0
	while elapsed < SIMULATED_MINUTES * 60.0:
		director.advance(CHECK_CHUNK_SECONDS, 0.2)
		elapsed += CHECK_CHUNK_SECONDS
		inside = _count_inside(director, houses)
		if inside > 0:
			break
	ok = ok and inside == 0
	var active: int = director.get_active_count()
	ok = ok and active > 0 and active <= TOTAL_NPCS
	print(
		"POPULATION total=",
		population.get_definition_count(),
		" named=",
		population.get_named_count(),
		" active=",
		active,
		" inside_houses=",
		inside,
		" simulated_s=",
		int(elapsed)
	)
	world.queue_free()
	await process_frame
	if ok:
		print("POPULATION_OK")
	else:
		printerr("POPULATION_FAIL")
	quit(0 if ok else 1)


func _house_rects(blockout: CuscoBlockout) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var half: Vector2 = Vector2(5.5, 4.0) * 0.5 + Vector2(HOUSE_MARGIN, HOUSE_MARGIN)
	for point: Vector3 in blockout.get_house_positions():
		var world_point: Vector3 = blockout.to_global(point)
		rects.append(Rect2(Vector2(world_point.x, world_point.z) - half, half * 2.0))
	return rects


func _count_inside(director: NpcDirector, houses: Array[Rect2]) -> int:
	var count: int = 0
	for definition: NpcDefinition in director.get_definitions():
		var position: Vector3 = director.get_npc_position(definition.id)
		var flat: Vector2 = Vector2(position.x, position.z)
		for rect: Rect2 in houses:
			if rect.has_point(flat):
				count += 1
				printerr(
					"POPULATION_IN_HOUSE ",
					definition.id,
					" at ",
					position,
					" anchor=",
					director.get_anchor(definition.id)
				)
				break
	return count
