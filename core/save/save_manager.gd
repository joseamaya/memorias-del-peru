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
const TEMP_SUFFIX: String = ".tmp"
const BACKUP_SUFFIX: String = ".bak"
## Ranura que la campaña usa para el guardado automático al descansar.
const AUTO_SLOT: StringName = &"auto"

## Las pruebas de integración pueden aislar sus guardados en otra raíz para no
## borrar la partida real del jugador. Vacío significa `user://saves`.
static var _root_override: String = ""

## Carga pedida por la pantalla de título y pendiente de aplicar en el mundo.
var _pending_load: Dictionary[StringName, StringName] = {}


## Devuelve el autoload, o `null` si no existe.
static func instance() -> SaveManagerService:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("SaveManager") as SaveManagerService


## Fija una raíz de guardado alternativa (pruebas). Cadena vacía restaura la
## raíz del juego.
static func set_save_root(path: String) -> void:
	_root_override = path


## Raíz de guardado activa, sin barra final.
static func save_root() -> String:
	return _root_override if not _root_override.is_empty() else SAVE_DIR


## Restaura la raíz de guardado del juego.
static func reset_save_root() -> void:
	_root_override = ""


## Pide que la próxima escena de campaña cargue la ranura indicada.
##
## Devuelve `false` si la ranura no existe o el nombre no es válido: la pantalla
## de título no debe ofrecer una carga que luego fallaría en silencio.
func request_load(campaign: StringName, slot: StringName) -> bool:
	if not has_slot(campaign, slot):
		return false
	_pending_load.clear()
	_pending_load[campaign] = slot
	return true


## Indica si hay una carga pendiente de aplicar.
func has_pending_load() -> bool:
	return not _pending_load.is_empty()


## Devuelve la carga pendiente y la borra. Vacío si no había ninguna.
func consume_pending_load() -> Dictionary[StringName, StringName]:
	var pending: Dictionary[StringName, StringName] = _pending_load
	_pending_load = {}
	return pending


## Descarta una carga pendiente; lo usa una partida nueva.
func cancel_pending_load() -> void:
	_pending_load.clear()


## Guarda [param payload] en la ranura indicada.
##
## El diccionario debe ser serializable a JSON (Strings, números, Arrays y
## Dictionaries). Se añaden `version`, `campaign`, `slot` y `saved_at`.
func save_slot(campaign: StringName, slot: StringName, payload: Dictionary) -> bool:
	var path: String = slot_path(campaign, slot)
	if path.is_empty():
		return false
	var directory: String = ProjectSettings.globalize_path(save_root().path_join(String(campaign)))
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(directory)
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return false
	var data: Dictionary = payload.duplicate(true)
	data["version"] = SCHEMA_VERSION
	data["campaign"] = String(campaign)
	data["slot"] = String(slot)
	data["saved_at"] = Time.get_datetime_string_from_system(true)
	var temp_path: String = path + TEMP_SUFFIX
	var backup_path: String = path + BACKUP_SUFFIX
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
	var temp_absolute: String = ProjectSettings.globalize_path(temp_path)
	var backup_absolute: String = ProjectSettings.globalize_path(backup_path)
	# No se borra la ranura anterior antes de renombrar el temporal: se aparta
	# como `.bak`. Si el proceso cae entre ambos pasos, `load_slot` puede
	# recuperar el respaldo.
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup_path):
			DirAccess.remove_absolute(backup_absolute)
		var backup_error: Error = DirAccess.rename_absolute(final_absolute, backup_absolute)
		if backup_error != OK:
			DirAccess.remove_absolute(temp_absolute)
			return false
	var rename_error: Error = DirAccess.rename_absolute(temp_absolute, final_absolute)
	if rename_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_absolute, final_absolute)
		DirAccess.remove_absolute(temp_absolute)
		return false
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_absolute)
	return true


## Carga una ranura. Devuelve `{}` si no existe, no se puede leer o el esquema
## no es compatible.
func load_slot(campaign: StringName, slot: StringName) -> Dictionary:
	var path: String = slot_path(campaign, slot)
	if path.is_empty():
		return {}
	# Un cierre en mitad del guardado deja la ranura anterior en `.bak`.
	if not FileAccess.file_exists(path):
		path = path + BACKUP_SUFFIX
		if not FileAccess.file_exists(path):
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
	if path.is_empty():
		return false
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + BACKUP_SUFFIX)


## Ranuras de una campaña, ordenadas alfabéticamente.
func list_slots(campaign: StringName) -> Array[String]:
	var result: Array[String] = []
	if not is_valid_name(campaign):
		return result
	var directory: String = ProjectSettings.globalize_path(save_root().path_join(String(campaign)))
	if not DirAccess.dir_exists_absolute(directory):
		return result
	var files: PackedStringArray = DirAccess.get_files_at(directory)
	for file_name: String in files:
		var slot_name: String = ""
		if file_name.ends_with(BACKUP_SUFFIX):
			var base_name: String = file_name.trim_suffix(BACKUP_SUFFIX)
			if base_name.ends_with(JSON_EXTENSION):
				slot_name = base_name.trim_suffix(JSON_EXTENSION)
		elif file_name.ends_with(JSON_EXTENSION):
			slot_name = file_name.trim_suffix(JSON_EXTENSION)
		if not slot_name.is_empty() and not result.has(slot_name):
			result.append(slot_name)
	result.sort()
	return result


## Borra una ranura. Devuelve si se eliminó.
func delete_slot(campaign: StringName, slot: StringName) -> bool:
	var path: String = slot_path(campaign, slot)
	if path.is_empty():
		return false
	var removed: bool = false
	for candidate: String in [path, path + BACKUP_SUFFIX, path + TEMP_SUFFIX]:
		if not FileAccess.file_exists(candidate):
			continue
		if DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate)) == OK:
			removed = true
	return removed


## Ruta relativa de la ranura, o cadena vacía si el nombre no es válido.
func slot_path(campaign: StringName, slot: StringName) -> String:
	if not is_valid_name(campaign) or not is_valid_name(slot):
		return ""
	return save_root().path_join(String(campaign)).path_join(String(slot) + JSON_EXTENSION)


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
