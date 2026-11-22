class_name CampaignSession
extends Node
## Sesión de la campaña 01: descanso, guardado y carga.
##
## Es el punto donde se juntan los sistemas de Core (reloj, estado del mundo,
## guardado) con los datos de la campaña (posición del jugador, estado de las
## banderas y rutina de los NPC de la ciudad). No dibuja el mundo: solo decide
## qué se guarda y qué se restaura.
##
## Contrato del guardado: el payload del jugador lleva `position`, `yaw`,
## `campaign` (banderas y datos de [CampaignState], donde vivirán misión e
## inventario cuando existan) y `npcs` (instantánea de [NpcDirector], solo NPC
## con nombre). Las obras de la defensa viven en [WorldState] y se guardan con
## el resto del mundo.

const CAMPAIGN_ID: StringName = &"01_pachacutec"
const SAVE_SLOT: StringName = SaveManagerService.AUTO_SLOT

var _world: RegionWorld = null
var _player: PlayerFPS = null
var _population: CityPopulation = null
var _overlay: SleepOverlay = null
var _mission: MissionController = null
var _side: SideActivities = null
var _notes: DiscoveryNotes = null
var _defense: DefenseWorks = null
var _battle: CarmencaBattle = null
var _pending_npcs: Dictionary = {}
var _last_save_ok: bool = false
var _restored: bool = false


func setup(world: RegionWorld, player: PlayerFPS, population: CityPopulation) -> void:
	_world = world
	_player = player
	_population = population
	add_to_group(&"campaign_session")


## Prepara el aviso de pantalla y aplica la carga pendiente, si la hay.
func begin() -> void:
	_overlay = SleepOverlay.new()
	_overlay.name = "SleepOverlay"
	add_child(_overlay)
	if _population != null:
		_population.built.connect(_on_population_built)
	_restored = _restore()
	_build_mission()
	_build_side_activities()
	_build_discovery_notes()
	_build_defense_works()
	_build_battle()


## Duerme en la casa del jugador: sale del interior, avanza a la mañana
## siguiente, despierta a la ciudad y guarda la partida.
func rest_until_morning() -> bool:
	if _player == null or _world == null:
		return false
	# El interior es un bolsillo 400 m bajo el terreno y no sobrevive al
	# guardado: al despertar se sale a la puerta, así seguir jugando y cargar la
	# partida dejan al jugador en el mismo sitio.
	var interiors: InteriorController = _world.get_interiors()
	if interiors != null and interiors.is_inside():
		interiors.exit()
	var rest: Vector2i = RestCycle.apply(WorldClockService.instance())
	if rest == Vector2i.ZERO:
		return false
	_refresh_population(rest.y)
	_last_save_ok = save_auto()
	if _overlay != null:
		_overlay.show_rest(rest.x, rest.y, _last_save_ok)
	_log(&"rest", "dia=%d" % rest.x)
	return true


## Guarda el estado completo en la ranura automática. Devuelve si se escribió.
func save_auto() -> bool:
	var clock: WorldClockService = WorldClockService.instance()
	var manager: SaveManagerService = SaveManagerService.instance()
	var world_state: WorldStateService = WorldStateService.instance()
	var campaign_state: CampaignStateService = CampaignStateService.instance()
	if clock == null or manager == null or world_state == null or campaign_state == null:
		return false
	if _player == null:
		return false
	var payload: Dictionary = {
		"position": _pack_vector(_player.global_position),
		"yaw": _player.rotation.y,
		"campaign": campaign_state.to_dict(),
		"npcs": _npc_snapshot(),
	}
	_last_save_ok = manager.save_world(CAMPAIGN_ID, SAVE_SLOT, world_state, clock, payload)
	return _last_save_ok


## Indica si la sesión arrancó desde una partida guardada.
func is_restored() -> bool:
	return _restored


## Resultado del último guardado.
func get_last_save_ok() -> bool:
	return _last_save_ok


## Aviso de pantalla, para las pruebas.
func get_overlay() -> SleepOverlay:
	return _overlay


func get_mission() -> MissionController:
	return _mission


func get_side_activities() -> SideActivities:
	return _side


func get_discovery_notes() -> DiscoveryNotes:
	return _notes


func get_defense_works() -> DefenseWorks:
	return _defense


func get_battle() -> CarmencaBattle:
	return _battle


