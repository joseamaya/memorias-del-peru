class_name CampaignProgress
extends RefCounted
## Estado de la campaña que sobrevive al cambio de escena: salud, ánimo,
## aliento, habilidades, reputación, inventario, oficio y diario.
##
## Vive en la capa de campaña y usa el almacén genérico de [CampaignState]. No
## conoce la UI: cada mundo llama a [method apply] al entrar y a [method save]
## antes de salir. Los puntos de control guardan una copia completa y se
## restauran al morir.

const STATE_KEY: StringName = &"progress"
const CHECKPOINT_KEY: StringName = &"checkpoint"
const RESPAWN_KEY: StringName = &"respawn"
const OFICIO_KEY: StringName = &"oficio"

const SKILLS: Array[StringName] = [&"honda", &"mano", &"palabra", &"oficio", &"monte"]
const GROUPS: Array[StringName] = [&"llacta", &"comitiva", &"cusco"]


## Guarda el estado del mundo en el almacén de campaña.
static func save(world: Node) -> void:
	if world == null:
		return
	CampaignState.set_data(STATE_KEY, snapshot(world))


## Aplica el estado guardado al mundo. Con [param replace_inventory] se vacía
## antes el inventario (restauración de punto de control); si no, se suman los
## objetos guardados a los que la escena ya haya creado.
static func apply(world: Node, replace_inventory: bool = false) -> void:
	if world == null:
		return
	var data: Dictionary = _as_dict(CampaignState.get_data(STATE_KEY, {}))
	if data.is_empty():
		return
	_apply_data(world, data, replace_inventory)


## Guarda un punto de control en [param scene_position].
static func save_checkpoint(world: Node, scene_position: Vector3) -> void:
	if world == null:
		return
	var data: Dictionary = snapshot(world)
	data["scene"] = world.scene_file_path
	data["position"] = scene_position
	CampaignState.set_data(CHECKPOINT_KEY, data)


## Marca que la próxima carga de la escena debe restaurar el punto de control.
static func request_respawn() -> void:
	CampaignState.set_data(RESPAWN_KEY, true)


## Indica si hay un rescate pendiente.
static func is_respawn_pending() -> bool:
	return CampaignState.get_data(RESPAWN_KEY, false) == true


## Restaura el punto de control del mundo actual. Devuelve si lo aplicó.
static func restore_checkpoint(world: Node) -> bool:
	CampaignState.set_data(RESPAWN_KEY, null)
	if world == null:
		return false
	var data: Dictionary = _as_dict(CampaignState.get_data(CHECKPOINT_KEY, {}))
	if data.is_empty():
		return false
	if str(data.get("scene", "")) != String(world.scene_file_path):
		return false
	_apply_data(world, data, true)
	var player: Node3D = _as_node3d(world.get("player"))
	if player != null and data.has("position"):
		player.global_position = _as_vector3(data.get("position", Vector3.ZERO))
	return true


## Fija el oficio elegido en el acto I.
static func set_oficio(oficio: StringName) -> void:
	if oficio == &"":
		return
	CampaignState.set_data(OFICIO_KEY, oficio)


## Oficio elegido, o cadena vacía si aún no se eligió.
static func get_oficio() -> StringName:
	return StringName(str(CampaignState.get_data(OFICIO_KEY, "")))


## Copia completa del estado del mundo.
static func snapshot(world: Node) -> Dictionary:
	var data: Dictionary = {}
	var character: CharacterState = _as_character(world.get("character"))
	if character != null:
		data["health"] = character.get_health()
		data["morale"] = character.get_morale()
		var skills: Dictionary = {}
		for skill: StringName in SKILLS:
			skills[skill] = character.get_skill_uses(skill)
		data["skills"] = skills
		var reputation: Dictionary = {}
		for group: StringName in GROUPS:
			reputation[group] = character.get_reputation(group)
		data["reputation"] = reputation
	var player: PlayerFPS = _as_player(world.get("player"))
	if player != null and player.stamina != null:
		data["stamina"] = player.stamina.get_current()
	var inventory: Inventory = _as_inventory(world.get("inventory"))
	if inventory != null:
		var items: Dictionary = {}
		for stack: Inventory.Stack in inventory.get_slots():
			if stack.item == null:
				continue
			items[stack.item.id] = _as_int(items.get(stack.item.id, 0)) + stack.amount
		data["inventory"] = items
	var journal: Journal = _as_journal(world.get("journal"))
	if journal != null:
		data["journal"] = _journal_to_data(journal)
	var oficio: StringName = get_oficio()
	if world is Llacta:
		var local_oficio: StringName = (world as Llacta).get_oficio()
		if local_oficio != &"":
			oficio = local_oficio
	data["oficio"] = oficio
	return data


