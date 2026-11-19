class_name NpcDirector
extends Node3D
## Director de NPC por sector: horarios, spawn/despawn y LOD de simulación.
##
## Recibe definiciones y anclas, mantiene una posición lógica por NPC aunque su
## actor esté descargado y decide cada fotograma qué actores existen, cuáles se
## mueven y cuáles reproducen animación. Los tier A/B se guardan en el snapshot;
## los de ambiente no persisten.

signal npc_spawned(id: StringName)
signal npc_despawned(id: StringName)
signal schedule_applied(id: StringName, anchor_id: StringName)

const BODY_OFFSET: float = 0.9
const ANCHOR_RADIUS: float = 1.6
const ANCHOR_RING_STEP: float = 0.65
const GOLDEN_ANGLE: float = 2.399963

@export var simulate_distance: float = 90.0
@export var animate_distance: float = 40.0
@export var max_active: int = 60
@export var max_animated: int = 25
## Los tier C se simulan y animan a menos distancia.
@export var ambient_ratio: float = 0.55
## Margen para no alternar spawn/despawn en el borde.
@export var despawn_margin: float = 10.0
@export var autostart: bool = true

var world_conditions: Dictionary[StringName, int] = {}
var target: Node3D = null

var _definitions: Array[NpcDefinition] = []
var _by_id: Dictionary[StringName, NpcDefinition] = {}
var _anchors: Dictionary[StringName, Vector3] = {}
var _actors: Dictionary[StringName, NpcSimActor] = {}
var _movers: Dictionary[StringName, NpcMover] = {}
var _positions: Dictionary[StringName, Vector3] = {}
var _goals: Dictionary[StringName, Vector3] = {}
var _targets: Dictionary[StringName, StringName] = {}
var _indices: Dictionary[StringName, int] = {}
var _minute: int = 0
var _clock: WorldClockService = null


func _process(delta: float) -> void:
	if not autostart:
		return
	if _clock == null:
		_clock = WorldClockService.instance()
	if _clock != null:
		_minute = _clock.get_minute_of_day()
		_refresh_schedule()
	advance(delta, delta)
	update_lod()


## Registra las definiciones y sus anclas. Devuelve `false` si no hay ninguna
## definición válida.
func register(definitions: Array[NpcDefinition], anchors: Dictionary[StringName, Vector3]) -> bool:
	if definitions.is_empty():
		return false
	_anchors = anchors.duplicate()
	for definition: NpcDefinition in definitions:
		if definition == null or not definition.is_valid():
			continue
		if _positions.has(definition.id):
			continue
		_definitions.append(definition)
		_by_id[definition.id] = definition
		_indices[definition.id] = _definitions.size() - 1
		var anchor_id: StringName = _resolve_anchor(definition.home_anchor, definition)
		_targets[definition.id] = anchor_id
		_goals[definition.id] = _goal_for(_indices[definition.id], anchor_id)
		_positions[definition.id] = _goals[definition.id]
		_movers[definition.id] = NpcMover.new()
	_refresh_schedule()
	return not _definitions.is_empty()


func set_target(node: Node3D) -> void:
	target = node


func set_time(minute: int) -> void:
	_minute = clampi(minute, 0, 1439)
	_refresh_schedule()


## Coloca a todos los NPC en su ancla actual y corta las rutas.
func teleport_to_goal() -> void:
	for id: StringName in _positions.keys():
		if _goals.has(id):
			_positions[id] = _goals[id]
		var actor: NpcSimActor = _actors.get(id)
		if actor != null:
			actor.position = _positions[id]
			actor.mover.set_path(PackedVector3Array())


## Avanza la simulación de los actores activos. Determinista para las pruebas.
func advance(seconds: float, step: float = 0.2) -> void:
	if seconds <= 0.0:
		return
	var safe_step: float = maxf(step, 0.02)
	var elapsed: float = 0.0
	while elapsed < seconds:
		var slice: float = minf(safe_step, seconds - elapsed)
		for id: StringName in _actors.keys():
			var actor: NpcSimActor = _actors[id]
			actor.advance(slice)
			_positions[id] = actor.position
		elapsed += slice


