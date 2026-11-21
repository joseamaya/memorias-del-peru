class_name SideActivities
extends Node
## Actividades secundarias de la campaña 01: el turno del agua y la manta.
##
## No son un sistema nuevo: son dos cadenas de banderas con sus grafos y un
## punto en el mundo, como la misión. Este nodo escucha [WorldState], cambia la
## conversación de los NPC cuando toca, escribe el diario y coloca el telar.
## La consecuencia de cada decisión se lee en el diario y en lo que dicen los
## vecinos; la reputación queda como contador en `WorldState` hasta que el
## personaje tenga hoja propia.

const MOLENDERA_ID: StringName = &"npc_molendera"
const AGRICULTOR_ID: StringName = &"npc_agricultor"
const TEJEDORA_ID: StringName = &"npc_tejedora"

const AGUA_PEDIDO: StringName = &"m01_agua"
const AGUA_DECIDIDA: StringName = &"s01_agua"
const AGUA_GRAPH: StringName = &"s01_agua"
const AGUA_ECO: StringName = &"s01_agua_eco"
const AGUA_ECO_AGRICULTOR: StringName = &"s01_agua_eco_agricultor"

const LANA_PEDIDO: StringName = &"m01_lana"
const MANTA_PEDIDO: StringName = &"s01_manta_pedido"
const MANTA_HECHA: StringName = &"s01_manta"
const MANTA_GRAPH: StringName = &"s01_manta"
const MANTA_LISTA: StringName = &"s01_manta_lista"

## Las tres decisiones del agua y su entrada de diario.
const AGUA_DECISIONES: Array[Dictionary] = [
	{
		"flag": &"s01_agua_molienda",
		"memory": &"s01_agua_mem_molienda",
		"title": &"PCH_S01_AGUA_MEM_MOLIENDA_TITULO",
		"body": &"PCH_S01_AGUA_MEM_MOLIENDA_CUERPO",
	},
	{
		"flag": &"s01_agua_chacra",
		"memory": &"s01_agua_mem_chacra",
		"title": &"PCH_S01_AGUA_MEM_CHACRA_TITULO",
		"body": &"PCH_S01_AGUA_MEM_CHACRA_CUERPO",
	},
	{
		"flag": &"s01_agua_turnos",
		"memory": &"s01_agua_mem_turnos",
		"title": &"PCH_S01_AGUA_MEM_TURNOS_TITULO",
		"body": &"PCH_S01_AGUA_MEM_TURNOS_CUERPO",
	},
]

const AGUA_QUEST: StringName = &"s01_agua_encargo"
const MANTA_QUEST: StringName = &"s01_manta_encargo"
const AGUA_TITLE: StringName = &"PCH_S01_AGUA_TITULO"
const AGUA_BODY: StringName = &"PCH_S01_AGUA_CUERPO"
const MANTA_TITLE: StringName = &"PCH_S01_MANTA_TITULO"
const MANTA_BODY: StringName = &"PCH_S01_MANTA_CUERPO"
const MEMORY_BADGE: StringName = &"N"
const MEMORY_SOURCE: StringName = &"PCH-039"

## Telar del taller: los tres postes que ya dibuja el blockout.
const LOOM_LOCAL: Vector3 = Vector3(65.0, 0.0, -40.0)
const LOOM_SIZE: Vector3 = Vector3(5.6, 1.7, 0.9)
const MANTA_SIZE: Vector3 = Vector3(0.9, 0.8, 0.06)
const MANTA_COLOR: Color = Color(0.78, 0.42, 0.30)
const MANTA_HEIGHT: float = 1.05

var _world: RegionWorld = null
var _population: CityPopulation = null
var _loom: Node3D = null
var _manta: MeshInstance3D = null


## Prepara las actividades. Debe llamarse con el mundo y la población creados.
func setup(world: RegionWorld, population: CityPopulation) -> void:
	_world = world
	_population = population
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null:
		return
	world_state.flag_changed.connect(_on_flag_changed)
	var streamer: SectorStreamer = world.get_streamer()
	if streamer != null:
		streamer.sector_loaded.connect(_on_sector_loaded)
	if population != null:
		if population.is_built():
			_place_loom()
			_restore()
		else:
			# Los diálogos viven en la tabla de la población: hasta que no está
			# construida, `set_dialogue` no encuentra a quién cambiar.
			population.built.connect(_on_population_built)
	else:
		_restore()


func get_loom_spot() -> FlagInteractable:
	if _loom == null:
		return null
	return _loom.get_node_or_null("Interact") as FlagInteractable


func has_manta_visible() -> bool:
	return _manta != null and _manta.visible


## Reconstruye conversaciones y diario desde las banderas guardadas.
func _restore() -> void:
	var state: WorldStateService = WorldStateService.instance()
	if state == null:
		return
	if state.has_flag(AGUA_PEDIDO):
		if state.has_flag(AGUA_DECIDIDA):
			_resolve_agua()
		else:
			_offer_agua()
	if state.has_flag(LANA_PEDIDO):
		if state.has_flag(MANTA_HECHA):
			_finish_manta()
		elif state.has_flag(MANTA_PEDIDO):
			_switch(TEJEDORA_ID, MANTA_GRAPH)
			_add_quest(MANTA_QUEST, MANTA_TITLE, MANTA_BODY)