static func _apply_data(world: Node, data: Dictionary, replace_inventory: bool) -> void:
	var character: CharacterState = _as_character(world.get("character"))
	if character != null:
		if data.has("health"):
			character.health = clampf(_as_float(data.get("health", 0.0)), 0.0, character.max_health)
			character.health_changed.emit(character.health, character.max_health)
		if data.has("morale"):
			character.morale = clampf(_as_float(data.get("morale", 0.0)), 0.0, character.max_morale)
			character.morale_changed.emit(character.morale, character.max_morale)
		var skills: Dictionary = _as_dict(data.get("skills", {}))
		for skill: StringName in skills.keys():
			character.set_skill_uses(skill, _as_int(skills[skill]))
		var reputation: Dictionary = _as_dict(data.get("reputation", {}))
		for group: StringName in reputation.keys():
			character.set_reputation(group, _as_int(reputation[group]))
	var player: PlayerFPS = _as_player(world.get("player"))
	if player != null and player.stamina != null and data.has("stamina"):
		_restore_stamina(player.stamina, _as_float(data.get("stamina", 0.0)))
	var inventory: Inventory = _as_inventory(world.get("inventory"))
	if inventory != null:
		if replace_inventory:
			inventory.clear()
		var items: Dictionary = _as_dict(data.get("inventory", {}))
		for item_id: StringName in items.keys():
			var definition: ItemDefinition = item_definition(item_id)
			if definition != null:
				inventory.add(definition, _as_int(items[item_id]))
	var journal: Journal = _as_journal(world.get("journal"))
	if journal != null:
		_apply_journal(journal, data.get("journal", []))
	var oficio: StringName = StringName(str(data.get("oficio", "")))
	if oficio != &"":
		set_oficio(oficio)
		if world is Llacta:
			(world as Llacta).set_oficio(oficio)


static func _restore_stamina(stamina: StaminaComponent, target: float) -> void:
	var current: float = stamina.get_current()
	if target > current:
		stamina.restore(target - current)
	elif target < current:
		stamina.consume(current - target)


static func _journal_to_data(journal: Journal) -> Array:
	var entries: Array = []
	for entry: JournalEntry in journal.get_entries():
		entries.append({
			"id": entry.id,
			"title": entry.title_key,
			"body": entry.body_key,
			"badge": entry.badge,
			"source": entry.source_key,
			"kind": int(entry.kind),
			"done": entry.done,
		})
	return entries


static func _apply_journal(journal: Journal, entries: Variant) -> void:
	var list: Array = _as_array(entries)
	for raw: Variant in list:
		if not raw is Dictionary:
			continue
		var entry: Dictionary = _as_dict(raw)
		var entry_id: StringName = StringName(str(entry.get("id", "")))
		if entry_id == &"" or journal.has(entry_id):
			continue
		var kind: int = _as_int(entry.get("kind", int(JournalEntry.Kind.QUEST)))
		if kind == int(JournalEntry.Kind.MEMORY):
			journal.add_memory(
				entry_id,
				StringName(str(entry.get("title", ""))),
				StringName(str(entry.get("body", ""))),
				StringName(str(entry.get("badge", ""))),
				StringName(str(entry.get("source", ""))))
		else:
			journal.add_quest(
				entry_id,
				StringName(str(entry.get("title", ""))),
				StringName(str(entry.get("body", ""))))
			if entry.get("done", false) == true:
				journal.complete_quest(entry_id)


## Definición de un objeto de la campaña por su identificador.
static func item_definition(item_id: StringName) -> ItemDefinition:
	var item: ItemDefinition = ItemDefinition.new()
	item.id = item_id
	match item_id:
		&"agua":
			item.name_key = &"PCH_ITEM_AGUA"
			item.category = ItemDefinition.Category.QUEST
			item.max_stack = 1
		&"maiz":
			item.name_key = &"PCH_ITEM_MAIZ"
			item.category = ItemDefinition.Category.QUEST
			item.max_stack = 1
		&"manta":
			item.name_key = &"PCH_ITEM_MANTA"
			item.category = ItemDefinition.Category.QUEST
			item.max_stack = 1
		&"cuerda":
			item.name_key = &"PCH_ITEM_CUERDA"
			item.category = ItemDefinition.Category.QUEST
			item.max_stack = 1
		&"coca":
			item.name_key = &"PCH_ITEM_COCA"
			item.description_key = &"PCH_ITEM_COCA_DESC"
			item.category = ItemDefinition.Category.CONSUMABLE
			item.max_stack = 5
			item.stamina_restore = 25.0
			item.morale_change = -5.0
		_:
			item.category = ItemDefinition.Category.QUEST
			item.max_stack = 1
	return item


# El almacén de CampaignState es Variant por diseño; estas funciones son el
# único punto de conversión de la campaña y concentran la supresión necesaria.
static func _as_dict(value: Variant) -> Dictionary:
	@warning_ignore("unsafe_cast")
	return value as Dictionary


static func _as_array(value: Variant) -> Array:
	@warning_ignore("unsafe_cast")
	return value as Array


static func _as_character(value: Variant) -> CharacterState:
	@warning_ignore("unsafe_cast")
	return value as CharacterState


static func _as_player(value: Variant) -> PlayerFPS:
	@warning_ignore("unsafe_cast")
	return value as PlayerFPS


static func _as_inventory(value: Variant) -> Inventory:
	@warning_ignore("unsafe_cast")
	return value as Inventory


static func _as_journal(value: Variant) -> Journal:
	@warning_ignore("unsafe_cast")
	return value as Journal


static func _as_node3d(value: Variant) -> Node3D:
	@warning_ignore("unsafe_cast")
	return value as Node3D


static func _as_vector3(value: Variant) -> Vector3:
	@warning_ignore("unsafe_cast")
	return value as Vector3


static func _as_int(value: Variant) -> int:
	@warning_ignore("unsafe_call_argument")
	return int(value)


static func _as_float(value: Variant) -> float:
	@warning_ignore("unsafe_call_argument")
	return float(value)