## Decide qué actores existen y su nivel de detalle para la cámara actual.
func update_lod() -> void:
	var center: Vector3 = _target_position()
	var candidates: Array[Dictionary] = []
	for definition: NpcDefinition in _definitions:
		var id: StringName = definition.id
		var npc_position: Vector3 = _positions.get(id, Vector3.ZERO)
		(
			candidates
			. append(
				{
					"id": id,
					"distance": npc_position.distance_to(center),
					"tier": definition.tier,
				}
			)
		)
	candidates.sort_custom(_closer_first)
	var active: int = 0
	var animated: int = 0
	for candidate: Dictionary in candidates:
		var id: StringName = candidate["id"]
		var distance: float = candidate["distance"]
		var tier: int = candidate["tier"]
		var margin: float = despawn_margin if _actors.has(id) else 0.0
		var keep: bool = (
			tier == NpcDefinition.Tier.NARRATIVE or distance <= _simulate_limit(tier) + margin
		)
		if not keep or active >= max_active:
			_despawn(id)
			continue
		var actor: NpcSimActor = _spawn(id)
		active += 1
		var wants_animation: bool = distance <= _animate_limit(tier)
		if wants_animation and animated < max_animated:
			actor.set_lod(NpcSimActor.Lod.ANIMATED)
			animated += 1
		else:
			actor.set_lod(NpcSimActor.Lod.SIMULATED)


func get_active_count() -> int:
	return _actors.size()


func get_animated_count() -> int:
	var count: int = 0
	for actor: NpcSimActor in _actors.values():
		if actor.is_animated():
			count += 1
	return count


func get_registered_count() -> int:
	return _definitions.size()


func get_minute() -> int:
	return _minute


func get_npc_position(id: StringName) -> Vector3:
	var actor: NpcSimActor = _actors.get(id)
	if actor != null:
		return actor.position
	return _positions.get(id, Vector3.ZERO)


func get_goal(id: StringName) -> Vector3:
	return _goals.get(id, Vector3.ZERO)


func get_anchor(id: StringName) -> StringName:
	return _targets.get(id, &"")


func get_lod(id: StringName) -> int:
	var actor: NpcSimActor = _actors.get(id)
	if actor == null:
		return NpcSimActor.Lod.DORMANT
	return actor.get_lod()


func is_at_goal(id: StringName, tolerance: float = 0.6) -> bool:
	return get_npc_position(id).distance_to(get_goal(id)) <= tolerance


## Estado persistente de los NPC con nombre y rutina. El ambiente no se guarda.
func get_snapshot() -> Dictionary:
	var npcs: Dictionary = {}
	for definition: NpcDefinition in _definitions:
		if definition.tier == NpcDefinition.Tier.AMBIENT:
			continue
		var npc_position: Vector3 = get_npc_position(definition.id)
		npcs[String(definition.id)] = {
			"position": [npc_position.x, npc_position.y, npc_position.z],
			"anchor": str(_targets.get(definition.id, &"")),
		}
	return {"minute": _minute, "npcs": npcs}


## Restaura un snapshot de `get_snapshot()`. No recrea actores: el siguiente
## `update_lod` los vuelve a poblar.
func restore_snapshot(data: Dictionary) -> bool:
	var npcs_value: Variant = data.get("npcs", null)
	if not (npcs_value is Dictionary):
		return false
	var npcs: Dictionary = npcs_value
	_minute = clampi(_to_int(data.get("minute", _minute)), 0, 1439)
	for key: Variant in npcs.keys():
		var id: StringName = StringName(str(key))
		if not _positions.has(id):
			continue
		var state_value: Variant = npcs[key]
		if not (state_value is Dictionary):
			continue
		var state: Dictionary = state_value
		var point_value: Variant = state.get("position", null)
		if point_value is Array:
			var point: Array = point_value
			if point.size() == 3:
				_positions[id] = Vector3(
					_to_float(point[0]), _to_float(point[1]), _to_float(point[2])
				)
		var anchor_id: StringName = StringName(str(state.get("anchor", _targets.get(id, &""))))
		if _anchors.has(anchor_id):
			_targets[id] = anchor_id
			_goals[id] = _goal_for(_indices[id], anchor_id)
		var actor: NpcSimActor = _actors.get(id)
		if actor != null:
			actor.position = _positions[id]
			actor.mover.set_path(PackedVector3Array())
	return true


