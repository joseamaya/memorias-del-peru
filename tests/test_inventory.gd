extends RefCounted
## Comprueba el inventario: apilado, límites, retirada, consumo y equipo
## (ADR-0038).


func _make_item(id: StringName, category: ItemDefinition.Category, max_stack: int = 1) -> ItemDefinition:
	var item: ItemDefinition = ItemDefinition.new()
	item.id = id
	item.name_key = StringName("ITEM_%s" % String(id).to_upper())
	item.category = category
	item.max_stack = max_stack
	return item


func test_inventory_add_and_stack() -> bool:
	var inventory: Inventory = Inventory.new()
	inventory.capacity = 2
	inventory._ready()
	var item: ItemDefinition = _make_item(&"piedra", ItemDefinition.Category.AMMO, 3)
	var leftover: int = inventory.add(item, 4)
	var ok: bool = leftover == 0
	ok = ok and inventory.count(&"piedra") == 4
	ok = ok and inventory.get_slots().size() == 2
	leftover = inventory.add(item, 3)
	ok = ok and leftover == 1
	ok = ok and inventory.count(&"piedra") == 6
	inventory.free()
	return ok


func test_inventory_full_returns_leftover() -> bool:
	var inventory: Inventory = Inventory.new()
	inventory.capacity = 1
	inventory._ready()
	var item: ItemDefinition = _make_item(&"coca", ItemDefinition.Category.CONSUMABLE, 1)
	var leftover: int = inventory.add(item, 2)
	var ok: bool = leftover == 1
	ok = ok and inventory.count(&"coca") == 1
	inventory.free()
	return ok


func test_inventory_remove() -> bool:
	var inventory: Inventory = Inventory.new()
	inventory.capacity = 4
	inventory._ready()
	var item: ItemDefinition = _make_item(&"maiz", ItemDefinition.Category.CONSUMABLE, 5)
	inventory.add(item, 5)
	var removed: int = inventory.remove(&"maiz", 2)
	var ok: bool = removed == 2 and inventory.count(&"maiz") == 3
	removed = inventory.remove(&"maiz", 10)
	ok = ok and removed == 3 and not inventory.has(&"maiz")
	ok = ok and inventory.remove(&"agua", 1) == 0
	inventory.free()
	return ok


func test_inventory_use_consumable() -> bool:
	var inventory: Inventory = Inventory.new()
	var character: CharacterState = CharacterState.new()
	var stamina: StaminaComponent = StaminaComponent.new()
	stamina.restore(stamina.get_maximum())
	stamina.consume(30.0)
	var item: ItemDefinition = _make_item(&"coca", ItemDefinition.Category.CONSUMABLE, 5)
	item.health_restore = 20.0
	item.stamina_restore = 15.0
	item.morale_change = -5.0
	inventory.add(item, 2)
	character.damage(50.0)
	var ok: bool = inventory.use(&"coca", character, stamina)
	ok = ok and is_equal_approx(character.get_health(), 70.0)
	ok = ok and is_equal_approx(stamina.get_current(), 85.0)
	ok = ok and is_equal_approx(character.get_morale(), 95.0)
	ok = ok and inventory.count(&"coca") == 1
	character.free()
	stamina.free()
	inventory.free()
	return ok


func test_inventory_use_rejects_non_consumable() -> bool:
	var inventory: Inventory = Inventory.new()
	var character: CharacterState = CharacterState.new()
	var item: ItemDefinition = _make_item(&"honda", ItemDefinition.Category.EQUIPMENT, 1)
	item.slot = ItemDefinition.Slot.MAIN_HAND
	inventory.add(item, 1)
	var reasons: Array[StringName] = []
	inventory.use_failed.connect(func(_item: ItemDefinition, reason: StringName) -> void: reasons.append(reason))
	var ok: bool = not inventory.use(&"honda", character)
	ok = ok and reasons == [&"not_consumable"]
	ok = ok and inventory.has(&"honda")
	character.free()
	inventory.free()
	return ok


func test_inventory_equip_and_unequip() -> bool:
	var inventory: Inventory = Inventory.new()
	inventory._ready()
	var item: ItemDefinition = _make_item(&"honda", ItemDefinition.Category.EQUIPMENT, 1)
	item.slot = ItemDefinition.Slot.MAIN_HAND
	inventory.add(item, 1)
	var ok: bool = inventory.equip(&"honda")
	ok = ok and not inventory.has(&"honda")
	ok = ok and inventory.get_equipped()[0] == item
	ok = ok and inventory.unequip(0)
	ok = ok and inventory.has(&"honda")
	ok = ok and inventory.get_equipped()[0] == null
	inventory.free()
	return ok


func test_inventory_clear() -> bool:
	var inventory: Inventory = Inventory.new()
	inventory._ready()
	var item: ItemDefinition = _make_item(&"agua", ItemDefinition.Category.CONSUMABLE, 2)
	inventory.add(item, 2)
	inventory.clear()
	var ok: bool = inventory.is_empty() and inventory.count(&"agua") == 0
	inventory.free()
	return ok
