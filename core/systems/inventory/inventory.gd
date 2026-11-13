class_name Inventory
extends Node
## Inventario del jugador: ocho huecos, tres equipados y consumibles.
##
## Guarda referencias a [ItemDefinition] y cantidades. No conoce la UI ni la
## campaña: emite señales y la UI decide qué mostrar. El aliento se aplica sobre
## un [StaminaComponent] opcional para no duplicar ese estado.
##
## Reglas:
## - Los objetos se apilan hasta [member ItemDefinition.max_stack].
## - [method add] añade lo que cabe y devuelve el resto; nunca pierde objetos en
##   silencio.
## - Los objetos de encargo no ocupan hueco: los lleva el diario, no el inventario.

## Montón de un objeto dentro de un hueco.
class Stack:
	var item: ItemDefinition
	var amount: int

	func _init(stack_item: ItemDefinition, stack_amount: int) -> void:
		item = stack_item
		amount = stack_amount


signal changed
signal item_added(item: ItemDefinition, amount: int)
signal item_removed(item: ItemDefinition, amount: int)
signal item_used(item: ItemDefinition)
signal equipment_changed
signal use_failed(item: ItemDefinition, reason: StringName)

## Huecos de mochila.
@export_range(1, 24, 1) var capacity: int = 8
## Huecos de equipo (mano principal, mano torpe y prenda).
@export_range(1, 3, 1) var equipment_capacity: int = 3

var _stacks: Array[Stack] = []
var _equipment: Array[ItemDefinition] = []


func _ready() -> void:
	_ensure_equipment()


## Devuelve una copia de los montones, en orden.
func get_slots() -> Array[Stack]:
	var copy: Array[Stack] = []
	copy.assign(_stacks)
	return copy


## Devuelve una copia del equipo, con `null` en los huecos libres.
func get_equipped() -> Array[ItemDefinition]:
	_ensure_equipment()
	var copy: Array[ItemDefinition] = []
	copy.assign(_equipment)
	return copy


## Indica si la mochila está vacía.
func is_empty() -> bool:
	return _stacks.is_empty()


## Cuántos objetos de [param item_id] hay en la mochila.
func count(item_id: StringName) -> int:
	var total: int = 0
	for stack: Stack in _stacks:
		if stack.item != null and stack.item.id == item_id:
			total += stack.amount
	return total


## Indica si hay al menos [param amount] objetos de [param item_id].
func has(item_id: StringName, amount: int = 1) -> bool:
	return count(item_id) >= amount


## Añade [param amount] objetos y devuelve lo que no cupo.
##
## Si el objeto es apilable, completa primero los montones existentes.
func add(item: ItemDefinition, amount: int = 1) -> int:
	if item == null or item.id == &"" or amount <= 0:
		return amount
	var remaining: int = amount
	if item.max_stack > 1:
		for stack: Stack in _stacks:
			if remaining <= 0:
				break
			if stack.item == null or stack.item.id != item.id:
				continue
			var space: int = item.max_stack - stack.amount
			if space <= 0:
				continue
			var moved: int = mini(space, remaining)
			stack.amount += moved
			remaining -= moved
	while remaining > 0 and _stacks.size() < capacity:
		var moved: int = mini(item.max_stack, remaining)
		_stacks.append(Stack.new(item, moved))
		remaining -= moved
	var added: int = amount - remaining
	if added > 0:
		item_added.emit(item, added)
		changed.emit()
	return remaining


## Quita hasta [param amount] objetos y devuelve cuántos se quitaron.
func remove(item_id: StringName, amount: int = 1) -> int:
	if amount <= 0:
		return 0
	var definition: ItemDefinition = find_definition(item_id)
	var removed: int = 0
	var index: int = _stacks.size() - 1
	while index >= 0 and removed < amount:
		var stack: Stack = _stacks[index]
		if stack.item != null and stack.item.id == item_id:
			var taken: int = mini(stack.amount, amount - removed)
			stack.amount -= taken
			removed += taken
			if stack.amount <= 0:
				_stacks.remove_at(index)
		index -= 1
	if removed > 0 and definition != null:
		item_removed.emit(definition, removed)
		changed.emit()
	return removed


## Consume un objeto y aplica sus efectos.
##
## [param character] recibe salud y ánimo; [param stamina], si se pasa, recibe
## aliento. Solo se consumen objetos de categoría
## [constant ItemDefinition.Category.CONSUMABLE].
func use(item_id: StringName, character: CharacterState = null, stamina: StaminaComponent = null) -> bool:
	var index: int = _find_slot(item_id)
	if index == -1:
		use_failed.emit(find_definition(item_id), &"not_found")
		return false
	var item: ItemDefinition = _stacks[index].item
	if item == null or not item.is_consumable():
		use_failed.emit(item, &"not_consumable")
		return false
	if character != null:
		if item.health_restore > 0.0:
			character.heal(item.health_restore)
		if not is_zero_approx(item.morale_change):
			character.change_morale(item.morale_change)
	if stamina != null and item.stamina_restore > 0.0:
		stamina.restore(item.stamina_restore)
	_remove_at(index, 1)
	item_used.emit(item)
	changed.emit()
	return true


## Equipa el primer objeto de [param item_id] en un hueco libre.
func equip(item_id: StringName) -> bool:
	var index: int = _find_slot(item_id)
	if index == -1:
		return false
	var item: ItemDefinition = _stacks[index].item
	if item == null or not item.is_equipment():
		return false
	_ensure_equipment()
	for slot_index: int in range(_equipment.size()):
		if _equipment[slot_index] == null:
			_equipment[slot_index] = item
			_remove_at(index, 1)
			equipment_changed.emit()
			changed.emit()
			return true
	return false


## Devuelve al inventario el objeto del hueco de equipo indicado.
func unequip(slot_index: int) -> bool:
	_ensure_equipment()
	if slot_index < 0 or slot_index >= _equipment.size():
		return false
	var item: ItemDefinition = _equipment[slot_index]
	if item == null:
		return false
	if add(item, 1) != 0:
		return false
	_equipment[slot_index] = null
	equipment_changed.emit()
	changed.emit()
	return true


## Busca la definición de un objeto por su identificador, en mochila o equipo.
func find_definition(item_id: StringName) -> ItemDefinition:
	for stack: Stack in _stacks:
		if stack.item != null and stack.item.id == item_id:
			return stack.item
	_ensure_equipment()
	for item: ItemDefinition in _equipment:
		if item != null and item.id == item_id:
			return item
	return null


## Vacía la mochila y el equipo.
func clear() -> void:
	_stacks.clear()
	_ensure_equipment()
	for index: int in range(_equipment.size()):
		_equipment[index] = null
	equipment_changed.emit()
	changed.emit()


func _find_slot(item_id: StringName) -> int:
	for index: int in range(_stacks.size()):
		var stack: Stack = _stacks[index]
		if stack.item != null and stack.item.id == item_id:
			return index
	return -1


func _remove_at(index: int, amount: int) -> void:
	if index < 0 or index >= _stacks.size():
		return
	var stack: Stack = _stacks[index]
	stack.amount -= amount
	if stack.amount <= 0:
		_stacks.remove_at(index)


func _ensure_equipment() -> void:
	if not _equipment.is_empty():
		return
	for _index: int in range(equipment_capacity):
		_equipment.append(null)