func _refresh_schedule() -> void:
	for definition: NpcDefinition in _definitions:
		var anchor_id: StringName = _resolve_anchor(
			definition.get_anchor(_minute, world_conditions), definition
		)
		if _targets.get(definition.id, &"") == anchor_id:
			continue
		_targets[definition.id] = anchor_id
		_goals[definition.id] = _goal_for(_indices[definition.id], anchor_id)
		schedule_applied.emit(definition.id, anchor_id)
		var actor: NpcSimActor = _actors.get(definition.id)
		if actor != null:
			actor.mover.set_path(_path_for(actor.position, _goals[definition.id]))


func _spawn(id: StringName) -> NpcSimActor:
	if _actors.has(id):
		return _actors[id]
	var actor: NpcSimActor = NpcSimActor.new()
	actor.setup(_by_id[id], _movers[id])
	add_child(actor)
	actor.position = _positions.get(id, Vector3.ZERO)
	_actors[id] = actor
	npc_spawned.emit(id)
	return actor


func _despawn(id: StringName) -> void:
	var actor: NpcSimActor = _actors.get(id)
	if actor == null:
		return
	_positions[id] = actor.position
	_actors.erase(id)
	actor.queue_free()
	npc_despawned.emit(id)


func _path_for(origin: Vector3, goal: Vector3) -> PackedVector3Array:
	var ground_goal: Vector3 = Vector3(goal.x, goal.y - BODY_OFFSET, goal.z)
	var fallback: PackedVector3Array = PackedVector3Array([ground_goal])
	if not is_inside_tree():
		return fallback
	var map: RID = get_world_3d().navigation_map
	if not map.is_valid() or not NavigationServer3D.map_is_active(map):
		return fallback
	var from: Vector3 = Vector3(origin.x, ground_goal.y, origin.z)
	var path: PackedVector3Array = NavigationServer3D.map_get_path(map, from, ground_goal, true)
	if path.size() < 2:
		return fallback
	return path


func _goal_for(index: int, anchor_id: StringName) -> Vector3:
	var base: Vector3 = Vector3.ZERO
	if _anchors.has(anchor_id):
		base = _anchors[anchor_id]
	var radius: float = ANCHOR_RADIUS + float(index % 4) * ANCHOR_RING_STEP
	var angle: float = float(index) * GOLDEN_ANGLE
	return base + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)


func _resolve_anchor(anchor_id: StringName, definition: NpcDefinition) -> StringName:
	if _anchors.has(anchor_id):
		return anchor_id
	if _anchors.has(definition.home_anchor):
		return definition.home_anchor
	return anchor_id


func _simulate_limit(tier: int) -> float:
	if tier == NpcDefinition.Tier.NARRATIVE:
		return INF
	if tier == NpcDefinition.Tier.AMBIENT:
		return simulate_distance * ambient_ratio
	return simulate_distance


func _animate_limit(tier: int) -> float:
	if tier == NpcDefinition.Tier.AMBIENT:
		return animate_distance * ambient_ratio
	return animate_distance


func _target_position() -> Vector3:
	if target != null and is_instance_valid(target):
		return target.global_position
	return global_position


func _to_int(value: Variant) -> int:
	var text: String = str(value)
	if text.is_valid_int():
		return text.to_int()
	if text.is_valid_float():
		return int(text.to_float())
	return 0


func _to_float(value: Variant) -> float:
	var text: String = str(value)
	if text.is_valid_float():
		return text.to_float()
	return 0.0


func _closer_first(first: Dictionary, second: Dictionary) -> bool:
	return str(first["distance"]).to_float() < str(second["distance"]).to_float()
