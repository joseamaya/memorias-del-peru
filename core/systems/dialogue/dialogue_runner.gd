class_name DialogueRunner
extends Node
## Recorre un [DialogueGraph]: muestra líneas, filtra opciones por condiciones y
## aplica efectos. No conoce la UI ni la campaña.
##
## La UI se suscribe a [signal line_shown] y [signal choices_shown] y llama a
## [method advance] o [method choose]. Las banderas viven en el nodo y
## sobreviven entre conversaciones; [method reset] las borra.
##
## Las condiciones se evalúan contra:
## - banderas propias del nodo,
## - el [CharacterState] asignado (habilidades y reputación),
## - el [Inventory] asignado (objetos).

signal started
signal line_shown(speaker_key: StringName, text_key: StringName)
signal choices_shown(text_keys: Array[StringName])
signal finished
signal flag_changed(key: StringName, value: int)
signal effect_applied(effect: DialogueEffect)

## Estado del jugador para habilidades y reputación.
@export var character: CharacterState = null
## Inventario del jugador para condiciones y efectos de objetos.
@export var inventory: Inventory = null

var _graph: DialogueGraph = null
var _current: DialogueNode = null
var _visible: Array[DialogueChoice] = []
var _flags: Dictionary[StringName, int] = {}
var _visited: Dictionary[StringName, bool] = {}
var _chosen: Dictionary[String, bool] = {}


## Empieza una conversación. Si [param entry_id] está vacío, usa el del grafo.
func start(graph: DialogueGraph, entry_id: StringName = &"") -> bool:
	if graph == null:
		return false
	var start_id: StringName = entry_id if entry_id != &"" else graph.entry_id
	var node: DialogueNode = graph.find_node(start_id)
	if node == null:
		return false
	_graph = graph
	_current = node
	_visible.clear()
	_visited.clear()
	_chosen.clear()
	started.emit()
	_show_current()
	return true


## Indica si hay una conversación en curso.
func is_active() -> bool:
	return _current != null


## Nodo actual, o `null` si la conversación terminó.
func get_current_node() -> DialogueNode:
	return _current


## Clave de texto de la línea actual.
func get_current_text_key() -> StringName:
	return _current.text_key if _current != null else &""


## Clave del nombre del hablante actual.
func get_current_speaker_key() -> StringName:
	return _current.speaker_key if _current != null else &""


## Opciones visibles en este momento.
func get_visible_choices() -> Array[DialogueChoice]:
	var copy: Array[DialogueChoice] = []
	copy.assign(_visible)
	return copy


## Claves de texto de las opciones visibles, en orden.
func get_visible_choice_text_keys() -> Array[StringName]:
	var keys: Array[StringName] = []
	for choice: DialogueChoice in _visible:
		keys.append(choice.text_key)
	return keys


## Avanza una línea sin opciones. Devuelve `false` si hay que elegir.
func advance() -> bool:
	if not is_active() or not _visible.is_empty():
		return false
	_go_to(_current.next_id)
	return true


## Elige una opción visible por su índice. Devuelve `false` si no es válida.
func choose(index: int) -> bool:
	if not is_active() or index < 0 or index >= _visible.size():
		return false
	var choice: DialogueChoice = _visible[index]
	if choice.once:
		_chosen[_choice_key(choice)] = true
	for effect: DialogueEffect in choice.effects:
		_apply_effect(effect)
	_go_to(choice.next_id)
	return true


## Valor de una bandera; 0 si no existe.
func get_flag(key: StringName) -> int:
	return _flags.get(key, 0)


## Fija una bandera y emite [signal flag_changed].
func set_flag(key: StringName, value: int) -> void:
	if key == &"":
		return
	if get_flag(key) == value:
		return
	_flags[key] = value
	flag_changed.emit(key, value)


## Indica si una bandera tiene un valor distinto de cero.
func has_flag(key: StringName) -> bool:
	return get_flag(key) != 0


## Borra banderas y estado de la conversación.
func reset() -> void:
	_graph = null
	_current = null
	_visible.clear()
	_flags.clear()
	_visited.clear()
	_chosen.clear()


func _show_current() -> void:
	if _current == null or _current.id == &"end" or _current.id == &"":
		_finish()
		return
	if not _visited.has(_current.id):
		_visited[_current.id] = true
		for effect: DialogueEffect in _current.effects:
			_apply_effect(effect)
	_visible.clear()
	for choice: DialogueChoice in _current.choices:
		if choice == null:
			continue
		if choice.once and _chosen.has(_choice_key(choice)):
			continue
		if not _choice_available(choice):
			continue
		_visible.append(choice)
	line_shown.emit(_current.speaker_key, _current.text_key)
	if not _visible.is_empty():
		choices_shown.emit(get_visible_choice_text_keys())


func _go_to(next_id: StringName) -> void:
	if next_id == &"end" or next_id == &"":
		_finish()
		return
	var node: DialogueNode = _graph.find_node(next_id) if _graph != null else null
	if node == null:
		_finish()
		return
	_current = node
	_show_current()


func _finish() -> void:
	_current = null
	_visible.clear()
	finished.emit()


func _choice_available(choice: DialogueChoice) -> bool:
	for condition: DialogueCondition in choice.conditions:
		if not _condition_met(condition):
			return false
	return true


func _condition_met(condition: DialogueCondition) -> bool:
	if condition == null:
		return true
	var value: int = 0
	match condition.kind:
		DialogueCondition.Kind.FLAG:
			value = get_flag(condition.key)
		DialogueCondition.Kind.ITEM:
			value = inventory.count(condition.key) if inventory != null else 0
		DialogueCondition.Kind.SKILL:
			value = character.get_skill(condition.key) if character != null else 0
		DialogueCondition.Kind.REPUTATION:
			value = character.get_reputation(condition.group) if character != null else 0
	var met: bool = value >= condition.minimum
	return not met if condition.negate else met


func _apply_effect(effect: DialogueEffect) -> void:
	if effect == null:
		return
	match effect.kind:
		DialogueEffect.Kind.SET_FLAG:
			set_flag(effect.key, effect.amount)
		DialogueEffect.Kind.ITEM_ADD:
			if inventory != null and effect.item != null:
				inventory.add(effect.item, maxi(effect.amount, 1))
		DialogueEffect.Kind.ITEM_REMOVE:
			if inventory != null:
				inventory.remove(effect.key, maxi(effect.amount, 1))
		DialogueEffect.Kind.REPUTATION:
			if character != null:
				character.change_reputation(effect.group, effect.amount)
	effect_applied.emit(effect)


func _choice_key(choice: DialogueChoice) -> String:
	return String(_current.id) + ":" + String(choice.text_key)
