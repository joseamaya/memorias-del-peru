class_name WorldStateService
extends Node
## Estado persistente del mundo: fase histórica, banderas, descubrimientos,
## estado de NPC y cambios físicos.
##
## Es un sistema de Core: no conoce campañas. Los IDs son estables y los datos
## se serializan con `to_dict()` / `from_dict()` para el guardado. No escribe en
## disco: de eso se encarga `SaveManagerService`.

signal phase_changed(phase: StringName)
signal flag_changed(key: StringName, value: int)
signal discovery_added(id: StringName)
signal npc_state_changed(id: StringName)
signal world_change_changed(id: StringName, value: int)

const INITIAL_PHASE: StringName = &"paz"

var _phase: StringName = INITIAL_PHASE
var _flags: Dictionary[StringName, int] = {}
var _discoveries: Dictionary[StringName, bool] = {}
var _npcs: Dictionary[StringName, Dictionary] = {}
var _changes: Dictionary[StringName, int] = {}


## Fija la fase histórica del mundo.
func set_phase(phase: StringName) -> void:
	if phase == &"" or phase == _phase:
		return
	_phase = phase
	phase_changed.emit(_phase)


## Fase histórica actual.
func get_phase() -> StringName:
	return _phase


## Fija una bandera. El valor 0 la borra.
func set_flag(key: StringName, value: int = 1) -> void:
	if key == &"":
		return
	if value == 0:
		if not _flags.has(key):
			return
		_flags.erase(key)
		flag_changed.emit(key, 0)
		return
	if _flags.get(key, 0) == value:
		return
	_flags[key] = value
	flag_changed.emit(key, value)


## Valor de una bandera; 0 si no existe.
func get_flag(key: StringName) -> int:
	return _flags.get(key, 0)


## Indica si la bandera tiene un valor distinto de cero.
func has_flag(key: StringName) -> bool:
	return get_flag(key) != 0


## Copia de todas las banderas.
func get_flags() -> Dictionary[StringName, int]:
	return _flags.duplicate()


## Registra un descubrimiento. No emite si ya estaba.
func discover(id: StringName) -> void:
	if id == &"" or _discoveries.has(id):
		return
	_discoveries[id] = true
	discovery_added.emit(id)


## Indica si un lugar, persona o hecho ya se descubrió.
func is_discovered(id: StringName) -> bool:
	return _discoveries.has(id)


## Descubrimientos registrados, en orden de inserción.
func get_discoveries() -> Array[StringName]:
	var result: Array[StringName] = []
	for id: StringName in _discoveries.keys():
		result.append(id)
	return result


## Guarda el estado de un NPC. El llamador no debe mutar el diccionario después.
func set_npc_state(id: StringName, state: Dictionary) -> void:
	if id == &"":
		return
	_npcs[id] = state.duplicate(true)
	npc_state_changed.emit(id)


## Estado de un NPC, o un diccionario vacío si no existe.
func get_npc_state(id: StringName) -> Dictionary:
	var state: Dictionary = {}
	if _npcs.has(id):
		state = _npcs[id]
	return state.duplicate(true)


## Indica si hay estado guardado para un NPC.
func has_npc_state(id: StringName) -> bool:
	return _npcs.has(id)


## Copia de todos los estados de NPC.
func get_npc_states() -> Dictionary[StringName, Dictionary]:
	return _npcs.duplicate(true)


## Registra un cambio físico del mundo (puerta, corral, puente, contenedor).
func set_change(id: StringName, value: int = 1) -> void:
	if id == &"":
		return
	if _changes.get(id, 0) == value:
		return
	_changes[id] = value
	world_change_changed.emit(id, value)


## Valor de un cambio físico; 0 si no existe.
func get_change(id: StringName) -> int:
	return _changes.get(id, 0)


## Indica si un cambio físico está activo.
func has_change(id: StringName) -> bool:
	return get_change(id) != 0


## Copia de todos los cambios físicos.
func get_changes() -> Dictionary[StringName, int]:
	return _changes.duplicate()


## Borra todo el estado y vuelve a la fase inicial.
func clear() -> void:
	var previous_phase: StringName = _phase
	_phase = INITIAL_PHASE
	_flags.clear()
	_discoveries.clear()
	_npcs.clear()
	_changes.clear()
	if previous_phase != _phase:
		phase_changed.emit(_phase)


## Estado serializable, con claves String para JSON.
func to_dict() -> Dictionary:
	var flags: Dictionary = {}
	for key: StringName in _flags.keys():
		flags[String(key)] = _flags[key]
	var discoveries: Array[String] = []
	for id: StringName in _discoveries.keys():
		discoveries.append(String(id))
	var npcs: Dictionary = {}
	for id: StringName in _npcs.keys():
		npcs[String(id)] = _npcs[id].duplicate(true)
	var changes: Dictionary = {}
	for id: StringName in _changes.keys():
		changes[String(id)] = _changes[id]
	return {
		"phase": String(_phase),
		"flags": flags,
		"discoveries": discoveries,
		"npcs": npcs,
		"changes": changes,
	}


## Restaura el estado. Devuelve `false` si la estructura no es válida.
func from_dict(data: Dictionary) -> bool:
	var phase_value: Variant = data.get("phase", INITIAL_PHASE)
	if not (phase_value is String or phase_value is StringName):
		return false
	var flags_value: Variant = data.get("flags", {})
	if not (flags_value is Dictionary):
		return false
	var discoveries_value: Variant = data.get("discoveries", [])
	if not (discoveries_value is Array):
		return false
	var npcs_value: Variant = data.get("npcs", {})
	if not (npcs_value is Dictionary):
		return false
	var changes_value: Variant = data.get("changes", {})
	if not (changes_value is Dictionary):
		return false
	clear()
	set_phase(StringName(str(phase_value)))
	var flags: Dictionary = _as_dict(flags_value)
	for key: Variant in flags.keys():
		_flags[StringName(str(key))] = _to_int(flags[key])
	var discoveries: Array = _as_array(discoveries_value)
	for item: Variant in discoveries:
		_discoveries[StringName(str(item))] = true
	var npcs: Dictionary = _as_dict(npcs_value)
	for key: Variant in npcs.keys():
		var state: Variant = npcs[key]
		if state is Dictionary:
			_npcs[StringName(str(key))] = _as_dict(state).duplicate(true)
	var changes: Dictionary = _as_dict(changes_value)
	for key: Variant in changes.keys():
		_changes[StringName(str(key))] = _to_int(changes[key])
	return true


func _to_int(value: Variant) -> int:
	if value is bool:
		return 1 if value else 0
	var text: String = str(value)
	if text.is_valid_int():
		return int(text)
	if text.is_valid_float():
		return int(text.to_float())
	return 0


# El origen es JSON o estado dinámico; la comprobación `is Dictionary` se hace
# antes de llamar. Se concentra aquí la única supresión necesaria.
static func _as_dict(value: Variant) -> Dictionary:
	@warning_ignore("unsafe_cast")
	return value as Dictionary


# Igual que `_as_dict`, para listas de descubrimientos.
static func _as_array(value: Variant) -> Array:
	@warning_ignore("unsafe_cast")
	return value as Array
