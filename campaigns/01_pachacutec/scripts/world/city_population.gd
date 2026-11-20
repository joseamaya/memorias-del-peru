class_name CityPopulation
extends Node3D
## Población de S1 — Cusco: 24 NPC con rutinas de mañana, tarde y noche.
##
## Los datos viven aquí como tabla compacta de blockout. Cuando exista el
## pipeline de contenido de campaña (diálogos y misiones), cada fila pasa a un
## `NpcDefinition.tres` y esta tabla desaparece; las anclas ya son IDs estables.
##
## El director de Core hace el resto: horarios, rutas por navmesh y LOD.

const TOTAL_NPCS: int = 24
const NAMED_NPCS: int = 8

## Anclas en coordenadas locales de S1. Se convierten a mundo con el terreno.
const ANCHORS: Dictionary[StringName, Vector2] = {
	&"plaza": Vector2(0.0, 10.0),
	&"mercado": Vector2(-70.0, 60.0),
	&"coricancha": Vector2(0.0, -46.0),
	&"taller": Vector2(58.0, -44.0),
	&"depositos": Vector2(108.0, -92.0),
	&"ayllu_este": Vector2(86.0, 86.0),
	&"ayllu_oeste": Vector2(-138.0, 60.0),
	&"arrabal": Vector2(-112.0, -106.0),
	&"arrabal_calle": Vector2(-112.0, -70.0),
	&"camino_oeste": Vector2(-145.0, -100.0),
	&"puerta_sur": Vector2(18.0, 132.0),
}

const MORNING_START: int = 360
const AFTERNOON_START: int = 720
const EVENING_START: int = 1020

var _world: RegionWorld = null
var _streamer: SectorStreamer = null
var _director: NpcDirector = null
var _definitions: Array[NpcDefinition] = []
var _built: bool = false


func setup(world: RegionWorld, streamer: SectorStreamer, player: PlayerFPS) -> void:
	_world = world
	_streamer = streamer
	_director = NpcDirector.new()
	_director.name = "NpcDirector"
	add_child(_director)
	_director.set_target(player)


func _process(_delta: float) -> void:
	if not _built:
		_try_build()
		return
	if _director == null:
		return
	var clock: WorldClockService = WorldClockService.instance()
	if clock == null:
		return
	_director.set_time(clock.get_minute_of_day())


func get_director() -> NpcDirector:
	return _director


func get_definition_count() -> int:
	return _definitions.size()


func get_named_count() -> int:
	var count: int = 0
	for definition: NpcDefinition in _definitions:
		if definition.name_key != &"":
			count += 1
	return count


func _try_build() -> void:
	var blockout: CuscoBlockout = _streamer.get_loaded_node(&"s1_cusco") as CuscoBlockout
	if blockout == null or _world == null:
		return
	var anchors: Dictionary[StringName, Vector3] = {}
	var region: CampaignRegion = _world.get_region()
	for id: StringName in ANCHORS.keys():
		var local: Vector2 = ANCHORS[id]
		var world_point: Vector3 = blockout.to_global(Vector3(local.x, 0.0, local.y))
		world_point.y = region.height_at(world_point.x, world_point.z)
		anchors[id] = world_point
	_build_definitions()
	_built = _director.register(_definitions, anchors)
	_director.teleport_to_goal()
	_director.update_lod()