func _build_battle() -> void:
	_battle = CarmencaBattle.new()
	_battle.name = "Battle"
	add_child(_battle)
	_battle.setup(_world, _defense)


func _build_defense_works() -> void:
	_defense = DefenseWorks.new()
	_defense.name = "DefenseWorks"
	add_child(_defense)
	_defense.setup(_world)


func _build_discovery_notes() -> void:
	_notes = DiscoveryNotes.new()
	_notes.name = "DiscoveryNotes"
	add_child(_notes)
	_notes.setup(_world)


func _build_side_activities() -> void:
	_side = SideActivities.new()
	_side.name = "SideActivities"
	add_child(_side)
	_side.setup(_world, _population)


func _build_mission() -> void:
	_mission = MissionController.new()
	_mission.name = "Mission"
	add_child(_mission)
	_mission.setup(_world, _population)


func get_save_slot() -> StringName:
	return SAVE_SLOT


func _restore() -> bool:
	var manager: SaveManagerService = SaveManagerService.instance()
	var clock: WorldClockService = WorldClockService.instance()
	var world_state: WorldStateService = WorldStateService.instance()
	var campaign_state: CampaignStateService = CampaignStateService.instance()
	if manager == null or clock == null or world_state == null or campaign_state == null:
		return false
	var pending: Dictionary[StringName, StringName] = manager.consume_pending_load()
	if not pending.has(CAMPAIGN_ID):
		return false
	var payload: Dictionary = manager.load_world(
		CAMPAIGN_ID, pending[CAMPAIGN_ID], world_state, clock
	)
	if payload.is_empty():
		return false
	_apply_player(payload)
	var campaign_value: Variant = payload.get("campaign", {})
	if campaign_value is Dictionary:
		campaign_state.from_dict(_as_dict(campaign_value))
	var npcs_value: Variant = payload.get("npcs", {})
	if npcs_value is Dictionary:
		_pending_npcs = _as_dict(npcs_value)
	# La población casi siempre se construye después de este punto. Llamar a
	# `_on_population_built()` aquí hacía que `restore_snapshot()` no aplicara
	# nada (el director aún no tiene definiciones) y borrara la instantánea.
	if _population != null and _population.is_built():
		_on_population_built()
	if _overlay != null:
		_overlay.show_loaded(clock.get_day(), clock.get_minute_of_day())
	_log(&"session_loaded", "dia=%d" % clock.get_day())
	return true


func _apply_player(payload: Dictionary) -> void:
	var position_value: Variant = payload.get("position", null)
	if not (position_value is Array) or _world == null:
		return
	var points: Array = _as_array(position_value)
	if points.size() != 3:
		return
	var point: Vector3 = Vector3(_to_float(points[0]), _to_float(points[1]), _to_float(points[2]))
	var yaw: float = _to_float(payload.get("yaw", 0.0))
	_world.place_player(point, yaw)


## Despierta a la ciudad: los NPC vuelven a su ancla de la nueva hora.
func _refresh_population(minute: int) -> void:
	var director: NpcDirector = _director()
	if director == null:
		return
	director.set_time(minute)
	director.teleport_to_goal()
	director.update_lod()


func _on_population_built() -> void:
	if _pending_npcs.is_empty():
		return
	var director: NpcDirector = _director()
	if director == null:
		return
	if director.restore_snapshot(_pending_npcs):
		director.update_lod()
	_pending_npcs = {}


func _log(event: StringName, detail: String) -> void:
	var log_service: SessionLogService = SessionLogService.instance()
	if log_service != null:
		log_service.mark(event, detail)


func _npc_snapshot() -> Dictionary:
	if _population == null or not _population.is_built():
		return {}
	var director: NpcDirector = _director()
	if director == null:
		return {}
	return director.get_snapshot()


func _director() -> NpcDirector:
	if _population == null:
		return null
	return _population.get_director()


static func _pack_vector(point: Vector3) -> Array:
	return [point.x, point.y, point.z]


func _to_float(value: Variant) -> float:
	return str(value).to_float()


# El payload viene de JSON; las comprobaciones `is` se hacen antes de llamar.
# Se concentran aquí las dos únicas supresiones necesarias.
static func _as_dict(value: Variant) -> Dictionary:
	@warning_ignore("unsafe_cast")
	return value as Dictionary


static func _as_array(value: Variant) -> Array:
	@warning_ignore("unsafe_cast")
	return value as Array
