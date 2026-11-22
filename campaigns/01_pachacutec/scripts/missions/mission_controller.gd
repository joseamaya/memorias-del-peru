class_name MissionController
extends Node
## Misión principal de la campaña 01, sin motor genérico.
##
## Lee `data/missions/m01_la_ciudad_que_se_queda.tres` y avanza etapas cuando
## las banderas de [WorldState] que pide la etapa están puestas. El diario se
## reconstruye desde la etapa guardada, así que no se serializa aparte.

const MISSION_DIR: String = "res://campaigns/01_pachacutec/data/missions"
const MISSION_FILE: String = "m01_la_ciudad_que_se_queda.tres"
const STAGE_FLAG: StringName = &"m01_etapa"
const CURACA_ID: StringName = &"npc_curaca"
const CURACA_DIALOGUE: StringName = &"m01_curaca"
const CURACA_PARTIDA: StringName = &"m01_curaca_partida"
const SUBTITLE_SECONDS: float = 6.0

## Puntos del mundo que completan los encargos: bandera, requisito, texto,
## posición local en S1, tamaño y color.
const SPOTS: Array[Dictionary] = [
	{
		"flag": &"m01_agua",
		"requires": &"m01_agua_pedido",
		"text_key": &"INTERACT_WATER",
		"position": Vector2(-118.0, -102.0),
		"size": Vector3(1.3, 0.55, 1.3),
		"color": Color(0.60, 0.63, 0.60),
	},
	{
		"flag": &"m01_lana",
		"requires": &"m01_lana_pedido",
		"text_key": &"INTERACT_WOOL",
		"position": Vector2(60.0, -50.6),
		"size": Vector3(0.8, 0.55, 0.8),
		"color": Color(0.66, 0.52, 0.36),
	},
	{
		"flag": &"m01_maiz",
		"requires": &"m01_maiz_pedido",
		"text_key": &"INTERACT_MAIZE",
		"position": Vector2(108.0, -90.0),
		"size": Vector3(1.0, 0.9, 1.0),
		"color": Color(0.74, 0.62, 0.34),
	},
]

var _world: RegionWorld = null
var _population: CityPopulation = null
var _mission: MissionDefinition = null
var _stage: int = 0
var _spots: Node3D = null
var _departure: DepartureColumn = null


## Prepara la misión. Debe llamarse con el mundo y la población ya creados.
func setup(world: RegionWorld, population: CityPopulation) -> void:
	_world = world
	_population = population
	_mission = load(MISSION_DIR.path_join(MISSION_FILE)) as MissionDefinition
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null:
		return
	world_state.flag_changed.connect(_on_flag_changed)
	if population != null:
		if population.is_built():
			_place_spots()
		else:
			# La población puede construirse después de `_restore()`: al cargar
			# una partida en la etapa 2, la curáca todavía no existe y el cambio
			# de conversación se perdería. Se reintenta al construirla.
			population.built.connect(_on_population_built)
	_restore()


func get_stage() -> int:
	return _stage


func get_stage_count() -> int:
	return _mission.get_stage_count() if _mission != null else 0


func get_mission() -> MissionDefinition:
	return _mission


func has_departure() -> bool:
	return _departure != null and is_instance_valid(_departure)


func get_spots() -> Node3D:
	return _spots


## Reconstruye el diario desde la etapa guardada. Una partida nueva empieza en
## la etapa 1; una cargada no repite la escena de la partida.
func _restore() -> void:
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null or _mission == null:
		return
	_stage = world_state.get_flag(STAGE_FLAG)
	if _stage < 1:
		_enter_stage(1, false)
		return
	var journal: Journal = _world.get_journal()
	var flags: Dictionary[StringName, int] = world_state.get_flags()
	for index: int in range(1, mini(_stage, _mission.get_stage_count()) + 1):
		var stage: MissionStage = _mission.get_stage(index)
		if stage == null:
			continue
		journal.add_quest(stage.journal_id(), stage.title_key, stage.body_key)
		# La etapa actual también puede estar cumplida: al cargar después de
		# ganar Carmenca, `m01_victoria` ya está puesta y su entrada no debe
		# volver a aparecer abierta.
		if index < _stage or stage.is_complete(flags):
			journal.complete_quest(stage.journal_id())
	if _stage >= 2:
		_switch_curaca(true)
	if _stage >= 3:
		_apply_war_phase()