func _build_definitions() -> void:
	_add_named(&"npc_curaca", &"PCH_NPC_CURACA", &"arrabal", &"arrabal", &"plaza", 0)
	_add_named(&"npc_tejedora", &"PCH_NPC_TEJEDORA", &"ayllu_este", &"taller", &"taller", 1)
	_add_named(&"npc_molendera", &"PCH_NPC_MOLENDERA", &"ayllu_oeste", &"mercado", &"mercado", 1)
	_add_named(
		&"npc_agricultor", &"PCH_NPC_AGRICULTOR", &"ayllu_oeste", &"puerta_sur", &"mercado", 1
	)
	_add_named(&"npc_mensajero", &"PCH_NPC_MENSAJERO", &"plaza", &"camino_oeste", &"plaza", 1)
	_add_named(&"npc_nino", &"PCH_NPC_NINO", &"arrabal_calle", &"arrabal", &"plaza", 1)
	_add_named(&"npc_anciano", &"PCH_NPC_ANCIANO", &"ayllu_este", &"plaza", &"coricancha", 1)
	_add_named(&"npc_principal", &"PCH_NPC_PRINCIPAL", &"ayllu_este", &"coricancha", &"plaza", 1)
	_add_ambient(&"npc_vecino_01", &"plaza", &"plaza", &"mercado")
	_add_ambient(&"npc_vecino_02", &"plaza", &"depositos", &"plaza")
	_add_ambient(&"npc_vecino_03", &"mercado", &"mercado", &"ayllu_oeste")
	_add_ambient(&"npc_vecino_04", &"mercado", &"plaza", &"ayllu_este")
	_add_ambient(&"npc_vecino_05", &"taller", &"taller", &"ayllu_este")
	_add_ambient(&"npc_vecino_06", &"taller", &"mercado", &"arrabal")
	_add_ambient(&"npc_vecino_07", &"arrabal", &"arrabal", &"arrabal_calle")
	_add_ambient(&"npc_vecino_08", &"arrabal_calle", &"camino_oeste", &"arrabal")
	_add_ambient(&"npc_vecino_09", &"ayllu_este", &"puerta_sur", &"ayllu_este")
	_add_ambient(&"npc_vecino_10", &"ayllu_oeste", &"mercado", &"ayllu_oeste")
	_add_ambient(&"npc_vecino_11", &"coricancha", &"coricancha", &"plaza")
	_add_ambient(&"npc_vecino_12", &"depositos", &"depositos", &"plaza")
	_add_ambient(&"npc_vecino_13", &"puerta_sur", &"camino_oeste", &"plaza")
	_add_ambient(&"npc_vecino_14", &"arrabal", &"arrabal_calle", &"camino_oeste")
	_add_ambient(&"npc_vecino_15", &"plaza", &"taller", &"arrabal")
	_add_ambient(&"npc_vecino_16", &"mercado", &"ayllu_este", &"mercado")


func _add_named(
	id: StringName,
	name_key: StringName,
	home: StringName,
	morning: StringName,
	afternoon: StringName,
	tier: int,
) -> void:
	_definitions.append(_make_definition(id, name_key, home, morning, afternoon, tier))


func _add_ambient(
	id: StringName, home: StringName, morning: StringName, afternoon: StringName
) -> void:
	_definitions.append(
		_make_definition(id, &"", home, morning, afternoon, NpcDefinition.Tier.AMBIENT)
	)


func _make_definition(
	id: StringName,
	name_key: StringName,
	home: StringName,
	morning: StringName,
	afternoon: StringName,
	tier: int,
) -> NpcDefinition:
	var definition: NpcDefinition = NpcDefinition.new()
	definition.id = id
	definition.name_key = name_key
	definition.tier = tier
	definition.home_anchor = home
	definition.work_anchor = morning
	var schedule: Array[ScheduleEntry] = [
		_entry(0, MORNING_START, home, &"rest"),
		_entry(MORNING_START, AFTERNOON_START, morning, &"work"),
		_entry(AFTERNOON_START, EVENING_START, afternoon, &"work"),
		_entry(EVENING_START, 1440, home, &"rest"),
	]
	definition.schedule = schedule
	return definition


func _entry(start: int, end: int, anchor: StringName, activity: StringName) -> ScheduleEntry:
	var entry: ScheduleEntry = ScheduleEntry.new()
	entry.start_minute = start
	entry.end_minute = end
	entry.anchor_id = anchor
	entry.activity = activity
	return entry
