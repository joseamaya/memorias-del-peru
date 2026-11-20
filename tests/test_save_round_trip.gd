extends RefCounted
## Comprueba el guardado versionado y el ciclo mundo/reloj/jugador (F1.6).


func test_save_slot_round_trip() -> bool:
	var manager: SaveManagerService = SaveManagerService.new()
	var campaign: StringName = StringName("test_save_%d" % Time.get_ticks_msec())
	var slot: StringName = &"slot_a"
	var ok: bool = manager.save_slot(campaign, slot, {"value": 7, "nested": {"name": "prueba"}})
	ok = ok and manager.has_slot(campaign, slot)
	var data: Dictionary = manager.load_slot(campaign, slot)
	ok = ok and _to_int(data.get("version", 0)) == SaveManagerService.SCHEMA_VERSION
	ok = ok and str(data.get("campaign", "")) == String(campaign)
	ok = ok and str(data.get("slot", "")) == String(slot)
	ok = ok and _to_int(data.get("value", 0)) == 7
	var nested_value: Variant = data.get("nested", {})
	ok = ok and nested_value is Dictionary
	if nested_value is Dictionary:
		ok = ok and str(_as_dict(nested_value).get("name", "")) == "prueba"
	var slots: Array[String] = manager.list_slots(campaign)
	ok = ok and slots.has(String(slot))
	ok = ok and manager.save_slot(campaign, slot, {"value": 9})
	data = manager.load_slot(campaign, slot)
	ok = ok and _to_int(data.get("value", 0)) == 9
	ok = ok and manager.delete_slot(campaign, slot)
	ok = ok and not manager.has_slot(campaign, slot)
	ok = ok and manager.load_slot(campaign, slot).is_empty()
	_cleanup(manager, campaign)
	manager.free()
	return ok


func test_save_invalid_names() -> bool:
	var manager: SaveManagerService = SaveManagerService.new()
	var ok: bool = not manager.save_slot(&"../fuera", &"slot", {})
	ok = ok and manager.slot_path(&"../fuera", &"slot").is_empty()
	ok = ok and manager.load_slot(&"../fuera", &"slot").is_empty()
	ok = ok and not manager.delete_slot(&"../fuera", &"slot")
	ok = ok and not manager.is_valid_name(&"")
	ok = ok and not manager.is_valid_name(&"con espacio")
	manager.free()
	return ok


func test_save_world_round_trip() -> bool:
	var manager: SaveManagerService = SaveManagerService.new()
	var world: WorldStateService = WorldStateService.new()
	var clock: WorldClockService = WorldClockService.new()
	world.clear()
	world.set_phase(&"noticia")
	world.set_flag(&"mensajero_ayudado", 1)
	world.discover(&"poi_manantial")
	world.set_change(&"corral_reparado", 1)
	clock.autostart = false
	clock.set_time(2, 480.0)
	var campaign: StringName = StringName("test_world_%d" % Time.get_ticks_msec())
	var slot: StringName = &"auto_01"
	var ok: bool = manager.save_world(campaign, slot, world, clock, {"inventory": ["agua"]})
	var restored_world: WorldStateService = WorldStateService.new()
	var restored_clock: WorldClockService = WorldClockService.new()
	restored_clock.autostart = false
	var player: Dictionary = manager.load_world(campaign, slot, restored_world, restored_clock)
	ok = ok and restored_world.get_phase() == &"noticia"
	ok = ok and restored_world.get_flag(&"mensajero_ayudado") == 1
	ok = ok and restored_world.is_discovered(&"poi_manantial")
	ok = ok and restored_world.get_change(&"corral_reparado") == 1
	ok = ok and restored_clock.get_day() == 2
	ok = ok and restored_clock.get_minute_of_day() == 480
	var inventory: Variant = player.get("inventory", [])
	ok = ok and inventory is Array
	if inventory is Array:
		ok = ok and _as_array(inventory).size() == 1
	ok = ok and manager.delete_slot(campaign, slot)
	_cleanup(manager, campaign)
	world.free()
	clock.free()
	restored_world.free()
	restored_clock.free()
	manager.free()
	return ok


func test_pending_load_requires_a_slot() -> bool:
	var manager: SaveManagerService = SaveManagerService.new()
	var campaign: StringName = StringName("test_pending_%d" % Time.get_ticks_msec())
	var slot: StringName = &"auto"
	var ok: bool = not manager.request_load(campaign, slot)
	ok = ok and not manager.has_pending_load()
	ok = ok and manager.save_slot(campaign, slot, {"value": 1})
	ok = ok and manager.request_load(campaign, slot)
	ok = ok and manager.has_pending_load()
	var pending: Dictionary[StringName, StringName] = manager.consume_pending_load()
	ok = ok and pending.get(campaign, &"") == slot
	ok = ok and not manager.has_pending_load()
	ok = ok and manager.consume_pending_load().is_empty()
	ok = ok and manager.request_load(campaign, slot)
	manager.cancel_pending_load()
	ok = ok and not manager.has_pending_load()
	ok = ok and not manager.request_load(campaign, &"no_existe")
	ok = ok and manager.delete_slot(campaign, slot)
	_cleanup(manager, campaign)
	manager.free()
	return ok


func _to_int(value: Variant) -> int:
	var text: String = str(value)
	if text.is_valid_int():
		return int(text)
	if text.is_valid_float():
		return int(text.to_float())
	return 0


# El origen es JSON; la comprobación `is` se hace antes de llamar.
static func _as_dict(value: Variant) -> Dictionary:
	@warning_ignore("unsafe_cast")
	return value as Dictionary


static func _as_array(value: Variant) -> Array:
	@warning_ignore("unsafe_cast")
	return value as Array


func _cleanup(manager: SaveManagerService, campaign: StringName) -> void:
	var slots: Array[String] = manager.list_slots(campaign)
	for slot_name: String in slots:
		manager.delete_slot(campaign, StringName(slot_name))
	DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SaveManagerService.SAVE_DIR.path_join(String(campaign)))
	)