## La población terminó de construirse: se colocan los puntos y se reaplica la
## conversación que la etapa necesite.
func _on_population_built() -> void:
	_place_spots()
	if _stage >= 2:
		_switch_curaca(true)


func _enter_stage(index: int, live: bool) -> void:
	if _mission == null:
		return
	var stage: MissionStage = _mission.get_stage(index)
	if stage == null:
		return
	_stage = index
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state != null:
		world_state.set_flag(STAGE_FLAG, index)
	var journal: Journal = _world.get_journal()
	if journal != null:
		journal.add_quest(stage.journal_id(), stage.title_key, stage.body_key)
	if index == 2:
		_switch_curaca(true)
		if live:
			_start_departure()
			_show_subtitle(&"PCH_M01_PARTIDA_AVISO")
	if index == 3:
		_apply_war_phase()
		if live:
			_show_subtitle(&"PCH_M01_GUERRA_AVISO")


func _on_flag_changed(key: StringName, value: int) -> void:
	if value == 0 or _mission == null or _stage < 1:
		return
	var stage: MissionStage = _mission.get_stage(_stage)
	if stage == null or not stage.required_flags.has(key):
		return
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state == null or not stage.is_complete(world_state.get_flags()):
		return
	var journal: Journal = _world.get_journal()
	if journal != null:
		journal.complete_quest(stage.journal_id())
	if _stage < _mission.get_stage_count():
		_enter_stage(_stage + 1, true)


func _apply_war_phase() -> void:
	var world_state: WorldStateService = WorldStateService.instance()
	if world_state != null:
		world_state.set_phase(&"guerra")


func _switch_curaca(partida: bool) -> void:
	if _population == null:
		return
	_population.set_dialogue(CURACA_ID, CURACA_PARTIDA if partida else CURACA_DIALOGUE)


func _start_departure() -> void:
	if has_departure():
		return
	var blockout: CuscoBlockout = _get_blockout()
	if blockout == null:
		return
	var region: CampaignRegion = _world.get_region()
	var start: Vector3 = blockout.to_global(Vector3(-2.0, 0.0, 4.0))
	start.y = region.height_at(start.x, start.z)
	_departure = DepartureColumn.new()
	_departure.name = "DepartureColumn"
	add_child(_departure)
	_departure.setup(start, Vector3(-1.0, 0.0, -0.15), region)


func _show_subtitle(key: StringName) -> void:
	var hud: PlayerHud = _world.get_player_hud()
	if hud != null:
		hud.show_subtitle(tr(String(key)), SUBTITLE_SECONDS)


## Coloca los tres puntos de encargo. Se llama cuando el sector está cargado.
func _place_spots() -> void:
	var blockout: CuscoBlockout = _get_blockout()
	if blockout == null or _spots != null:
		return
	_spots = Node3D.new()
	_spots.name = "MissionSpots"
	add_child(_spots)
	var region: CampaignRegion = _world.get_region()
	for entry: Dictionary in SPOTS:
		_add_spot(entry, blockout, region)


func _add_spot(entry: Dictionary, blockout: CuscoBlockout, region: CampaignRegion) -> void:
	var local: Vector2 = entry["position"]
	var size: Vector3 = entry["size"]
	var color: Color = entry["color"]
	var point: Vector3 = blockout.to_global(Vector3(local.x, 0.0, local.y))
	point.y = region.height_at(point.x, point.z)
	var root: Node3D = Node3D.new()
	root.name = "Spot_%s" % entry["flag"]
	root.position = point
	_spots.add_child(root)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = BlockoutKit.material(color)
	mesh.position = Vector3(0.0, size.y * 0.5, 0.0)
	root.add_child(mesh)
	var spot: FlagInteractable = FlagInteractable.new()
	spot.name = "Interact"
	spot.flag = entry["flag"]
	spot.requires_flag = entry["requires"]
	spot.text_key = entry["text_key"]
	spot.interact_size = size
	spot.highlight_target = mesh
	root.add_child(spot)


func _get_blockout() -> CuscoBlockout:
	if _world == null:
		return null
	return _world.get_streamer().get_loaded_node(&"s1_cusco") as CuscoBlockout
