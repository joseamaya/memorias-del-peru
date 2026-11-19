class_name SaveManagerService
extends Node
## Guardado en disco, versionado y por ranura.
##
## Es un sistema de Core: no conoce campañas. Cada archivo vive en
## `user://saves/<campaña>/<ranura>.json` y se escribe con un temporal para no
## dejar un JSON a medias si el proceso se interrumpe. El esquema lleva versión
## para poder migrar sin romper partidas.
##
## El guardado completo del jugador se compone fuera: este servicio serializa
## el mundo, el reloj y un diccionario de estado del jugador.

const SAVE_DIR: String = "user://saves"
const SCHEMA_VERSION: int = 1
const MAX_NAME_LENGTH: int = 32
const JSON_EXTENSION: String = ".json"


## Guarda [param payload] en la ranura indicada.
##
## El diccionario debe ser serializable a JSON (Strings, números, Arrays y
## Dictionaries). Se añaden `version`, `campaign`, `slot` y `saved_at`.
func save_slot(campaign: StringName, slot: StringName, payload: Dictionary) -> bool:
	var path: String = slot_path(campaign, slot)
	if path.is_empty():
		return false
	var directory: String = ProjectSettings.globalize_path(SAVE_DIR.path_join(String(campaign)))
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(directory)
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return false
	var data: Dictionary = payload.duplicate(true)
	data["version"] = SCHEMA_VERSION
	data["campaign"] = String(campaign)
	data["slot"] = String(slot)
	data["saved_at"] = Time.get_datetime_string_from_system(true)
	var temp_path: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temp_path))
		return false
	var final_absolute: String = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(final_absolute)
	var rename_error: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temp_path), final_absolute
	)
	if rename_error != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temp_path))
		return false
	return true


## Carga una ranura. Devuelve `{}` si no existe, no se puede leer o el esquema
## no es compatible.
func load_slot(campaign: StringName, slot: StringName) -> Dictionary:
	var path: String = slot_path(campaign, slot)
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return {}
	var data: Dictionary = _as_dict(parsed)
	var version: int = _to_int(data.get("version", 0))
	if version <= 0 or version > SCHEMA_VERSION:
		return {}
	if version < SCHEMA_VERSION:
		data = _migrate(data, version)
	return data


## Indica si la ranura existe.
func has_slot(campaign: StringName, slot: StringName) -> bool:
	var path: String = slot_path(campaign, slot)
	return not path.is_empty() and FileAccess.file_exists(path)


## Ranuras de una campaña, ordenadas alfabéticamente.
func list_slots(campaign: StringName) -> Array[String]:
	var result: Array[String] = []
	if not is_valid_name(campaign):
		return result
	var directory: String = ProjectSettings.globalize_path(SAVE_DIR.path_join(String(campaign)))
	if not DirAccess.dir_exists_absolute(directory):
		return result
	var files: PackedStringArray = DirAccess.get_files_at(directory)
	for file_name: String in files:
		if file_name.ends_with(JSON_EXTENSION):
			result.append(file_name.trim_suffix(JSON_EXTENSION))
	result.sort()
	return result


## Borra una ranura. Devuelve si se eliminó.
func delete_slot(campaign: StringName, slot: StringName) -> bool:
	var path: String = slot_path(campaign, slot)
	if path.is_empty() or not FileAccess.file_exists(path):
		return false
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK


## Ruta relativa de la ranura, o cadena vacía si el nombre no es válido.
func slot_path(campaign: StringName, slot: StringName) -> String:
	if not is_valid_name(campaign) or not is_valid_name(slot):
		return ""
	return SAVE_DIR.path_join(String(campaign)).path_join(String(slot) + JSON_EXTENSION)


## Guarda el estado del mundo, el reloj y el jugador.
func save_world(
	campaign: StringName,
	slot: StringName,
	world: WorldStateService,
	clock: WorldClockService,
	player_state: Dictionary = {}
) -> bool:
	if world == null or clock == null:
		return false
	var payload: Dictionary = {
		"world": world.to_dict(),
		"clock": clock.to_dict(),
		"player": player_state.duplicate(true),
	}
	return save_slot(campaign, slot, payload)


## Restaura mundo y reloj y devuelve el estado del jugador. Devuelve `{}` si
## la ranura no existe o el estado del mundo no es válido.
func load_world(
	campaign: StringName, slot: StringName, world: WorldStateService, clock: WorldClockService
) -> Dictionary:
	var result: Dictionary = {}
	if world != null and clock != null:
		var data: Dictionary = load_slot(campaign, slot)
		if not data.is_empty():
			var world_value: Variant = data.get("world", {})
			var clock_value: Variant = data.get("clock", {})
			if world_value is Dictionary and clock_value is Dictionary:
				if (
					world.from_dict(_as_dict(world_value))
					and clock.from_dict(_as_dict(clock_value))
				):
					var player_value: Variant = data.get("player", {})
					if player_value is Dictionary:
						result = _as_dict(player_value).duplicate(true)
	return result


## Nombre válido para campaña o ranura: letras, números, guion y guion bajo.
func is_valid_name(value: StringName) -> bool:
	var text: String = String(value)
	if text.is_empty() or text.length() > MAX_NAME_LENGTH:
		return false
	for index: int in text.length():
		var code: int = text.unicode_at(index)
		if code >= 48 and code <= 57:
			continue
		if code >= 65 and code <= 90:
			continue
		if code >= 97 and code <= 122:
			continue
		if code == 45 or code == 95:
			continue
		return false
	return true


func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	var result: Dictionary = data.duplicate(true)
	var version: int = from_version
	while version < SCHEMA_VERSION:
		version += 1
		result["version"] = version
	return result


func _to_int(value: Variant) -> int:
	var text: String = str(value)
	if text.is_valid_int():
		return int(text)
	if text.is_valid_float():
		return int(text.to_float())
	return 0


# El origen es JSON; la comprobación `is Dictionary` se hace antes de llamar.
# Se concentra aquí la única supresión necesaria.
static func _as_dict(value: Variant) -> Dictionary:
	@warning_ignore("unsafe_cast")
	return value as Dictionary