func _on_flag_changed(key: StringName, value: int) -> void:
	if value == 0:
		return
	match key:
		AGUA_PEDIDO:
			_offer_agua()
		AGUA_DECIDIDA:
			_resolve_agua()
		LANA_PEDIDO:
			_offer_manta()
		MANTA_HECHA:
			_finish_manta()


## La molendera plantea el reparto cuando ya tiene su agua.
func _offer_agua() -> void:
	var state: WorldStateService = WorldStateService.instance()
	if state != null and state.has_flag(AGUA_DECIDIDA):
		return
	_switch(MOLENDERA_ID, AGUA_GRAPH)
	_add_quest(AGUA_QUEST, AGUA_TITLE, AGUA_BODY)


## Se decidió el reparto: se cierra el encargo, se guarda la decisión y los dos
## vecinos cambian de conversación.
func _resolve_agua() -> void:
	var state: WorldStateService = WorldStateService.instance()
	if state == null:
		return
	_add_quest(AGUA_QUEST, AGUA_TITLE, AGUA_BODY)
	var journal: Journal = _journal()
	if journal != null:
		journal.complete_quest(AGUA_QUEST)
		for decision: Dictionary in AGUA_DECISIONES:
			var flag: StringName = decision["flag"]
			if not state.has_flag(flag):
				continue
			var memory: StringName = decision["memory"]
			var title: StringName = decision["title"]
			var body: StringName = decision["body"]
			journal.add_memory(memory, title, body, MEMORY_BADGE, MEMORY_SOURCE)
	_switch(MOLENDERA_ID, AGUA_ECO)
	_switch(AGRICULTOR_ID, AGUA_ECO_AGRICULTOR)


## La tejedora ofrece la manta cuando ya recibió la lana.
func _offer_manta() -> void:
	var state: WorldStateService = WorldStateService.instance()
	if state != null and state.has_flag(MANTA_HECHA):
		return
	_switch(TEJEDORA_ID, MANTA_GRAPH)
	_add_quest(MANTA_QUEST, MANTA_TITLE, MANTA_BODY)


## La manta está tejida: encargo cerrado, la tejedora lo sabe y se ve en el telar.
func _finish_manta() -> void:
	_add_quest(MANTA_QUEST, MANTA_TITLE, MANTA_BODY)
	var journal: Journal = _journal()
	if journal != null:
		journal.complete_quest(MANTA_QUEST)
	_switch(TEJEDORA_ID, MANTA_LISTA)
	if _manta != null:
		_manta.visible = true


func _switch(npc_id: StringName, dialogue_id: StringName) -> void:
	if _population != null:
		_population.set_dialogue(npc_id, dialogue_id)


func _add_quest(id: StringName, title: StringName, body: StringName) -> void:
	var journal: Journal = _journal()
	if journal != null:
		journal.add_quest(id, title, body)


func _journal() -> Journal:
	return _world.get_journal() if _world != null else null


func _on_population_built() -> void:
	_place_loom()
	_restore()


func _on_sector_loaded(id: StringName, _node: Node3D) -> void:
	if id == &"s1_cusco":
		_place_loom()


## Coloca el punto del telar en cuanto el sector de la ciudad está cargado.
func _place_loom() -> void:
	if _loom != null or _world == null:
		return
	var blockout: CuscoBlockout = (
		_world.get_streamer().get_loaded_node(&"s1_cusco") as CuscoBlockout
	)
	if blockout == null:
		return
	var region: CampaignRegion = _world.get_region()
	var point: Vector3 = blockout.to_global(LOOM_LOCAL)
	point.y = region.height_at(point.x, point.z)
	_loom = Node3D.new()
	_loom.name = "Loom"
	_loom.position = point
	add_child(_loom)
	_build_manta()
	var spot: FlagInteractable = FlagInteractable.new()
	spot.name = "Interact"
	spot.flag = MANTA_HECHA
	spot.requires_flag = MANTA_PEDIDO
	spot.text_key = &"PCH_S01_TEJER"
	spot.interact_size = LOOM_SIZE
	spot.highlight_target = _manta
	_loom.add_child(spot)


func _build_manta() -> void:
	_manta = MeshInstance3D.new()
	_manta.name = "Manta"
	var box: BoxMesh = BoxMesh.new()
	box.size = MANTA_SIZE
	_manta.mesh = box
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = MANTA_COLOR
	material.roughness = 0.95
	_manta.material_override = material
	_manta.position = Vector3(0.0, MANTA_HEIGHT, 0.14)
	_loom.add_child(_manta)
	var state: WorldStateService = WorldStateService.instance()
	_manta.visible = state != null and state.has_flag(MANTA_HECHA)
