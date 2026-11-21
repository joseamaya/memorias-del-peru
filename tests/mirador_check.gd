extends SceneTree
## Comprueba el descubrimiento sin marcador del mirador de Carmenca (F3.6.b).
##
## El jugador camina hasta la terraza, el POI se descubre solo por proximidad,
## el diario recibe su memoria y el campamento chanca está a la vista. La carga
## conserva el descubrimiento sin duplicar la entrada.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const CAMPAIGN: StringName = &"01_pachacutec"
const SETTLE_FRAMES: int = 600
const LOAD_FRAMES: int = 300
const MIRADOR: Vector3 = Vector3(825.0, 0.0, 325.0)
const MEMORY: StringName = &"s01_mirador_memoria"
const POI: StringName = &"poi_31"
const EXPECTED_TENTS: int = 12


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var manager: SaveManagerService = SaveManagerService.instance()
	var state: WorldStateService = WorldStateService.instance()
	var campaign_state: CampaignStateService = CampaignStateService.instance()
	var ok: bool = manager != null and state != null and campaign_state != null
	if not ok:
		printerr("MIRADOR_FAIL sin servicios")
		quit(1)
		return
	_clear_campaign(manager)
	state.clear()
	campaign_state.clear()

	var world: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world)
	var journal: Journal = world.get_journal()
	var hud: PlayerHud = world.get_player_hud()
	var player: PlayerFPS = world.get_player()
	var region: CampaignRegion = world.get_region()
	var streamer: SectorStreamer = world.get_streamer()
	var session: CampaignSession = world.get_session()
	ok = ok and journal != null and hud != null and player != null
	ok = ok and region != null and streamer != null and session != null
	ok = ok and session.get_discovery_notes() != null
	if not ok:
		printerr("MIRADOR_FAIL sin diario, jugador o sesión")
		world.queue_free()
		await process_frame
		quit(1)
		return

	# Lejos del mirador no hay descubrimiento.
	ok = ok and not state.is_discovered(POI)
	ok = ok and not journal.has(MEMORY)

	# Caminata hasta la terraza: el streaming carga S2 y el POI entra por radio.
	player.global_position = Vector3(
		MIRADOR.x, region.height_at(MIRADOR.x, MIRADOR.z) + 0.6, MIRADOR.z
	)
	var sector: Node3D = null
	for _i: int in LOAD_FRAMES:
		await process_frame
		sector = streamer.get_loaded_node(&"s2_afueras")
		if sector != null and state.is_discovered(POI):
			break
	ok = ok and sector != null
	var overlook: CarmencaOverlook = null
	if sector != null:
		overlook = sector.get_node_or_null("CarmencaOverlook") as CarmencaOverlook
	ok = ok and overlook != null
	var tent_count: int = overlook.get_tent_count() if overlook != null else 0
	ok = ok and tent_count == EXPECTED_TENTS
	ok = ok and state.is_discovered(POI)
	ok = ok and journal.has(MEMORY)
	ok = ok and hud.hint_label.text != ""
	ok = ok and not hud.hint_label.text.begins_with("PCH_")

	# Guardar y cargar en otra instancia: el descubrimiento no se pierde ni se
	# duplica la memoria.
	var entries_before: int = journal.count()
	ok = ok and session.save_auto()
	world.queue_free()
	await process_frame
	state.clear()
	campaign_state.clear()
	ok = ok and manager.request_load(CAMPAIGN, SaveManagerService.AUTO_SLOT)

	var world2: RegionWorld = _spawn()
	ok = ok and await _wait_ready(world2)
	var journal2: Journal = world2.get_journal()
	ok = ok and journal2 != null
	ok = ok and WorldStateService.instance().is_discovered(POI)
	ok = ok and journal2.has(MEMORY)
	ok = ok and journal2.count() == entries_before

	print(
		"MIRADOR descubierto=",
		WorldStateService.instance().is_discovered(POI),
		" tiendas=",
		tent_count,
		" diario=",
		journal2.count()
	)
	world2.queue_free()
	WorldStateService.instance().clear()
	campaign_state.clear()
	_clear_campaign(manager)
	await process_frame
	await process_frame
	if ok:
		print("MIRADOR_OK")
	else:
		printerr("MIRADOR_FAIL")
	quit(0 if ok else 1)


func _spawn() -> RegionWorld:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		return null
	var world: RegionWorld = packed.instantiate() as RegionWorld
	if world == null:
		return null
	root.add_child(world)
	return world


func _wait_ready(world: RegionWorld) -> bool:
	if world == null:
		return false
	for _i: int in SETTLE_FRAMES:
		await process_frame
		var population: CityPopulation = world.get_population()
		if population == null or not population.is_built():
			continue
		var session: CampaignSession = world.get_session()
		if session == null or session.get_discovery_notes() == null:
			continue
		return true
	return false


func _clear_campaign(manager: SaveManagerService) -> void:
	for slot: String in manager.list_slots(CAMPAIGN):
		manager.delete_slot(CAMPAIGN, StringName(slot))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.SAVE_DIR.path_join(String(CAMPAIGN)))
	)
